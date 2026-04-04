import SwiftUI
import Photos

struct PhotoThumbnailView: View {
    let asset: PHAsset
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(minHeight: 160)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            if isSelected {
                SelectionOverlayView()
            }
        }
        .overlay(alignment: .bottomLeading) {
            // Video duration badge
            if asset.isVideo {
                Text(formatDuration(asset.duration))
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.6), in: Capsule())
                    .padding(6)
            }
        }
        .overlay(alignment: .topTrailing) {
            // Favorite badge
            if asset.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                    .padding(6)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onLongPress)
        .task(id: asset.localIdentifier) {
            thumbnail = await ThumbnailCache.shared.thumbnail(for: asset)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
