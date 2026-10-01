import Photos

@Observable
final class ReviewModel {
    var range: DateRange
    var selection: Set<String> = []
    var errorMessage: String?

    private(set) var assets: [PHAsset] = []
    private(set) var isLoading = true
    private(set) var isDeleting = false
    /// True when the user deleted every photo in the range — shown as a celebration, not "no photos".
    private(set) var clearedEverything = false
    private var sizes: [String: Int64] = [:]

    init(range: DateRange) {
        self.range = range
    }

    var hasSelection: Bool { !selection.isEmpty }
    var allSelected: Bool { !assets.isEmpty && selection.count == assets.count }

    /// Nil until file sizes have been measured.
    var selectedBytes: Int64? {
        guard !sizes.isEmpty else { return nil }
        return selection.reduce(0) { $0 + (sizes[$1] ?? 0) }
    }

    var subtitle: String {
        guard !isLoading else { return "" }
        let videos = assets.count { $0.mediaType == .video }
        let photos = assets.count - videos
        var parts: [String] = []
        if let age = range.relativeAge, range.isSingleDay { parts.append(age) }
        if photos > 0 || videos == 0 { parts.append(photos == 1 ? "1 photo" : "\(photos) photos") }
        if videos > 0 { parts.append(videos == 1 ? "1 video" : "\(videos) videos") }
        return parts.joined(separator: " · ")
    }

    func load() async {
        isLoading = true
        selection = []
        clearedEverything = false
        ImageLoader.shared.stopPreheating()

        let fetched = await PhotoLibrary.assets(in: range.interval)
        guard !Task.isCancelled else { return }
        assets = fetched
        isLoading = false
        ImageLoader.shared.preheat(Array(fetched.prefix(60)))

        let fetchedSizes = await PhotoLibrary.fileSizes(of: fetched)
        guard !Task.isCancelled else { return }
        sizes = fetchedSizes
    }

    func toggle(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if selection.remove(id) == nil { selection.insert(id) }
    }

    func toggleSelectAll() {
        selection = allSelected ? [] : Set(assets.map(\.localIdentifier))
    }

    /// Returns what was deleted, or nil if nothing was (including when the user cancels the system prompt).
    func deleteSelection() async -> (count: Int, bytes: Int64)? {
        let doomed = assets.filter { selection.contains($0.localIdentifier) }
        guard !doomed.isEmpty else { return nil }

        isDeleting = true
        defer { isDeleting = false }

        // Measure before deleting: once the assets are gone their resources can't be read.
        let missing = doomed.filter { sizes[$0.localIdentifier] == nil }
        if !missing.isEmpty {
            sizes.merge(await PhotoLibrary.fileSizes(of: missing)) { _, new in new }
        }
        let bytes = doomed.reduce(Int64(0)) { $0 + (sizes[$1.localIdentifier] ?? 0) }

        do {
            try await PhotoLibrary.delete(doomed)
        } catch {
            if (error as? PHPhotosError)?.code != .userCancelled {
                errorMessage = error.localizedDescription
            }
            return nil
        }

        let deletedIDs = Set(doomed.map(\.localIdentifier))
        assets.removeAll { deletedIDs.contains($0.localIdentifier) }
        selection.subtract(deletedIDs)
        clearedEverything = assets.isEmpty
        return (doomed.count, bytes)
    }
}
