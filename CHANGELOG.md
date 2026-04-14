# Changelog

## 1.0.6

- Updated README for pub.dev: installation version and iOS/Android notification behavior note.

## 1.0.5

- Reverted 1.0.4 iOS local notification integration.
- Removed `flutter_local_notifications` dependency.

## 1.0.4

- Added iOS local notifications for download completion/failure via flutter_local_notifications.
- Added iOS notification permission request in DownloadManager.

## 1.0.3

- Added example screenshots to README and updated image links to render correctly on pub.dev.

## 0.1.3

- Updated README screenshot links to absolute GitHub URLs so screenshots render on pub.dev package page.

## 0.1.2

- Updated package metadata links to the original repository.
- Updated README with original repository link.

## 0.1.1

- Made the package state-management agnostic: removed required `provider` dependency.
- Updated `DownloadHomeScreen` to accept a `DownloadManager` directly.
- Updated README and example app to show usage with any state management approach.

## 0.1.0

- Initial release of `easy_backgroud_downloader`.
- Added `DownloadManager` for background download lifecycle management.
- Added default catalog (`DownloadCatalog`) and `DownloadFile` model.
- Added ready-to-use UI: `DownloadHomeScreen` and `DownloadTile`.
- Added Android and iOS integration instructions in README.
