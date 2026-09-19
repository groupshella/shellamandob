import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_shift_controller.dart';
import '../models/employee_shift_model.dart';

class ShiftStatusCardWidget extends StatelessWidget {
  final VoidCallback? onStartShift;
  final VoidCallback? onRequestBreak;
  final VoidCallback? onResumeWork;
  final VoidCallback? onEndShift;

  const ShiftStatusCardWidget({
    super.key,
    this.onStartShift,
    this.onRequestBreak,
    this.onResumeWork,
    this.onEndShift,
  });

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final status = controller.status;
        final isActive = status == ShiftStatus.active;
        final isOnBreak = status == ShiftStatus.onBreak;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
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
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: _subText,
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
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _darkText,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Pill Badge (Child 1 -> Far left in RTL)
                  _buildPillBadge(status),
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
                // Timer Container (matching Figma bg: #E8F5E9)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
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
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF236B30),
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

                    // إنهاء الدوام (Light grey button #F6F6F6 - Child 1 -> Left in RTL)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isLoading ? null : (onEndShift ?? () => controller.endShift()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6F6F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'end_shift'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF43474F),
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

  Widget _buildPillBadge(ShiftStatus status) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case ShiftStatus.active:
        label = 'active'.tr;
        bgColor = const Color(0xFFE8F5E9);
        textColor = _primaryGreen;
        break;
      case ShiftStatus.onBreak:
        label = 'break'.tr;
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFF59E0B);
        break;
      case ShiftStatus.notStarted:
        label = 'inactive'.tr;
        bgColor = const Color(0xFFF6F5F8);
        textColor = const Color(0xFF555555);
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
