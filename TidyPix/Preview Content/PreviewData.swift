import Foundation

enum PreviewData {
    static let emptyStats = CleanupStats()

    static var sampleStats: CleanupStats {
        var stats = CleanupStats()
        stats.totalPhotosDeleted = 6576
        stats.totalBytesFreed = 17_000_000_000 // ~17 GB
        stats.lastSessionCount = 33
        stats.lastSessionDate = Date()
        stats.weeklyDeletedCounts = [Date().isoWeekString: 5694]
        return stats
    }
}
