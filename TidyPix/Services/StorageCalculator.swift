import Photos

enum StorageCalculator {
    /// Estimates total storage size of the given assets.
    /// Uses PHAssetResource fileSize via KVC with a 3MB fallback per asset.
    static func totalSize(of assets: [PHAsset]) async -> Int64 {
        await withTaskGroup(of: Int64.self, returning: Int64.self) { group in
            for asset in assets {
                group.addTask {
                    let resources = PHAssetResource.assetResources(for: asset)
                    var size: Int64 = 0
                    for resource in resources {
                        if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
                            size += fileSize
                        }
                    }
                    // Fallback: 3MB estimate if no fileSize available
                    return size > 0 ? size : 3_000_000
                }
            }

            var total: Int64 = 0
            for await partialSize in group {
                total += partialSize
            }
            return total
        }
    }
}
