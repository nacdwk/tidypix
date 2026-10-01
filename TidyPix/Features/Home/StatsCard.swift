import SwiftUI

struct StatsCard: View {
    let stats: CleanupStats
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 2) {
                Text(stats.totalPhotosDeleted, format: .number)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.brand)
                    .contentTransition(.numericText(value: Double(stats.totalPhotosDeleted)))
                Text("photos cleaned up")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                StatTile(value: freedText, label: "Freed", systemImage: "internaldrive.fill")
                Divider().frame(height: 36)
                StatTile(value: stats.thisWeekCount.formatted(), label: "This week", systemImage: "calendar")
                Divider().frame(height: 36)
                StatTile(value: stats.lastSessionCount.formatted(), label: "Last session", systemImage: "sparkles")
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: .rect(cornerRadius: 32))
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(.white.opacity(colorScheme == .dark ? 0.12 : 0.4), lineWidth: 0.5)
        }
        .animation(.spring, value: stats)
    }

    private var freedText: String {
        stats.totalBytesFreed == 0 ? "0 MB" : stats.totalBytesFreed.formatted(.byteCount(style: .file))
    }
}

private struct StatTile: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(.tint)
                .frame(height: 18)
            Text(value)
                .font(.headline.monospacedDigit())
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatsCard(stats: CleanupStats(
        totalPhotosDeleted: 6576,
        totalBytesFreed: 17_000_000_000,
        lastSessionCount: 33
    ))
    .padding()
    .background { AppBackground() }
}
