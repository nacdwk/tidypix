import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Binding var stats: CleanupStats
    @AppStorage("prefersDarkMode") private var prefersDarkMode: Bool?
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @Environment(\.dismiss) private var dismiss

    init(totalLibraryCount: Int, stats: Binding<CleanupStats>) {
        _viewModel = State(initialValue: SettingsViewModel(totalLibraryCount: totalLibraryCount))
        _stats = stats
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: themeBinding) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                }

                Section("Library") {
                    HStack {
                        Text("Total photos")
                        Spacer()
                        Text("\(viewModel.totalLibraryCount)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notifications") {
                    Toggle("Daily reminder", isOn: dailyReminderBinding)
                        .disabled(viewModel.isUpdatingReminder)

                    Text("Sends a reminder every day at 7:00 PM to review a few photos.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    NavigationLink {
                        PrivacyInfoView()
                    } label: {
                        Label("Privacy", systemImage: "lock.shield")
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Reset Statistics", role: .destructive) {
                        viewModel.showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Reset all statistics?",
                isPresented: $viewModel.showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    viewModel.resetStats(stats: $stats)
                }
            } message: {
                Text("This will clear your cleanup history. Your photos won't be affected.")
            }
            .alert("Notifications are turned off", isPresented: $viewModel.showNotificationPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Open Settings") {
                    openAppSettings()
                }
            } message: {
                Text("Allow notifications in the system Settings app to enable daily reminders.")
            }
        }
    }

    private var themeBinding: Binding<Int> {
        Binding<Int>(
            get: {
                guard let dark = prefersDarkMode else { return 0 }
                return dark ? 2 : 1
            },
            set: { newValue in
                switch newValue {
                case 1: prefersDarkMode = false
                case 2: prefersDarkMode = true
                default: prefersDarkMode = nil
                }
            }
        )
    }

    private var dailyReminderBinding: Binding<Bool> {
        Binding(
            get: { dailyReminderEnabled },
            set: { newValue in
                let previousValue = dailyReminderEnabled
                dailyReminderEnabled = newValue

                Task {
                    let didSucceed = await viewModel.updateDailyReminder(isEnabled: newValue)
                    if !didSucceed {
                        await MainActor.run {
                            dailyReminderEnabled = previousValue
                        }
                    }
                }
            }
        )
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
