import Photos

extension PHAsset {
    var calendarDate: Date {
        (creationDate ?? Date()).startOfDay
    }

    var formattedCreationDate: String {
        (creationDate ?? Date()).dayAndMonth
    }

    var isVideo: Bool {
        mediaType == .video
    }
}

extension PHFetchResult where ObjectType == PHAsset {
    var allAssets: [PHAsset] {
        var assets: [PHAsset] = []
        assets.reserveCapacity(count)
        enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
}
