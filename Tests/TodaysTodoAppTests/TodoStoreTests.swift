import XCTest
@testable import TodaysTodoApp

@MainActor
final class TodoStoreTests: XCTestCase {
    func testCRUDPersistsAcrossStoreInstances() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("todos-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        let first = TodoStore(storageURL: url)
        let item = try XCTUnwrap(first.add(title: "整理项目提醒"))
        first.update(item, title: "整理项目提醒（已更新）")
        first.toggle(item)

        let second = TodoStore(storageURL: url)
        XCTAssertEqual(second.items.count, 1)
        XCTAssertEqual(second.items[0].title, "整理项目提醒（已更新）")
        XCTAssertTrue(second.items[0].isCompleted)

        second.delete(second.items[0])
        XCTAssertTrue(second.items.isEmpty)
    }

    func testCarriesUnfinishedItemsFromYesterday() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
        let yesterday = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 3, hour: 9)))
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 9)))
        let yesterdayKey = ReminderSchedule.dayKey(for: yesterday, calendar: calendar)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("carry-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        let item = TodoItem(title: "跟进昨天未完成事项", createdAt: yesterday, updatedAt: yesterday)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode([yesterdayKey: TodoDay(dateKey: yesterdayKey, items: [item])]).write(to: url)

        let store = TodoStore(storageURL: url, calendar: calendar)
        store.refreshForToday(date: today)
        XCTAssertEqual(store.items.count, 1)
        XCTAssertTrue(store.items[0].isCarryOver)
        XCTAssertFalse(store.items[0].isCompleted)
    }
}
