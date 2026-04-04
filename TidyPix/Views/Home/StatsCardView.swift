import SwiftUI

struct StatsCardView: View {
    let stats: CleanupStats

    var body: some View {
        VStack(spacing: 12) {
            // Main stat
            Text(stats.totalPhotosFormatted)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text("photos cleaned up")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(stats.storageFreedFormatted + " freed")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Divider()
                .padding(.vertical, 4)

            // Weekly / session stats
            HStack {
                VStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.tidyAccent)
                    Text("\(stats.thisWeekCount)")
                        .font(.title2.bold())
                    Text("This week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 50)

                VStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("\(stats.lastSessionCount)")
                        .font(.title2.bold())
                    Text("Last session")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frostedCard()
    }
}
