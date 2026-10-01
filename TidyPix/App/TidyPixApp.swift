import SwiftUI

@main
struct TidyPixApp: App {
    @State private var library = PhotoLibrary()
    @AppStorage("appTheme") private var theme = AppTheme.system

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(library)
                .preferredColorScheme(theme.colorScheme)
        }
    }
}
