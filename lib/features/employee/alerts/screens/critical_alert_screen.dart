import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/anti_fraud_alerts_controller.dart';
import '../../controllers/employee_shift_controller.dart';

class CriticalAlertScreen extends StatefulWidget {
  const CriticalAlertScreen({super.key});

  @override
  State<CriticalAlertScreen> createState() => _CriticalAlertScreenState();
}

class _CriticalAlertScreenState extends State<CriticalAlertScreen> {
  final TextEditingController _justificationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button until resumed
      child: Scaffold(
        backgroundColor: const Color(0xFF1F1212),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Critical Icon & Pulse Badge
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEF4444), width: 3),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 54,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Title
                const Text(
                  'الإنذار الرابع الحرج (مخالفة نظامية)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'تم رصد خمول ميداني متواصل وتجاوز المهلة المسموحة للزيارة دون استقرار أو تحرك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Color(0xFFD1D5DB),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Penalty Card (بدء احتساب خارج الدوام)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.timer_off_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الإجراء التشغيلي المتخذ:',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    color: Color(0xFFFCA5A5),
                                  ),
                                ),
                                Text(
                                  'بدء احتساب الوقت كـ "خارج الدوام"',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF991B1B), height: 24),
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تم توثيق المخالفة في سجل الامتثال وإشعار المشرف المباشر تلقائياً.',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Justification Form
                const Text(
                  'تقديم تبرير للمشرف (اختياري / موثق):',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _justificationController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'stop_reason_hint'.tr,
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'Tajawal', fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF374151)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Resume Action Button
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleResumeShift,
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text(
                    'استئناف النشاط الميداني والعودة للدوام',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF30913F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                ),

                const SizedBox(height: 14),

                // Secondary Button: Request Rest
                OutlinedButton(
                  onPressed: () {
                    if (Get.isRegistered<EmployeeShiftController>()) {
                      Get.find<EmployeeShiftController>().requestBreak();
                    }
                    if (Get.isRegistered<AntiFraudAlertsController>()) {
                      Get.find<AntiFraudAlertsController>().resumeActivity();
                    }
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4B5563)),
                    foregroundColor: const Color(0xFFD1D5DB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'تحويل إلى "طلب راحة مصرحة"',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleResumeShift() {
    setState(() => _isSubmitting = true);

    if (Get.isRegistered<AntiFraudAlertsController>()) {
      Get.find<AntiFraudAlertsController>().resumeActivity();
    }

    // Give visual feedback and return
    Get.back();
    Get.snackbar(
      'تم استئناف العمل',
      'تم تسجيل استئناف النشاط وإرسال التبرير إلى المشرف.',
      backgroundColor: const Color(0xFF30913F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
