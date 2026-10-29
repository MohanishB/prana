import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_data.dart';

/// The two kinds of video the admin "Video Watch Report" covers.
abstract final class VideoWatchType {
  /// Masterclass chapter video; the reference is the chapter video id.
  static const String chapter = 'chapter';

  /// Gut Reset day video; the reference is the booking item id of that day.
  static const String gutReset = 'gut_reset';
}

/// Tells the server how much of a video the signed-in student watched.
abstract interface class VideoWatchRepository {
  Future<void> report({
    required String videoType,
    required int videoRefId,
    required double positionSeconds,
    required double durationSeconds,
    required int playedSeconds,
  });
}

final class ApiVideoWatchRepository implements VideoWatchRepository {
  ApiVideoWatchRepository(this._api);

  final ApiClient _api;

  @override
  Future<void> report({
    required String videoType,
    required int videoRefId,
    required double positionSeconds,
    required double durationSeconds,
    required int playedSeconds,
  }) async {
    await postData(
      _api,
      ApiConstants.videoProgress,
      authenticated: true,
      body: {
        'video_type': videoType,
        'video_ref_id': videoRefId,
        'position_seconds': positionSeconds,
        'duration_seconds': durationSeconds,
        'played_seconds': playedSeconds,
      },
    );
  }
}
