import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    var showResetConfirmation = false
    var showNotificationPermissionAlert = false
    var isUpdatingReminder = false

    let totalLibraryCount: Int

    init(totalLibraryCount: Int) {
        self.totalLibraryCount = totalLibraryCount
    }

    func resetStats(stats: Binding<CleanupStats>) {
        stats.wrappedValue = CleanupStats()
    }

    func updateDailyReminder(isEnabled: Bool) async -> Bool {
        isUpdatingReminder = true
        defer { isUpdatingReminder = false }

        let result = await DailyReminderService.shared.setReminderEnabled(isEnabled)
        showNotificationPermissionAlert = result == .permissionDenied
        return result == .enabled || result == .disabled
    }
}
