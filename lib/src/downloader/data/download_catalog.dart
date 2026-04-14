import '../../models/download_file.dart';

/// Default demo catalog used by `DownloadHomeScreen`.
class DownloadCatalog {
  static const List<DownloadFile> files = <DownloadFile>[
    DownloadFile(
      id: 'report_pdf',
      title: 'Q1 Report',
      description: 'Company report PDF',
      url:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      fileName: 'q1_report.pdf',
      sizeLabel: '13 KB',
    ),
    DownloadFile(
      id: 'sample_mp4',
      title: 'Promo Video',
      description: 'Marketing sample video',
      url:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      fileName: 'promo_video.mp4',
      sizeLabel: '2.1 MB',
    ),
    DownloadFile(
      id: 'sample_jpg',
      title: 'Cover Image',
      description: 'Product preview image',
      url: 'https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg',
      fileName: 'cover_image.jpg',
      sizeLabel: '87 KB',
    ),
    DownloadFile(
      id: 'sample_docx',
      title: 'Sample Document',
      description: 'Office document example',
      url: 'https://calibre-ebook.com/downloads/demos/demo.docx',
      fileName: 'sample_document.docx',
      sizeLabel: '1.2 MB',
    ),
  ];
}
