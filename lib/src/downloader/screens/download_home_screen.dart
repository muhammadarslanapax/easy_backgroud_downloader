import 'package:flutter/material.dart';

import '../state/download_manager.dart';
import '../widgets/download_tile.dart';

class DownloadHomeScreen extends StatefulWidget {
  const DownloadHomeScreen({required this.manager, super.key});

  final DownloadManager manager;

  @override
  State<DownloadHomeScreen> createState() => _DownloadHomeScreenState();
}

class _DownloadHomeScreenState extends State<DownloadHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.manager.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drive Style Downloader')),
      body: ListenableBuilder(
        listenable: widget.manager,
        builder: (BuildContext context, Widget? _) {
          final DownloadManager manager = widget.manager;
          return Column(
            children: <Widget>[
              if (!manager.initialized)
                const LinearProgressIndicator(minHeight: 2),
              if (manager.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    manager.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: manager.files.length,
                  itemBuilder: (BuildContext context, int index) {
                    final file = manager.files[index];
                    return DownloadTile(file: file, manager: manager);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
