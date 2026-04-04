import Foundation
import UserNotifications

struct DailyReminderService {
    static let shared = DailyReminderService()

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "daily-cleanup-reminder"

    enum ReminderResult {
        case enabled
        case disabled
        case permissionDenied
    }

    func setReminderEnabled(_ isEnabled: Bool) async -> ReminderResult {
        guard isEnabled else {
            removeReminder()
            return .disabled
        }

        let status = await authorizationStatus()
        switch status {
        case .authorized, .provisional, .ephemeral:
            await scheduleReminder()
            return .enabled
        case .notDetermined:
            let granted = await requestAuthorization()
            guard granted else { return .permissionDenied }
            await scheduleReminder()
            return .enabled
        case .denied:
            return .permissionDenied
        @unknown default:
            return .permissionDenied
        }
    }

    func refreshReminderIfNeeded(isEnabled: Bool) async {
        guard isEnabled else {
            removeReminder()
            return
        }

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional || status == .ephemeral else {
            return
        }

        await scheduleReminder()
    }

    private func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    private func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    private func scheduleReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Time for a quick cleanup"
        content.body = "Open TidyPix and review a few photos from today in years past."
        content.sound = .default

        var components = DateComponents()
        components.hour = 19
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        try? await center.add(request)
    }

    private func removeReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [reminderIdentifier])
    }
}
