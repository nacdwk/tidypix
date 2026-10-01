import Photos
import UIKit

nonisolated final class ImageLoader: Sendable {
    static let shared = ImageLoader()

    /// Fixed so preheated thumbnails hit PhotoKit's cache. Covers a ~220pt cell at 3x.
    static let thumbnailSize = CGSize(width: 640, height: 640)

    private let manager = PHCachingImageManager()

    private init() {}

    /// Yields a fast low-quality image first (when available), then the final one.
    func images(
        for asset: PHAsset,
        targetSize: CGSize = thumbnailSize,
        contentMode: PHImageContentMode = .aspectFill
    ) -> AsyncStream<UIImage> {
        AsyncStream { continuation in
            let requestID = manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: Self.options
            ) { image, info in
                if let image { continuation.yield(image) }
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded { continuation.finish() }
            }
            continuation.onTermination = { [manager] _ in
                manager.cancelImageRequest(requestID)
            }
        }
    }

    func preheat(_ assets: [PHAsset]) {
        manager.startCachingImages(
            for: assets,
            targetSize: Self.thumbnailSize,
            contentMode: .aspectFill,
            options: Self.options
        )
    }

    func stopPreheating() {
        manager.stopCachingImagesForAllAssets()
    }

    private static var options: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return options
    }
}
