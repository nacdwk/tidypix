import SwiftUI
import Photos

@Observable
final class PhotoGridViewModel {
    var assets: [PHAsset] = []
    var selectedAssetIDs: Set<String> = []
    var isLoading = false
    var isDeleting = false
    var showDeleteConfirmation = false
    var zoomedAsset: PHAsset?
    var deletionError: String?

    let dateRange: DateRange
    private let service: PhotoLibraryService

    var selectedCount: Int { selectedAssetIDs.count }
    var hasSelection: Bool { !selectedAssetIDs.isEmpty }
    var photoCount: Int { assets.count }
    var dateTitle: String { dateRange.displayTitle }

    init(dateRange: DateRange, service: PhotoLibraryService) {
        self.dateRange = dateRange
        self.service = service
    }

    func loadPhotos() async {
        isLoading = true
        let fetched = await Task.detached(priority: .userInitiated) { [service, dateRange] in
            service.fetchPhotos(for: dateRange)
        }.value

        await MainActor.run {
            self.assets = fetched
            self.isLoading = false
        }

        // Start caching thumbnails for visible area
        let cacheBatch = Array(assets.prefix(40))
        service.thumbnailCache.startCaching(assets: cacheBatch)
    }

    func toggleSelection(of asset: PHAsset) {
        let id = asset.localIdentifier
        if selectedAssetIDs.contains(id) {
            selectedAssetIDs.remove(id)
        } else {
            selectedAssetIDs.insert(id)
        }
    }

    func isSelected(_ asset: PHAsset) -> Bool {
        selectedAssetIDs.contains(asset.localIdentifier)
    }

    func selectAll() {
        selectedAssetIDs = Set(assets.map(\.localIdentifier))
    }

    func deselectAll() {
        selectedAssetIDs.removeAll()
    }

    func deleteSelected(stats: Binding<CleanupStats>) async {
        let toDelete = assets.filter { selectedAssetIDs.contains($0.localIdentifier) }
        guard !toDelete.isEmpty else { return }

        isDeleting = true
        deletionError = nil

        do {
            let result = try await service.deleteAssets(toDelete)

            await MainActor.run {
                // Remove deleted assets from local array
                assets.removeAll { selectedAssetIDs.contains($0.localIdentifier) }
                selectedAssetIDs.removeAll()

                // Update stats
                var updatedStats = stats.wrappedValue
                updatedStats.recordDeletion(count: result.count, bytes: result.bytesFreed)
                stats.wrappedValue = updatedStats

                isDeleting = false
            }
        } catch {
            await MainActor.run {
                isDeleting = false
                // User cancelled the system deletion dialog — not an error
                if (error as NSError).code == 3072 { // PHPhotosError.userCancelled
                    return
                }
                deletionError = error.localizedDescription
            }
        }
    }

    func thumbnail(for asset: PHAsset) async -> UIImage? {
        await service.thumbnailCache.thumbnail(for: asset)
    }

    func fullImage(for asset: PHAsset) async -> UIImage? {
        await service.thumbnailCache.fullSizeImage(for: asset)
    }

    func cleanup() {
        service.thumbnailCache.stopAllCaching()
    }
}
