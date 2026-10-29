enum VideoProvider {
  network,
  vimeo,
}

class AppVideoSource {
  const AppVideoSource({
    required this.id,
    required this.url,
    required this.provider,
  });

  /// Path of the server's player page (`player/player.php`). Vimeo videos are
  /// played through a signed link to it, see the backend `PlayerLink`.
  static const String playerPagePath = '/player/player.php';

  final String id;
  final String url;
  final VideoProvider provider;

  bool get isPlayerPage => url.toLowerCase().contains(playerPagePath);

  factory AppVideoSource.fromUrl({
    required String id,
    required String url,
  }) {
    final normalizedUrl = url.trim();
    final lowerUrl = normalizedUrl.toLowerCase();
    // A video file (.mp4) always plays directly, whatever else is in its address.
    final isMp4 = (Uri.tryParse(normalizedUrl)?.path ?? lowerUrl)
        .toLowerCase()
        .endsWith('.mp4');
    final provider = !isMp4 &&
            (lowerUrl.contains('vimeo') || lowerUrl.contains(playerPagePath))
        ? VideoProvider.vimeo
        : VideoProvider.network;

    return AppVideoSource(
      id: id,
      url: normalizedUrl,
      provider: provider,
    );
  }
}
