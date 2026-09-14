import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/pos/helper/pos_checkout_token_storage.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// Deep Link & Deferred Installation Service for POS Customer Checkouts.
class PosCheckoutDeepLinkService {
  PosCheckoutDeepLinkService._();

  static const String _posCheckoutReferralType = 'pos_checkout';
  static const String _referralTypeKey = 'referral_type';
  static const String _posTokenKey = 'pos_token';

  static AppLinks? _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;

  /// Initialize Deep Link listener for both foreground & cold starts
  static Future<void> init(SharedPreferences prefs) async {
    if (kIsWeb) return;

    try {
      _appLinks = AppLinks();

      // 1. Handle Cold Start (App launched via deep link)
      final Uri? initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 [POS_DEEP_LINK_COLD_START] uri=$initialUri');
        _handleIncomingUri(initialUri, prefs);
      }

      // 2. Handle Foreground / Background URI Stream
      _linkSubscription?.cancel();
      _linkSubscription = _appLinks!.uriLinkStream.listen(
        (Uri uri) {
          debugPrint('🔗 [POS_DEEP_LINK_STREAM] uri=$uri');
          _handleIncomingUri(uri, prefs);
        },
        onError: (err) {
          debugPrint('❌ [POS_DEEP_LINK_STREAM_ERROR] $err');
        },
      );
    } catch (e) {
      debugPrint('❌ [POS_DEEP_LINK_INIT_ERROR] $e');
    }
  }

  static void _handleIncomingUri(Uri uri, SharedPreferences prefs) {
    final String? token = extractTokenFromUri(uri);
    if (token != null && token.isNotEmpty) {
      final storage = PosCheckoutTokenStorage(prefs);
      storage.saveToken(token);
      handleCheckoutTokenNavigation(token);
    }
  }

  /// Check Android Play Install Referrer for deferred pos_token
  static Future<String?> captureFromInstallReferrer(
      SharedPreferences prefs) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      final ReferrerDetails referrerDetails =
          await PlayInstallReferrer.installReferrer;
      final String rawReferrer = referrerDetails.installReferrer?.trim() ?? '';
      if (rawReferrer.isEmpty) return null;

      final Map<String, String> parsed = _parseReferrerPayload(rawReferrer);
      final String refType = parsed[_referralTypeKey]?.trim() ?? '';
      final String token = parsed[_posTokenKey]?.trim() ?? '';

      if (refType == _posCheckoutReferralType && token.isNotEmpty) {
        final storage = PosCheckoutTokenStorage(prefs);
        await storage.saveToken(token);
        debugPrint('[POS_DEEP_LINK_REFERRER_CAPTURED] token=$token');
        return token;
      }
    } catch (e) {
      debugPrint('[POS_DEEP_LINK_REFERRER_ERROR] $e');
    }
    return null;
  }

  /// Check iOS Clipboard fallback on first launch
  static Future<String?> captureFromClipboard(SharedPreferences prefs) async {
    if (kIsWeb || !Platform.isIOS) return null;

    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String text = data?.text?.trim() ?? '';
      if (text.startsWith('pos_token:')) {
        final String token = text.substring('pos_token:'.length).trim();
        if (token.isNotEmpty) {
          final storage = PosCheckoutTokenStorage(prefs);
          await storage.saveToken(token);
          // Clear clipboard so it doesn't trigger again
          await Clipboard.setData(const ClipboardData(text: ''));
          debugPrint('[POS_DEEP_LINK_CLIPBOARD_CAPTURED] token=$token');
          return token;
        }
      }
    } catch (e) {
      debugPrint('[POS_DEEP_LINK_CLIPBOARD_ERROR] $e');
    }
    return null;
  }

  /// Parse URI and extract checkout token if matching POS pattern
  static String? extractTokenFromUri(Uri uri) {
    // 1. Path: /pos/checkout/{token}
    final segments = uri.pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'pos' &&
        segments[1] == 'checkout') {
      return segments[2].trim();
    }

    // 2. Custom Scheme: shella://pos/checkout/{token} or shella://pos/checkout?token=...
    if (uri.host == 'pos' && segments.isNotEmpty && segments[0] == 'checkout') {
      if (segments.length >= 2) {
        return segments[1].trim();
      }
    }

    // 3. Custom Scheme: shella://checkout/{token}
    if (uri.scheme == 'shella' && segments.isNotEmpty) {
      if (segments[0] == 'checkout' && segments.length >= 2) {
        return segments[1].trim();
      }
      if (segments[0] == 'pos' &&
          segments.length >= 3 &&
          segments[1] == 'checkout') {
        return segments[2].trim();
      }
    }

    // 4. Query Parameter: ?pos_token={token} or ?checkout_token={token} or ?token={token}
    final qToken = uri.queryParameters['pos_token'] ??
        uri.queryParameters['checkout_token'] ??
        uri.queryParameters['token'];
    if (qToken != null && qToken.trim().isNotEmpty) {
      return qToken.trim();
    }

    return null;
  }

  /// Route user to POS checkout screen
  static void handleCheckoutTokenNavigation(String token) {
    if (token.trim().isEmpty) return;
    debugPrint('[POS_DEEP_LINK_NAVIGATING] token=$token');

    // Defer slightly until GetX routing engine is ready if called early
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(RouteHelper.getPosCheckoutRoute(token.trim()));
    });
  }

  static Map<String, String> _parseReferrerPayload(String rawReferrer) {
    try {
      final String normalized =
          rawReferrer.startsWith('?') ? rawReferrer.substring(1) : rawReferrer;
      return Uri.splitQueryString(normalized);
    } catch (_) {
      return <String, String>{};
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
