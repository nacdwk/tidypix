import SwiftUI

@main
struct TidyPixApp: App {
    @State private var photoService = PhotoLibraryService()
    @AppStorage("prefersDarkMode") private var prefersDarkMode: Bool?
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false

    var body: some Scene {
        WindowGroup {
            HomeView(service: photoService)
                .preferredColorScheme(colorScheme)
                .task {
                    await DailyReminderService.shared.refreshReminderIfNeeded(isEnabled: dailyReminderEnabled)
                }
        }
    }

    private var colorScheme: ColorScheme? {
        guard let prefersDarkMode else { return nil }
        return prefersDarkMode ? .dark : .light
    }
}
