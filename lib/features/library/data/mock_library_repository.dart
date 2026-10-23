import '../domain/library_video.dart';
import 'library_repository.dart';

class MockLibraryRepository implements LibraryRepository {
  static final _videos = <LibraryVideo>[
    LibraryVideo(
      id: 'agni',
      title: 'Understanding Agni & Digestion',
      youtubeVideoId: 'dQw4w9WgXcQ',
      durationLabel: '12:00',
      description:
          'Agni, digestion, bloating, appetite changes and meal timing.',
      thumbnailUrl: '',
      publishedAt: null,
      tags: const ['digestion', 'agni', 'bloating', 'appetite'],
    ),
    LibraryVideo(
      id: 'sleep',
      title: 'Ayurvedic Evening Routine for Better Sleep',
      youtubeVideoId: 'M7lc1UVf-VE',
      durationLabel: '18:00',
      description:
          'A calming evening routine for sleep and nervous system support.',
      thumbnailUrl: '',
      publishedAt: null,
      tags: const ['sleep', 'restlessness', 'routine'],
    ),
  ];

  @override
  Future<LibraryPage> getVideos({String? pageToken}) async {
    return LibraryPage(videos: _videos);
  }

  @override
  Future<LibraryPage> search(
    String query, {
    String? pageToken,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return getVideos();

    final videos = _videos.where((video) {
      final haystack = [
        video.title,
        video.description,
        ...video.tags,
      ].join(' ').toLowerCase();
      return normalized
          .split(RegExp(r'\s+'))
          .every((token) => haystack.contains(token));
    }).toList(growable: false);

    return LibraryPage(videos: videos);
  }
}
