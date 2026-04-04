import SwiftUI
import Photos

struct PhotoGridView: View {
    @State private var viewModel: PhotoGridViewModel
    @Binding var stats: CleanupStats

    private let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]

    init(dateRange: DateRange, service: PhotoLibraryService, stats: Binding<CleanupStats>) {
        _viewModel = State(initialValue: PhotoGridViewModel(dateRange: dateRange, service: service))
        _stats = stats
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading photos...")
            } else if viewModel.assets.isEmpty {
                emptyState
            } else {
                gridContent
            }

            // Zoom overlay
            if let zoomedAsset = viewModel.zoomedAsset {
                ZoomablePhotoView(asset: zoomedAsset) {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.zoomedAsset = nil
                    }
                }
            }
        }
        .navigationTitle(viewModel.dateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(viewModel.dateTitle)
                        .font(.headline)
                    Text("\(viewModel.photoCount) Photos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.selectAll()
                    } label: {
                        Label("Select All", systemImage: "checkmark.circle")
                    }
                    Button {
                        viewModel.deselectAll()
                    } label: {
                        Label("Deselect All", systemImage: "circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.hasSelection {
                DeletionToolbarView(
                    selectedCount: viewModel.selectedCount,
                    isDeleting: viewModel.isDeleting,
                    onDelete: {
                        viewModel.showDeleteConfirmation = true
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .confirmationDialog(
            "Delete \(viewModel.selectedCount) photo\(viewModel.selectedCount == 1 ? "" : "s")?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteSelected(stats: $stats)
                }
            }
        } message: {
            Text("These photos will be moved to Recently Deleted and can be recovered for 30 days.")
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.deletionError != nil },
            set: { if !$0 { viewModel.deletionError = nil } }
        )) {
            Button("OK") { viewModel.deletionError = nil }
        } message: {
            Text(viewModel.deletionError ?? "")
        }
        .animation(.spring(response: 0.3), value: viewModel.hasSelection)
        .task {
            await viewModel.loadPhotos()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                    PhotoThumbnailView(
                        asset: asset,
                        isSelected: viewModel.isSelected(asset),
                        onTap: {
                            withAnimation(.spring(response: 0.2)) {
                                viewModel.toggleSelection(of: asset)
                            }
                        },
                        onLongPress: {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.zoomedAsset = asset
                            }
                        }
                    )
                }
            }
            .padding(3)

            // Bottom spacer for deletion toolbar
            if viewModel.hasSelection {
                Spacer()
                    .frame(height: 80)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No photos found")
                .font(.headline)
            Text("No photos were taken on this date.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
