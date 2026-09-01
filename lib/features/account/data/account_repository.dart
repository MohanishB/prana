import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/session/user_session.dart';
import 'account_models.dart';

abstract interface class AccountRepository {
  Future<AccountProfile> getProfile();
  Future<AccountProfile> updateProfile(UpdateProfileRequest request);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

final class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  @override
  Future<AccountProfile> getProfile() async {
    final json = await _api.get(ApiConstants.accountProfile);
    final profile = _parseProfile(json);
    await _syncSession(profile);
    return profile;
  }

  @override
  Future<AccountProfile> updateProfile(UpdateProfileRequest request) async {
    final photoPath = request.photoPath?.trim();
    final json = await _api.postMultipart(
      ApiConstants.updateProfile,
      fields: request.toFields(),
      files: photoPath == null || photoPath.isEmpty
          ? const {}
          : {'student_photo': File(photoPath)},
    );
    final profile = _parseProfile(json);
    await _syncSession(profile);
    return profile;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.post(
      ApiConstants.changePassword,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  AccountProfile _parseProfile(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing profile data');
    }
    return AccountProfile.fromJson(data);
  }

  Future<void> _syncSession(AccountProfile profile) async {
    final current = _sessionManager.current;
    if (current == null) return;
    await _sessionManager.setSession(
      UserSession(
        studentId: current.studentId,
        accessToken: current.accessToken,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        phone: profile.phone,
        photoUrl: profile.photoUrl,
        expiresAt: current.expiresAt,
      ),
    );
  }
}
