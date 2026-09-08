import '../domain/library_video.dart';

abstract interface class LibraryRepository {
  Future<LibraryPage> getVideos({String? pageToken});

  Future<LibraryPage> search(
    String query, {
    String? pageToken,
  });
}
