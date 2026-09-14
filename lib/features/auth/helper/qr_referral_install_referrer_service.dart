import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/auth/helper/qr_referral_token_storage.dart';

/// Reads Android Play Install Referrer and stores customer store-QR referral tokens and pending gift campaigns.
class QrReferralInstallReferrerService {
  QrReferralInstallReferrerService._();

  static const List<String> _validCustomerReferralTypes = [
    'customer',
    'customer_invite',
    'gift_campaign',
    'customer_referral',
    'invite',
  ];
  static const String _referralTypeKey = 'referral_type';
  static const String _referralTokenKey = 'referral_token';
  static const String _refKey = 'ref';
  static const String _storeIdKey = 'store_id';
  static const String pendingGiftStoreIdKey = 'pending_gift_store_id';

  static Future<void> captureFromInstallReferrer(
    SharedPreferences sharedPreferences,
  ) async {
    if (!(!kIsWeb && Platform.isAndroid)) {
      return;
    }
    debugPrint('[QR_REFERRAL_INSTALL_REFERRER_INIT]');
    final QrReferralTokenStorage storage =
        QrReferralTokenStorage(sharedPreferences);
    try {
      final ReferrerDetails referrerDetails =
          await PlayInstallReferrer.installReferrer;
      final String rawReferrer = referrerDetails.installReferrer?.trim() ?? '';
      debugPrint('[QR_REFERRAL_INSTALL_REFERRER_RAW] payload=$rawReferrer');
      if (rawReferrer.isEmpty) {
        _logIgnored('empty_referrer_payload');
        return;
      }
      final Map<String, String> parsed = _parseReferrerPayload(rawReferrer);
      final String referralType = parsed[_referralTypeKey]?.trim() ?? '';
      final String referralToken = (parsed[_referralTokenKey] ?? parsed[_refKey] ?? '').trim();
      final String storeIdStr = parsed[_storeIdKey]?.trim() ?? '';

      debugPrint(
        '[QR_REFERRAL_INSTALL_REFERRER_PARSED] '
        'referral_type=$referralType '
        'token=$referralToken '
        'store_id=$storeIdStr',
      );

      // Handle store_id for First Order Gift campaign navigation
      if (storeIdStr.isNotEmpty) {
        final int? storeId = int.tryParse(storeIdStr);
        if (storeId != null && storeId > 0) {
          await sharedPreferences.setInt(pendingGiftStoreIdKey, storeId);
          debugPrint('🎁 [GIFT_REFERRER_STORE_SAVED] store_id=$storeId');
        }
      }

      if (referralType.isNotEmpty && !_validCustomerReferralTypes.contains(referralType)) {
        _logIgnored('referral_type_not_customer type=$referralType');
        return;
      }

      if (referralToken.isNotEmpty) {
        if (!storage.hasStoredToken()) {
          await storage.saveToken(referralToken);
          debugPrint('✅ [QR_REFERRAL_TOKEN_SAVED] token=$referralToken');
        }
      }
    } catch (error) {
      _logIgnored('referrer_unavailable error=$error');
    }
  }

  static Map<String, String> _parseReferrerPayload(String rawReferrer) {
    try {
      final String normalized = rawReferrer.startsWith('?')
          ? rawReferrer.substring(1)
          : rawReferrer;
      return Uri.splitQueryString(normalized);
    } catch (_) {
      return <String, String>{};
    }
  }

  static void _logIgnored(String reason) {
    debugPrint('[QR_REFERRAL_INSTALL_REFERRER_IGNORED] reason=$reason');
  }
}
