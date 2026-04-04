import SwiftUI

struct SelectionOverlayView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Blue border
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.tidySelection, lineWidth: 3)

            // Checkmark badge
            AnimatedCheckmark()
                .padding(6)
        }
    }
}
