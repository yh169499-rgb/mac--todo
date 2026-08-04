import Foundation

struct TodoItem: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
