import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/employee_shift_controller.dart';

class ShiftMetricsGridWidget extends StatelessWidget {
  const ShiftMetricsGridWidget({super.key});

  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF555555);
  static const Color _purpleBg = Color(0xFFDFD3F5);
  static const Color _purpleTitle = Color(0xFF331259);
  static const Color _purpleValue = Color(0xFF240648);
  static const Color _cardBg = Color(0xFFFAFBFB);
  static const Color _borderColor = Color(0xFFF0F0F2);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final model = controller.shiftModel;
        final workTime = model.localizedWorkedTime;
        final String currentDate = DateFormat('d MMMM y', Get.locale?.languageCode ?? 'ar').format(DateTime.now());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              // Row 1: وقت بدء الدوام (Right in RTL) & وقت العمل (Left in RTL)
              Row(
                children: [
                  // وقت بدء الدوام (Child 0 -> Far right in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'shift_start_time'.tr,
                      value: model.localizedStartTime,
                      backgroundColor: _purpleBg,
                      titleColor: _purpleTitle,
                      valueColor: _purpleValue,
                      icon: IconlyLight.timeCircle,
                      iconColor: _purpleTitle,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // وقت العمل (Child 1 -> Far left in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'work_time'.tr,
                      value: workTime,
                      backgroundColor: _cardBg,
                      titleColor: _subText,
                      valueColor: _darkText,
                      icon: IconlyLight.work,
                      iconColor: _subText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: خارج الدوام (Right in RTL) & الاستئذان المعتمد (Left in RTL)
              Row(
                children: [
                  // خارج الدوام (Child 0 -> Far right in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'overtime_hours'.tr,
                      value: model.localizedOvertimeHours,
                      backgroundColor: _cardBg,
                      titleColor: _subText,
                      valueColor: _darkText,
                      icon: IconlyLight.timeSquare,
                      iconColor: _subText,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // الاستئذان المعتمد (Child 1 -> Far left in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'approved_leave'.tr,
                      value: model.localizedApprovedLeaveHours,
                      backgroundColor: _cardBg,
                      titleColor: _subText,
                      valueColor: _darkText,
                      icon: IconlyLight.ticketStar,
                      iconColor: _subText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String date,
    required String title,
    required String value,
    required Color backgroundColor,
    required Color titleColor,
    required Color valueColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: _subText,
            ),
          ),
          const SizedBox(height: 6),

          // Title & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? titleColor,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
