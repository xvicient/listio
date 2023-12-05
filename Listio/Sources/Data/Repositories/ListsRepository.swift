protocol ListsRepositoryApi {
    func fetchLists(
        completion: @escaping (Result<[ListModel], Error>) -> Void
    )
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteList(
        _ documentId: String?
    )    
    func toggleList(
        _ list: ListModel,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func importList(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ListsRepository: ListsRepositoryApi {
    let listsDataSource: ListsDataSourceApi
    let usersDataSource: UsersDataSourceApi
    let productsDataSource: ProductsDataSourceApi
    
    init(listsDataSource: ListsDataSourceApi = ListsDataSource(),
         usersDataSource: UsersDataSourceApi = UsersDataSource(),
         productsDataSource: ProductsDataSourceApi = ProductsDataSource()) {
        self.listsDataSource = listsDataSource
        self.usersDataSource = usersDataSource
        self.productsDataSource = productsDataSource
    }
    
    func fetchLists(completion: @escaping (Result<[ListModel], Error>) -> Void) {
        listsDataSource.fetchLists(
            uuid: usersDataSource.uuid) { result in
                switch result {
                case .success(let dto):
                    completion(.success(
                        dto.map {
                            $0.toDomain
                        }
                    ))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
    }
    
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void) {
            listsDataSource.addList(
                with: name,
                uuid: usersDataSource.uuid,
                completion: completion)
        }
    
    func deleteList(
        _ documentId: String?
    ) {
        listsDataSource.deleteList(documentId)
    }
    
    func toggleList(
        _ list: ListModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsDataSource.toggleList(list.toDTO, completion: completion)
    }
    
    func importList(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsDataSource.importList(id: id, uuid: usersDataSource.uuid, completion: completion)
    }
}
