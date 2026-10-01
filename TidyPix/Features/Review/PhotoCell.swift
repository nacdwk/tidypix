import Photos
import SwiftUI

struct PhotoCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let isSelecting: Bool

    @State private var image: UIImage?

    var body: some View {
        // The placeholder defines a square that layout can trust. The photo is an overlay,
        // so a landscape or panorama image can never widen the cell or spill into its neighbours.
        Rectangle()
            .fill(.quaternary)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                }
            }
            .overlay {
                if isSelected {
                    Color.black.opacity(0.18)
                }
            }
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.brand, lineWidth: 3)
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelecting || isSelected {
                    SelectionBadge(isSelected: isSelected)
                        .padding(8)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay(alignment: .bottom) { badges }
            .scaleEffect(isSelected ? 0.94 : 1)
            .animation(.spring(duration: 0.25), value: isSelected)
            .contentShape(.rect)
            .task(id: asset.localIdentifier) {
                for await next in ImageLoader.shared.images(for: asset) {
                    withAnimation(image == nil ? .easeOut(duration: 0.15) : nil) { image = next }
                }
            }
    }

    private var badges: some View {
        HStack(spacing: 4) {
            if asset.mediaType == .video {
                Label(
                    Duration.seconds(asset.duration).formatted(.time(pattern: .minuteSecond)),
                    systemImage: "play.fill"
                )
                .labelStyle(.titleAndIcon)
            }
            Spacer(minLength: 0)
            if asset.isFavorite {
                Image(systemName: "heart.fill")
            }
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.5), radius: 3)
        .padding(8)
    }
}

private struct SelectionBadge: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? AnyShapeStyle(.brand) : AnyShapeStyle(.black.opacity(0.2)))
            Circle()
                .strokeBorder(.white, lineWidth: 1.5)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 24, height: 24)
        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
    }
}
