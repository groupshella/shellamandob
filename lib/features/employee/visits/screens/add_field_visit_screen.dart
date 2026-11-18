import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/api/api_client.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../../../../util/app_constants.dart';
import '../../attendance/models/work_zone_model.dart';
import '../../services/marketer_shift_service.dart';
import '../controllers/store_visits_controller.dart';
import 'active_store_visit_screen.dart';

const LatLng _kDefaultRiyadhCenter = LatLng(24.7136, 46.6753);

class _PlacePrediction {
  final String placeId;
  final String description;
  const _PlacePrediction({required this.placeId, required this.description});
}

/// New field-discovery flow: the marketer types the store name and sets
/// their own current location, photographs the signboard, and the app
/// creates + starts the visit in one step -- no pre-loaded store list.
class AddFieldVisitScreen extends StatefulWidget {
  const AddFieldVisitScreen({super.key});

  @override
  State<AddFieldVisitScreen> createState() => _AddFieldVisitScreenState();
}

class _AddFieldVisitScreenState extends State<AddFieldVisitScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  final TextEditingController _storeNameController = TextEditingController();

  LatLng? _pickedLocation;
  bool _locatingSelf = true;
  bool _submitting = false;
  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<_PlacePrediction> _predictions = [];
  bool _searching = false;

  // The admin-assigned zone the marketer is restricted to -- drawn in green
  // so they can see where they're allowed to place the store before even
  // trying; the server rejects anything outside it regardless.
  List<LatLng> _assignedZonePolygon = [];
  String? _assignedZoneName;

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: calling controller.update() here
    // synchronously conflicts with the previous screen's own
    // GetBuilder<StoreVisitsController>, which is still mid-build as part
    // of the push transition when initState runs.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.find<StoreVisitsController>().clearStoreApprovalPhoto();
      _loadAssignedZone();
      // Center the map on the marketer's real position first, so moving the
      // pin is a small nudge to the storefront rather than a search from
      // Riyadh's center.
      final pos = await Get.find<StoreVisitsController>().captureStoreApprovalLocation();
      if (!mounted) return;
      setState(() {
        _locatingSelf = false;
        if (pos != null) {
          _pickedLocation = LatLng(pos.latitude, pos.longitude);
          _mapController?.animateCamera(CameraUpdate.newLatLng(_pickedLocation!));
        }
      });
    });
  }

  Future<void> _loadAssignedZone() async {
    try {
      final service = MarketerShiftService(apiClient: Get.find<ApiClient>());
      final res = await service.getZones();
      if (res.statusCode != 200 || res.body == null || res.body['data'] == null) return;

      final data = res.body['data'];
      final lockedZoneId = int.tryParse('${data['locked_zone_id']}');
      if (lockedZoneId == null || data['zones'] is! List) return;

      final zones = (data['zones'] as List)
          .map((z) => WorkZoneModel.fromJson(z as Map<String, dynamic>, lockedZoneId: lockedZoneId))
          .toList();
      final assigned = zones.where((z) => z.id == lockedZoneId).firstOrNull;
      if (assigned == null || assigned.polygon.length < 3 || !mounted) return;

      setState(() {
        _assignedZoneName = assigned.name;
        _assignedZonePolygon = assigned.polygon.map((p) => LatLng(p.latitude, p.longitude)).toList();
      });
    } catch (e) {
      debugPrint('Assigned zone load error: $e');
    }
  }

  /// Standard ray-casting point-in-polygon test, just for an instant local
  /// warning -- the server is still the real authority on this.
  bool _isInsideAssignedZone(LatLng point) {
    if (_assignedZonePolygon.length < 3) return true;
    var inside = false;
    for (var i = 0, j = _assignedZonePolygon.length - 1; i < _assignedZonePolygon.length; j = i++) {
      final pi = _assignedZonePolygon[i];
      final pj = _assignedZonePolygon[j];
      final intersects = ((pi.latitude > point.latitude) != (pj.latitude > point.latitude)) &&
          (point.longitude <
              (pj.longitude - pi.longitude) * (point.latitude - pi.latitude) / (pj.latitude - pi.latitude) +
                  pi.longitude);
      if (intersects) inside = !inside;
    }
    return inside;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _handleCapturePhoto({bool fromGallery = false}) async {
    await Get.find<StoreVisitsController>().captureStoreApprovalPhoto(fromGallery: fromGallery);
    setState(() {});
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _predictions = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () => _fetchPredictions(query.trim()));
  }

  Future<void> _fetchPredictions(String query) async {
    setState(() => _searching = true);
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': AppConstants.googleMapsApiKey,
        'language': 'ar',
        'components': 'country:sa',
      });
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'OK') {
          final results = (body['predictions'] as List)
              .map((p) => _PlacePrediction(placeId: p['place_id'], description: p['description']))
              .toList();
          if (mounted) setState(() => _predictions = results);
        } else if (mounted) {
          setState(() => _predictions = []);
        }
      }
    } catch (e) {
      debugPrint('Place autocomplete error: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectPrediction(_PlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.text = prediction.description;
      _predictions = [];
      _searching = true;
    });
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': prediction.placeId,
        'key': AppConstants.googleMapsApiKey,
        'fields': 'geometry',
      });
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'OK') {
          final loc = body['result']['geometry']['location'];
          final target = LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
          setState(() => _pickedLocation = target);
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _handlePickLocation(LatLng latLng) {
    setState(() => _pickedLocation = latLng);
    if (_assignedZonePolygon.length >= 3 && !_isInsideAssignedZone(latLng)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'outside_assigned_zone_warning'.trParams({'zone': _assignedZoneName ?? ''}),
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleLocateMePrecisely() async {
    setState(() => _searching = true);
    final pos = await Get.find<StoreVisitsController>().captureStoreApprovalLocation();
    if (!mounted) return;
    setState(() {
      _searching = false;
      if (pos != null) {
        _pickedLocation = LatLng(pos.latitude, pos.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_pickedLocation!, 18));
      }
    });
  }

  bool get _canSubmit =>
      _storeNameController.text.trim().isNotEmpty &&
      Get.find<StoreVisitsController>().storeApprovalPhotoPath != null &&
      _pickedLocation != null &&
      !_submitting;

  // The map/search flow only ever gives us coordinates (a tapped point, a
  // dragged marker, "locate me", or a resolved place_id) -- never a
  // human-readable address, which is why every visit created from here used
  // to reach the dashboard with "لم يتم تحديد العنوان" even though the pin
  // was placed correctly. Resolve it once, right before submit, from the
  // final picked point so it matches whatever the marketer actually confirmed.
  Future<String?> _reverseGeocodeAddress(LatLng latLng) async {
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${latLng.latitude},${latLng.longitude}',
        'key': AppConstants.googleMapsApiKey,
        'language': 'ar',
      });
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'OK' && (body['results'] as List).isNotEmpty) {
          return body['results'][0]['formatted_address'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final address = await _reverseGeocodeAddress(_pickedLocation!);

    final visit = await Get.find<StoreVisitsController>().createAndStartVisit(
      storeName: _storeNameController.text.trim(),
      position: _pickedLocation!,
      address: address,
    );

    setState(() => _submitting = false);

    if (visit != null && mounted) {
      Get.off(() => ActiveStoreVisitScreen(visit: visit));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.darkTheme;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final headingText = isDark ? Colors.white : const Color(0xFF0F172B);
    final hintText = isDark ? Colors.white60 : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFE2E8F0);

    return GetBuilder<StoreVisitsController>(
      builder: (controller) {
        final photoPath = controller.storeApprovalPhotoPath;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: Text(
              'new_field_visit'.tr,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w700, color: headingText),
            ),
            backgroundColor: cardBg,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'store_name'.tr,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: headingText),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _storeNameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'store_name_hint'.tr,
                      filled: true,
                      fillColor: cardBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'capture_signboard_photo'.tr,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: headingText),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _handleCapturePhoto,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: photoPath != null ? _primaryGreen : borderColor, width: photoPath != null ? 2 : 1),
                        image: photoPath != null
                            ? DecorationImage(
                                image: ResizeImage(FileImage(File(photoPath)), width: 480),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(IconlyLight.camera, color: hintText, size: 34),
                                const SizedBox(height: 8),
                                Text('tap_to_capture_signboard'.tr, style: TextStyle(color: hintText, fontFamily: 'Tajawal')),
                              ],
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: _primaryGreen, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => _handleCapturePhoto(fromGallery: true),
                      icon: Icon(IconlyLight.image, size: 18, color: hintText),
                      label: Text(
                        'choose_from_gallery'.tr,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w500, color: hintText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'set_store_location_on_map'.tr,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: headingText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'tap_map_to_set_location'.tr,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: hintText),
                  ),
                  const SizedBox(height: 8),

                  // Search box: type a place name / address to jump the map there.
                  Stack(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'search_location_hint'.tr,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: cardBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        ),
                      ),
                      if (_predictions.isNotEmpty)
                        Positioned(
                          top: 52,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: cardBg,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _predictions.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                              itemBuilder: (context, i) {
                                final p = _predictions[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.location_on_outlined, size: 18),
                                  title: Text(p.description, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: headingText)),
                                  onTap: () => _selectPrediction(p),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(border: Border.all(color: borderColor)),
                      child: _locatingSelf
                          ? Center(child: CircularProgressIndicator(color: _primaryGreen))
                          : Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _pickedLocation ?? _kDefaultRiyadhCenter,
                                    zoom: 17,
                                  ),
                                  onMapCreated: (c) => _mapController = c,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: false,
                                  compassEnabled: false,
                                  mapToolbarEnabled: false,
                                  onTap: _handlePickLocation,
                                  polygons: _assignedZonePolygon.length < 3
                                      ? {}
                                      : {
                                          Polygon(
                                            polygonId: const PolygonId('assigned_zone'),
                                            points: _assignedZonePolygon,
                                            strokeColor: _primaryGreen,
                                            strokeWidth: 2,
                                            fillColor: _primaryGreen.withValues(alpha: 0.12),
                                          ),
                                        },
                                  markers: _pickedLocation == null
                                      ? {}
                                      : {
                                          Marker(
                                            markerId: const MarkerId('picked_store_location'),
                                            position: _pickedLocation!,
                                            draggable: true,
                                            onDragEnd: _handlePickLocation,
                                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                                          ),
                                        },
                                ),
                                if (_pickedLocation != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBg.withValues(alpha: 0.92),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle, color: _primaryGreen, size: 14),
                                          const SizedBox(width: 4),
                                          Text('location_confirmed'.tr, style: TextStyle(fontSize: 11, fontFamily: 'Tajawal', color: headingText)),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Material(
                                    color: cardBg,
                                    elevation: 3,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: _searching ? null : _handleLocateMePrecisely,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: _searching
                                            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen))
                                            : const Icon(IconlyBold.location, color: _primaryGreen, size: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        disabledBackgroundColor: _primaryGreen.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              'approve_store_and_start_visit'.tr,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
