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

        store.refreshForToday(date: yesterday)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testCarriesUnfinishedItemsAcrossDaysWithoutOpeningApp() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
        let lastOpenedDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2030, month: 8, day: 14, hour: 9)))
        let reopenedDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2030, month: 8, day: 17, hour: 9)))
        let lastOpenedKey = ReminderSchedule.dayKey(for: lastOpenedDate, calendar: calendar)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("carry-gap-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        let unfinished = TodoItem(title: "周末前未完成", createdAt: lastOpenedDate, updatedAt: lastOpenedDate)
        var completed = TodoItem(title: "周末前已完成", createdAt: lastOpenedDate, updatedAt: lastOpenedDate)
        completed.isCompleted = true
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode([
            lastOpenedKey: TodoDay(dateKey: lastOpenedKey, items: [unfinished, completed])
        ]).write(to: url)

        let store = TodoStore(storageURL: url, calendar: calendar)
        store.refreshForToday(date: reopenedDate)

        XCTAssertEqual(store.items.map(\.title), ["周末前未完成"])
        XCTAssertTrue(store.items[0].isCarryOver)

        store.refreshForToday(date: lastOpenedDate)
        XCTAssertTrue(store.items.isEmpty)
    }
}
