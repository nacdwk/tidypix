import AVKit
import Photos
import SwiftUI

struct PhotoViewer: View {
    let assets: [PHAsset]
    @Binding var currentID: String?
    @Binding var selection: Set<String>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $currentID) {
            ForEach(assets, id: \.localIdentifier) { asset in
                AssetPage(asset: asset, isCurrent: asset.localIdentifier == currentID)
                    .tag(Optional(asset.localIdentifier))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(.black)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) { topBar }
        .safeAreaInset(edge: .bottom) { selectButton }
        .environment(\.colorScheme, .dark)
        .statusBarHidden()
        .sensoryFeedback(.selection, trigger: selection)
    }

    private var currentAsset: PHAsset? {
        assets.first { $0.localIdentifier == currentID }
    }

    private var isCurrentSelected: Bool {
        currentID.map(selection.contains) ?? false
    }

    private var topBar: some View {
        HStack {
            Button("Close", systemImage: "xmark") { dismiss() }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)

            Spacer()

            if let currentAsset, let index = assets.firstIndex(of: currentAsset) {
                VStack(spacing: 0) {
                    Text("\(index + 1) of \(assets.count)")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                    if let created = currentAsset.creationDate {
                        Text(created.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
            }

            Spacer()

            // Balances the close button so the title stays centred.
            Color.clear.frame(width: 48, height: 48)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var selectButton: some View {
        Group {
            if isCurrentSelected {
                Button("Selected", systemImage: "checkmark.circle.fill", action: toggleCurrent)
                    .buttonStyle(.glassProminent)
                    .tint(.brandMagenta)
            } else {
                Button("Select", systemImage: "circle", action: toggleCurrent)
                    .buttonStyle(.glass)
            }
        }
        .font(.headline)
        .controlSize(.extraLarge)
        .padding(.bottom, 8)
    }

    private func toggleCurrent() {
        guard let currentID else { return }
        if selection.remove(currentID) == nil { selection.insert(currentID) }
    }
}

private struct AssetPage: View {
    let asset: PHAsset
    let isCurrent: Bool

    var body: some View {
        if asset.mediaType == .video {
            AssetVideoPlayer(asset: asset, isCurrent: isCurrent)
                .padding(.vertical, 80)
        } else {
            AssetImage(asset: asset)
        }
    }
}

private struct AssetImage: View {
    let asset: PHAsset
    @Environment(\.displayScale) private var displayScale
    @State private var image: UIImage?

    var body: some View {
        GeometryReader { proxy in
            ZoomableImageView(image: image)
                .overlay {
                    if image == nil { ProgressView() }
                }
                .task(id: asset.localIdentifier) {
                    // Twice the screen resolution so zooming in stays sharp.
                    let side = max(proxy.size.width, proxy.size.height) * displayScale * 2
                    let target = CGSize(width: side, height: side)
                    for await next in ImageLoader.shared.images(for: asset, targetSize: target, contentMode: .aspectFit) {
                        image = next
                    }
                }
        }
        .ignoresSafeArea()
    }
}

private struct AssetVideoPlayer: View {
    let asset: PHAsset
    let isCurrent: Bool
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
            } else {
                ProgressView()
            }
        }
        .task(id: asset.localIdentifier) {
            guard let video = await Self.loadVideo(asset) else { return }
            player = AVPlayer(playerItem: AVPlayerItem(asset: video))
        }
        .onChange(of: isCurrent) { _, isCurrent in
            if !isCurrent { player?.pause() }
        }
        .onDisappear { player?.pause() }
    }

    /// Nonisolated because PhotoKit calls the result handler on a background queue.
    private nonisolated static func loadVideo(_ asset: PHAsset) async -> AVAsset? {
        let box = await withCheckedContinuation { (continuation: CheckedContinuation<AVAssetBox, Never>) in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { video, _, _ in
                continuation.resume(returning: AVAssetBox(asset: video))
            }
        }
        return box.asset
    }
}

/// AVAsset is immutable and documented as thread-safe, but isn't annotated Sendable.
private nonisolated struct AVAssetBox: @unchecked Sendable {
    let asset: AVAsset?
}
