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
import '../models/training_lesson_model.dart';
import '../screens/account_frozen_screen.dart';
import '../screens/employee_main_screen.dart';
import '../services/marketer_shift_service.dart';
import '../visits/controllers/store_visits_controller.dart';

class EmployeeShiftController extends GetxController implements GetxService {
  EmployeeShiftModel _shiftModel = const EmployeeShiftModel();
  EmployeeShiftModel get shiftModel => _shiftModel;

  ShiftStatus get status => _shiftModel.status;
  List<EmployeeWarningModel> get warnings => _shiftModel.warnings;

  int? currentShiftId;
  int? currentZoneId;
  bool isLoading = false;
  bool hasLoadedOnce = false;

  Timer? _tickerTimer;
  Timer? _pollingTimer;
  Timer? _locationPingTimer;

  MarketerShiftService get _service {
    if (Get.isRegistered<MarketerShiftService>()) {
      return Get.find<MarketerShiftService>();
    }
    return Get.put(MarketerShiftService(apiClient: Get.find()));
  }

  @override
  void onInit() {
    super.onInit();
    loadCurrentShift();
    // Ping as soon as the app is open, regardless of shift state, so the
    // admin dashboard can show every marketer who has the app open right
    // now (colored red/"stopped" until they actually start a shift).
    _startLocationPing();
  }

  @override
  void onClose() {
    _tickerTimer?.cancel();
    _pollingTimer?.cancel();
    _locationPingTimer?.cancel();
    super.onClose();
  }

  /// Live location: foreground-only (no background tracking), running the
  /// whole time this controller is alive (i.e. the app is open) regardless
  /// of shift state, so the admin dashboard can show every marketer who has
  /// the app open right now. Pings immediately, then every 20s.
  Future<void> _sendLocationPingOnce() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ [EmployeeShiftController] location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('❌ [EmployeeShiftController] location permission not granted: $permission');
        return;
      }

      // High accuracy forces a real GPS fix instead of a coarse
      // network/cell-based position, which on some devices gets served
      // from cache and can repeat the exact same coordinate for hours.
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _service.pingLocation(lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      debugPrint('❌ [EmployeeShiftController] location ping error: $e');
    }
  }

  void _startLocationPing() {
    _locationPingTimer?.cancel();
    _sendLocationPingOnce();
    _locationPingTimer = Timer.periodic(const Duration(seconds: 20), (_) => _sendLocationPingOnce());
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

        // 7. Visits Summary & Daily Target
        int dailyTargetVisits = StoreVisitsController.dailyTargetVisits;
        if (data['daily_target_visits'] != null) {
          dailyTargetVisits = int.tryParse('${data['daily_target_visits']}') ?? dailyTargetVisits;
        }

        int totalVisits = 0;
        int completedVisits = 0;
        int upcomingVisits = 0;
        int followUpVisits = 0;
        if (data['visits_summary'] is Map) {
          final vs = data['visits_summary'];
          if (vs['target'] != null) {
            dailyTargetVisits = int.tryParse('${vs['target']}') ?? dailyTargetVisits;
          }
          totalVisits = int.tryParse('${vs['total']}') ?? 0;
          completedVisits = int.tryParse('${vs['completed']}') ?? 0;
          upcomingVisits = int.tryParse('${vs['upcoming']}') ?? 0;
          followUpVisits = int.tryParse('${vs['needs_follow_up'] ?? vs['follow_up']}') ?? 0;
        }

        // 8. Monthly Acquisition Targets (Stores & Marketers)
        int storesTarget = _shiftModel.storesTarget;
        int storesAchieved = _shiftModel.storesAchieved;
        int storesRemaining = _shiftModel.storesRemaining;
        int storesPercent = _shiftModel.storesPercent;
        int marketersTarget = _shiftModel.marketersTarget;
        int marketersAchieved = _shiftModel.marketersAchieved;
        int marketersRemaining = _shiftModel.marketersRemaining;
        int marketersPercent = _shiftModel.marketersPercent;

        if (data['targets'] is Map) {
          final t = data['targets'];
          if (t['monthly_stores'] is Map) {
            final ms = t['monthly_stores'];
            storesTarget = int.tryParse('${ms['target']}') ?? storesTarget;
            storesAchieved = int.tryParse('${ms['achieved']}') ?? 0;
            storesRemaining = int.tryParse('${ms['remaining']}') ?? (storesTarget - storesAchieved).clamp(0, storesTarget);
            storesPercent = int.tryParse('${ms['percentage']}') ?? 0;
          }
          if (t['monthly_marketers'] is Map) {
            final mm = t['monthly_marketers'];
            marketersTarget = int.tryParse('${mm['target']}') ?? marketersTarget;
            marketersAchieved = int.tryParse('${mm['achieved']}') ?? 0;
            marketersRemaining = int.tryParse('${mm['remaining']}') ?? (marketersTarget - marketersAchieved).clamp(0, marketersTarget);
            marketersPercent = int.tryParse('${mm['percentage']}') ?? 0;
          }
        }

        DailyPerformanceReportModel? performanceReport = _shiftModel.performanceReport;
        if (data['performance_report'] is Map) {
          performanceReport = DailyPerformanceReportModel.fromJson(
            Map<String, dynamic>.from(data['performance_report']),
          );
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
          dailyTargetVisits: dailyTargetVisits,
          totalVisits: totalVisits,
          completedVisits: completedVisits,
          upcomingVisits: upcomingVisits,
          followUpVisits: followUpVisits,
          warnings: warningsList,
          warningCount: warningCount,
          storesTarget: storesTarget,
          storesAchieved: storesAchieved,
          storesRemaining: storesRemaining,
          storesPercent: storesPercent,
          marketersTarget: marketersTarget,
          marketersAchieved: marketersAchieved,
          marketersRemaining: marketersRemaining,
          marketersPercent: marketersPercent,
          performanceReport: performanceReport,
        );

        if (data['account_frozen'] == true) {
          final reason = data['freeze_reason']?.toString();
          if (Get.currentRoute != '/AccountFrozenScreen') {
            Get.offAll(() => AccountFrozenScreen(freezeReason: reason));
          }
          return;
        } else if (Get.currentRoute == '/AccountFrozenScreen') {
          Get.offAll(() => const EmployeeMainScreen());
        }

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
    } finally {
      if (!hasLoadedOnce) {
        hasLoadedOnce = true;
        if (notify) update();
      }
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

  /// Constant ID used to scope 1-second timer tick rebuilds strictly to the timer UI
  static const String timerClockUpdateId = 'shift_timer_clock';

  void _startTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_shiftModel.status == ShiftStatus.active) {
        _shiftModel = _shiftModel.copyWith(
          actualWorkSeconds: _shiftModel.actualWorkSeconds + 1,
        );
        update([timerClockUpdateId]);
      } else if (_shiftModel.status == ShiftStatus.onBreak) {
        _shiftModel = _shiftModel.copyWith(
          breakSeconds: _shiftModel.breakSeconds + 1,
        );
        update([timerClockUpdateId]);
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
        final msg = res.body?['message'] ?? 'failed_to_start_shift'.tr;
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('${'error_starting_shift'.tr}: $e', isError: true);
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
        final msg = res.body?['message'] ?? 'failed_to_request_break'.tr;
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('error_requesting_break'.tr, isError: true);
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
        final msg = res.body?['message'] ?? 'failed_to_resume_work'.tr;
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('error_resuming_work'.tr, isError: true);
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
        showCustomSnackBar('shift_ended_successfully'.tr, isError: false);
        loadCurrentShift(notify: true);
        return true;
      } else {
        final msg = res.body?['message'] ?? 'failed_to_end_shift'.tr;
        showCustomSnackBar(msg.toString(), isError: true);
        update();
        return false;
      }
    } catch (e) {
      isLoading = false;
      showCustomSnackBar('error_ending_shift'.tr, isError: true);
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
      date: 'today'.tr,
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
