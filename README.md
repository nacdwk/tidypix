<p align="center">
  <img src="TidyPix/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="128" alt="TidyPix app icon">
</p>

<h1 align="center">TidyPix</h1>

<p align="center">
  Clean up your photo library, one day at a time.
</p>

<p align="center">
  A native iOS app that turns managing thousands of photos into a quick daily habit.<br>
  Pick a random day, review what you shot, delete what you don't need.
</p>

---

## How it works

1. **Pick a day.** Tap **Pick a random day** to land somewhere in your library, or choose Today, Last 7 days or Last 30 days.
2. **Review.** Photos from that day appear in a clean square grid. Press and hold any photo to open it full screen, then swipe between photos, pinch or double-tap to zoom, and play videos.
3. **Select.** Tap photos to mark them, either in the grid or with the Select button in the full-screen viewer. The bar at the bottom shows how much space you'll free.
4. **Delete.** Tap Delete and confirm the iOS prompt. Items move to Recently Deleted, where you can recover them for 30 days.
5. **Keep going.** Tap the dice to jump to another random day. Your totals, storage freed and weekly progress appear on the home screen.

## Features

- Random-day picker across your whole library, showing how long ago the day was ("6 years ago")
- Uniform square grid that handles panoramas, landscape and portrait photos, and videos
- Full-screen viewer with paging, pinch and double-tap zoom, video playback, and a zoom transition from the grid
- Live size estimate for the current selection
- Cleanup stats: total cleaned, storage freed, this week, last session
- Daily reminder at a time you choose
- Light, dark and system themes, plus a dark and tinted app icon
- Updates automatically when your library changes outside the app
- Works on iPhone and iPad

## Privacy

- No accounts, tracking, analytics or AI
- No server. Your photos never leave your device.
- Deleted items go to Recently Deleted in the Photos app.
- Built entirely with Apple frameworks, with no third-party dependencies

## Requirements

- iOS 26.0+
- Xcode 26+

## Getting started

```bash
git clone https://github.com/nacdwk/tidypix.git
open tidypix/TidyPix.xcodeproj
```

Choose a simulator or device and press ⌘R. To run on a physical device, set your Apple ID as the signing team under **Signing & Capabilities**.

## Architecture

SwiftUI, PhotoKit and Swift 6 strict concurrency, with main-actor isolation by default. The Xcode project uses folder-synced groups, so new files in `TidyPix/` are picked up automatically.

```
TidyPix/
├── App/              TidyPixApp — entry point, theme
├── Models/           CleanupStats, DateRange, AppTheme
├── Services/         PhotoLibrary (access, day index, fetch, delete),
│                     ImageLoader (PhotoKit thumbnails), DailyReminder
├── DesignSystem/     Brand colours and gradient, BrandButtonStyle, AppBackground
└── Features/
    ├── Home/         HomeView, StatsCard
    ├── Review/       ReviewView, ReviewModel, PhotoCell, PhotoViewer, ZoomableImageView
    └── Settings/     SettingsView, PrivacyView
```

## License

This project is for personal use.
