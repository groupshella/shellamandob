import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
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

        // Handle nested shift object or root data
        final Map<String, dynamic> shiftData = (data['shift'] is Map)
            ? Map<String, dynamic>.from(data['shift'])
            : (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});

        final String serverStatus = (shiftData['status'] ?? data['status'] ?? 'not_started').toString().toLowerCase();
        currentShiftId = int.tryParse('${shiftData['shift_id'] ?? shiftData['id'] ?? data['shift_id']}');
        currentZoneId = int.tryParse('${shiftData['zone_id'] ?? data['zone_id']}');

        ShiftStatus mappedStatus = ShiftStatus.notStarted;
        if (serverStatus == 'active') {
          mappedStatus = ShiftStatus.active;
        } else if (serverStatus == 'break' || serverStatus == 'on_break') {
          mappedStatus = ShiftStatus.onBreak;
        } else {
          mappedStatus = ShiftStatus.notStarted;
        }

        // 1. Employee Name
        String employeeName = '';
        if (data['employee'] is Map && data['employee']['name'] != null) {
          employeeName = data['employee']['name'].toString();
        }
        if (employeeName.isEmpty && Get.isRegistered<ProfileController>()) {
          final userInfo = Get.find<ProfileController>().userInfoModel;
          if (userInfo != null) {
            employeeName = '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim();
          }
        }

        // 2. Start Time
        String startTimeText = shiftData['start_time_text']?.toString() ?? '';
        if (startTimeText.isEmpty && shiftData['started_at'] != null) {
          try {
            final dt = DateTime.parse(shiftData['started_at'].toString());
            startTimeText = DateFormat('hh:mm a', 'ar').format(dt);
          } catch (_) {
            startTimeText = shiftData['started_at'].toString();
          }
        }
        if (startTimeText.isEmpty && mappedStatus == ShiftStatus.notStarted) {
          startTimeText = '--:--';
        }

        // 3. Work Seconds and Work Time Text
        final int workedSeconds = int.tryParse('${shiftData['worked_seconds'] ?? shiftData['elapsed_seconds'] ?? data['worked_seconds'] ?? 0}') ?? 0;
        final String workedTimeText = shiftData['worked_time_text']?.toString() ?? '';
        final int breakSeconds = int.tryParse('${shiftData['break_seconds'] ?? data['break_seconds'] ?? 0}') ?? 0;

        // 4. Overtime
        final int overtimeSeconds = int.tryParse('${shiftData['overtime_seconds'] ?? 0}') ?? 0;
        final String overtimeText = shiftData['overtime_text']?.toString() ?? '';

        // 5. Approved Leave
        final int approvedLeaveSeconds = int.tryParse('${shiftData['approved_leave_seconds'] ?? 0}') ?? 0;
        final String approvedLeaveText = shiftData['approved_leave_text']?.toString() ?? '';

        // 6. Warnings
        List<EmployeeWarningModel> warningsList = [];
        int warningCount = 0;
        if (data['warnings'] != null) {
          if (data['warnings'] is Map) {
            warningCount = int.tryParse('${data['warnings']['count']}') ?? 0;
            if (data['warnings']['items'] is List) {
              warningsList = (data['warnings']['items'] as List)
                  .map((e) => EmployeeWarningModel.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
            }
          } else if (data['warnings'] is List) {
            warningsList = (data['warnings'] as List)
                .map((e) => EmployeeWarningModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            warningCount = warningsList.length;
          }
        }
        if (warningCount == 0 && warningsList.isNotEmpty) {
          warningCount = warningsList.length;
        }

        // 7. Visits Summary
        int totalVisits = 0;
        int completedVisits = 0;
        int upcomingVisits = 0;
        int followUpVisits = 0;
        if (data['visits_summary'] is Map) {
          final vs = data['visits_summary'];
          totalVisits = int.tryParse('${vs['total']}') ?? 0;
          completedVisits = int.tryParse('${vs['completed']}') ?? 0;
          upcomingVisits = int.tryParse('${vs['upcoming']}') ?? 0;
          followUpVisits = int.tryParse('${vs['needs_follow_up'] ?? vs['follow_up']}') ?? 0;
        }

        _shiftModel = _shiftModel.copyWith(
          status: mappedStatus,
          employeeName: employeeName.isNotEmpty ? employeeName : _shiftModel.employeeName,
          startTimeText: startTimeText.isNotEmpty ? startTimeText : _shiftModel.startTimeText,
          actualWorkSeconds: workedSeconds,
          workedTimeText: workedTimeText,
          breakSeconds: breakSeconds,
          overtimeSeconds: overtimeSeconds,
          overtimeHoursText: overtimeText,
          approvedLeaveSeconds: approvedLeaveSeconds,
          approvedLeaveHoursText: approvedLeaveText,
          totalVisits: totalVisits,
          completedVisits: completedVisits,
          upcomingVisits: upcomingVisits,
          followUpVisits: followUpVisits,
          warnings: warningsList,
          warningCount: warningCount,
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
        
        String startText = '';
        if (data['started_at'] != null) {
          try {
            final dt = DateTime.parse(data['started_at'].toString());
            startText = DateFormat('hh:mm a', 'ar').format(dt);
          } catch (_) {
            startText = data['started_at'].toString();
          }
        }
        if (startText.isEmpty) {
          startText = DateFormat('hh:mm a', 'ar').format(DateTime.now());
        }

        _shiftModel = _shiftModel.copyWith(
          status: ShiftStatus.active,
          startTimeText: startText,
        );
        _startTimer();
        _startPolling();
        update();
        loadCurrentShift(notify: true);
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
        loadCurrentShift(notify: true);
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
        loadCurrentShift(notify: true);
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
        _shiftModel = _shiftModel.copyWith(
          status: ShiftStatus.notStarted,
          actualWorkSeconds: 0,
        );
        update();
        showCustomSnackBar('تم إنهاء الدوام بنجاح', isError: false);
        loadCurrentShift(notify: true);
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
