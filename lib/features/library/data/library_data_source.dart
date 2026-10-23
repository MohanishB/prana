import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'backend_library_repository.dart';
import 'library_repository.dart';
import 'youtube_library_repository.dart';

enum LibraryDataSourceMode {
  backend,
  youtubeDirect;

  static LibraryDataSourceMode fromEnvironment(String value) {
    switch (value.trim().toLowerCase()) {
      case 'youtube':
      case 'youtube_direct':
      case 'mobile':
      case 'client':
        return LibraryDataSourceMode.youtubeDirect;
      case 'backend':
      case 'api':
      default:
        return LibraryDataSourceMode.backend;
    }
  }
}

LibraryRepository createLibraryRepository(ApiClient api) {
  final mode = LibraryDataSourceMode.fromEnvironment(
    ApiConstants.libraryDataSource,
  );

  return switch (mode) {
    LibraryDataSourceMode.backend => BackendLibraryRepository(api),
    LibraryDataSourceMode.youtubeDirect => YouTubeLibraryRepository(),
  };
}
