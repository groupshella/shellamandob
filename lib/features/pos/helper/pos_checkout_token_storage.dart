import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Persists the pending POS customer checkout token across app lifecycle and auth flows.
class PosCheckoutTokenStorage {
  final SharedPreferences _sharedPreferences;

  PosCheckoutTokenStorage(this._sharedPreferences);

  String? getStoredToken() {
    final String? token = _sharedPreferences.getString(AppConstants.pendingPosCheckoutToken);
    if (token == null || token.trim().isEmpty) {
      return null;
    }
    return token.trim();
  }

  String? getToken() => getStoredToken();

  bool hasStoredToken() => getStoredToken() != null;

  Future<bool> saveToken(String token) async {
    final String trimmed = token.trim();
    if (trimmed.isEmpty) return false;
    final bool saved = await _sharedPreferences.setString(
      AppConstants.pendingPosCheckoutToken,
      trimmed,
    );
    if (saved && kDebugMode) {
      debugPrint('[POS_CHECKOUT_TOKEN_STORED] token=$trimmed');
    }
    return saved;
  }

  Future<bool> clearToken() async {
    final bool hadToken = hasStoredToken();
    final bool cleared = await _sharedPreferences.remove(AppConstants.pendingPosCheckoutToken);
    if (cleared && hadToken && kDebugMode) {
      debugPrint('[POS_CHECKOUT_TOKEN_CLEARED]');
    }
    return cleared;
  }
}
