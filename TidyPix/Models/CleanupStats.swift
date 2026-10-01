import Foundation

nonisolated struct CleanupStats: Equatable {
    var totalPhotosDeleted = 0
    var totalBytesFreed: Int64 = 0
    var weeklyDeletedCounts: [String: Int] = [:]
    var lastSessionCount = 0
    var lastSessionDate: Date?

    var thisWeekCount: Int {
        weeklyDeletedCounts[Self.weekKey(for: .now)] ?? 0
    }

    mutating func recordDeletion(count: Int, bytes: Int64) {
        totalPhotosDeleted += count
        totalBytesFreed += bytes
        lastSessionCount = count
        lastSessionDate = .now
        weeklyDeletedCounts[Self.weekKey(for: .now), default: 0] += count
    }

    private static func weekKey(for date: Date) -> String {
        let calendar = Calendar(identifier: .iso8601)
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let week = calendar.component(.weekOfYear, from: date)
        return String(format: "%04d-W%02d", year, week)
    }
}

// Hand-written so the RawRepresentable conformance below doesn't get used for encoding,
// which would recurse forever.
extension CleanupStats: Codable {
    private enum CodingKeys: String, CodingKey {
        case totalPhotosDeleted, totalBytesFreed, weeklyDeletedCounts, lastSessionCount, lastSessionDate
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

extension CleanupStats: RawRepresentable {
    init?(rawValue: String) {
        self = (try? JSONDecoder().decode(Self.self, from: Data(rawValue.utf8))) ?? Self()
    }

    var rawValue: String {
        (try? String(data: JSONEncoder().encode(self), encoding: .utf8)) ?? "{}"
    }
}
