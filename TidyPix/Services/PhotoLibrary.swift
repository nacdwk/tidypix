import Photos

@Observable
final class PhotoLibrary {
    private(set) var status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    private(set) var totalCount = 0
    /// Every calendar day (start of day) that has at least one asset, oldest first.
    private(set) var days: [Date] = []
    private(set) var hasIndexed = false
    private(set) var isIndexing = false

    @ObservationIgnored private var needsReindex = false
    @ObservationIgnored private var changeObserver: ChangeObserver?

    var isAuthorized: Bool { status == .authorized || status == .limited }
    var isLimited: Bool { status == .limited }
    var isDenied: Bool { status == .denied || status == .restricted }

    /// Safe to call repeatedly (e.g. every time the app becomes active).
    func refreshAccess() async {
        status = status == .notDetermined
            ? await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            : PHPhotoLibrary.authorizationStatus(for: .readWrite)

        guard isAuthorized else { return }
        if changeObserver == nil {
            changeObserver = ChangeObserver { [weak self] in
                Task { await self?.reindex() }
            }
        }
        if !hasIndexed { await reindex() }
    }

    func reindex() async {
        guard !isIndexing else {
            needsReindex = true
            return
        }
        isIndexing = true
        repeat {
            needsReindex = false
            let snapshot = await Self.scanLibrary()
            totalCount = snapshot.count
            days = snapshot.days
        } while needsReindex
        hasIndexed = true
        isIndexing = false
    }

    func randomDay(excluding excluded: Date? = nil) -> Date? {
        let candidates = days.count > 1 ? days.filter { $0 != excluded } : days
        return candidates.randomElement()
    }

    /// Moves the assets to Recently Deleted. iOS shows its own confirmation prompt.
    /// Nonisolated because PhotoKit runs the change block on its own queue.
    @concurrent
    nonisolated static func delete(_ assets: [PHAsset]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }
    }

    @concurrent
    nonisolated static func assets(in interval: DateInterval) async -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate < %@",
            interval.start as NSDate,
            interval.end as NSDate
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(with: options)
        return result.objects(at: IndexSet(integersIn: 0..<result.count))
    }

    /// On-disk size of each asset's original resources, keyed by local identifier.
    @concurrent
    nonisolated static func fileSizes(of assets: [PHAsset]) async -> [String: Int64] {
        var sizes: [String: Int64] = [:]
        sizes.reserveCapacity(assets.count)
        for asset in assets {
            if Task.isCancelled { break }
            sizes[asset.localIdentifier] = PHAssetResource.assetResources(for: asset).reduce(0) {
                $0 + (($1.value(forKey: "fileSize") as? Int64) ?? 0)
            }
        }
        return sizes
    }

    @concurrent
    private nonisolated static func scanLibrary() async -> (count: Int, days: [Date]) {
        let result = PHAsset.fetchAssets(with: nil)
        let calendar = Calendar.current
        var days = Set<Date>()
        result.enumerateObjects { asset, _, _ in
            if let created = asset.creationDate {
                days.insert(calendar.startOfDay(for: created))
            }
        }
        return (result.count, days.sorted())
    }
}

private nonisolated final class ChangeObserver: NSObject, PHPhotoLibraryChangeObserver {
    private let onChange: @Sendable () -> Void

    init(onChange: @escaping @Sendable () -> Void) {
        self.onChange = onChange
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        onChange()
    }
}
