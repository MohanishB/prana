class DownloadableFile {
  const DownloadableFile({
    required this.id,
    required this.title,
    required this.remoteUrl,
    required this.folder,
    this.fallbackExtension = 'pdf',
  });

  final String id;
  final String title;
  final String remoteUrl;
  final String folder;
  final String fallbackExtension;
}
