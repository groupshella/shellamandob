import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import '../../controllers/employee_shift_controller.dart';
import '../../services/marketer_shift_service.dart';
import '../models/work_zone_model.dart';

enum GeofenceStatus { checking, inside, outside, error }

class AttendanceController extends GetxController implements GetxService {
  List<WorkZoneModel> zones = WorkZoneModel.defaultZones;
  WorkZoneModel? selectedZone;
  bool isZoneLocked = false;
  int? lockedZoneId;
  String? lockedAt;

  bool isLoadingZones = false;
  bool isLockingZone = false;
  bool isStartingShift = false;

  // Stepper: 0 = الموقع, 1 = الصورة, 2 = تأكيد
  int currentStep = 0;

  // Geofence & Location
  GeofenceStatus geofenceStatus = GeofenceStatus.inside;
  LatLng? userLocation;
  bool isLoadingLocation = false;
  bool pendingSupervisorApproval = false;
  String selectedChangeReason = 'خطأ في اختيار المنطقة';
  String additionalChangeNotes = '';

  // Selfie
  XFile? selfieImage;
  final ImagePicker _picker = ImagePicker();

  MarketerShiftService get _service => Get.find<MarketerShiftService>();

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    loadZones();
  }

  /// 1) Load Zones from API: GET /api/v1/customer/marketer/zones
  Future<void> loadZones() async {
    isLoadingZones = true;
    update();
    try {
      final res = await _service.getZones();
      if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
        final data = res.body['data'];
        lockedZoneId = int.tryParse('${data['locked_zone_id']}');
        lockedAt = data['locked_at']?.toString();

        if (data['zones'] is List) {
          final List rawZones = data['zones'];
          if (rawZones.isNotEmpty) {
            zones = rawZones
                .map((z) => WorkZoneModel.fromJson(z as Map<String, dynamic>, lockedZoneId: lockedZoneId))
                .toList();
          }
        }

        if (lockedZoneId != null) {
          isZoneLocked = true;
          final match = zones.firstWhereOrNull((z) => z.id == lockedZoneId);
          if (match != null) {
            selectedZone = match;
          }
        } else if (zones.isNotEmpty && selectedZone == null) {
          selectedZone = zones.first;
        }
      }
    } catch (e) {
      debugPrint('❌ [AttendanceController] loadZones error: $e');
    } finally {
      isLoadingZones = false;
      update();
    }
  }

  /// Lock Zone via API: POST /api/v1/customer/marketer/zone/lock
  Future<bool> lockZoneApi({
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    if (selectedZone == null) {
      onError('يرجى اختيار منطقة أولاً');
      return false;
    }

    isLockingZone = true;
    update();

    try {
      if (userLocation == null) {
        await fetchUserLocation();
      }

      final lat = userLocation?.latitude ?? selectedZone!.latitude;
      final lng = userLocation?.longitude ?? selectedZone!.longitude;

      final res = await _service.lockZone(
        zoneId: selectedZone!.id,
        lat: lat,
        lng: lng,
      );

      isLockingZone = false;
      update();

      if (res.statusCode == 200) {
        isZoneLocked = true;
        lockedZoneId = selectedZone!.id;
        update();
        onSuccess();
        return true;
      } else {
        final msg = res.body?['message'] ?? 'فشل في قفل منطقة العمل';
        onError(msg.toString());
        return false;
      }
    } catch (e) {
      isLockingZone = false;
      update();
      onError('حدث خطأ أثناء الاتصال: $e');
      return false;
    }
  }

  Future<void> fetchUserLocation() async {
    isLoadingLocation = true;
    update();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        userLocation = LatLng(position.latitude, position.longitude);
      } else {
        userLocation ??= LatLng(
          selectedZone?.latitude ?? 24.7136,
          selectedZone?.longitude ?? 46.6753,
        );
      }
    } catch (_) {
      userLocation ??= LatLng(
        selectedZone?.latitude ?? 24.7136,
        selectedZone?.longitude ?? 46.6753,
      );
    } finally {
      isLoadingLocation = false;
      update();
    }
  }

  void selectZone(WorkZoneModel zone) {
    if (!isZoneLocked) {
      selectedZone = zone;
      userLocation ??= LatLng(zone.latitude, zone.longitude);
      update();
    }
  }

  void lockAndConfirmZone() {
    isZoneLocked = true;
    update();
  }

  void setStep(int step) {
    currentStep = step;
    update();
  }

  Future<void> checkGeofence() async {
    geofenceStatus = GeofenceStatus.checking;
    update();
    await fetchUserLocation();
    await Future.delayed(const Duration(milliseconds: 600));

    if (userLocation != null && selectedZone != null) {
      final distance = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        selectedZone!.latitude,
        selectedZone!.longitude,
      );
      geofenceStatus = distance <= selectedZone!.radiusMeters
          ? GeofenceStatus.inside
          : GeofenceStatus.outside;
    } else {
      geofenceStatus = GeofenceStatus.inside;
    }
    update();
  }

  void simulateOutsideGeofence() {
    geofenceStatus = GeofenceStatus.outside;
    update();
  }

  Future<void> captureSelfie({bool fromGallery = false}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        selfieImage = photo;
        update();
      }
    } catch (_) {
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
        if (photo != null) {
          selfieImage = photo;
          update();
        }
      } catch (_) {}
    }
  }

  void clearSelfie() {
    selfieImage = null;
    update();
  }

  /// Request Zone Change: POST /api/v1/customer/marketer/zone/change-request
  Future<bool> submitChangeZoneRequest({
    required String reason,
    String? notes,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    selectedChangeReason = reason;
    additionalChangeNotes = notes ?? '';
    update();

    if (selectedZone == null) return false;

    try {
      final res = await _service.requestZoneChange(
        requestedZoneId: selectedZone!.id,
        reason: '$reason ${notes ?? ''}'.trim(),
      );

      if (res.statusCode == 200) {
        pendingSupervisorApproval = true;
        update();
        if (onSuccess != null) onSuccess();
        showCustomSnackBar('تم تقديم طلب تغيير المنطقة بنجاح', isError: false);
        return true;
      } else {
        final msg = res.body?['message'] ?? 'فشل في تقديم الطلب';
        if (onError != null) onError(msg.toString());
        showCustomSnackBar(msg.toString(), isError: true);
        return false;
      }
    } catch (e) {
      final msg = 'حدث خطأ: $e';
      if (onError != null) onError(msg);
      showCustomSnackBar(msg, isError: true);
      return false;
    }
  }

  /// Complete Attendance -> Starts shift via backend API
  Future<bool> completeAttendance() async {
    isStartingShift = true;
    update();

    if (userLocation == null) {
      await fetchUserLocation();
    }

    final lat = userLocation?.latitude ?? selectedZone?.latitude ?? 24.7136;
    final lng = userLocation?.longitude ?? selectedZone?.longitude ?? 46.6753;

    bool success = false;
    if (Get.isRegistered<EmployeeShiftController>()) {
      success = await Get.find<EmployeeShiftController>().startShiftApi(
        lat: lat,
        lng: lng,
        selfie: selfieImage,
      );
    } else {
      success = true;
    }

    isStartingShift = false;
    if (success) {
      setStep(2);
    }
    update();
    return success;
  }
}
