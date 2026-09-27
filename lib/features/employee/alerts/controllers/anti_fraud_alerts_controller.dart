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
        _showAdvancedDialog();
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

  void _showAdvancedDialog() {
    final ctx = Get.context;
    final isDark = ctx != null && Theme.of(ctx).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF111827);
    final textSub = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);

    Get.dialog(
      AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.report_problem_rounded, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 8),
            Text(
              'third_alert_advanced'.tr,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.bold, color: textDark),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentAlertMessage ?? '',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, height: 1.5, color: textSub),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF351A1A) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_off_outlined, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'one_minute_remaining_penalty'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              resumeActivity();
              Get.back();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF30913F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('resume_field_work'.tr, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      barrierDismissible: false,
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
