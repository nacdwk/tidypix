import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 14) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.brand)
                    Text("Your photos stay yours.")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 22) {
                    PrivacyRow(systemImage: "person.crop.circle.badge.xmark", title: "No account", detail: "Nothing to sign up for.")
                    PrivacyRow(systemImage: "eye.slash.fill", title: "No tracking", detail: "No analytics, no ads, no third-party code.")
                    PrivacyRow(systemImage: "cpu", title: "No AI", detail: "You decide what to keep. Nothing is scanned or uploaded.")
                    PrivacyRow(systemImage: "iphone", title: "On device", detail: "TidyPix has no server. Your photos never leave your phone.")
                    PrivacyRow(systemImage: "arrow.uturn.backward.circle.fill", title: "Undo for 30 days", detail: "Deleted items go to Recently Deleted in the Photos app.")
                }
                .padding(24)
                .background(.thinMaterial, in: .rect(cornerRadius: 28))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background { AppBackground() }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrivacyRow: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
