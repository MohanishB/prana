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

/// The sign-up form. Optional fields are sent empty and the server fills defaults.
class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.countryId,
    required this.city,
    required this.pincode,
    required this.phone,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String lastName;

  /// "MALE", "FEMALE" or empty.
  final String gender;

  /// YYYY-MM-DD or empty.
  final String dob;
  final int countryId;
  final String city;
  final String pincode;
  final String phone;
  final String email;
  final String password;

  Map<String, Object?> toJson({
    required String deviceToken,
    required int deviceType,
  }) =>
      {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'gender': gender,
        'dob': dob,
        'country_id': countryId,
        'city_name': city.trim(),
        'pincode': pincode.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
        'device_token': deviceToken,
        'device_type': deviceType,
      };
}
