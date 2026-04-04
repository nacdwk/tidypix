<p align="center">
  <img src="TidyPix/Assets.xcassets/AppIcon.appiconset/180.png" width="120" alt="TidyPix app icon">
</p>

<h1 align="center">TidyPix</h1>

<p align="center">
  Clean up your photo library. One day at a time.
</p>

<p align="center">
  A native iOS app that turns managing thousands of photos into a quick daily habit.<br>
  Pick a random date, review your photos, delete what you don't need.
</p>

---

## How It Works

1. **Pick a day** — tap "Random day across all years" or choose Today / Last 7 days / Last 30 days
2. **Review** — browse your photos from that day in a 2-column grid
3. **Select** — tap to mark photos for deletion, long-press to zoom in for a closer look
4. **Delete** — hit the trash icon and confirm. Photos move to Recently Deleted (recoverable for 30 days)
5. **Track progress** — see your total photos cleaned, storage freed, and weekly stats on the home dashboard

## Features

- Random date picker across your entire photo library
- 2-column photo grid with tap-to-select and long-press-to-zoom
- Bulk delete with system confirmation dialog
- Cleanup stats tracking (total deleted, storage freed, this week, last session)
- Daily reminder notifications
- Dark mode support
- Works on iPhone and iPad

## Privacy

- No accounts
- No tracking
- No AI
- No cloud uploads
- Your photos never leave your device
- Deleted photos go to the "Recently Deleted" folder
- Built entirely with Apple frameworks — the app has no server

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/nacdwk/tidypix.git
   ```
2. Open `TidyPix.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (Cmd+R)

> To run on a physical device, set your Apple ID as the signing team in **Signing & Capabilities**.

## Architecture

Built with **SwiftUI** and **PhotoKit**. No external dependencies.

```
TidyPix/
├── Models/              # CleanupStats, DateRange, PhotoDateGroup
├── Services/            # PhotoLibraryService, PhotoDateIndexer, ThumbnailCache,
│                        #   StorageCalculator, DailyReminderService
├── ViewModels/          # HomeViewModel, PhotoGridViewModel, SettingsViewModel
├── Views/
│   ├── Home/            # HomeView, StatsCardView, DatePickerButtonsView
│   ├── PhotoGrid/       # PhotoGridView, PhotoThumbnailView, ZoomablePhotoView,
│   │                    #   SelectionOverlayView, DeletionToolbarView
│   ├── Settings/        # SettingsView, PrivacyInfoView
│   └── Shared/          # GradientBackground, FrostedCardModifier, AnimatedCheckmark
└── Extensions/          # Color+Theme, Date+Extensions, PHAsset+Extensions, View+Extensions
```

## License

This project is for personal use.
