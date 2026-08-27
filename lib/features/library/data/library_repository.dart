import '../domain/library_video.dart';

abstract interface class LibraryRepository {
  Future<List<LibraryVideo>> getVideos();
  Future<List<LibraryVideo>> search(String query);
}
