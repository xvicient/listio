import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ProductsViewModel: ItemsViewModel {
    private var list: ListModel
    let listName: String
    @Published var items: [any ItemModel] = []
    internal var options: (any ItemModel) -> [ItemOption] {
        { [weak self] item in
            guard let self = self else { return [] }
            return [ItemOption(type: item.done ? .undone : .done,
                               action: toggleProduct),
                    ItemOption(type: .delete,
                               action: deleteProduct)]
        }
    }
    @Published var isLoading = false
    @Published var productName: String = ""
    private let productsRepository: ProductsRepositoryApi
    private let listsRepository: ListsRepositoryApi
    
    init(list: ListModel,
         productsRepository: ProductsRepositoryApi = ProductsRepository(),
         listsRepository: ListsRepositoryApi = ListsRepository()) {
        self.list = list
        listName = list.name
        self.productsRepository = productsRepository
        self.listsRepository = listsRepository
    }
    
    func fetchProducts() {
        isLoading = true
        productsRepository.fetchProducts(listId: list.documentId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let products):
                self?.items = products.sorted {
                    $0.dateCreated < $1.dateCreated
                }
            case .failure:
                break
            }
        }
    }
    
    func addProduct() {
        guard !productName.isEmpty else { return }
        isLoading = true
        productsRepository.addProduct(with: productName,
                                      listId: list.documentId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.productName = ""
            case .failure:
                break
            }
        }
    }
    
    private var toggleProduct: (any ItemModel) -> Void {
        { [weak self] item in
            guard let self = self,
                  var product = item as? ProductModel else { return }
            product.done.toggle()
            productsRepository.toggleProduct(product,
                                             listId: list.documentId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    list.done = self.items.allSatisfy({ $0.done })
                    listsRepository.toggleList(list) { _ in }
                    break
                case .failure:
                    break
                }
            }
        }
    }
    
    private var deleteProduct: (any ItemModel) -> Void {
        { [weak self] item in
            guard let self = self else { return }
            productsRepository.deleteProduct(item.documentId,
                                             listId: list.documentId)
        }
    }
}

extension ProductModel: ItemModel {}
