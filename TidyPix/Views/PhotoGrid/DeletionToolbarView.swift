import SwiftUI

struct DeletionToolbarView: View {
    let selectedCount: Int
    let isDeleting: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack {
            // Selected count badge
            Text("\(selectedCount) selected")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Group {
                    if isDeleting {
                        ProgressView()
                            .tint(.red)
                    } else {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                }
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
            }
            .disabled(isDeleting)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
