import Foundation

struct Invitation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let ownerName: String
    let ownerEmail: String
    let listId: String
    let listName: String
    let invitedId: String
    let dateCreated: Int
}

extension InvitationDTO {
    var toDomain: Invitation {
        Invitation(documentId: id ?? "",
                        ownerName: ownerName,
                        ownerEmail: ownerEmail,
                        listId: listId,
                        listName: listName,
                        invitedId: invitedId,
                        dateCreated: dateCreated)
    }
}
