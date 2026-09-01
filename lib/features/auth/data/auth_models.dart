import '../../../core/session/user_session.dart';

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceToken,
    required this.deviceType,
  });
  final String email;
  final String password;
  final String deviceToken;
  final int deviceType;

  Map<String, Object?> toJson() => {
        'email': email,
        'password': password,
        'device_token': deviceToken,
        'device_type': deviceType,
      };
}

class LoginResponse {
  const LoginResponse({required this.session});
  final UserSession session;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing login data');
    }
    final student = data['student'];
    if (student is! Map<String, dynamic>) {
      throw const FormatException('Missing student data');
    }
    return LoginResponse(
      session: UserSession(
        studentId: (data['student_id'] as num).toInt(),
        accessToken: data['access_token'] as String,
        firstName: student['first_name']?.toString() ?? '',
        lastName: student['last_name']?.toString() ?? '',
        email: student['email']?.toString() ?? '',
        phone: student['phone']?.toString() ?? '',
        photoUrl: _nullableString(student['photo_url']),
        expiresAt: DateTime.now().add(
          Duration(seconds: (data['expires_in'] as num?)?.toInt() ?? 0),
        ),
      ),
    );
  }


  static String? _nullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
