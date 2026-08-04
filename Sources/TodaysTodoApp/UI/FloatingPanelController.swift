import AppKit
import SwiftUI

@MainActor
final class FloatingPanelController {
    private let store: TodoStore
    private let notes: NotesStore
    private var panel: FloatingPanel?
    private var expandedFrame: NSRect?
    private var isCollapsed = false

    init(store: TodoStore, notes: NotesStore) {
        self.store = store
        self.notes = notes
    }

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
        panel.contentView = NSHostingView(rootView: CollapsedBubbleView(
            expand: { [weak self] in self?.expand() },
            move: { [weak self] delta in self?.moveBubble(by: delta) }
        ))
    }

    private func expand() {
        guard let panel else { return }
        let target = expandedFrame ?? defaultFrame()
        isCollapsed = false
        panel.contentView = NSHostingView(rootView: TodoPanelView(store: store, notes: notes) { [weak self] in self?.collapse() })
        panel.setFrame(target, display: true, animate: true)
        panel.orderFrontRegardless()
    }

    private func createPanel() {
        let panel = FloatingPanel(contentRect: defaultFrame(), styleMask: FloatingPanel.defaultStyleMask, backing: .buffered, defer: false)
        panel.level = .floating
        panel.minSize = NSSize(width: 280, height: 420)
        panel.maxSize = NSSize(width: 560, height: 760)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.contentView = NSHostingView(rootView: TodoPanelView(store: store, notes: notes) { [weak self] in self?.collapse() })
        self.panel = panel
    }

    private func moveBubble(by delta: CGSize) {
        guard let panel, isCollapsed else { return }
        var origin = panel.frame.origin
        origin.x += delta.width
        origin.y -= delta.height
        panel.setFrameOrigin(origin)
        UserDefaults.standard.set(NSStringFromPoint(origin), forKey: "TodaysTodoApp.bubbleOrigin")
    }

    private func defaultFrame() -> NSRect {
        let visible = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        if let saved = UserDefaults.standard.string(forKey: "TodaysTodoApp.bubbleOrigin") {
            let origin = NSPointFromString(saved)
            return NSRect(x: origin.x, y: origin.y, width: 300, height: 480)
        }
        return NSRect(x: visible.maxX - 320, y: visible.maxY - 510, width: 300, height: 480)
    }
}

final class FloatingPanel: NSPanel {
    static let defaultStyleMask: NSWindow.StyleMask = [.borderless, .nonactivatingPanel, .resizable]

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

private struct CollapsedBubbleView: View {
    let expand: () -> Void
    let move: (CGSize) -> Void
    @State private var lastTranslation = CGSize.zero

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
        .highPriorityGesture(
            DragGesture()
                .onChanged { value in
                    let delta = CGSize(
                        width: value.translation.width - lastTranslation.width,
                        height: value.translation.height - lastTranslation.height
                    )
                    move(delta)
                    lastTranslation = value.translation
                }
                .onEnded { _ in lastTranslation = .zero }
        )
    }
}
