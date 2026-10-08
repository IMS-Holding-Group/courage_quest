class Validators {
  static bool isUsernameValid(String v) {
    final t = v.trim();
    return t.length >= 7 && t.length <= 11;
  }

  static bool isEmailValid(String v) {
    return v.contains('@') && v.trim().length > 2;
  }

  static bool hasUpper(String v) => v.contains(RegExp(r'[A-Z]'));
  static bool hasLower(String v) => v.contains(RegExp(r'[a-z]'));
  static bool hasDigit(String v) => v.contains(RegExp(r'[0-9]'));

  static bool isPasswordLengthValid(String v) {
    return v.length >= 8 && v.length <= 12;
  }

  static bool isPasswordStrong(String v) {
    return isPasswordLengthValid(v) && hasUpper(v) && hasLower(v) && hasDigit(v);
  }
}
