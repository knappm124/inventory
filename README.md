# Inventory

A cross-platform Flutter app for keeping a lightweight, local inventory of items.
Inventory supports item photos, quantities, prices, tags, locations, statuses,
search, filtering, sorting, and PDF export.

## Features

- Add, edit, and remove inventory items.
- Track quantity, price, notes, locations, statuses, and custom tags.
- Add multiple photos to an item and choose its primary image.
- Search inventory and sort by common item fields.
- Filter by status, location, tags, price range, or low-stock threshold.
- Manage locations, statuses, and tags from the settings menu.
- Export the current inventory view to a shareable PDF.
- Save data locally with backup recovery for file-based platforms.
- Persist browser data with `SharedPreferences` when running on the web.
- Migrate older item data formats when legacy data is detected.

## Requirements

- Flutter SDK compatible with Dart `^3.12.1`.
- A platform toolchain for the target platform:
  - Android Studio and an Android SDK for Android.
  - Xcode for iOS or macOS.
  - Chrome for web.
  - Visual Studio with Desktop development with C++ for Windows.
  - A C++ toolchain for Linux.

Check the local Flutter installation with:

```bash
flutter doctor
```

## Getting Started

Install dependencies and run the application from the project root:

```bash
flutter pub get
flutter run
```

To choose a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

Useful platform commands include:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

## Development

Run the analyzer and tests before submitting changes:

```bash
flutter analyze
flutter test
```

Format Dart files with:

```bash
dart format lib test
```

Build release artifacts with the platform-specific Flutter build command, for
example:

```bash
flutter build web
flutter build apk --release
flutter build windows
```

## Data Storage

Inventory is designed for local use and does not require a backend service.

- On Android, iOS, Windows, macOS, and Linux, item data and collection data are
  stored as JSON in the application documents directory.
- On the web, data is stored in browser-managed `SharedPreferences` storage.
- File-based storage keeps `.bak` copies while writing so recoverable data is
  available if a write is interrupted.
- Browser storage is tied to the browser profile and origin. Clearing site data
  can remove the inventory, so use PDF export for portable snapshots.

The app currently has no authentication or cloud synchronization. Treat local
storage as the source of truth for each device or browser profile.

## Project Structure

```text
lib/
  main.dart                 App shell, theme, loading, search, and navigation
  utilities/
    collections.dart        Item model and local persistence
    filter.dart             Filtering criteria and filter panel
    itemwidgets.dart        Inventory list and item presentation
    newitem.dart            New item flow and image management
    editing.dart            Item editing flow
    menu.dart               Settings, collection management, and export
    pdf.dart                PDF generation and sharing
    image_utils.dart        Cross-platform image helpers
```

## Dependencies

The app uses Flutter Material 3 with `google_fonts` for typography. Important
runtime packages include `image_picker` for photos, `shared_preferences` and
`path_provider` for persistence, and `pdf` and `printing` for export.

## License

This project is not currently published under a license.
