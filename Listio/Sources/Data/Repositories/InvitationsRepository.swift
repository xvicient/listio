protocol InvitationsRepositoryApi {
    func fetchInvitations(
        completion: @escaping (Result<[InvitationModel], Error>) -> Void
    )
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteInvitation(
        _ documentId: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class InvitationsRepository: InvitationsRepositoryApi {
    let invitationsDataSource: InvitationsDataSourceApi
    let usersDataSource: UsersDataSourceApi
    
    init(invitationsDataSource: InvitationsDataSourceApi = InvitationsDataSource(),
         usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.invitationsDataSource = invitationsDataSource
        self.usersDataSource = usersDataSource
    }
    
    func fetchInvitations(
        completion: @escaping (Result<[InvitationModel], Error>) -> Void
    ) {
        invitationsDataSource.fetchInvitations(uuid: usersDataSource.uuid) { result in
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
    
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        invitationsDataSource.sendInvitation(ownerName: ownerName,
                                             ownerEmail: ownerEmail, 
                                             listId: listId,
                                             listName: listName,
                                             invitedId: invitedId,
                                             completion: completion)
    }
    
    func deleteInvitation(
        _ documentId: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        invitationsDataSource.deleteInvitation(documentId, completion: completion)
    }
}
