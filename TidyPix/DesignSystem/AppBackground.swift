import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.45], [0.6, 0.4], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1],
            ],
            colors: colorScheme == .dark ? Self.dark : Self.light
        )
        .ignoresSafeArea()
    }

    private static let light: [Color] = [
        Color(hex: 0xE9E2FF), Color(hex: 0xF5E4FB), Color(hex: 0xFFE3EA),
        Color(hex: 0xF6F3FF), Color(hex: 0xFBF8FF), Color(hex: 0xFFF2EC),
        Color(hex: 0xFFFFFF), Color(hex: 0xFFFFFF), Color(hex: 0xFFFFFF),
    ]

    private static let dark: [Color] = [
        Color(hex: 0x24124A), Color(hex: 0x2C0F3E), Color(hex: 0x331526),
        Color(hex: 0x100B20), Color(hex: 0x130C1F), Color(hex: 0x170D16),
        Color(hex: 0x09080F), Color(hex: 0x09080F), Color(hex: 0x09080F),
    ]
}
