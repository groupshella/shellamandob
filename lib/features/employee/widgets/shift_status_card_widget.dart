import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../models/employee_shift_model.dart';

class ShiftStatusCardWidget extends StatelessWidget {
  final VoidCallback? onStartShift;
  final VoidCallback? onRequestBreak;
  final VoidCallback? onResumeWork;
  final VoidCallback? onEndShift;
  final bool? isDark;

  const ShiftStatusCardWidget({
    super.key,
    this.onStartShift,
    this.onRequestBreak,
    this.onResumeWork,
    this.onEndShift,
    this.isDark,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = dark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final status = controller.status;
        final isActive = status == ShiftStatus.active;
        final isOnBreak = status == ShiftStatus.onBreak;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Status Title & Dot (Right in RTL) + Pill Badge (Left in RTL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Dot (Child 0 -> Far right in RTL)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'shift_status'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: subText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusDotColor(status),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusTitle(status),
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Pill Badge (Child 1 -> Far left in RTL)
                  _buildPillBadge(status, dark),
                ],
              ),
              const SizedBox(height: 16),

              // Middle & Action Content according to status
              if (status == ShiftStatus.notStarted) ...[
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onStartShift ?? () => controller.startShift(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'start_shift'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else if (isActive) ...[
                // Timer Container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        controller.formattedWorkTimer,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: _primaryGreen,
                          letterSpacing: 1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'actual_work_time'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dark ? const Color(0xFF81C784) : const Color(0xFF236B30),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Active Buttons: طلب الراحة (Right in RTL) & إنهاء الدوام (Left in RTL)
                Row(
                  children: [
                    // طلب الراحة (Green button - Child 0 -> Right in RTL)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isLoading ? null : (onRequestBreak ?? () => controller.requestBreak()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'request_break'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // إنهاء الدوام
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isLoading ? null : (onEndShift ?? () => controller.endShift()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dark ? const Color(0xFF2B3240) : const Color(0xFFF6F6F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'end_shift'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: dark ? Colors.white : const Color(0xFF43474F),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (isOnBreak) ...[
                // Break State: استئناف العمل
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : (onResumeWork ?? () => controller.resumeWork()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'resume_work'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getStatusTitle(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.active:
        return 'shift_active'.tr;
      case ShiftStatus.onBreak:
        return 'shift_on_break'.tr;
      case ShiftStatus.notStarted:
        return 'shift_not_started'.tr;
    }
  }

  Color _getStatusDotColor(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.active:
        return const Color(0xFF3EC856);
      case ShiftStatus.onBreak:
        return const Color(0xFFF59E0B);
      case ShiftStatus.notStarted:
        return const Color(0xFF555555);
    }
  }

  Widget _buildPillBadge(ShiftStatus status, bool isDark) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case ShiftStatus.active:
        label = 'active'.tr;
        bgColor = isDark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9);
        textColor = isDark ? const Color(0xFF81C784) : _primaryGreen;
        break;
      case ShiftStatus.onBreak:
        label = 'break'.tr;
        bgColor = isDark ? const Color(0xFF3B2E15) : const Color(0xFFFEF3C7);
        textColor = const Color(0xFFF59E0B);
        break;
      case ShiftStatus.notStarted:
        label = 'inactive'.tr;
        bgColor = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
