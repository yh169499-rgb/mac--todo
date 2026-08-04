import XCTest
@testable import TodaysTodoApp

@MainActor
final class NotesStoreTests: XCTestCase {
    func testNotesPersistWithoutDateRotation() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("notes-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }

        let first = NotesStore(storageURL: url)
        first.text = "发布前检查通知权限\n确认项目提醒"

        let second = NotesStore(storageURL: url)
        XCTAssertEqual(second.text, "发布前检查通知权限\n确认项目提醒")
    }
}
