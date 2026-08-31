abstract final class AppValidators {
  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidPassword(String value) => value.isNotEmpty;
}
