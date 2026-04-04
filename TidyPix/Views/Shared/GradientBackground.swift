import SwiftUI

struct GradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                Color.tidyNavy
            } else {
                LinearGradient(
                    colors: [.tidyLavenderStart, .tidyLavenderEnd, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}
