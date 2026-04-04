import Foundation
import Photos

struct PhotoDateGroup: Identifiable {
    let id: Date // normalized to midnight
    let assetCount: Int
}
