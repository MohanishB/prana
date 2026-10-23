import 'package:equatable/equatable.dart';

class LibraryVideo extends Equatable {
  const LibraryVideo({
    required this.id,
    required this.title,
    required this.youtubeVideoId,
    required this.durationLabel,
    required this.description,
    required this.thumbnailUrl,
    required this.publishedAt,
    this.tags = const [],
    this.isShortOverride,
  });

  final String id;
  final String title;
  final String youtubeVideoId;
  final String durationLabel;
  final String description;
  final String thumbnailUrl;
  final DateTime? publishedAt;
  final List<String> tags;
  final bool? isShortOverride;

  bool get isShortForm {
    // A backend `true` is authoritative, but `false` must not disable our
    // presentation heuristic. Some regular YouTube uploads are still portrait
    // videos and should keep the same Reels-style layout used by the direct
    // YouTube implementation.
    if (isShortOverride == true) return true;

    final normalizedTags = tags.map((tag) => tag.toLowerCase());
    if (normalizedTags.any(
      (tag) => tag == 'shorts' || tag == 'short' || tag.contains('#shorts'),
    )) {
      return true;
    }

    final parts = durationLabel.split(':');
    if (parts.length != 2) return false;

    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null || seconds == null) return false;

    return (minutes * 60) + seconds <= 180;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        youtubeVideoId,
        durationLabel,
        description,
        thumbnailUrl,
        publishedAt,
        tags,
        isShortOverride,
      ];
}

class LibraryPage extends Equatable {
  const LibraryPage({
    required this.videos,
    this.nextPageToken,
  });

  final List<LibraryVideo> videos;
  final String? nextPageToken;

  @override
  List<Object?> get props => [videos, nextPageToken];
}

class LibraryPlaybackArgs extends Equatable {
  const LibraryPlaybackArgs({
    required this.videos,
    required this.initialIndex,
    required this.query,
    this.nextPageToken,
  });

  final List<LibraryVideo> videos;
  final int initialIndex;
  final String query;
  final String? nextPageToken;

  LibraryVideo get selected => videos[initialIndex];

  @override
  List<Object?> get props => [
        videos,
        initialIndex,
        query,
        nextPageToken,
      ];
}
