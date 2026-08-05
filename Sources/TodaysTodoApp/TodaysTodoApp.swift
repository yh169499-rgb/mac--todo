import SwiftUI
import AppKit
import ServiceManagement

@main
struct TodaysTodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: TodoStore!
    private var notes: NotesStore!
    private var documentStore: TodoDocumentStore!
    private var scheduler: ReminderScheduler!
    private var panelController: FloatingPanelController!
    private var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        documentStore = TodoDocumentStore()
        store = TodoStore(documentStore: documentStore)
        notes = NotesStore(documentStore: documentStore)
        scheduler = ReminderScheduler()
        panelController = FloatingPanelController(store: store, notes: notes)
        statusBarController = StatusBarController(panelController: panelController, scheduler: scheduler, store: store)
        scheduler.start { [weak self] in self?.store.remainingCount ?? 0 }
        try? SMAppService.mainApp.register()
        panelController.show()
    }
}
