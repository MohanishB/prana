import '../models/json_readers.dart';

/// A country for the checkout form (name + phone code).
class Country {
  const Country({required this.id, required this.name, required this.ext});

  final int id;
  final String name;

  /// Phone code as stored, for example "+91" or "91".
  final String ext;

  String get phoneCode => ext.startsWith('+') ? ext : '+$ext';

  /// India: the website asks for a 10 digit mobile number.
  bool get isIndia => phoneCode == '+91';

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: jsonInt(json['country_id']),
        name: jsonString(json['country_name']),
        ext: jsonString(json['country_ext']).trim(),
      );
}
