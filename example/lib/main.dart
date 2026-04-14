import 'package:easy_backgroud_downloader/easy_backgroud_downloader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static final DownloadManager _manager = DownloadManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drive Downloader Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: DownloadHomeScreen(manager: _manager),
    );
  }
}
