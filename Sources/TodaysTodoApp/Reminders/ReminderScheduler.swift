import Foundation
import UserNotifications

@MainActor
final class ReminderScheduler: NSObject, UNUserNotificationCenterDelegate {
    private let center: UNUserNotificationCenter?
    private let calendar: Calendar
    private var timer: Timer?
    private var sentHours = Set<Int>()
    private(set) var isPaused = false

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        let notificationCenter = Self.isAppBundle(Bundle.main.bundleURL) ? UNUserNotificationCenter.current() : nil
        self.center = notificationCenter
        super.init()
        notificationCenter?.delegate = self
    }

    static func isAppBundle(_ url: URL) -> Bool {
        url.pathExtension.caseInsensitiveCompare("app") == .orderedSame
    }

    func start(remainingCount: @escaping () -> Int) {
        guard let center else { return }
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        scheduleNext(remainingCount: remainingCount)
    }

    func togglePaused(remainingCount: @escaping () -> Int) {
        isPaused.toggle()
        if isPaused { timer?.invalidate(); timer = nil }
        else { scheduleNext(remainingCount: remainingCount) }
    }

    func scheduleNext(remainingCount: @escaping () -> Int) {
        timer?.invalidate()
        guard !isPaused else { return }
        let now = Date()
        let todayKey = ReminderSchedule.dayKey(for: now, calendar: calendar)
        let hour = calendar.component(.hour, from: now)
        if hour < 10 || hour > 19 { sentHours = [] }
        if hour == 0 { sentHours = [] }
        guard let next = ReminderSchedule.nextReminder(after: now.addingTimeInterval(1), sent: sentHours, calendar: calendar) else { return }
        let interval = max(1, next.timeIntervalSinceNow)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let nextHour = self.calendar.component(.hour, from: next)
                self.sentHours.insert(nextHour)
                self.postNotification(dateKey: todayKey, remainingCount: remainingCount())
                self.scheduleNext(remainingCount: remainingCount)
            }
        }
    }

    private func postNotification(dateKey: String, remainingCount: Int) {
        guard let center else { return }
        let content = UNMutableNotificationContent()
        content.title = "看一下今日待办"
        content.body = remainingCount > 0 ? "还有 (remainingCount) 项未完成" : "今天的待办已完成"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "todays-todo-\(dateKey)-\(UUID().uuidString)", content: content, trigger: nil)
        center.add(request)
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
