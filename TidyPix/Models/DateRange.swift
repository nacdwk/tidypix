import Foundation

nonisolated enum DateRange: Hashable, Sendable {
    case day(Date)
    case today
    case lastSevenDays
    case lastThirtyDays

    var interval: DateInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start: Date
        let end: Date
        switch self {
        case .day(let date):
            start = calendar.startOfDay(for: date)
            end = calendar.date(byAdding: .day, value: 1, to: start)!
        case .today:
            start = today
            end = calendar.date(byAdding: .day, value: 1, to: today)!
        case .lastSevenDays:
            start = calendar.date(byAdding: .day, value: -6, to: today)!
            end = calendar.date(byAdding: .day, value: 1, to: today)!
        case .lastThirtyDays:
            start = calendar.date(byAdding: .day, value: -29, to: today)!
            end = calendar.date(byAdding: .day, value: 1, to: today)!
        }
        return DateInterval(start: start, end: end)
    }

    var title: String {
        switch self {
        case .day(let date): date.formatted(.dateTime.day().month(.abbreviated).year())
        case .today: "Today"
        case .lastSevenDays: "Last 7 Days"
        case .lastThirtyDays: "Last 30 Days"
        }
    }

    var isSingleDay: Bool {
        if case .day = self { true } else { false }
    }

    /// "6 years ago", "3 months ago", "Yesterday" — only meaningful for a single past day.
    var relativeAge: String? {
        guard case .day(let date) = self else { return nil }
        let calendar = Calendar.current
        let parts = calendar.dateComponents(
            [.year, .month, .day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: .now)
        )
        if let years = parts.year, years > 0 { return years == 1 ? "1 year ago" : "\(years) years ago" }
        if let months = parts.month, months > 0 { return months == 1 ? "1 month ago" : "\(months) months ago" }
        switch parts.day ?? 0 {
        case 0: return "Today"
        case 1: return "Yesterday"
        case let days: return "\(days) days ago"
        }
    }
}
