import Foundation

nonisolated enum DateRange: Hashable, Sendable {
    case day(Date)
    case today
    case lastSevenDays
    case lastThirtyDays
    /// Today's month and day in past years — one start-of-day date per year that has photos.
    case onThisDay([Date])

    var intervals: [DateInterval] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        func interval(from start: Date, days: Int) -> DateInterval {
            DateInterval(start: start, end: calendar.date(byAdding: .day, value: days, to: start)!)
        }
        switch self {
        case .day(let date):
            return [interval(from: calendar.startOfDay(for: date), days: 1)]
        case .today:
            return [interval(from: today, days: 1)]
        case .lastSevenDays:
            return [interval(from: calendar.date(byAdding: .day, value: -6, to: today)!, days: 7)]
        case .lastThirtyDays:
            return [interval(from: calendar.date(byAdding: .day, value: -29, to: today)!, days: 30)]
        case .onThisDay(let days):
            return days.map { interval(from: calendar.startOfDay(for: $0), days: 1) }
        }
    }

    var title: String {
        switch self {
        case .day(let date): date.formatted(.dateTime.day().month(.abbreviated).year())
        case .today: "Today"
        case .lastSevenDays: "Last 7 Days"
        case .lastThirtyDays: "Last 30 Days"
        case .onThisDay: "On This Day"
        }
    }

    var isSingleDay: Bool {
        if case .day = self { true } else { false }
    }

    var groupsByYear: Bool {
        if case .onThisDay = self { true } else { false }
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
        if let years = parts.year, years > 0 { return Self.yearsAgo(years) }
        if let months = parts.month, months > 0 { return months == 1 ? "1 month ago" : "\(months) months ago" }
        switch parts.day ?? 0 {
        case 0: return "Today"
        case 1: return "Yesterday"
        case let days: return "\(days) days ago"
        }
    }

    static func yearsAgo(_ years: Int) -> String {
        years == 1 ? "1 year ago" : "\(years) years ago"
    }
}
