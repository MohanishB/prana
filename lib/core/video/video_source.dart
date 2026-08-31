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

  final String id;
  final String url;
  final VideoProvider provider;

  factory AppVideoSource.fromUrl({
    required String id,
    required String url,
  }) {
    final normalizedUrl = url.trim();
    final provider = normalizedUrl.toLowerCase().contains('vimeo')
        ? VideoProvider.vimeo
        : VideoProvider.network;

    return AppVideoSource(
      id: id,
      url: normalizedUrl,
      provider: provider,
    );
  }
}
