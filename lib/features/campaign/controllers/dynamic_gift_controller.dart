import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/campaign/domain/models/dynamic_gift_campaign_model.dart';

class DynamicGiftController extends GetxController implements GetxService {
  final ApiClient apiClient;
  DynamicGiftController({required this.apiClient});

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  DynamicGiftCampaignModel? _giftCampaign;
  DynamicGiftCampaignModel? get giftCampaign => _giftCampaign;

  SelectableGiftItem? _selectedItem;
  SelectableGiftItem? get selectedItem => _selectedItem;

  String? _qrToken;
  String? get qrToken => _qrToken;

  String? _nonce;
  String? get nonce => _nonce;

  bool _isRedeemed = false;
  bool get isRedeemed => _isRedeemed;

  Map<String, dynamic>? _redemptionData;
  Map<String, dynamic>? get redemptionData => _redemptionData;

  Timer? _statusCheckTimer;
  Timer? _countdownTimer;

  // View state management (0: Store View, 1: Cart View, 2: QR Claim View, 3: Success View)
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Store Tab selection: 0 = المنتجات المجانية, 1 = كل المنتجات
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  // Quantities for items in store / cart
  final Map<int, int> _itemQuantities = {};
  Map<int, int> get itemQuantities => _itemQuantities;

  // Countdown timer for QR code screen (Figma: 00 : 29 : 24)
  int _remainingSeconds = 1764; // 29 mins 24 secs
  int get remainingSeconds => _remainingSeconds;

  String _qrOrderNumber = 'SH-500741';
  String get qrOrderNumber => _qrOrderNumber;

  String _qrClaimCode = '66587';
  String get qrClaimCode => _qrClaimCode;

  void setStep(int step) {
    _currentStep = step;
    if (step == 2 && _countdownTimer == null) {
      startCountdownTimer();
    }
    update();
  }

  void setSelectedTab(int index) {
    _selectedTab = index;
    update();
  }

  void selectItem(SelectableGiftItem item) {
    final id = item.campaignItemId ?? item.itemId ?? 0;
    _selectedItem = item;
    _itemQuantities.clear();
    _itemQuantities[id] = 1;
    update();
  }

  void toggleItemSelection(SelectableGiftItem item) {
    final id = item.campaignItemId ?? item.itemId ?? 0;
    final currentSelectedId = _selectedItem?.campaignItemId ?? _selectedItem?.itemId;
    if (currentSelectedId != null && currentSelectedId == id) {
      _itemQuantities.clear();
      _selectedItem = null;
    } else {
      _selectedItem = item;
      _itemQuantities.clear();
      _itemQuantities[id] = 1;
    }
    update();
  }

  int getItemQuantity(int id) {
    final currentSelectedId = _selectedItem?.campaignItemId ?? _selectedItem?.itemId;
    if (currentSelectedId != null && currentSelectedId == id) {
      return 1;
    }
    return 0;
  }

  int get totalGiftQuantity => _selectedItem != null ? 1 : 0;

  void incrementQuantity(int id, [SelectableGiftItem? item]) {
    _itemQuantities.clear();
    _itemQuantities[id] = 1;
    if (item != null) {
      _selectedItem = item;
    }
    update();
  }

  void decrementQuantity(int id) {
    _itemQuantities.clear();
    _selectedItem = null;
    update();
  }

  void clearCart() {
    _itemQuantities.clear();
    _selectedItem = null;
    update();
  }

  String get formattedTimer {
    final hours = (_remainingSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$hours : $minutes : $seconds';
  }

  void startCountdownTimer() {
    _countdownTimer?.cancel();
    _remainingSeconds = 1764; // 00 : 29 : 24
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        update();
      } else {
        timer.cancel();
      }
    });
  }

  /// Call this synchronously in initState to reset state before the first build.
  void resetForNewFetch() {
    _isLoading = true;
    _isRedeemed = false;
    _qrToken = null;
    _nonce = null;
    _giftCampaign = null;
    _currentStep = 0;
    _selectedTab = 0;
    _itemQuantities.clear();
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<void> fetchFirstOrderGift({int? storeId}) async {
    _isLoading = true;

    try {
      String uri = '/api/v1/customer/campaigns/first-order-gift';
      if (storeId != null) {
        uri += '?store_id=$storeId';
      }

      Response response = await apiClient.getData(uri);
      debugPrint('[GIFT_DEBUG] uri=$uri statusCode=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200 && response.body != null) {
        _giftCampaign = DynamicGiftCampaignModel.fromJson(response.body);
        _selectedItem = null;
        _itemQuantities.clear();
      }
    } catch (e) {
      debugPrint('Error fetching gift campaign: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  // Stores that offer the first-order gift — used by the manual "اختر المتجر"
  // path for customers whose camera can't scan the branch QR code.
  List<Map<String, dynamic>> _giftStores = [];
  List<Map<String, dynamic>> get giftStores => _giftStores;

  bool _isLoadingStores = false;
  bool get isLoadingStores => _isLoadingStores;

  // Last gift-claim rejection message (e.g. geofence "not at store").
  String? _giftError;
  String? get giftError => _giftError;

  Future<List<Map<String, dynamic>>> fetchGiftStores() async {
    _isLoadingStores = true;
    update();
    try {
      // useEtag: false → always fetch fresh; this list changes as merchants
      // add/remove free products and a 304 would keep a stale (e.g. empty) list.
      final Response response = await apiClient.getData(
        '/api/v1/customer/campaigns/first-order-gift/stores',
        useEtag: false,
      );
      if (response.statusCode == 200 && response.body?['data'] is List) {
        _giftStores = List<Map<String, dynamic>>.from(
          (response.body['data'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
    } catch (e) {
      debugPrint('Error fetching gift stores: $e');
    }
    _isLoadingStores = false;
    update();
    return _giftStores;
  }

  Future<bool> generateGiftQr({int? storeId}) async {
    // One-time gift: once it has been handed over this session, never issue
    // another claim — blocks the "browse offers → claim again" loophole.
    if (_isRedeemed) {
      _giftError = 'لقد استفدت من هذا العرض مسبقاً';
      showCustomSnackBar(_giftError!);
      return false;
    }
    if (_giftCampaign?.campaign?.id != null && _selectedItem?.campaignItemId != null) {
      _isLoading = true;
      update();

      try {
        // 📍 Capture the customer's real GPS position so the backend can verify
        // they are physically at the store (anti-fraud geofence) before issuing
        // the claim code.
        double? lat, lng;
        try {
          LocationPermission perm = await Geolocator.checkPermission();
          if (perm == LocationPermission.denied) {
            perm = await Geolocator.requestPermission();
          }
          if (perm == LocationPermission.whileInUse ||
              perm == LocationPermission.always) {
            final Position pos = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high),
            ).timeout(const Duration(seconds: 12));
            lat = pos.latitude;
            lng = pos.longitude;
          }
        } catch (e) {
          debugPrint('Gift claim location error: $e');
        }

        Response response = await apiClient.postData(
          '/api/v1/customer/campaigns/generate-gift-qr',
          {
            'campaign_id': _giftCampaign!.campaign!.id,
            'campaign_item_id': _selectedItem!.campaignItemId,
            'store_id': storeId,
            if (lat != null) 'latitude': lat,
            if (lng != null) 'longitude': lng,
          },
        );

        if (response.statusCode == 200 && response.body['success'] == true) {
          _qrToken = response.body['qr_token'];
          _nonce = response.body['nonce'];
          if (response.body['order_number'] != null) {
            _qrOrderNumber = response.body['order_number'].toString();
          }
          if (response.body['claim_code'] != null) {
            _qrClaimCode = response.body['claim_code'].toString();
          }
          _isRedeemed = false;
          _giftError = null;
          startPollingRedemptionStatus();
          startCountdownTimer();
          _currentStep = 2; // Jump to QR Claim Screen
          _isLoading = false;
          update();
          return true;
        }

        // Geofence / eligibility rejection (403/422): surface the server message
        // and do NOT fall through to the demo QR — the customer must be at the store.
        final dynamic body = response.body;
        final String? msg =
            (body is Map && body['message'] != null) ? body['message'].toString() : null;
        if (msg != null && msg.isNotEmpty) {
          _giftError = msg;
          showCustomSnackBar(msg);
          _isLoading = false;
          update();
          return false;
        }
      } catch (e) {
        debugPrint('Error generating QR: $e');
      }
    }

    // Fallback: only in DEBUG builds do we show a demo QR (Figma preview). In
    // release we must NEVER fabricate a claim — a demo code would let a customer
    // "claim" without the server issuing a real one (and re-claim endlessly).
    // Fail cleanly instead.
    if (kDebugMode) {
      _qrToken = _qrToken ?? 'DEMO-SH-500741-66587';
      _qrOrderNumber = 'SH-500741';
      _qrClaimCode = '66587';
      _currentStep = 2; // Jump to QR Claim Screen
      startCountdownTimer();
      _isLoading = false;
      update();
      return true;
    }
    _isLoading = false;
    update();
    return false;
  }

  void simulateHandoverSuccess() {
    // SECURITY: never let the CUSTOMER self-declare handover in a release build.
    // The real flow is server-driven — the cashier redeems the QR and
    // startPollingRedemptionStatus() advances the screen. Fabricating a claim
    // here would mark the gift consumed client-side without server verification
    // (and could enable re-claim abuse). Allowed only in DEBUG for Figma preview.
    if (!kDebugMode) return;
    _isRedeemed = true;
    _currentStep = 3;
    _redemptionData = {
      'store_name': _giftCampaign?.campaign?.store?.name ?? 'مانويل',
      'item_name': _selectedItem?.name ?? 'الوليمة أرز مزة بسمتي هندي 5 كجم',
      'claim_date': '26 أغسطس, 2026',
      'claim_time': '10:00 pm',
      'total': '00.0',
    };
    update();
  }

  void startPollingRedemptionStatus() {
    _statusCheckTimer?.cancel();
    if (_nonce == null) return;

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        Response response = await apiClient.getData(
          '/api/v1/customer/campaigns/claim-status/$_nonce',
        );

        if (response.statusCode == 200 && response.body['status'] == 'redeemed') {
          timer.cancel();
          _isRedeemed = true;
          _currentStep = 3;
          _redemptionData = response.body['data'];
          update();
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  @override
  void onClose() {
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }
}
