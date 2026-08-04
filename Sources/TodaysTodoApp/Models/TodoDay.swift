import Foundation

struct TodoDay: Codable, Equatable {
    let dateKey: String
    var items: [TodoItem]
}
