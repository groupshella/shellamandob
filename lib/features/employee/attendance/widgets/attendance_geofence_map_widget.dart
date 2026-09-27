import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/attendance_controller.dart';

class AttendanceGeofenceMapWidget extends StatefulWidget {
  const AttendanceGeofenceMapWidget({super.key});

  @override
  State<AttendanceGeofenceMapWidget> createState() => _AttendanceGeofenceMapWidgetState();
}

class _AttendanceGeofenceMapWidgetState extends State<AttendanceGeofenceMapWidget> {
  GoogleMapController? _mapController;

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _errorRed = Color(0xFFDC2626);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _recenter(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(
      builder: (controller) {
        final zone = controller.selectedZone;
        final zoneLatLng = LatLng(
          zone?.latitude ?? 24.7136,
          zone?.longitude ?? 46.6753,
        );
        final userLatLng = controller.userLocation ?? zoneLatLng;
        final isInside = controller.geofenceStatus == GeofenceStatus.inside;
        final isChecking = controller.geofenceStatus == GeofenceStatus.checking;
        final radius = zone?.radiusMeters ?? 1000.0;

        final Set<Circle> circles = {
          Circle(
            circleId: const CircleId('geofence_circle'),
            center: zoneLatLng,
            radius: radius,
            fillColor: (isInside ? _primaryGreen : _errorRed).withValues(alpha: 0.15),
            strokeColor: isInside ? _primaryGreen : _errorRed,
            strokeWidth: 2,
          ),
        };

        final Set<Marker> markers = {
          Marker(
            markerId: const MarkerId('zone_center'),
            position: zoneLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isInside ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: zone?.name ?? 'work_zone_label'.tr,
              snippet: '${'geofence_radius'.tr}: ${(radius).toInt()} ${'meter_unit'.tr}',
            ),
          ),
          if (controller.userLocation != null)
            Marker(
              markerId: const MarkerId('user_location'),
              position: userLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: InfoWindow(
                title: 'your_current_location'.tr,
              ),
            ),
        };

        final isDark = Theme.of(context).brightness == Brightness.dark;
        String? mapStyle;
        if (Get.isRegistered<ThemeController>()) {
          final theme = Get.find<ThemeController>();
          mapStyle = theme.darkTheme ? theme.darkMap : theme.lightMap;
        }

        final borderColor = isInside
            ? (isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC))
            : (isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5));
        final pillBg = (isDark ? const Color(0xFF1C2028) : Colors.white).withValues(alpha: 0.92);
        final pillTextColor = isDark ? Colors.white : const Color(0xFF111B18);
        final buttonBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final buttonIconColor = isDark ? Colors.white : const Color(0xFF111B18);

        return Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userLatLng,
                    zoom: 14.8,
                  ),
                  circles: circles,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  style: mapStyle,
                  onMapCreated: (mapCtrl) {
                    _mapController = mapCtrl;
                  },
                ),

                // Top Badge: Zone Info Pill
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconlyBold.location,
                          size: 14,
                          color: isInside ? _primaryGreen : _errorRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${zone?.name ?? 'work_zone_label'.tr} (${radius.toInt()}${'meter_unit'.tr})',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pillTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recenter GPS Button
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => _recenter(userLatLng),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: buttonBg,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location,
                        size: 20,
                        color: buttonIconColor,
                      ),
                    ),
                  ),
                ),

                // Checking / Loading overlay
                if (isChecking || controller.isLoadingLocation)
                  Container(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
                    child: const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
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
