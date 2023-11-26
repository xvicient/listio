struct CreateListBuilder {
    static func makeCreateList() -> CreateListView {
        CreateListView(
            viewModel: CreateListViewModel(
                listsRepository: ListsRepository()
            )
        )
    }
}
