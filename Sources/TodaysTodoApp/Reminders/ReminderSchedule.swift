import Foundation

enum ReminderSchedule {
    static let validHours = 10...19

    static func isValidHour(_ hour: Int) -> Bool {
        validHours.contains(hour)
    }

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func nextReminder(after date: Date, sent: Set<Int> = [], calendar: Calendar = .current) -> Date? {
        var cursor = date
        for _ in 0..<370 {
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: cursor)
            let dayStart = calendar.startOfDay(for: cursor)
            let currentHour = components.hour ?? 0
            let candidateHours = validHours.filter { $0 > currentHour || ($0 == currentHour && date <= cursor) }
            for hour in candidateHours where !sent.contains(hour) {
                if let candidate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dayStart), candidate >= date {
                    return candidate
                }
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return nil }
            cursor = nextDay
        }
        return nil
    }
}
