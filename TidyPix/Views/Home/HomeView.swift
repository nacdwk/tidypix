import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @AppStorage("cleanupStats") private var stats = CleanupStats()

    init(service: PhotoLibraryService) {
        _viewModel = State(initialValue: HomeViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                if viewModel.isDenied {
                    deniedView
                } else {
                    mainContent
                }
            }
            .navigationDestination(item: $viewModel.selectedDateRange) { dateRange in
                PhotoGridView(
                    dateRange: dateRange,
                    service: viewModel.service,
                    stats: $stats
                )
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(
                    totalLibraryCount: viewModel.totalPhotoCount,
                    stats: $stats
                )
            }
            .task {
                await viewModel.requestAccess()
            }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Button {
                        viewModel.showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal)

                // App title
                VStack(spacing: 8) {
                    Text("TidyPix")
                        .font(.system(size: 36, weight: .bold, design: .serif))

                    Text("Clean up your photo library.\nOne day at a time.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Stats card
                StatsCardView(stats: stats)
                    .padding(.horizontal)

                // Date picker buttons
                DatePickerButtonsView(
                    isPickingRandom: viewModel.isPickingRandom,
                    isIndexReady: viewModel.isIndexReady,
                    onRandom: {
                        Task { await viewModel.pickRandomDate() }
                    },
                    onSelect: { range in
                        viewModel.selectRange(range)
                    }
                )
                .padding(.horizontal)

                // Indexing indicator
                if viewModel.isIndexing {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Scanning your photo library...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
    }

    private var deniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Photo Access Required")
                .font(.title2.bold())

            Text("TidyPix needs access to your photo library to help you clean up your photos.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.tidyAccent)
        }
    }
}
