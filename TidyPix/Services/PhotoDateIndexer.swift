import Foundation
import Photos

@Observable
final class PhotoDateIndexer {
    private(set) var datesWithPhotos: [Date] = []
    private(set) var isReady = false
    private(set) var isIndexing = false
    private var buildTask: Task<[Date], Never>?

    func buildIndex() async {
        if let buildTask {
            let dates = await buildTask.value
            await MainActor.run {
                self.datesWithPhotos = dates
                self.isReady = true
                self.isIndexing = false
                self.buildTask = nil
            }
            return
        }

        await MainActor.run {
            isIndexing = true
            isReady = false
        }

        let task = Task.detached(priority: .userInitiated) {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let result = PHAsset.fetchAssets(with: options)

            var dateSet = Set<Date>()
            let calendar = Calendar.current

            result.enumerateObjects { asset, _, _ in
                if let creationDate = asset.creationDate {
                    let startOfDay = calendar.startOfDay(for: creationDate)
                    dateSet.insert(startOfDay)
                }
            }

            return dateSet.sorted()
        }

        buildTask = task
        let dates = await task.value

        await MainActor.run {
            self.datesWithPhotos = dates
            self.isReady = true
            self.isIndexing = false
            self.buildTask = nil
        }
    }

    func randomDate() -> Date? {
        guard !datesWithPhotos.isEmpty else { return nil }
        return datesWithPhotos.randomElement()
    }

    func photoCount(for date: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }

        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate < %@",
            start as NSDate,
            end as NSDate
        )
        return PHAsset.fetchAssets(with: options).count
    }
}
