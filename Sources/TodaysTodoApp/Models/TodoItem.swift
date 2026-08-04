import Foundation

struct TodoItem: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var isCarryOver: Bool
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, isCarryOver: Bool = false, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.isCarryOver = isCarryOver
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey { case id, title, isCompleted, isCarryOver, createdAt, updatedAt }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isCarryOver = try container.decodeIfPresent(Bool.self, forKey: .isCarryOver) ?? false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
