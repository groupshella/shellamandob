import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import '../models/employee_shift_model.dart';
import '../models/employee_warning_model.dart';
import '../services/marketer_shift_service.dart';

class EmployeeShiftController extends GetxController implements GetxService {
  EmployeeShiftModel _shiftModel = const EmployeeShiftModel();
  EmployeeShiftModel get shiftModel => _shiftModel;

  ShiftStatus get status => _shiftModel.status;
  List<EmployeeWarningModel> get warnings => _shiftModel.warnings;

  int? currentShiftId;
  int? currentZoneId;
  bool isLoading = false;

  Timer? _tickerTimer;
  Timer? _pollingTimer;

  MarketerShiftService get _service => Get.find<MarketerShiftService>();

  @override
  void onInit() {
    super.onInit();
    loadCurrentShift();
  }

  @override
  void onClose() {
    _tickerTimer?.cancel();
    _pollingTimer?.cancel();
    super.onClose();
  }

  /// Load current active shift from server truth
  /// GET /api/v1/customer/marketer/shift/current
  Future<void> loadCurrentShift({bool notify = true}) async {
    try {
      final res = await _service.getCurrentShift();
      if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
        final data = res.body['data'];
        final String serverStatus = (data['status'] ?? 'none').toString().toLowerCase();
        currentShiftId = int.tryParse('${data['shift_id']}');
        currentZoneId = int.tryParse('${data['zone_id']}');

        final int workedSeconds = int.tryParse('${data['worked_seconds'] ?? data['elapsed_seconds'] ?? 0}') ?? 0;
        final int breakSeconds = int.tryParse('${data['break_seconds'] ?? 0}') ?? 0;

        ShiftStatus mappedStatus = ShiftStatus.notStarted;
        if (serverStatus == 'active') {
          mappedStatus = ShiftStatus.active;
        } else if (serverStatus == 'break') {
          mappedStatus = ShiftStatus.onBreak;
        } else {
          mappedStatus = ShiftStatus.notStarted;
        }

        _shiftModel = _shiftModel.copyWith(
          status: mappedStatus,
          actualWorkSeconds: workedSeconds,
          breakSeconds: breakSeconds,
        );

        if (mappedStatus == ShiftStatus.active || mappedStatus == ShiftStatus.onBreak) {
          _startPolling();
          _startTimer();
        } else {
          _stopPolling();
          _tickerTimer?.cancel();
        }

        if (notify) update();
      }
    } catch (e) {
      debugPrint('❌ [EmployeeShiftController] loadCurrentShift error: $e');
    }
  }

  /// Polling server every 12 seconds as specified in API contract (Page 2)
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      loadCurrentShift(notify: false);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _startTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_shiftModel.status == ShiftStatus.active) {
        _shiftModel = _shiftModel.copyWith(
          actualWorkSeconds: _shiftModel.actualWorkSeconds + 1,
        );
        update();
      } else if (_shiftModel.status == ShiftStatus.onBreak) {
        _shiftModel = _shiftModel.copyWith(
          breakSeconds: _shiftModel.breakSeconds + 1,
        );
        update();
      }
    });
  }

  /// Start Shift via API
  /// POST /api/v1/customer/marketer/shift/start
  Future<bool> startShiftApi({
    required double lat,
    required double lng,
    XFile? selfie,
  }) async {
    isLoading = true;
    update();
    try {
      final res = await _service.startShift(lat: lat, lng: lng, selfie: selfie);
      isLoading = false;

      if (res.statusCode == 200 && res.body != null) {
        final data = res.body['data'] ?? {};
        currentShiftId = int.tryParse('${data['shift_id']}');
        _shiftModel = _shiftModel.copyWith(status: ShiftStatus.active);
        _startTimer();
        _startPolling();
        update();
        return true;
      } else {
        final msg = res.body?['message'] ?? 'فشل في بدء الدوام';
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('حدث خطأ أثناء بدء الدوام: $e', isError: true);
      update();
      return false;
    }
  }

  /// Start Break via API
  /// POST /api/v1/customer/marketer/shift/break
  Future<bool> requestBreakApi() async {
    isLoading = true;
    update();
    try {
      final res = await _service.startBreak();
      isLoading = false;

      if (res.statusCode == 200) {
        _shiftModel = _shiftModel.copyWith(status: ShiftStatus.onBreak);
        update();
        return true;
      } else {
        final msg = res.body?['message'] ?? 'فشل في طلب الراحة';
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('حدث خطأ أثناء طلب الراحة', isError: true);
      update();
      return false;
    }
  }

  /// Resume Work via API
  /// POST /api/v1/customer/marketer/shift/resume
  Future<bool> resumeWorkApi() async {
    isLoading = true;
    update();
    try {
      final res = await _service.resumeShift();
      isLoading = false;

      if (res.statusCode == 200) {
        _shiftModel = _shiftModel.copyWith(status: ShiftStatus.active);
        update();
        return true;
      } else {
        final msg = res.body?['message'] ?? 'فشل في استئناف العمل';
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('حدث خطأ أثناء استئناف العمل', isError: true);
      update();
      return false;
    }
  }

  /// End Shift via API
  /// POST /api/v1/customer/marketer/shift/end
  Future<bool> endShiftApi({
    required double lat,
    required double lng,
  }) async {
    isLoading = true;
    update();
    try {
      final res = await _service.endShift(lat: lat, lng: lng);
      isLoading = false;

      if (res.statusCode == 200) {
        _tickerTimer?.cancel();
        _stopPolling();
        _shiftModel = _shiftModel.copyWith(status: ShiftStatus.notStarted);
        update();
        showCustomSnackBar('تم إنهاء الدوام بنجاح', isError: false);
        return true;
      } else {
        final msg = res.body?['message'] ?? 'فشل في إنهاء الدوام';
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('حدث خطأ أثناء إنهاء الدوام', isError: true);
      update();
      return false;
    }
  }

  // Fallback sync methods for offline / local preview
  void setStatus(ShiftStatus newStatus) {
    _shiftModel = _shiftModel.copyWith(status: newStatus);
    if (newStatus == ShiftStatus.active || newStatus == ShiftStatus.onBreak) {
      _startTimer();
      _startPolling();
    } else {
      _tickerTimer?.cancel();
      _stopPolling();
    }
    update();
  }

  void startShift() => setStatus(ShiftStatus.active);
  void requestBreak() => requestBreakApi();
  void resumeWork() => resumeWorkApi();
  Future<bool> endShift() async {
    double lat = 24.7136;
    double lng = 46.6753;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {}
    return await endShiftApi(lat: lat, lng: lng);
  }

  void recordVisitCompleted(bool isQualified) {
    _shiftModel = _shiftModel.copyWith(
      completedVisits: _shiftModel.completedVisits + 1,
    );
    update();
  }

  void addWarning({required String reason}) {
    final newWarning = EmployeeWarningModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: reason,
      date: 'اليوم',
    );
    final updatedWarnings = List<EmployeeWarningModel>.from(_shiftModel.warnings)..add(newWarning);
    _shiftModel = _shiftModel.copyWith(warnings: updatedWarnings);
    update();
  }

  /// Format seconds to HH:mm:ss for live active shift counter
  String get formattedWorkTimer {
    final int sec = _shiftModel.actualWorkSeconds;
    final int h = sec ~/ 3600;
    final int m = (sec % 3600) ~/ 60;
    final int s = sec % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Format hours to "HH:mm hrs"
  String get formattedWorkHours {
    final int sec = _shiftModel.actualWorkSeconds;
    final int h = sec ~/ 3600;
    final int m = (sec % 3600) ~/ 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${'hour_unit'.tr}';
  }
}
