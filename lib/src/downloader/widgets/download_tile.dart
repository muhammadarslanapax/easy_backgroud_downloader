import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../../models/download_file.dart';
import '../state/download_manager.dart';

class DownloadTile extends StatelessWidget {
  const DownloadTile({required this.file, required this.manager, super.key});

  final DownloadFile file;
  final DownloadManager manager;

  @override
  Widget build(BuildContext context) {
    final DownloadTaskEntry? entry = manager.entryForFile(file.id);
    final DownloadTaskStatus? status = entry?.status;
    final int progress = entry?.progress ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(file.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(file.description),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Text(
                  file.sizeLabel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status == null
                        ? 'Not downloaded'
                        : manager.statusLabel(status),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text('$progress%'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: status == null ? 0 : progress / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _buildActions(status)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(DownloadTaskStatus? status) {
    if (status == null) {
      return <Widget>[
        FilledButton.icon(
          onPressed: () => manager.startDownload(file),
          icon: const Icon(Icons.download),
          label: const Text('Download'),
        ),
      ];
    }

    if (status == DownloadTaskStatus.running ||
        status == DownloadTaskStatus.enqueued) {
      return <Widget>[
        OutlinedButton.icon(
          onPressed: () => manager.pauseDownload(file),
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
        TextButton(
          onPressed: () => manager.cancelDownload(file),
          child: const Text('Cancel'),
        ),
      ];
    }

    if (status == DownloadTaskStatus.paused) {
      return <Widget>[
        FilledButton.icon(
          onPressed: () => manager.resumeDownload(file),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Resume'),
        ),
        TextButton(
          onPressed: () => manager.cancelDownload(file),
          child: const Text('Cancel'),
        ),
      ];
    }

    if (status == DownloadTaskStatus.complete) {
      return <Widget>[
        FilledButton.icon(
          onPressed: () => manager.openDownload(file),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open'),
        ),
        OutlinedButton(
          onPressed: () => manager.removeDownload(file),
          child: const Text('Delete'),
        ),
      ];
    }

    return <Widget>[
      FilledButton.icon(
        onPressed: () => manager.retryDownload(file),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
      TextButton(
        onPressed: () => manager.removeDownload(file),
        child: const Text('Clear'),
      ),
    ];
  }
}
