import SwiftUI

struct PrivacyInfoView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Your data\nis yours!")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                privacyRow(icon: "person.slash", text: "No account")
                privacyRow(icon: "eye.slash", text: "No tracking")
                privacyRow(icon: "brain", text: "No AI")

                Text("Your photos never leave\nyour device.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                Text("Deleted photos go to\nthe \"Recently Deleted\" folder")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(GradientBackground())
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacyRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
