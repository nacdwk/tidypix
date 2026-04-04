import SwiftUI

struct AnimatedCheckmark: View {
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 22))
            .foregroundStyle(.white, Color.tidySelection)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .transition(.scale.combined(with: .opacity))
    }
}
