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
}
