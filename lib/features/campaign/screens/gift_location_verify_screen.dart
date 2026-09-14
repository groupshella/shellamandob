import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// Shown after the customer picks a store in the manual "اختر المتجر" flow.
/// Captures the real GPS position and only lets them continue to claim the free
/// gift if they are physically inside the store's geofence — anti-fraud.
class GiftLocationVerifyScreen extends StatefulWidget {
  final int storeId;
  final String storeName;
  final double storeLat;
  final double storeLng;

  /// Must match the backend GIFT_CLAIM_RADIUS_METERS (default 200m).
  static const double radiusMeters = 200;

  const GiftLocationVerifyScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeLat,
    required this.storeLng,
  });

  @override
  State<GiftLocationVerifyScreen> createState() =>
      _GiftLocationVerifyScreenState();
}

enum _VerifyState { loading, inside, tooFar, denied, error }

class _GiftLocationVerifyScreenState extends State<GiftLocationVerifyScreen> {
  static const Color _green = Color(0xFF30913F);
  static const Color _red = Color(0xFFFA2D3F);

  _VerifyState _state = _VerifyState.loading;
  double _distance = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const earth = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earth * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double d) => d * math.pi / 180.0;

  Future<void> _verify() async {
    setState(() => _state = _VerifyState.loading);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _state = _VerifyState.denied);
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _state = _VerifyState.denied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));
      final d = _haversine(
          pos.latitude, pos.longitude, widget.storeLat, widget.storeLng);
      if (!mounted) return;
      setState(() {
        _distance = d;
        _state = d <= GiftLocationVerifyScreen.radiusMeters
            ? _VerifyState.inside
            : _VerifyState.tooFar;
      });
    } catch (_) {
      if (mounted) setState(() => _state = _VerifyState.error);
    }
  }

  void _continue() {
    // Replace this verification screen with the gift flow for the chosen store.
    Get.offNamed(RouteHelper.getFirstOrderGiftRoute(storeId: widget.storeId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'التحقق من الموقع',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111B18),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF2D3633), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _icon(),
              const SizedBox(height: 24),
              Text(
                _title(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111B18),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _subtitle(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                  height: 1.7,
                ),
              ),
              const Spacer(),
              _actions(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    if (_state == _VerifyState.loading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(color: _green, strokeWidth: 4),
          ),
        ),
      );
    }
    final bool ok = _state == _VerifyState.inside;
    final Color c = ok ? _green : _red;
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          ok ? Icons.check_circle_rounded : Icons.wrong_location_rounded,
          color: c,
          size: 64,
        ),
      ),
    );
  }

  String _title() {
    switch (_state) {
      case _VerifyState.loading:
        return 'جارٍ تحديد موقعك...';
      case _VerifyState.inside:
        return 'أنت داخل ${widget.storeName} ✅';
      case _VerifyState.tooFar:
        return 'يجب أن تكون داخل المتجر';
      case _VerifyState.denied:
        return 'فعّل خدمة الموقع';
      case _VerifyState.error:
        return 'تعذّر تحديد موقعك';
    }
  }

  String _subtitle() {
    switch (_state) {
      case _VerifyState.loading:
        return 'نتأكد أنك في ${widget.storeName} لاستلام هديتك المجانية.';
      case _VerifyState.inside:
        return 'أنت على بُعد ${_distance.round()} متر من الفرع. تابع لاختيار هديتك.';
      case _VerifyState.tooFar:
        return 'أنت على بُعد ${_distance.round()} متر تقريباً من ${widget.storeName}. توجّه إلى الفرع لاستلام هديتك المجانية.';
      case _VerifyState.denied:
        return 'نحتاج إذن الوصول لموقعك للتأكد أنك في المتجر، حمايةً من إساءة الاستخدام.';
      case _VerifyState.error:
        return 'تأكد من تفعيل GPS وحاول مرة أخرى.';
    }
  }

  Widget _actions() {
    switch (_state) {
      case _VerifyState.loading:
        return const SizedBox.shrink();
      case _VerifyState.inside:
        return _button('متابعة لاختيار هديتك', _green, _continue);
      case _VerifyState.tooFar:
      case _VerifyState.error:
        return _button('إعادة المحاولة', _green, _verify);
      case _VerifyState.denied:
        return Column(
          children: [
            _button('فتح الإعدادات', _green, () => Geolocator.openAppSettings()),
            const SizedBox(height: 10),
            _button('حاول مرة أخرى', const Color(0xFF6B7280), _verify,
                outlined: true),
          ],
        );
    }
  }

  Widget _button(String label, Color color, VoidCallback onTap,
      {bool outlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color)),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
    );
  }
}
