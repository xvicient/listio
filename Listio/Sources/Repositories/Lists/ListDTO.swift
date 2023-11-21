import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListDTO: Identifiable, Decodable, Encodable, Hashable {
    @DocumentID var id: String?
    let listId: String
    let name: String
    var uuid: [String]
}
