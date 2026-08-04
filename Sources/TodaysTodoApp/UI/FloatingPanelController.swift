import AppKit
import SwiftUI

@MainActor
final class FloatingPanelController {
    private let store: TodoStore
    private var panel: NSPanel?
    private var expandedFrame: NSRect?
    private var isCollapsed = false

    init(store: TodoStore) { self.store = store }

    func show() {
        if panel == nil { createPanel() }
        if isCollapsed { expand() }
        panel?.orderFrontRegardless()
    }

    func hide() { panel?.orderOut(nil) }
    func toggleVisibility() {
        guard let panel else { show(); return }
        panel.isVisible ? hide() : show()
    }

    func collapse() {
        guard let panel, !isCollapsed else { return }
        expandedFrame = panel.frame
        let frame = NSRect(x: panel.frame.minX, y: panel.frame.minY, width: 42, height: 42)
        isCollapsed = true
        panel.setFrame(frame, display: true, animate: true)
        panel.contentView = NSHostingView(rootView: CollapsedBubbleView { [weak self] in self?.expand() })
    }

    private func expand() {
        guard let panel else { return }
        let target = expandedFrame ?? defaultFrame()
        isCollapsed = false
        panel.contentView = NSHostingView(rootView: TodoPanelView(store: store) { [weak self] in self?.collapse() })
        panel.setFrame(target, display: true, animate: true)
        panel.orderFrontRegardless()
    }

    private func createPanel() {
        let panel = NSPanel(contentRect: defaultFrame(), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.contentView = NSHostingView(rootView: TodoPanelView(store: store) { [weak self] in self?.collapse() })
        self.panel = panel
    }

    private func defaultFrame() -> NSRect {
        let visible = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        return NSRect(x: visible.maxX - 320, y: visible.maxY - 390, width: 300, height: 360)
    }
}

private struct CollapsedBubbleView: View {
    let expand: () -> Void
    var body: some View {
        Button(action: expand) {
            Image(systemName: "checkmark")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Color.accentColor, in: Circle())
        }
        .buttonStyle(.plain)
        .shadow(radius: 8, y: 3)
    }
}
