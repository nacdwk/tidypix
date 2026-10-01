import SwiftUI

struct SettingsView: View {
    @Binding var stats: CleanupStats

    @Environment(PhotoLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("appTheme") private var theme = AppTheme.system
    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false
    @AppStorage("dailyReminderMinutes") private var reminderMinutes = 19 * 60
    @State private var showResetConfirmation = false
    @State private var showNotificationsDenied = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        ForEach(AppTheme.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    Toggle("Daily reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("A daily nudge to tidy up one day of photos.")
                }

                Section("Library") {
                    LabeledContent("Photos & videos", value: library.totalCount.formatted())
                    LabeledContent("Days with photos", value: library.days.count.formatted())
                    if library.isLimited {
                        Button("Allow Access to All Photos", action: openAppSettings)
                    }
                }

                Section("About") {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Label("Privacy", systemImage: "hand.raised.fill")
                    }
                    LabeledContent("Version", value: Bundle.main.appVersion)
                }

                Section {
                    Button("Reset Statistics", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                }
            }
            .confirmationDialog("Reset all statistics?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { stats = CleanupStats() }
            } message: {
                Text("This clears your cleanup history. Your photos won't be affected.")
            }
            .alert("Notifications Are Off", isPresented: $showNotificationsDenied) {
                Button("Cancel", role: .cancel) {}
                Button("Open Settings", action: openAppSettings)
            } message: {
                Text("Allow notifications for TidyPix in the Settings app to get a daily reminder.")
            }
            .onChange(of: reminderEnabled) { updateReminder() }
            .onChange(of: reminderMinutes) { updateReminder() }
        }
    }

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderMinutes / 60,
                    minute: reminderMinutes % 60,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderMinutes = (parts.hour ?? 19) * 60 + (parts.minute ?? 0)
            }
        )
    }

    private func updateReminder() {
        guard reminderEnabled else {
            DailyReminder.cancel()
            return
        }
        Task {
            let scheduled = await DailyReminder.schedule(hour: reminderMinutes / 60, minute: reminderMinutes % 60)
            if !scheduled {
                reminderEnabled = false
                showNotificationsDenied = true
            }
        }
    }

    private func openAppSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString)!)
    }
}

private extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "–"
        return "\(version) (\(build))"
    }
}
