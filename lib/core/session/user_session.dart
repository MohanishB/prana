class UserSession {
  const UserSession({
    required this.studentId,
    required this.accessToken,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.expiresAt,
    this.photoUrl,
  });

  final int studentId;
  final String accessToken;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime expiresAt;

  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  bool get isWithinRefreshWindow =>
      DateTime.now().isBefore(expiresAt.add(const Duration(days: 7)));

  String get fullName => '$firstName $lastName'.trim();


  UserSession copyWith({
    int? studentId,
    String? accessToken,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? expiresAt,
  }) {
    return UserSession(
      studentId: studentId ?? this.studentId,
      accessToken: accessToken ?? this.accessToken,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, String> toMap() => {
        'student_id': '$studentId',
        'access_token': accessToken,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'photo_url': photoUrl ?? '',
        'expires_at': expiresAt.toUtc().toIso8601String(),
      };

  factory UserSession.fromMap(Map<String, String> map) => UserSession(
        studentId: int.parse(map['student_id']!),
        accessToken: map['access_token']!,
        firstName: map['first_name'] ?? '',
        lastName: map['last_name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        photoUrl: _nullableString(map['photo_url']),
        expiresAt: DateTime.parse(map['expires_at']!).toLocal(),
      );

  static String? _nullableString(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
