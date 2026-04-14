# easy_backgroud_downloader

Google Drive style background downloader for Flutter with:

- background task handling
- per-file progress updates
- pause, resume, retry, cancel, open, and remove actions
- ready-made download list UI widgets

## Features

- State-management agnostic API (works with Provider, Riverpod, BLoC, GetX, or no state library)
- Production-ready `DownloadManager` (`ChangeNotifier`) that you can wire into any architecture
- Built-in `DownloadHomeScreen` and `DownloadTile` widgets
- Recover in-progress tasks after app restart
- Supports Android and iOS

## Original repository

- https://github.com/muhammadarslanapax/easy_backgroud_downloader

## Installation

```yaml
dependencies:
  easy_backgroud_downloader: ^0.1.2
```

## Usage

```dart
import 'package:easy_backgroud_downloader/easy_backgroud_downloader.dart';

final manager = DownloadManager();

MaterialApp(
  home: DownloadHomeScreen(manager: manager),
);
```

You can also keep `DownloadManager` inside your own state management solution
(`Provider`, `Riverpod`, `BLoC`, `GetX`, or any custom pattern) and pass it into
`DownloadHomeScreen(manager: yourManager)`.

## Use with custom files

```dart
final manager = DownloadManager(
  files: const <DownloadFile>[
    DownloadFile(
      id: 'invoice',
      title: 'Invoice',
      description: 'June invoice PDF',
      url: 'https://example.com/invoice.pdf',
      fileName: 'invoice_june.pdf',
      sizeLabel: '220 KB',
    ),
  ],
);
```

## Android setup

In `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<application ...>
  <provider
      android:name="vn.hunghd.flutterdownloader.DownloadedFileProvider"
      android:authorities="${applicationId}.flutter_downloader.provider"
      android:exported="false"
      android:grantUriPermissions="true">
      <meta-data
          android:name="android.support.FILE_PROVIDER_PATHS"
          android:resource="@xml/provider_paths" />
  </provider>
</application>
```

Create `android/app/src/main/res/xml/provider_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="." />
    <files-path name="files_path" path="." />
    <cache-path name="cache_path" path="." />
</paths>
```

## iOS setup

In `ios/Runner/AppDelegate.swift`:

```swift
import Flutter
import flutter_downloader
import UIKit

private func registerPlugins(registry: FlutterPluginRegistry) {
  if !registry.hasPlugin("FlutterDownloaderPlugin") {
    FlutterDownloaderPlugin.register(
      with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!
    )
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

In `ios/Runner/Info.plist` add:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
</array>
```

## Example

A runnable example app is included in `example/`.

Run:

```bash
cd example
flutter pub get
flutter run
```

## State management integration

`DownloadManager` is a `ChangeNotifier`, so you can:

- use it directly (no state library),
- expose it via `Provider`,
- wrap it in `Riverpod` notifiers/providers,
- dispatch from `BLoC/Cubit` events,
- or connect it to any custom architecture.

## License

MIT
