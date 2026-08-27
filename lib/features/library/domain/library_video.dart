import 'package:equatable/equatable.dart';

class LibraryVideo extends Equatable {
  const LibraryVideo({
    required this.id,
    required this.title,
    required this.youtubeVideoId,
    required this.durationLabel,
    required this.transcript,
    required this.tags,
  });

  final String id;
  final String title;
  final String youtubeVideoId;
  final String durationLabel;
  final String transcript;
  final List<String> tags;

  @override
  List<Object> get props => [
        id,
        title,
        youtubeVideoId,
        durationLabel,
        transcript,
        tags,
      ];
}
