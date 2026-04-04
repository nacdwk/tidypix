import Foundation

enum DateRange: Hashable, Identifiable {
    case specificDate(Date)
    case today
    case lastSevenDays
    case lastThirtyDays

    var id: String {
        switch self {
        case .specificDate(let date): return "date-\(date.timeIntervalSince1970)"
        case .today: return "today"
        case .lastSevenDays: return "last7"
        case .lastThirtyDays: return "last30"
        }
    }

    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        switch self {
        case .specificDate(let date):
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .today:
            let start = startOfToday
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .lastSevenDays:
            let start = calendar.date(byAdding: .day, value: -6, to: startOfToday)!
            let end = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            return DateInterval(start: start, end: end)
        case .lastThirtyDays:
            let start = calendar.date(byAdding: .day, value: -29, to: startOfToday)!
            let end = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            return DateInterval(start: start, end: end)
        }
    }

    var displayTitle: String {
        switch self {
        case .specificDate(let date): return date.dayMonthAndYear
        case .today: return "Today"
        case .lastSevenDays: return "Last 7 Days"
        case .lastThirtyDays: return "Last 30 Days"
        }
    }
}
