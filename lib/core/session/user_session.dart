class UserSession {
  const UserSession({
    required this.studentId,
    required this.accessToken,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.expiresAt,
  });

  final int studentId;
  final String accessToken;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime expiresAt;

  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  String get fullName => '$firstName $lastName'.trim();

  Map<String, String> toMap() => {
        'student_id': '$studentId',
        'access_token': accessToken,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'expires_at': expiresAt.toUtc().toIso8601String(),
      };

  factory UserSession.fromMap(Map<String, String> map) => UserSession(
        studentId: int.parse(map['student_id']!),
        accessToken: map['access_token']!,
        firstName: map['first_name'] ?? '',
        lastName: map['last_name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        expiresAt: DateTime.parse(map['expires_at']!).toLocal(),
      );
}
