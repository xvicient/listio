import Foundation

struct List: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let name: String
    var done: Bool
    var uuid: [String]
    let dateCreated: Int
}

extension ListDTO {
    var toDomain: List {
        List(documentId: id ?? "",
             name: name,
             done: done,
             uuid: uuid,
             dateCreated: dateCreated)
    }
}
