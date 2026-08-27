import '../domain/library_video.dart';
import 'library_repository.dart';

class MockLibraryRepository implements LibraryRepository {
  static const _videos = <LibraryVideo>[
    LibraryVideo(
      id: 'agni',
      title: 'Understanding Agni & Digestion',
      youtubeVideoId: 'dQw4w9WgXcQ',
      durationLabel: '12 min',
      transcript:
          'Agni is the digestive fire. Symptoms discussed include heaviness, bloating, appetite changes, sluggish digestion and meal timing.',
      tags: ['digestion', 'agni', 'bloating', 'appetite'],
    ),
    LibraryVideo(
      id: 'sleep',
      title: 'Ayurvedic Evening Routine for Better Sleep',
      youtubeVideoId: 'M7lc1UVf-VE',
      durationLabel: '18 min',
      transcript:
          'A calming evening routine for sleep, restlessness, racing thoughts and nervous system support. Includes warm oil and regular bedtime.',
      tags: ['sleep', 'restlessness', 'routine'],
    ),
    LibraryVideo(
      id: 'herbs',
      title: 'Everyday Herbs for Seasonal Wellness',
      youtubeVideoId: 'ysz5S6PUM-U',
      durationLabel: '15 min',
      transcript:
          'Common culinary herbs and spices are discussed for seasonal wellness, warmth, congestion and digestive comfort.',
      tags: ['herbs', 'spices', 'congestion', 'wellness'],
    ),
  ];

  @override
  Future<List<LibraryVideo>> getVideos() async => _videos;

  @override
  Future<List<LibraryVideo>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return _videos;

    return _videos.where((video) {
      final haystack = [
        video.title,
        video.transcript,
        ...video.tags,
      ].join(' ').toLowerCase();
      return normalized
          .split(RegExp(r'\s+'))
          .every((token) => haystack.contains(token));
    }).toList(growable: false);
  }
}
