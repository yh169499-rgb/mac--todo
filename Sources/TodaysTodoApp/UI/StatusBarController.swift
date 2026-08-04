import AppKit

@MainActor
final class StatusBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let panelController: FloatingPanelController
    private let scheduler: ReminderScheduler
    private let store: TodoStore

    init(panelController: FloatingPanelController, scheduler: ReminderScheduler, store: TodoStore) {
        self.panelController = panelController
        self.scheduler = scheduler
        self.store = store
        super.init()
        configure()
    }

    private func configure() {
        statusItem.button?.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "今日待办")
        let menu = NSMenu()
        menu.addItem(withTitle: "显示今日待办", action: #selector(showPanel), keyEquivalent: "")
        menu.addItem(withTitle: "添加待办", action: #selector(addTodo), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "暂停/恢复今日提醒", action: #selector(toggleReminders), keyEquivalent: "")
        menu.addItem(withTitle: "打开通知设置", action: #selector(openNotificationSettings), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "退出", action: #selector(terminate), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    @objc private func showPanel() { panelController.show() }
    @objc private func addTodo() { panelController.show() }
    @objc private func toggleReminders() { scheduler.togglePaused { [weak store] in store?.remainingCount ?? 0 } }
    @objc private func openNotificationSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings")!)
    }
    @objc private func terminate() { NSApplication.shared.terminate(nil) }
}
