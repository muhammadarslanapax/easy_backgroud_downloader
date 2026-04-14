import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/download_file.dart';
import '../data/download_catalog.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    DownloadManager.portName,
  );
  send?.send(<dynamic>[id, status, progress]);
}

class DownloadTaskEntry {
  DownloadTaskEntry({
    required this.file,
    required this.taskId,
    required this.status,
    required this.progress,
  });

  final DownloadFile file;
  String taskId;
  DownloadTaskStatus status;
  int progress;
}

class DownloadManager extends ChangeNotifier {
  DownloadManager({List<DownloadFile>? files})
      : _files = files ?? DownloadCatalog.files;

  static const String portName = 'downloader_send_port';

  final ReceivePort _port = ReceivePort();
  final List<DownloadFile> _files;
  final Map<String, DownloadTaskEntry> _entriesByFileId =
      <String, DownloadTaskEntry>{};
  bool _initialized = false;
  String? _errorMessage;

  bool get initialized => _initialized;
  String? get errorMessage => _errorMessage;
  List<DownloadFile> get files => List<DownloadFile>.unmodifiable(_files);

  DownloadTaskEntry? entryForFile(String fileId) => _entriesByFileId[fileId];

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await FlutterDownloader.initialize(debug: false, ignoreSsl: false);
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    await _restoreTasks();
    _initialized = true;
    notifyListeners();
  }

  Future<void> startDownload(DownloadFile file) async {
    _errorMessage = null;
    notifyListeners();

    final bool allowed = await _ensurePermissions();
    if (!allowed) {
      _errorMessage = 'Permission required for background download.';
      notifyListeners();
      return;
    }

    final Directory directory = await _resolveDownloadDirectory();
    final String? taskId = await FlutterDownloader.enqueue(
      url: file.url,
      savedDir: directory.path,
      fileName: file.fileName,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: false,
    );

    if (taskId == null) {
      _errorMessage = 'Unable to start download.';
      notifyListeners();
      return;
    }

    _entriesByFileId[file.id] = DownloadTaskEntry(
      file: file,
      taskId: taskId,
      status: DownloadTaskStatus.enqueued,
      progress: 0,
    );
    notifyListeners();
  }

  Future<void> pauseDownload(DownloadFile file) async {
    final DownloadTaskEntry? entry = _entriesByFileId[file.id];
    if (entry == null) {
      return;
    }
    await FlutterDownloader.pause(taskId: entry.taskId);
  }

  Future<void> resumeDownload(DownloadFile file) async {
    final DownloadTaskEntry? entry = _entriesByFileId[file.id];
    if (entry == null) {
      return;
    }
    final String? newTaskId = await FlutterDownloader.resume(
      taskId: entry.taskId,
    );
    if (newTaskId != null) {
      entry.taskId = newTaskId;
      notifyListeners();
    }
  }

  Future<void> retryDownload(DownloadFile file) async {
    final DownloadTaskEntry? entry = _entriesByFileId[file.id];
    if (entry == null) {
      return;
    }
    final String? newTaskId = await FlutterDownloader.retry(
      taskId: entry.taskId,
    );
    if (newTaskId != null) {
      entry.taskId = newTaskId;
      entry.status = DownloadTaskStatus.enqueued;
      entry.progress = 0;
      notifyListeners();
    }
  }

  Future<void> cancelDownload(DownloadFile file) async {
    final DownloadTaskEntry? entry = _entriesByFileId[file.id];
    if (entry == null) {
      return;
    }
    await FlutterDownloader.cancel(taskId: entry.taskId);
  }

  Future<void> removeDownload(DownloadFile file) async {
    final DownloadTaskEntry? entry = _entriesByFileId[file.id];
    if (entry == null) {
      return;
    }
    await FlutterDownloader.remove(
      taskId: entry.taskId,
      shouldDeleteContent: true,
    );
    _entriesByFileId.remove(file.id);
    notifyListeners();
  }

  Future<void> openDownload(DownloadFile file) async {
    final DownloadTaskEntry? entry = _entriesByFileId[file.id];
    if (entry == null || entry.status != DownloadTaskStatus.complete) {
      return;
    }
    await FlutterDownloader.open(taskId: entry.taskId);
  }

  String statusLabel(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.running) {
      return 'Downloading';
    }
    if (status == DownloadTaskStatus.complete) {
      return 'Completed';
    }
    if (status == DownloadTaskStatus.paused) {
      return 'Paused';
    }
    if (status == DownloadTaskStatus.failed) {
      return 'Failed';
    }
    if (status == DownloadTaskStatus.canceled) {
      return 'Canceled';
    }
    if (status == DownloadTaskStatus.enqueued) {
      return 'Queued';
    }
    return 'Idle';
  }

  Future<void> _restoreTasks() async {
    final List<DownloadTask>? tasks = await FlutterDownloader.loadTasks();
    if (tasks == null || tasks.isEmpty) {
      return;
    }
    for (final DownloadTask task in tasks) {
      DownloadFile? matchedFile;
      for (final DownloadFile file in _files) {
        if (file.fileName == task.filename) {
          matchedFile = file;
          break;
        }
      }
      if (matchedFile == null) {
        continue;
      }
      _entriesByFileId[matchedFile.id] = DownloadTaskEntry(
        file: matchedFile,
        taskId: task.taskId,
        status: task.status,
        progress: task.progress,
      );
    }
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, portName);
    _port.listen((dynamic data) {
      final String taskId = data[0] as String;
      final DownloadTaskStatus status = DownloadTaskStatus.fromInt(
        data[1] as int,
      );
      final int progress = data[2] as int;

      DownloadTaskEntry? matchedEntry;
      for (final DownloadTaskEntry entry in _entriesByFileId.values) {
        if (entry.taskId == taskId) {
          matchedEntry = entry;
          break;
        }
      }
      if (matchedEntry == null) {
        return;
      }

      matchedEntry.status = status;
      matchedEntry.progress = progress;
      notifyListeners();
    });
  }

  Future<bool> _ensurePermissions() async {
    if (Platform.isAndroid) {
      final PermissionStatus status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final Directory target = Directory('${externalDir.path}/downloads');
        if (!await target.exists()) {
          await target.create(recursive: true);
        }
        return target;
      }
    }
    final Directory docsDir = await getApplicationDocumentsDirectory();
    return docsDir;
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(portName);
    _port.close();
    super.dispose();
  }
}
