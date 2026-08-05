import XCTest
@testable import TodaysTodoApp

@MainActor
final class TodoDocumentStoreTests: XCTestCase {
    func testDocumentPersistsTodoAndNotes() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("record-\(UUID().uuidString).md")
        defer { try? FileManager.default.removeItem(at: url) }

        let document = TodoDocumentStore(storageURL: url)
        document.update(date: "2026-08-05", notes: "注意发布窗口", items: [
            TodoItem(title: "跟进接口", isCarryOver: true)
        ])

        let saved = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(saved.contains("注意发布窗口"))
        XCTAssertTrue(saved.contains("跟进接口"))
        XCTAssertTrue(saved.contains("延续"))
    }
}
