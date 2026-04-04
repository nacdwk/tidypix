import Photos
import UIKit

@Observable
final class PhotoLibraryService {
    private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    private(set) var totalPhotoCount: Int = 0

    let indexer = PhotoDateIndexer()
    let thumbnailCache = ThumbnailCache.shared

    func requestAuthorization() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }

        if status == .authorized || status == .limited {
            await refreshCounts()
            await indexer.buildIndex()
        }
    }

    func refreshCounts() async {
        let count = PHAsset.fetchAssets(with: .image, options: nil).count
            + PHAsset.fetchAssets(with: .video, options: nil).count
        await MainActor.run {
            self.totalPhotoCount = count
        }
    }

    func fetchPhotos(for dateRange: DateRange) -> [PHAsset] {
        let interval = dateRange.dateInterval
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate < %@",
            interval.start as NSDate,
            interval.end as NSDate
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: options).allAssets
    }

    func deleteAssets(_ assets: [PHAsset]) async throws -> (count: Int, bytesFreed: Int64) {
        let totalBytes = await StorageCalculator.totalSize(of: assets)
        let count = assets.count

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }

        // Refresh counts and rebuild the date index so random picks stay accurate.
        await refreshCounts()
        await indexer.buildIndex()

        return (count, totalBytes)
    }
}
