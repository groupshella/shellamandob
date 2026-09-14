import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

/// Helpers for deciding whether text should be shown based on its language.
///
/// Used to hide untranslated English product descriptions in the Arabic UI:
/// any English (or English-dominant) description is hidden rather than shown to
/// Arabic users.
class TextLanguageHelper {
  static bool isArabicLocale() {
    try {
      return Get.find<LocalizationController>().locale.languageCode == 'ar';
    } catch (_) {
      return false;
    }
  }

  /// True when the text is English or English-dominant (more Latin letters than
  /// Arabic). A mostly-Arabic string with a few English words/brand names is NOT
  /// flagged.
  static bool isPredominantlyEnglish(String text) {
    final int arabic = RegExp('[؀-ۿ]').allMatches(text).length;
    final int latin = RegExp(r'[A-Za-z]').allMatches(text).length;
    if (latin == 0) return false;
    return arabic == 0 || latin > arabic;
  }

  /// Whether a product description should be shown: hidden only when the app is
  /// in Arabic AND the description is English-dominant.
  static bool shouldShowDescription(String? description) {
    if (description == null || description.trim().isEmpty) return false;
    if (isArabicLocale() && isPredominantlyEnglish(description)) return false;
    return true;
  }
}
