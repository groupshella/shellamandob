import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

class BranchLocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const BranchLocationPickerScreen({
    super.key,
    this.initialLat = 24.7136,
    this.initialLng = 46.6753,
  });

  @override
  State<BranchLocationPickerScreen> createState() =>
      _BranchLocationPickerScreenState();
}

class _BranchLocationPickerScreenState
    extends State<BranchLocationPickerScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  late LatLng _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().darkTheme;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF111B18);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          'branch_pick_location_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 13,
            ),
            onTap: (pos) => setState(() => _selectedPosition = pos),
            markers: {
              Marker(
                markerId: const MarkerId('branch_pin'),
                position: _selectedPosition,
                draggable: true,
                onDragEnd: (pos) => setState(() => _selectedPosition = pos),
              ),
            },
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back(result: {
                      'latitude': _selectedPosition.latitude,
                      'longitude': _selectedPosition.longitude,
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  label: Text(
                    'branch_confirm_location_btn'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
