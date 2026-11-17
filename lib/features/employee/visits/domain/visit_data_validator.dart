/// Client-side mirror of the backend's MarketerVisitValidator rules, so the
/// marketer sees the problem before the request is sent. The backend enforces
/// the same rules regardless.
class VisitDataValidator {
  VisitDataValidator._();

  static String digitsOnly(String? value) => (value ?? '').replaceAll(RegExp(r'\D'), '');

  /// True for repeated (0000000000) or sequential (1234567890, 9876543210) runs.
  static bool isFakeSequence(String digits) {
    if (digits.isEmpty) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return true;
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      final prev = int.parse(digits[i - 1]);
      final cur = int.parse(digits[i]);
      if (cur != (prev + 1) % 10) ascending = false;
      if (cur != (prev + 9) % 10) descending = false;
    }
    return ascending || descending;
  }

  /// Normalizes to 05XXXXXXXX, or returns null when not a valid Saudi mobile.
  static String? normalizeSaudiMobile(String? raw) {
    String digits = digitsOnly(raw);
    if (digits.startsWith('00966')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('966')) {
      digits = digits.substring(3);
    }
    if (digits.length == 9 && digits.startsWith('5')) digits = '0$digits';
    if (!RegExp(r'^05\d{8}$').hasMatch(digits)) return null;
    if (isFakeSequence(digits.substring(2))) return null;
    return digits;
  }

  static bool isValidSaudiMobile(String? raw) => normalizeSaudiMobile(raw) != null;
}
