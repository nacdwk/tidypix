import SwiftUI
import Photos

@Observable
final class HomeViewModel {
    var selectedDateRange: DateRange?
    var isPickingRandom = false
    var showSettings = false

    let service: PhotoLibraryService

    var isAuthorized: Bool {
        service.authorizationStatus == .authorized || service.authorizationStatus == .limited
    }

    var isDenied: Bool {
        service.authorizationStatus == .denied || service.authorizationStatus == .restricted
    }

    var isIndexReady: Bool {
        service.indexer.isReady
    }

    var isIndexing: Bool {
        service.indexer.isIndexing
    }

    var totalPhotoCount: Int {
        service.totalPhotoCount
    }

    init(service: PhotoLibraryService) {
        self.service = service
    }

    func requestAccess() async {
        await service.requestAuthorization()
    }

    func pickRandomDate() async {
        isPickingRandom = true
        // Ensure index is ready
        if !service.indexer.isReady {
            await service.indexer.buildIndex()
        }
        if let date = service.indexer.randomDate() {
            selectedDateRange = .specificDate(date)
        }
        isPickingRandom = false
    }

    func selectRange(_ range: DateRange) {
        selectedDateRange = range
    }
}
