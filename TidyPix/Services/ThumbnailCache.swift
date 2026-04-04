import Photos
import UIKit

final class ThumbnailCache: Sendable {
    static let shared = ThumbnailCache()

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 300, height: 300)

    private init() {
        imageManager.allowsCachingHighQualityImages = true
    }

    private var thumbnailOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return options
    }

    private var fullSizeOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        return options
    }

    func thumbnail(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: thumbnailOptions
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                // Only resolve on the final (non-degraded) image, or if it's the only one
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func fullSizeImage(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: fullSizeOptions
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func startCaching(assets: [PHAsset]) {
        imageManager.startCachingImages(
            for: assets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: thumbnailOptions
        )
    }

    func stopCaching(assets: [PHAsset]) {
        imageManager.stopCachingImages(
            for: assets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: thumbnailOptions
        )
    }

    func stopAllCaching() {
        imageManager.stopCachingImagesForAllAssets()
    }
}
