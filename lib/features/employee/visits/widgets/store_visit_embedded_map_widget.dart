import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../models/store_visit_model.dart';
import '../screens/store_visit_map_screen.dart';

class StoreVisitEmbeddedMapWidget extends StatelessWidget {
  final StoreVisitModel visit;
  final double height;

  const StoreVisitEmbeddedMapWidget({
    super.key,
    required this.visit,
    this.height = 170,
  });

  static const Color _primaryGreen = Color(0xFF30913F);
  static const LatLng _defaultRiyadhCenter = LatLng(24.7136, 46.6753);

  LatLng get _targetLatLng {
    if (visit.latitude != null && visit.longitude != null && visit.latitude != 0 && visit.longitude != 0) {
      return LatLng(visit.latitude!, visit.longitude!);
    }
    return _defaultRiyadhCenter;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final target = _targetLatLng;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Native GoogleMap
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: target, zoom: 15),
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {
                    Marker(
                      markerId: MarkerId('store_${visit.id}'),
                      position: target,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    ),
                  },
                  style: isDark ? themeCtrl.darkMap : themeCtrl.lightMap,
                ),

                // Transparent touch barrier that opens full screen map
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.to(() => StoreVisitMapScreen(visit: visit)),
                    ),
                  ),
                ),

                // Floating Action Badge: فتح الخريطة بالكامل والتتبع
                Positioned(
                  bottom: 10,
                  right: 10,
                  left: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C2028).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: _primaryGreen),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  visit.address.isNotEmpty ? visit.address : 'موقع المتجر المحدد',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Get.to(() => StoreVisitMapScreen(visit: visit)),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x2630913F), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.fullscreen_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'الخريطة الكاملة',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
