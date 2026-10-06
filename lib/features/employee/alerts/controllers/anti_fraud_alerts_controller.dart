import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employee_shift_controller.dart';
import '../screens/critical_alert_screen.dart';

enum AlertLevel {
  none(0, 'طبيعي', Colors.transparent),
  alert1(1, 'الإنذار الأول: تنبيه خمول مبدئي', Color(0xFF3B82F6)),
  alert2(2, 'الإنذار الثاني: عدم رصد حركة ميدانية', Color(0xFFF59E0B)),
  alert3(3, 'الإنذار الثالث: تحذير متقدم قبل الخصم', Color(0xFFEF4444)),
  criticalAlert4(4, 'الإنذار الرابع الحرج: احتساب خارج الدوام', Color(0xFF991B1B));

  final int level;
  final String title;
  final Color color;

  const AlertLevel(this.level, this.title, this.color);
}

class AntiFraudAlertsController extends GetxController {
  /// Test/Local environment flag: completely disables anti-fraud penalties, warning popups, and CriticalAlertScreen
  static bool disableInactivityAlertsInTest = true;

  AlertLevel _currentAlertLevel = AlertLevel.none;
  AlertLevel get currentAlertLevel => _currentAlertLevel;

  int _totalViolationsCount = 0;
  int get totalViolationsCount => _totalViolationsCount;

  bool _isPenaltyActive = false;
  bool get isPenaltyActive => _isPenaltyActive;

  DateTime? _lastAlertTime;
  DateTime? get lastAlertTime => _lastAlertTime;

  String? _currentAlertMessage;
  String? get currentAlertMessage => _currentAlertMessage;

  @override
  void onInit() {
    super.onInit();
    if (disableInactivityAlertsInTest) {
      resumeActivity();
    }
  }

  void triggerAlert(AlertLevel level) {
    if (disableInactivityAlertsInTest) {
      debugPrint('⚠️ [AntiFraudAlertsController] Inactivity alert ($level) bypassed in test/local mode.');
      return;
    }

    _currentAlertLevel = level;
    _lastAlertTime = DateTime.now();

    switch (level) {
      case AlertLevel.alert1:
        _currentAlertMessage = 'alert1_message'.tr;
        _showGentleSnackbar(title: 'field_movement_alert_first'.tr, message: _currentAlertMessage!, color: const Color(0xFF3B82F6));
        break;

      case AlertLevel.alert2:
        _currentAlertMessage = 'alert2_message'.tr;
        _showGentleSnackbar(title: 'idle_alert_second'.tr, message: _currentAlertMessage!, color: const Color(0xFFF59E0B));
        break;

      case AlertLevel.alert3:
        _currentAlertMessage = 'alert3_message'.tr;
        _showAdvancedToast();
        break;

      case AlertLevel.criticalAlert4:
        _isPenaltyActive = true;
        _totalViolationsCount++;
        _currentAlertMessage = 'alert4_message'.tr;
        // Notify shift controller of warning
        if (Get.isRegistered<EmployeeShiftController>()) {
          Get.find<EmployeeShiftController>().addWarning(
            reason: 'inactivity_warning_reason'.tr,
          );
        }
        _showCriticalPenaltyScreen();
        break;

      case AlertLevel.none:
        _currentAlertMessage = null;
        break;
    }

    update();
  }

  void _showGentleSnackbar({required String title, required String message, required Color color}) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
      backgroundColor: color.withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  void _showAdvancedToast() {
    Get.snackbar(
      'third_alert_advanced'.tr,
      _currentAlertMessage ?? 'one_minute_remaining_penalty'.tr,
      icon: const Icon(Icons.report_problem_rounded, color: Colors.white, size: 28),
      backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      isDismissible: true,
      mainButton: TextButton(
        onPressed: () {
          resumeActivity();
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: Text(
          'resume_field_work'.tr,
          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  void _showCriticalPenaltyScreen() {
    Get.to(() => const CriticalAlertScreen());
  }

  // Representative resumes and explains
  void resumeActivity() {
    _currentAlertLevel = AlertLevel.none;
    _isPenaltyActive = false;
    _currentAlertMessage = null;
    update();
  }
}
