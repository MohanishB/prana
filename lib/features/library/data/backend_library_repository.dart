import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/text/html_plain_text.dart';
import '../domain/library_video.dart';
import 'library_repository.dart';

class BackendLibraryRepository implements LibraryRepository {
  BackendLibraryRepository(this._api);

  final ApiClient _api;

  @override
  Future<LibraryPage> getVideos({String? pageToken}) {
    return _load(
      query: '',
      pageToken: pageToken,
    );
  }

  @override
  Future<LibraryPage> search(
    String query, {
    String? pageToken,
  }) {
    return _load(
      query: query.trim(),
      pageToken: pageToken,
    );
  }

  Future<LibraryPage> _load({
    required String query,
    String? pageToken,
  }) async {
    final page = _pageNumber(pageToken);
    final json = await _api.getRaw(
      ApiConstants.youtubeChannelSearch,
      query: {
        'page': '$page',
        if (query.isNotEmpty) 'q': query,
      },
      authenticated: false,
    );

    final items = _videoItems(json);
    final parsedVideos = items
        .map(_parseVideo)
        .whereType<LibraryVideo>()
        .toList(growable: false);

    if (items.isNotEmpty && parsedVideos.isEmpty) {
      throw const AppException(AppErrorType.invalidResponse);
    }

    final videos = _deduplicate(parsedVideos);

    // Latest pages contain multiple backend buckets. Keep a single
    // chronological feed while preserving relevance ordering for search.
    if (query.isEmpty) {
      videos.sort((left, right) {
        final leftDate = left.publishedAt;
        final rightDate = right.publishedAt;
        if (leftDate == null && rightDate == null) return 0;
        if (leftDate == null) return 1;
        if (rightDate == null) return -1;
        return rightDate.compareTo(leftDate);
      });
    }

    return LibraryPage(
      videos: videos,
      nextPageToken: _nextPageToken(json),
    );
  }

  /// The backend can expose playable content in separate arrays such as
  /// `videos`, `shorts`, `podcasts`, or future video-shaped buckets. Lists
  /// without a video id (for example playlist metadata) are ignored because
  /// the Library feed opens an individual video player.
  List<Map<String, dynamic>> _videoItems(Map<String, dynamic> json) {
    final result = <Map<String, dynamic>>[];

    for (final entry in json.entries) {
      final value = entry.value;
      if (value is! List) continue;

      for (final item in value) {
        final mapped = _map(item);
        if (mapped == null || _videoId(mapped).isEmpty) continue;
        result.add(mapped);
      }
    }

    return result;
  }

  LibraryVideo? _parseVideo(Map<String, dynamic> item) {
    final id = _videoId(item);
    if (id.isEmpty) return null;

    final durationSeconds = _intValue(item['durationSeconds']);
    final publishedAtRaw = item['publishedAt']?.toString();
    final tags = (item['tags'] as List?)
            ?.map((tag) => tag.toString())
            .where((tag) => tag.trim().isNotEmpty)
            .toList(growable: false) ??
        const <String>[];

    return LibraryVideo(
      id: id,
      youtubeVideoId: id,
      title: htmlToPlainText(item['title']?.toString() ?? ''),
      durationLabel: _formatSeconds(durationSeconds),
      description: htmlToPlainText(item['description']?.toString() ?? ''),
      thumbnailUrl: _thumbnailUrl(item),
      publishedAt: publishedAtRaw == null
          ? null
          : DateTime.tryParse(publishedAtRaw)?.toLocal(),
      tags: tags,
      isShortOverride: _boolValue(item['isShort']),
    );
  }

  String _thumbnailUrl(Map<String, dynamic> item) {
    final thumbnails = _map(item['thumbnails']);

    String? nestedUrl(String key) {
      final value = thumbnails?[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();

      final mapped = _map(value);
      final url = mapped?['url']?.toString().trim();
      return url == null || url.isEmpty ? null : url;
    }

    final direct = item['thumbnail']?.toString().trim();
    return nestedUrl('maxres') ??
        (direct == null || direct.isEmpty ? null : direct) ??
        nestedUrl('standard') ??
        nestedUrl('high') ??
        nestedUrl('medium') ??
        nestedUrl('default') ??
        '';
  }

  String? _nextPageToken(Map<String, dynamic> json) {
    final pagination = _map(json['pagination']);
    if (pagination == null) return null;

    final hasNextPage = _boolValue(pagination['hasNextPage']) ?? false;
    if (!hasNextPage) return null;

    final currentPage = _intValue(pagination['page']);
    final totalPages = _intValue(pagination['totalPages']);
    if (currentPage <= 0) return null;
    if (totalPages > 0 && currentPage >= totalPages) return null;

    return '${currentPage + 1}';
  }

  int _pageNumber(String? pageToken) {
    final page = int.tryParse(pageToken?.trim() ?? '');
    return page == null || page < 1 ? 1 : page;
  }

  List<LibraryVideo> _deduplicate(List<LibraryVideo> videos) {
    final seen = <String>{};
    return videos
        .where((video) => seen.add(video.id))
        .toList(growable: true);
  }

  String _videoId(Map<String, dynamic> item) =>
      item['videoId']?.toString().trim() ??
      item['video_id']?.toString().trim() ??
      '';

  int _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}
