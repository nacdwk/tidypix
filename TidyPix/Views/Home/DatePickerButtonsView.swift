import SwiftUI

struct DatePickerButtonsView: View {
    let isPickingRandom: Bool
    let isIndexReady: Bool
    let onRandom: () -> Void
    let onSelect: (DateRange) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Pick a day and start sorting.")
                .font(.headline)
                .padding(.top, 8)

            // Random date button
            Button(action: onRandom) {
                HStack(spacing: 12) {
                    if isPickingRandom {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "dice.fill")
                            .font(.title3)
                    }
                    Text("Random day across all years")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.tidyAccent, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
            }
            .disabled(isPickingRandom || !isIndexReady)

            // Quick filter buttons
            HStack(spacing: 12) {
                FilterButton(
                    title: "Today",
                    icon: "calendar",
                    action: { onSelect(.today) }
                )

                FilterButton(
                    title: "Last 7 days",
                    icon: "clock",
                    action: { onSelect(.lastSevenDays) }
                )

                FilterButton(
                    title: "Last 30 days",
                    icon: "clock.arrow.circlepath",
                    action: { onSelect(.lastThirtyDays) }
                )
            }
        }
    }
}

private struct FilterButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .font(.caption2.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.tidyNavyCard)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
