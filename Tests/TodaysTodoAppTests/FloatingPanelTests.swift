import XCTest
import AppKit
@testable import TodaysTodoApp

@MainActor
final class FloatingPanelTests: XCTestCase {
    func testFloatingPanelAcceptsKeyboardFocus() {
        let panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 100, height: 100), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        XCTAssertTrue(panel.canBecomeKey)
    }
}
