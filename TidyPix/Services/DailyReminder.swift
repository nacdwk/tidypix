import UserNotifications

enum DailyReminder {
    nonisolated static let identifier = "daily-cleanup-reminder"
    private static var center: UNUserNotificationCenter { .current() }

    /// Returns false if notifications are not allowed for the app.
    static func schedule(hour: Int, minute: Int) async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        let allowed = switch status {
        case .authorized, .provisional, .ephemeral: true
        case .notDetermined: (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        default: false
        }
        guard allowed else { return false }

        let content = UNMutableNotificationContent()
        content.title = "Time for a quick tidy"
        content.body = "See what you shot on this day in past years and clear out what you don't need."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute),
            repeats: true
        )
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
        return true
    }

    static func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
