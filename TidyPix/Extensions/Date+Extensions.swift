import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isoWeekString: String {
        let calendar = Calendar(identifier: .iso8601)
        let year = calendar.component(.yearForWeekOfYear, from: self)
        let week = calendar.component(.weekOfYear, from: self)
        return String(format: "%04d-W%02d", year, week)
    }

    var dayAndMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM"
        return formatter.string(from: self)
    }

    var dayMonthAndYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMMM yyyy"
        return formatter.string(from: self)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
