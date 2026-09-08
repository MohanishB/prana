import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/text/html_plain_text.dart';
import '../domain/library_video.dart';
import 'library_repository.dart';

class YouTubeLibraryRepository implements LibraryRepository {
  YouTubeLibraryRepository({
    HttpClient? httpClient,
    String apiKey = ApiConstants.youtubeApiKey,
    String channelHandle = ApiConstants.youtubeChannelHandle,
  })  : _httpClient = httpClient ?? HttpClient(),
        _apiKey = apiKey,
        _channelHandle = channelHandle;

  static const _youtubeApiBaseUrl =
      'https://www.googleapis.com/youtube/v3';
  static const _pageSize = 20;

  final HttpClient _httpClient;
  final String _apiKey;
  final String _channelHandle;

  String? _channelId;
  String? _uploadsPlaylistId;

  @override
  Future<LibraryPage> getVideos({String? pageToken}) async {
    _ensureConfigured();
    await _ensureChannel();

    final json = await _getJson(
      '/playlistItems',
      {
        'part': 'contentDetails',
        'playlistId': _uploadsPlaylistId!,
        'maxResults': '$_pageSize',
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
        'key': _apiKey,
      },
    );

    final ids = _items(json)
        .map((item) => _map(item['contentDetails']))
        .whereType<Map<String, dynamic>>()
        .map((details) => details['videoId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    final videos = await _loadVideoDetails(ids);
    return LibraryPage(
      videos: videos,
      nextPageToken: json['nextPageToken']?.toString(),
    );
  }

  @override
  Future<LibraryPage> search(
    String query, {
    String? pageToken,
  }) async {
    _ensureConfigured();
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return getVideos(pageToken: pageToken);
    }

    await _ensureChannel();

    final json = await _getJson(
      '/search',
      {
        'part': 'snippet',
        'channelId': _channelId!,
        'q': normalized,
        'type': 'video',
        'order': 'relevance',
        'videoEmbeddable': 'true',
        'maxResults': '$_pageSize',
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
        'key': _apiKey,
      },
    );

    final ids = _items(json)
        .map((item) => _map(item['id']))
        .whereType<Map<String, dynamic>>()
        .map((id) => id['videoId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    final videos = await _loadVideoDetails(ids);
    return LibraryPage(
      videos: videos,
      nextPageToken: json['nextPageToken']?.toString(),
    );
  }

  Future<void> _ensureChannel() async {
    if (_channelId != null && _uploadsPlaylistId != null) return;

    final json = await _getJson(
      '/channels',
      {
        'part': 'contentDetails',
        'forHandle': _channelHandle,
        'key': _apiKey,
      },
    );

    final items = _items(json);
    if (items.isEmpty) {
      throw const AppException(AppErrorType.libraryLoad);
    }

    final channel = items.first;
    final contentDetails = _map(channel['contentDetails']);
    final relatedPlaylists = _map(contentDetails?['relatedPlaylists']);
    final channelId = channel['id']?.toString();
    final uploadsPlaylistId = relatedPlaylists?['uploads']?.toString();

    if (channelId == null ||
        channelId.isEmpty ||
        uploadsPlaylistId == null ||
        uploadsPlaylistId.isEmpty) {
      throw const AppException(AppErrorType.invalidResponse);
    }

    _channelId = channelId;
    _uploadsPlaylistId = uploadsPlaylistId;
  }

  Future<List<LibraryVideo>> _loadVideoDetails(List<String> ids) async {
    if (ids.isEmpty) return const [];

    final json = await _getJson(
      '/videos',
      {
        'part': 'snippet,contentDetails,status',
        'id': ids.join(','),
        'key': _apiKey,
      },
    );

    final byId = <String, LibraryVideo>{};
    for (final item in _items(json)) {
      final id = item['id']?.toString() ?? '';
      final snippet = _map(item['snippet']);
      final contentDetails = _map(item['contentDetails']);
      final status = _map(item['status']);
      if (id.isEmpty || snippet == null || contentDetails == null) continue;
      if (status?['embeddable'] == false) continue;

      final thumbnails = _map(snippet['thumbnails']);
      final high = _map(thumbnails?['high']);
      final medium = _map(thumbnails?['medium']);
      final standard = _map(thumbnails?['standard']);
      final maxres = _map(thumbnails?['maxres']);
      final thumbnailUrl = (maxres?['url'] ??
              standard?['url'] ??
              high?['url'] ??
              medium?['url'])
          ?.toString();

      final publishedAtRaw = snippet['publishedAt']?.toString();
      final tags = (snippet['tags'] as List?)
              ?.map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(growable: false) ??
          const <String>[];

      byId[id] = LibraryVideo(
        id: id,
        youtubeVideoId: id,
        title: htmlToPlainText(snippet['title']?.toString() ?? ''),
        durationLabel: _formatDuration(
          contentDetails['duration']?.toString() ?? '',
        ),
        description:
            htmlToPlainText(snippet['description']?.toString() ?? ''),
        thumbnailUrl: thumbnailUrl ?? '',
        publishedAt: publishedAtRaw == null
            ? null
            : DateTime.tryParse(publishedAtRaw)?.toLocal(),
        tags: tags,
      );
    }

    return ids
        .map((id) => byId[id])
        .whereType<LibraryVideo>()
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(
    String path,
    Map<String, String> query,
  ) async {
    final uri = Uri.parse('$_youtubeApiBaseUrl$path').replace(
      queryParameters: query,
    );

    _logRequest(path, query);

    try {
      final request = await _httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      final response = await request
          .close()
          .timeout(ApiConstants.requestTimeout);
      final raw = await utf8.decoder.bind(response).join();

      _logResponse(path, response.statusCode, raw);

      if (response.statusCode == HttpStatus.forbidden) {
        throw const AppException(AppErrorType.libraryConfiguration);
      }
      if (response.statusCode >= 500) {
        throw const AppException(AppErrorType.server);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppException(AppErrorType.libraryLoad);
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const AppException(AppErrorType.invalidResponse);
      }
      return decoded;
    } on AppException {
      rethrow;
    } on SocketException catch (error, stackTrace) {
      _logTransportError(path, error);
      throw AppException(
        AppErrorType.noInternet,
        cause: error,
        stackTrace: stackTrace,
      );
    } on TimeoutException catch (error, stackTrace) {
      _logTransportError(path, error);
      throw AppException(
        AppErrorType.timeout,
        cause: error,
        stackTrace: stackTrace,
      );
    } on FormatException catch (error, stackTrace) {
      _logTransportError(path, error);
      throw AppException(
        AppErrorType.invalidResponse,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logRequest(String path, Map<String, String> query) {
    if (!kDebugMode) return;

    final safeQuery = Map<String, String>.from(query);
    if (safeQuery.containsKey('key')) {
      safeQuery['key'] = '***';
    }

    debugPrint('[YouTube] REQUEST GET $path');
    debugPrint('[YouTube] query: $safeQuery');
  }

  void _logResponse(String path, int statusCode, String raw) {
    if (!kDebugMode) return;

    debugPrint('[YouTube] RESPONSE GET $path [$statusCode]');

    if (statusCode >= 200 && statusCode < 300) {
      debugPrint('[YouTube] success');
      return;
    }

    final error = _parseYouTubeError(raw);
    if (error.reason != null && error.reason!.isNotEmpty) {
      debugPrint('[YouTube] reason: ${error.reason}');
    }
    if (error.message != null && error.message!.isNotEmpty) {
      debugPrint('[YouTube] message: ${error.message}');
    }

    if ((error.reason == null || error.reason!.isEmpty) &&
        (error.message == null || error.message!.isEmpty)) {
      debugPrint('[YouTube] response body could not be parsed safely');
    }
  }

  void _logTransportError(String path, Object error) {
    if (!kDebugMode) return;
    debugPrint('[YouTube] TRANSPORT ERROR GET $path');
    debugPrint('[YouTube] ${error.runtimeType}: $error');
  }

  _YouTubeError _parseYouTubeError(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const _YouTubeError();

      final error = _map(decoded['error']);
      final message = error?['message']?.toString();
      final errors = error?['errors'];

      String? reason;
      if (errors is List && errors.isNotEmpty) {
        final first = _map(errors.first);
        reason = first?['reason']?.toString();
      }

      return _YouTubeError(
        reason: reason,
        message: message,
      );
    } on FormatException {
      return const _YouTubeError();
    }
  }

  void _ensureConfigured() {
    if (_apiKey.trim().isEmpty) {
      throw const AppException(AppErrorType.libraryConfiguration);
    }
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> json) {
    return (json['items'] as List?)
            ?.map(_map)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  String _formatDuration(String value) {
    final match = RegExp(
      r'^P(?:(\d+)D)?T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$',
    ).firstMatch(value);

    if (match == null) return '';

    final days = int.tryParse(match.group(1) ?? '') ?? 0;
    final hours = int.tryParse(match.group(2) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(3) ?? '') ?? 0;
    final seconds = int.tryParse(match.group(4) ?? '') ?? 0;
    final totalHours = hours + (days * 24);

    if (totalHours > 0) {
      return '$totalHours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _YouTubeError {
  const _YouTubeError({
    this.reason,
    this.message,
  });

  final String? reason;
  final String? message;
}
