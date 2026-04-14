/// File descriptor used by the downloader UI and manager.
class DownloadFile {
  const DownloadFile({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.fileName,
    required this.sizeLabel,
  });

  final String id;
  final String title;
  final String description;
  final String url;
  final String fileName;
  final String sizeLabel;
}
