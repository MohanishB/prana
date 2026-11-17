import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'prakriti_models.dart';

/// The Prakriti (body type) quiz needs a signed-in student: every call sends the
/// token, the saved profile is used and the result is kept on the account.
abstract interface class PrakritiRepository {
  Future<PrakritiQuiz> getQuiz();

  /// The signed-in student's latest result, or null .
  Future<PrakritiResult?> myResult();

  Future<PrakritiResult> submit({
    required int versionId,
    required Map<int, int> answers,
  });
}

final class ApiPrakritiRepository implements PrakritiRepository {
  ApiPrakritiRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  bool get _loggedIn => _sessionManager.current != null;

  @override
  Future<PrakritiQuiz> getQuiz() async {
    final data = await fetchData(
      _api,
      ApiConstants.prakritiQuestions,
      authenticated: true,
    );
    return parseData(() => PrakritiQuiz.fromJson(data));
  }

  @override
  Future<PrakritiResult?> myResult() async {
    if (!_loggedIn) return null;
    final data = await fetchData(
      _api,
      ApiConstants.prakritiMyResult,
      authenticated: true,
    );
    final raw = data['result'];
    if (raw is! Map<String, dynamic>) return null;
    return parseData(() => PrakritiResult.fromJson(raw));
  }

  @override
  Future<PrakritiResult> submit({
    required int versionId,
    required Map<int, int> answers,
  }) async {
    final data = await postData(
      _api,
      ApiConstants.prakritiSubmit,
      authenticated: true,
      body: {
        'version_id': versionId,
        'answers': {
          for (final e in answers.entries) '${e.key}': e.value,
        },
      },
    );
    return parseData(() => PrakritiResult.fromJson(data));
  }
}

/// Keeps the unfinished quiz on the phone only (nothing is sent to the server).
abstract interface class PrakritiProgressStore {
  Future<PrakritiProgress?> read();
  Future<void> save(PrakritiProgress progress);
  Future<void> clear();
}

final class SecurePrakritiProgressStore implements PrakritiProgressStore {
  SecurePrakritiProgressStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'prana_prakriti_progress';

  @override
  Future<PrakritiProgress?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      final answers = <int, int>{};
      final rawAnswers = json['answers'];
      if (rawAnswers is Map) {
        for (final e in rawAnswers.entries) {
          final q = int.tryParse('${e.key}');
          final o = e.value is num ? (e.value as num).toInt() : null;
          if (q != null && o != null) answers[q] = o;
        }
      }
      return PrakritiProgress(
        versionId: (json['version_id'] as num?)?.toInt() ?? 0,
        answers: answers,
        index: (json['index'] as num?)?.toInt() ?? 0,
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(PrakritiProgress progress) async {
    try {
      await _storage.write(
        key: _key,
        value: jsonEncode({
          'version_id': progress.versionId,
          'index': progress.index,
          'answers': {
            for (final e in progress.answers.entries) '${e.key}': e.value,
          },
        }),
      );
    } on Object {
      // Resuming is a convenience; never block the quiz because of it.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } on Object {
      // Nothing to do.
    }
  }
}
