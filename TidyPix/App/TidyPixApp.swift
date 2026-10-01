import SwiftUI

@main
struct TidyPixApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var library = PhotoLibrary()
    @AppStorage("appTheme") private var theme = AppTheme.system
    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false
    @AppStorage("dailyReminderMinutes") private var reminderMinutes = 19 * 60

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(library)
                .environment(appDelegate.router)
                .preferredColorScheme(theme.colorScheme)
                .task {
                    // Reschedule so an existing reminder picks up the current wording.
                    if reminderEnabled {
                        _ = await DailyReminder.schedule(hour: reminderMinutes / 60, minute: reminderMinutes % 60)
                    }
                }
        }
    }
}
