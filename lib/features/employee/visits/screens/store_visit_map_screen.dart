import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'active_store_visit_screen.dart';
import 'visit_summary_screen.dart';

class StoreVisitMapScreen extends StatefulWidget {
  final StoreVisitModel? visit;
  final List<StoreVisitModel>? allVisits;

  const StoreVisitMapScreen({
    super.key,
    this.visit,
    this.allVisits,
  });

  @override
  State<StoreVisitMapScreen> createState() => _StoreVisitMapScreenState();
}

class _StoreVisitMapScreenState extends State<StoreVisitMapScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const LatLng _defaultRiyadhCenter = LatLng(24.7136, 46.6753);

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Position? _currentPosition;
  StoreVisitModel? _selectedVisit;
  bool _isLoadingGps = false;
  double? _liveDistanceKm;

  @override
  void initState() {
    super.initState();
    _selectedVisit = widget.visit ?? (widget.allVisits != null && widget.allVisits!.isNotEmpty ? widget.allVisits!.first : null);
    _initMarkers();
    _requestGpsPosition();
  }

  LatLng _getVisitLatLng(StoreVisitModel visit) {
    if (visit.latitude != null && visit.longitude != null && visit.latitude != 0 && visit.longitude != 0) {
      return LatLng(visit.latitude!, visit.longitude!);
    }
    return _defaultRiyadhCenter;
  }

  void _initMarkers() {
    _markers.clear();

    if (widget.allVisits != null && widget.allVisits!.isNotEmpty) {
      for (final v in widget.allVisits!) {
        final pos = _getVisitLatLng(v);
        final isSelected = _selectedVisit?.id == v.id;
        final hue = v.visitStatus == StoreVisitStatus.completed
            ? BitmapDescriptor.hueGreen
            : v.visitStatus == StoreVisitStatus.inProgress
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueAzure;

        _markers.add(
          Marker(
            markerId: MarkerId('visit_${v.id}'),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(isSelected ? BitmapDescriptor.hueRed : hue),
            infoWindow: InfoWindow(
              title: v.storeName,
              snippet: v.address.isNotEmpty ? v.address : v.visitStatus.title,
            ),
            onTap: () {
              setState(() {
                _selectedVisit = v;
                _computeDistance();
                _updatePolylines();
              });
            },
          ),
        );
      }
    } else if (widget.visit != null) {
      final v = widget.visit!;
      final pos = _getVisitLatLng(v);
      _markers.add(
        Marker(
          markerId: MarkerId('visit_${v.id}'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: v.storeName,
            snippet: v.address.isNotEmpty ? v.address : 'موقع المتجر المحدد',
          ),
        ),
      );
    }
  }

  Future<void> _requestGpsPosition() async {
    setState(() => _isLoadingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        if (mounted) {
          setState(() {
            _currentPosition = pos;
            _computeDistance();
            _updatePolylines();
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ [StoreVisitMapScreen] GPS lookup: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingGps = false);
      }
    }
  }

  void _computeDistance() {
    if (_currentPosition == null || _selectedVisit == null) return;
    final pos = _getVisitLatLng(_selectedVisit!);
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      pos.latitude,
      pos.longitude,
    );
    _liveDistanceKm = meters / 1000.0;
  }

  void _updatePolylines() {
    _polylines.clear();
    if (_currentPosition != null && _selectedVisit != null) {
      final storePos = _getVisitLatLng(_selectedVisit!);
      final userPos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_store'),
          points: [userPos, storePos],
          color: _primaryGreen,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
  }

  void _animateCameraToStore() {
    if (_selectedVisit == null || _mapController == null) return;
    final pos = _getVisitLatLng(_selectedVisit!);
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: 16.5, tilt: 25),
      ),
    );
  }

  void _animateCameraToUser() {
    if (_currentPosition == null || _mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 16.5,
        ),
      ),
    );
  }

  void _fitBothPositions() {
    if (_mapController == null || _currentPosition == null || _selectedVisit == null) {
      _animateCameraToStore();
      return;
    }

    final storePos = _getVisitLatLng(_selectedVisit!);
    final userPos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    final southWest = LatLng(
      userPos.latitude < storePos.latitude ? userPos.latitude : storePos.latitude,
      userPos.longitude < storePos.longitude ? userPos.longitude : storePos.longitude,
    );
    final northEast = LatLng(
      userPos.latitude > storePos.latitude ? userPos.latitude : storePos.latitude,
      userPos.longitude > storePos.longitude ? userPos.longitude : storePos.longitude,
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111827);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB);

        final initialTarget = _selectedVisit != null ? _getVisitLatLng(_selectedVisit!) : _defaultRiyadhCenter;

        return Scaffold(
          body: Stack(
            children: [
              // 1. Native Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(target: initialTarget, zoom: 15.5),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _fitBothPositions();
                },
                style: isDark ? themeCtrl.darkMap : themeCtrl.lightMap,
              ),

              // 2. Floating Top Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: darkText,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Title Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.map_rounded, color: _primaryGreen, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedVisit?.storeName ?? 'خريطة زيارات المندوب',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: darkText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      widget.allVisits != null
                                          ? 'إجمالي الزيارات: ${widget.allVisits!.length}'
                                          : 'موقع المتجر المحدد',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 11,
                                        color: subText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Right Floating Action Controls
              Positioned(
                right: 16,
                top: 130,
                child: Column(
                  children: [
                    // Center on Store
                    _buildFloatingRoundBtn(
                      icon: Icons.store_mall_directory_rounded,
                      tooltip: 'موقع المتجر',
                      cardBg: cardBg,
                      darkText: darkText,
                      onTap: _animateCameraToStore,
                    ),
                    const SizedBox(height: 10),

                    // Center on Marketer GPS
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: IconButton(
                        icon: _isLoadingGps
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen),
                              )
                            : Icon(
                                Icons.my_location_rounded,
                                color: _currentPosition != null ? _primaryGreen : darkText,
                                size: 20,
                              ),
                        tooltip: 'موقعي الحالي',
                        onPressed: () {
                          if (_currentPosition == null) {
                            _requestGpsPosition();
                          } else {
                            _animateCameraToUser();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Fit Both
                    _buildFloatingRoundBtn(
                      icon: Icons.zoom_out_map_rounded,
                      tooltip: 'عرض المسافة كاملة',
                      cardBg: cardBg,
                      darkText: darkText,
                      onTap: _fitBothPositions,
                    ),
                  ],
                ),
              ),

              // 4. Bottom Floating Store Details Card
              if (_selectedVisit != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: _buildStoreDetailSheet(
                    visit: _selectedVisit!,
                    cardBg: cardBg,
                    darkText: darkText,
                    subText: subText,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingRoundBtn({
    required IconData icon,
    required String tooltip,
    required Color cardBg,
    required Color darkText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: darkText, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStoreDetailSheet({
    required StoreVisitModel visit,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
    required bool isDark,
  }) {
    final distText = _liveDistanceKm != null
        ? '${_liveDistanceKm!.toStringAsFixed(1)} كم من موقعك'
        : '${visit.distanceKm} كم';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: borderColor) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(IconlyBold.location, color: _primaryGreen, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.storeName,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(IconlyLight.location, size: 13, color: subText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            visit.address.isNotEmpty ? visit.address : 'لم يتم تسجيل العنوان بدقة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: subText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Distance Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF263238) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconlyLight.discovery, size: 12, color: subText),
                    const SizedBox(width: 4),
                    Text(
                      distText,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          // Manager Info & Phone
          Row(
            children: [
              if (visit.managerName.isNotEmpty) ...[
                Icon(IconlyLight.profile, size: 14, color: subText),
                const SizedBox(width: 4),
                Text(
                  visit.managerName,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              if (visit.phone.isNotEmpty) ...[
                Icon(IconlyLight.call, size: 14, color: subText),
                const SizedBox(width: 4),
                Text(
                  visit.phone,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('tel:${visit.phone}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.phone_in_talk_rounded, size: 14, color: _primaryGreen),
                        SizedBox(width: 4),
                        Text(
                          'اتصال',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Main Action Button
          Row(
            children: [
              // Copy address button
              if (visit.address.isNotEmpty)
                IconButton(
                  tooltip: 'نسخ العنوان',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: visit.address));
                    Get.snackbar(
                      'تم النسخ',
                      'تم نسخ عنوان المتجر للحافظة',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  icon: Icon(Icons.copy_rounded, size: 18, color: subText),
                ),
              const SizedBox(width: 4),

              // Navigate / Start Visit Button
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      final controller = Get.find<StoreVisitsController>();
                      if (visit.visitStatus == StoreVisitStatus.inProgress) {
                        controller.resumeVisit(visit);
                        Get.to(() => ActiveStoreVisitScreen(visit: visit));
                      } else if (visit.visitStatus == StoreVisitStatus.completed) {
                        Get.to(() => VisitSummaryScreen(visit: visit, isReadOnly: true));
                      } else if (visit.visitStatus == StoreVisitStatus.followUp) {
                        controller.resumeVisit(visit);
                        Get.to(() => VisitSummaryScreen(visit: visit, isReadOnly: false));
                      } else {
                        controller.startVisit(visit);
                        Get.to(() => ActiveStoreVisitScreen(visit: visit));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      visit.visitStatus == StoreVisitStatus.inProgress
                          ? 'متابعة الزيارة الحالية'
                          : visit.visitStatus == StoreVisitStatus.completed
                              ? 'عرض تفاصيل الزيارة'
                              : 'بدء الزيارة الآن',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
