import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'live_session_models.dart';

/// The live sessions still to come (or running), oldest start first.
abstract interface class LiveSessionRepository {
  Future<LiveSessionsData> getUpcomingSessions();
}

final class ApiLiveSessionRepository implements LiveSessionRepository {
  ApiLiveSessionRepository(this._api);

  final ApiClient _api;

  @override
  Future<LiveSessionsData> getUpcomingSessions() async {
    try {
      final response = await _api.get(ApiConstants.liveSessions);
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return LiveSessionsData(
        sessions: jsonList(data['sessions'], LiveSession.fromJson)
            .where((s) => s.buttonUrl.isNotEmpty)
            .toList(growable: false),
        serverTime: DateTime.tryParse(jsonString(data['server_time'])),
      );
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }
}
