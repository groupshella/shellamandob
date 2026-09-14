import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/auth/helper/qr_referral_install_referrer_service.dart';
import 'package:sixam_mart/features/auth/helper/qr_referral_token_storage.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// Deep Link & Deferred Installation Service for Customer First-Order Gift Campaigns.
class GiftCampaignDeepLinkService {
  GiftCampaignDeepLinkService._();

  static AppLinks? _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;

  /// Initialize Deep Link listener for both cold start & runtime stream
  static Future<void> init(SharedPreferences prefs) async {
    if (kIsWeb) return;

    try {
      _appLinks = AppLinks();

      // 1. Handle Cold Start (App opened via deep link)
      final Uri? initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        debugPrint('🎁 [GIFT_DEEP_LINK_COLD_START] uri=$initialUri');
        _handleIncomingUri(initialUri, prefs);
      }

      // 2. Handle Runtime URI Stream (Foreground / Background)
      _linkSubscription?.cancel();
      _linkSubscription = _appLinks!.uriLinkStream.listen(
        (Uri uri) {
          debugPrint('🎁 [GIFT_DEEP_LINK_STREAM] uri=$uri');
          _handleIncomingUri(uri, prefs);
        },
        onError: (err) {
          debugPrint('❌ [GIFT_DEEP_LINK_STREAM_ERROR] $err');
        },
      );
    } catch (e) {
      debugPrint('❌ [GIFT_DEEP_LINK_INIT_ERROR] $e');
    }
  }

  static void _handleIncomingUri(Uri uri, SharedPreferences prefs) {
    final Map<String, dynamic>? parsed = extractGiftParamsFromUri(uri);
    if (parsed == null) return;

    final int? storeId = parsed['store_id'];
    final String? ref = parsed['ref'];

    if (ref != null && ref.isNotEmpty) {
      final storage = QrReferralTokenStorage(prefs);
      storage.saveToken(ref);
      debugPrint('🎁 [GIFT_DEEP_LINK_REF_SAVED] ref=$ref');
    }

    if (storeId != null && storeId > 0) {
      prefs.setInt(QrReferralInstallReferrerService.pendingGiftStoreIdKey, storeId);
      debugPrint('🎁 [GIFT_DEEP_LINK_STORE_SAVED] store_id=$storeId');
      navigateToGiftCampaign(storeId);
    }
  }

  /// Parse URI and extract store_id / ref if matching Gift / Invite patterns
  static Map<String, dynamic>? extractGiftParamsFromUri(Uri uri) {
    final String uriStr = uri.toString().toLowerCase();
    final String host = uri.host.toLowerCase();
    final List<String> segments = uri.pathSegments;

    bool isGiftOrInvite = false;

    // Pattern 1: shella://invite/customer or shala://invite/customer
    if (uri.scheme == 'shella' || uri.scheme == 'shala') {
      if (host == 'invite' || host == 'campaign' || host == 'join' || host == 'gift') {
        isGiftOrInvite = true;
      }
      if (segments.isNotEmpty &&
          (segments[0] == 'invite' ||
              segments[0] == 'join' ||
              segments[0] == 'campaign' ||
              segments[0] == 'first-order-gift')) {
        isGiftOrInvite = true;
      }
    }

    // Pattern 2: https://shella.sa/join/customer or /invite/customer or /referral or /first-order-gift
    if (segments.isNotEmpty &&
        (segments.contains('join') ||
            segments.contains('invite') ||
            segments.contains('referral') ||
            segments.contains('first-order-gift') ||
            segments.contains('campaign') ||
            segments.contains('gift'))) {
      isGiftOrInvite = true;
    }

    if (!isGiftOrInvite && !uriStr.contains('ref=') && !uriStr.contains('store_id=')) {
      return null;
    }

    // Extract query parameters
    final String? rawStoreId = uri.queryParameters['store_id'];
    int? storeId = rawStoreId != null ? int.tryParse(rawStoreId) : null;
    String? ref = uri.queryParameters['ref'] ?? uri.queryParameters['referral_token'];

    // If ref format is like V48S9231 or S9231, parse store_id from ref if missing
    if (ref != null && storeId == null) {
      if (RegExp(r'S(\d+)', caseSensitive: false).hasMatch(ref)) {
        final match = RegExp(r'S(\d+)', caseSensitive: false).firstMatch(ref);
        if (match != null) {
          storeId = int.tryParse(match.group(1)!);
        }
      }
    }

    return {
      'store_id': storeId,
      'ref': ref,
    };
  }

  /// Check iOS Clipboard fallback on first launch
  static Future<void> captureFromClipboard(SharedPreferences prefs) async {
    if (kIsWeb || !Platform.isIOS) return;

    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String text = data?.text?.trim() ?? '';
      if (text.startsWith('gift_ref:') || text.startsWith('customer_invite:')) {
        final String payload = text.split(':').last.trim();
        final uri = Uri.tryParse('shella://invite/customer?$payload');
        if (uri != null) {
          _handleIncomingUri(uri, prefs);
        }
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (e) {
      debugPrint('[GIFT_CLIPBOARD_ERROR] $e');
    }
  }

  /// Execute navigation to the first order gift campaign screen
  static void navigateToGiftCampaign(int storeId) {
    if (storeId <= 0) return;
    debugPrint('🚀 [NAVIGATING_TO_GIFT_CAMPAIGN] store_id=$storeId');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(RouteHelper.getFirstOrderGiftRoute(storeId: storeId));
    });
  }

  /// Consume and handle pending gift campaign navigation after splash or login
  static bool handlePendingGiftNavigation() {
    if (!Get.isRegistered<SharedPreferences>()) return false;
    final SharedPreferences prefs = Get.find<SharedPreferences>();
    final int? pendingStoreId =
        prefs.getInt(QrReferralInstallReferrerService.pendingGiftStoreIdKey);

    if (pendingStoreId != null && pendingStoreId > 0) {
      prefs.remove(QrReferralInstallReferrerService.pendingGiftStoreIdKey);
      debugPrint('🎁 [CONSUMED_PENDING_GIFT_STORE] store_id=$pendingStoreId');
      navigateToGiftCampaign(pendingStoreId);
      return true;
    }
    return false;
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
