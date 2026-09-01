abstract final class AppValidators {
  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );
  static final RegExp _profileText = RegExp(r'^[A-Za-z0-9 ]+$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidPassword(String value) => value.isNotEmpty;

  static bool isValidNewPassword(String value) => value.length >= 6;

  static bool isValidProfileText(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && _profileText.hasMatch(trimmed);
  }

  static bool isValidOptionalProfileText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty || _profileText.hasMatch(trimmed);
  }
}
