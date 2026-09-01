class AccountCountry {
  const AccountCountry({
    required this.id,
    required this.name,
    required this.phoneExtension,
  });

  final int id;
  final String name;
  final String phoneExtension;

  factory AccountCountry.fromJson(Map<String, dynamic> json) => AccountCountry(
        id: (json['country_id'] as num).toInt(),
        name: json['country_name']?.toString() ?? '',
        phoneExtension: json['country_ext']?.toString() ?? '',
      );
}

class AccountProfile {
  const AccountProfile({
    required this.studentId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.countryId,
    required this.countryName,
    required this.cityName,
    required this.pincode,
    required this.phoneExtension,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.memberSince,
    required this.countries,
  });

  final int studentId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String dob;
  final int countryId;
  final String countryName;
  final String cityName;
  final String pincode;
  final String phoneExtension;
  final String phone;
  final String email;
  final String? photoUrl;
  final String memberSince;
  final List<AccountCountry> countries;

  String get fullName => [
        firstName,
        middleName,
        lastName,
      ].where((part) => part.trim().isNotEmpty).join(' ');

  String get formattedPhone => '$phoneExtension $phone'.trim();

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final countriesJson = json['countries'];
    return AccountProfile(
      studentId: (json['student_id'] as num).toInt(),
      firstName: json['first_name']?.toString() ?? '',
      middleName: json['middle_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      countryId: (json['country_id'] as num?)?.toInt() ?? 0,
      countryName: json['country_name']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      phoneExtension: json['phone_ext']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      photoUrl: _nullableString(json['photo_url']),
      memberSince: json['member_since']?.toString() ?? '',
      countries: countriesJson is List
          ? countriesJson
              .whereType<Map<String, dynamic>>()
              .map(AccountCountry.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.countryId,
    required this.cityName,
    required this.pincode,
    this.photoPath,
  });

  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String dob;
  final int countryId;
  final String cityName;
  final String pincode;
  final String? photoPath;

  Map<String, String> toFields() => {
        'first_name': firstName.trim(),
        'middle_name': middleName.trim(),
        'last_name': lastName.trim(),
        'gender': gender,
        'dob': dob,
        'country_id': '$countryId',
        'city_name': cityName.trim(),
        'pincode': pincode.trim(),
      };
}
