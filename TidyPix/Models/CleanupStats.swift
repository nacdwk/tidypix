import Foundation

struct CleanupStats: Codable, Equatable {
    var totalPhotosDeleted: Int = 0
    var totalBytesFreed: Int64 = 0
    var weeklyDeletedCounts: [String: Int] = [:]
    var lastSessionCount: Int = 0
    var lastSessionDate: Date?

    private enum CodingKeys: String, CodingKey {
        case totalPhotosDeleted
        case totalBytesFreed
        case weeklyDeletedCounts
        case lastSessionCount
        case lastSessionDate
    }

    init() {}

    init(
        totalPhotosDeleted: Int = 0,
        totalBytesFreed: Int64 = 0,
        weeklyDeletedCounts: [String: Int] = [:],
        lastSessionCount: Int = 0,
        lastSessionDate: Date? = nil
    ) {
        self.totalPhotosDeleted = totalPhotosDeleted
        self.totalBytesFreed = totalBytesFreed
        self.weeklyDeletedCounts = weeklyDeletedCounts
        self.lastSessionCount = lastSessionCount
        self.lastSessionDate = lastSessionDate
    }

    var thisWeekCount: Int {
        weeklyDeletedCounts[Date().isoWeekString] ?? 0
    }

    var storageFreedFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalBytesFreed, countStyle: .file)
    }

    var totalPhotosFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: totalPhotosDeleted)) ?? "\(totalPhotosDeleted)"
    }

    mutating func recordDeletion(count: Int, bytes: Int64) {
        totalPhotosDeleted += count
        totalBytesFreed += bytes
        lastSessionCount = count
        lastSessionDate = Date()

        let weekKey = Date().isoWeekString
        weeklyDeletedCounts[weekKey, default: 0] += count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalPhotosDeleted = try container.decodeIfPresent(Int.self, forKey: .totalPhotosDeleted) ?? 0
        totalBytesFreed = try container.decodeIfPresent(Int64.self, forKey: .totalBytesFreed) ?? 0
        weeklyDeletedCounts = try container.decodeIfPresent([String: Int].self, forKey: .weeklyDeletedCounts) ?? [:]
        lastSessionCount = try container.decodeIfPresent(Int.self, forKey: .lastSessionCount) ?? 0
        lastSessionDate = try container.decodeIfPresent(Date.self, forKey: .lastSessionDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalPhotosDeleted, forKey: .totalPhotosDeleted)
        try container.encode(totalBytesFreed, forKey: .totalBytesFreed)
        try container.encode(weeklyDeletedCounts, forKey: .weeklyDeletedCounts)
        try container.encode(lastSessionCount, forKey: .lastSessionCount)
        try container.encodeIfPresent(lastSessionDate, forKey: .lastSessionDate)
    }
}

// MARK: - @AppStorage support via RawRepresentable

extension CleanupStats: RawRepresentable {
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(CleanupStats.self, from: data) else {
            self = CleanupStats()
            return
        }
        self = decoded
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}
