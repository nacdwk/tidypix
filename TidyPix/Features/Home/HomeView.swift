import SwiftUI

struct HomeView: View {
    @Environment(PhotoLibrary.self) private var library
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("cleanupStats") private var stats = CleanupStats()
    @State private var destination: DateRange?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if library.isDenied {
                    AccessDeniedView()
                } else {
                    content
                }
            }
            .background { AppBackground() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") { showSettings = true }
                }
            }
            .navigationDestination(item: $destination) { range in
                ReviewView(range: range, stats: $stats)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(stats: $stats)
            }
        }
        .task(id: scenePhase) {
            if scenePhase == .active { await library.refreshAccess() }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                StatsCard(stats: stats)
                actions
                if library.isLimited {
                    LimitedAccessNote()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("TidyPix")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .foregroundStyle(.brand)
            Text("Clean up your library, one day at a time.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var actions: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                Button(action: pickRandomDay) {
                    Label("Pick a random day", systemImage: "dice.fill")
                }
                .buttonStyle(.brand)
                .disabled(library.days.isEmpty)

                randomDayCaption
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    RangeButton(title: "Today", systemImage: "sun.max.fill") { destination = .today }
                    RangeButton(title: "Last 7 days", systemImage: "calendar") { destination = .lastSevenDays }
                    RangeButton(title: "Last 30 days", systemImage: "calendar.badge.clock") { destination = .lastThirtyDays }
                }
            }
        }
    }

    @ViewBuilder
    private var randomDayCaption: some View {
        if !library.hasIndexed && library.isAuthorized {
            HStack(spacing: 6) {
                ProgressView().controlSize(.mini)
                Text("Scanning your library…")
            }
        } else if library.hasIndexed && library.days.isEmpty {
            Text("Your library is empty.")
        } else if library.hasIndexed {
            Text("From \(library.days.count.formatted()) days of photos")
        } else {
            Text(" ")
        }
    }

    private func pickRandomDay() {
        guard let day = library.randomDay() else { return }
        destination = .day(day)
    }
}

private struct RangeButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(height: 26)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .contentShape(.rect(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
    }
}

private struct LimitedAccessNote: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.title3)
                .foregroundStyle(.orange)
            Text("TidyPix can only see the photos you've shared with it.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Button("Change") {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            .font(.footnote.weight(.semibold))
        }
        .padding(16)
        .background(.thinMaterial, in: .rect(cornerRadius: 20))
    }
}

private struct AccessDeniedView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ContentUnavailableView {
            Label("Photo Access Needed", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text("TidyPix needs access to your photo library to help you clean it up. Your photos never leave your device.")
        } actions: {
            Button("Open Settings") {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            .buttonStyle(.glassProminent)
        }
    }
}
