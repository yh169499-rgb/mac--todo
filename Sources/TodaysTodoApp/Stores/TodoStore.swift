import Foundation
import Combine

@MainActor
final class TodoStore: ObservableObject {
    @Published private(set) var items: [TodoItem] = []
    @Published var lastError: String?

    private var days: [String: TodoDay] = [:]
    private let storageURL: URL
    private let calendar: Calendar
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var currentDate = Date()

    init(storageURL: URL? = nil, calendar: Calendar = .current) {
        self.calendar = calendar
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        load()
        refreshForToday()
    }

    var todayKey: String { ReminderSchedule.dayKey(for: currentDate, calendar: calendar) }

    var remainingCount: Int { items.filter { !$0.isCompleted }.count }

    func refreshForToday(date: Date = .now) {
        currentDate = date
        let key = ReminderSchedule.dayKey(for: date, calendar: calendar)
        var todayItems = days[key]?.items ?? []
        if let previousDate = calendar.date(byAdding: .day, value: -1, to: date) {
            let previousKey = ReminderSchedule.dayKey(for: previousDate, calendar: calendar)
            if let previousDay = days[previousKey] {
                let carryOver = previousDay.items.filter { !$0.isCompleted }.map { item in
                    var carried = item
                    carried.isCarryOver = true
                    return carried
                }
                let existingIDs = Set(todayItems.map(\.id))
                let newCarryOver = carryOver.filter { !existingIDs.contains($0.id) }
                if !newCarryOver.isEmpty {
                    todayItems = newCarryOver + todayItems
                    days[previousKey] = TodoDay(dateKey: previousKey, items: previousDay.items.filter(\.isCompleted))
                    days[key] = TodoDay(dateKey: key, items: todayItems)
                    save()
                }
            }
        }
        items = todayItems
    }

    @discardableResult
    func add(title: String) -> TodoItem? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var day = days[todayKey] ?? TodoDay(dateKey: todayKey, items: [])
        let item = TodoItem(title: trimmed)
        day.items.append(item)
        days[todayKey] = day
        items = day.items
        save()
        return item
    }

    func update(_ item: TodoItem, title: String) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = items[index]
        updated.title = trimmed
        updated.updatedAt = .now
        items[index] = updated
        days[todayKey] = TodoDay(dateKey: todayKey, items: items)
        save()
    }

    func toggle(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
        items[index].updatedAt = .now
        days[todayKey] = TodoDay(dateKey: todayKey, items: items)
        save()
    }

    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        days[todayKey] = TodoDay(dateKey: todayKey, items: items)
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            days = try decoder.decode([String: TodoDay].self, from: Data(contentsOf: storageURL))
        } catch {
            lastError = "无法读取本地待办数据"
        }
    }

    private func save() {
        do {
            let data = try encoder.encode(days)
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: storageURL, options: .atomic)
            lastError = nil
        } catch {
            lastError = "无法保存待办数据"
        }
    }

    private static func defaultStorageURL() -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return support.appendingPathComponent("TodaysTodoApp/todos.json")
    }
}
