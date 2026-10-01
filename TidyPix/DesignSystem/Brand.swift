import SwiftUI

extension Color {
    static let brandViolet = Color(hex: 0x5B21F5)
    static let brandMagenta = Color(hex: 0xD62AD0)
    static let brandCoral = Color(hex: 0xFF7A45)

    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension ShapeStyle where Self == LinearGradient {
    /// The violet → magenta → coral gradient from the app icon.
    static var brand: LinearGradient {
        LinearGradient(
            colors: [.brandViolet, .brandMagenta, .brandCoral],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct BrandButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(.brand, in: .capsule)
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                    .blendMode(.overlay)
            }
            .shadow(color: .brandMagenta.opacity(isEnabled ? 0.35 : 0), radius: 16, y: 8)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BrandButtonStyle {
    static var brand: BrandButtonStyle { BrandButtonStyle() }
}
