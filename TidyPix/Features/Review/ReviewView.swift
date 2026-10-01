import Photos
import SwiftUI

struct ReviewView: View {
    @Environment(PhotoLibrary.self) private var library
    @Binding var stats: CleanupStats
    @State private var model: ReviewModel
    @State private var viewerID: String?
    @State private var isViewerPresented = false
    @State private var toast: String?
    @State private var completedDeletions = 0
    @AppStorage("hasSeenReviewHint") private var hasSeenHint = false
    @Namespace private var zoomNamespace

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 4)]

    init(range: DateRange, stats: Binding<CleanupStats>) {
        _model = State(initialValue: ReviewModel(range: range))
        _stats = stats
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(model.assets, id: \.localIdentifier) { asset in
                        cell(for: asset)
                    }
                }
                .padding(.horizontal, 4)
            }
            .id(model.range)
            .onChange(of: viewerID) { _, id in
                // Keep the photo being viewed on screen so the dismiss animation lands on it.
                if let id, isViewerPresented { proxy.scrollTo(id, anchor: .center) }
            }
        }
        .overlay { emptyState }
        .overlay(alignment: .top) { toastView }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationTitle(model.range.title)
        .navigationSubtitle(model.subtitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .fullScreenCover(isPresented: $isViewerPresented) {
            PhotoViewer(assets: model.assets, currentID: $viewerID, selection: $model.selection)
                .navigationTransition(.zoom(sourceID: viewerID ?? "", in: zoomNamespace))
        }
        .alert("Couldn't Delete Photos", isPresented: errorBinding) {
            Button("OK") {}
        } message: {
            Text(model.errorMessage ?? "")
        }
        .sensoryFeedback(.selection, trigger: model.selection)
        .sensoryFeedback(.success, trigger: completedDeletions)
        .animation(.spring(duration: 0.3), value: model.hasSelection)
        .animation(.spring(duration: 0.35), value: toast)
        .task(id: model.range) { await model.load() }
        .onDisappear { ImageLoader.shared.stopPreheating() }
    }

    private func cell(for asset: PHAsset) -> some View {
        let id = asset.localIdentifier
        let isSelected = model.selection.contains(id)
        return PhotoCell(asset: asset, isSelected: isSelected, isSelecting: model.hasSelection)
            .matchedTransitionSource(id: id, in: zoomNamespace)
            .id(id)
            .onTapGesture {
                model.toggle(asset)
                hasSeenHint = true
            }
            .onLongPressGesture(minimumDuration: 0.35) { openViewer(at: id) }
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel(for: asset))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityAction(named: "View Full Screen") { openViewer(at: id) }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if model.range.isSingleDay {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Another Day", systemImage: "dice", action: showAnotherDay)
                    .disabled(library.days.count < 2)
            }
        }
        if !model.assets.isEmpty {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button(model.allSelected ? "Deselect All" : "Select All") {
                    model.toggleSelectAll()
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if model.isLoading {
            ProgressView()
        } else if model.assets.isEmpty {
            ContentUnavailableView {
                if model.clearedEverything {
                    Label("All Tidy", systemImage: "sparkles")
                } else {
                    Label("No Photos", systemImage: "photo.on.rectangle")
                }
            } description: {
                Text(model.clearedEverything
                     ? "You cleared out everything from here. Nice work."
                     : "Nothing was taken during this time.")
            } actions: {
                if library.days.count > 1 {
                    Button("Try Another Day", systemImage: "dice.fill", action: showAnotherDay)
                        .buttonStyle(.glassProminent)
                }
            }
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        if model.hasSelection {
            SelectionBar(
                count: model.selection.count,
                bytes: model.selectedBytes,
                isDeleting: model.isDeleting,
                onDelete: { Task { await deleteSelection() } }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else if !hasSeenHint && !model.assets.isEmpty {
            Text("Tap to select · Press and hold to view")
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .glassEffect(.regular, in: .capsule)
                .padding(.bottom, 8)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            Label(toast, systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .symbolRenderingMode(.multicolor)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .glassEffect(.regular, in: .capsule)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: toast) {
                    try? await Task.sleep(for: .seconds(2.5))
                    self.toast = nil
                }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )
    }

    private func openViewer(at id: String) {
        viewerID = id
        isViewerPresented = true
    }

    private func showAnotherDay() {
        let current: Date? = if case .day(let date) = model.range { date } else { nil }
        if let next = library.randomDay(excluding: current) {
            model.range = .day(next)
        }
    }

    private func deleteSelection() async {
        guard let result = await model.deleteSelection() else { return }
        stats.recordDeletion(count: result.count, bytes: result.bytes)
        completedDeletions += 1
        let noun = result.count == 1 ? "item" : "items"
        toast = "Deleted \(result.count) \(noun) · \(result.bytes.formatted(.byteCount(style: .file))) freed"
    }

    private func accessibilityLabel(for asset: PHAsset) -> String {
        let kind = asset.mediaType == .video ? "Video" : "Photo"
        guard let created = asset.creationDate else { return kind }
        return "\(kind), \(created.formatted(date: .omitted, time: .shortened))"
    }
}

private struct SelectionBar: View {
    let count: Int
    let bytes: Int64?
    let isDeleting: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count) selected")
                    .font(.headline)
                    .contentTransition(.numericText(value: Double(count)))
                Group {
                    if let bytes {
                        Text("\(bytes.formatted(.byteCount(style: .file))) to free up")
                    } else {
                        Text("Measuring…")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .animation(.snappy, value: count)

            Spacer()

            Button(role: .destructive, action: onDelete) {
                if isDeleting {
                    ProgressView()
                } else {
                    Label("Delete", systemImage: "trash.fill")
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(.glassProminent)
            .tint(.red)
            .controlSize(.large)
            .disabled(isDeleting)
        }
        .padding(.leading, 22)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
