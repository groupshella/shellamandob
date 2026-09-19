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

  void triggerAlert(AlertLevel level) {
    _currentAlertLevel = level;
    _lastAlertTime = DateTime.now();

    switch (level) {
      case AlertLevel.alert1:
        _currentAlertMessage = 'تنبيه خفيف: تم رصد توقف عن الحركة لأكثر من 10 دقائق داخل الزيارة. يرجى استئناف النشاط الميداني لتفادي تسجيل مخالفة.';
        _showGentleSnackbar(title: 'field_movement_alert_first'.tr, message: _currentAlertMessage!, color: const Color(0xFF3B82F6));
        break;

      case AlertLevel.alert2:
        _currentAlertMessage = 'تنبيه ثانٍ: عدم استقرار أو حركة نحو المتجر. اضغط "طلب راحة" إذا كنت في فترة توقف مصرح بها.';
        _showGentleSnackbar(title: 'idle_alert_second'.tr, message: _currentAlertMessage!, color: const Color(0xFFF59E0B));
        break;

      case AlertLevel.alert3:
        _currentAlertMessage = 'تحذير متقدم: أنت على وشك تجاوز المدة القصوى المسموحة للخمول. الإنذار القادم سيؤدي إلى الخصم واحتساب وقت خارج الدوام!';
        _showAdvancedDialog();
        break;

      case AlertLevel.criticalAlert4:
        _isPenaltyActive = true;
        _totalViolationsCount++;
        _currentAlertMessage = 'تم تفعيل الإنذار الرابع الحرج: بدء احتساب الوقت كـ "خارج الدوام" وتوثيق مخالفة خمول بنظام الرقابة والامتثال.';
        // Notify shift controller of warning
        if (Get.isRegistered<EmployeeShiftController>()) {
          Get.find<EmployeeShiftController>().addWarning(
            reason: 'خمول مستمر وتجاوز مهلة الـ 10 دقائق في الزيارة الميدانية',
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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.report_problem_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 8),
            Text(
              'الإنذار الثالث (تحذير متقدم)',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentAlertMessage ?? '',
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, height: 1.5, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.timer_off_outlined, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تبقى دقيقة واحدة فقط قبل بدء احتساب وقتك كـ "خارج الدوام".',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
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
