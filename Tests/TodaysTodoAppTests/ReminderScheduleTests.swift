import XCTest
@testable import TodaysTodoApp

final class ReminderScheduleTests: XCTestCase {
    func testNotificationRuntimeRequiresAppBundle() {
        XCTAssertFalse(ReminderScheduler.isAppBundle(URL(fileURLWithPath: "/tmp/.build/debug/TodaysTodoApp")))
        XCTAssertTrue(ReminderScheduler.isAppBundle(URL(fileURLWithPath: "/tmp/TodaysTodoApp.app")))
    }

    func testValidHours() {
        XCTAssertTrue(ReminderSchedule.isValidHour(10))
        XCTAssertTrue(ReminderSchedule.isValidHour(19))
        XCTAssertFalse(ReminderSchedule.isValidHour(9))
        XCTAssertFalse(ReminderSchedule.isValidHour(20))
    }

    func testNextReminderMovesToNextAvailableHour() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 10, minute: 1)))
        let next = try XCTUnwrap(ReminderSchedule.nextReminder(after: date, calendar: calendar))
        XCTAssertEqual(calendar.component(.hour, from: next), 11)
    }

    func testAfterLastHourMovesToNextDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 19, minute: 1)))
        let next = try XCTUnwrap(ReminderSchedule.nextReminder(after: date, calendar: calendar))
        XCTAssertEqual(ReminderSchedule.dayKey(for: next, calendar: calendar), "2026-08-05")
        XCTAssertEqual(calendar.component(.hour, from: next), 10)
    }
}
