import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../models/employee_shift_model.dart';

class ShiftMetricsGridWidget extends StatelessWidget {
  final bool? isDark;
  const ShiftMetricsGridWidget({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final dark = isDark ??
        (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
    final iconGray = dark ? const Color(0xFF9CA3AF) : const Color(0xFFB0B5BC);
    final purpleBg = dark ? const Color(0xFF261D3B) : const Color(0xFFE5DDFB);
    final purpleTitle = dark ? const Color(0xFFD3BFFF) : const Color(0xFF331259);
    final purpleValue = dark ? Colors.white : const Color(0xFF240648);
    final cardBg = dark ? const Color(0xFF1C2028) : const Color(0xFFFDFDFE);
    final borderColor = dark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final model = controller.shiftModel;
        final bool showValues = controller.status != ShiftStatus.notStarted;
        final workTime = model.localizedWorkedTime;
        final String currentDate =
            DateFormat('d MMMM y', Get.locale?.languageCode ?? 'ar').format(DateTime.now());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              // Row 1: وقت بدء الدوام (Right in RTL) & وقت العمل (Left in RTL)
              Row(
                children: [
                  // 1. وقت بدء الدوام (Right in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'shift_start_time'.tr,
                      value: model.localizedStartTime,
                      showValue: showValues,
                      backgroundColor: purpleBg,
                      borderColor: purpleBg,
                      titleColor: purpleTitle,
                      valueColor: purpleValue,
                      iconWidget: Icon(
                        IconlyLight.work,
                        size: 18,
                        color: purpleTitle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. وقت العمل (Left in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'work_time'.tr,
                      value: workTime,
                      showValue: showValues,
                      backgroundColor: cardBg,
                      borderColor: borderColor,
                      titleColor: subText,
                      valueColor: darkText,
                      iconWidget: _buildBriefcaseWithBadge(
                        iconColor: iconGray,
                        badgeBg: cardBg,
                        badgeIcon: Icons.access_time_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: خارج الدوام (Right in RTL) & الاستئذان المعتمد (Left in RTL)
              Row(
                children: [
                  // 3. خارج الدوام (Right in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'overtime_hours'.tr,
                      value: model.localizedOvertimeHours,
                      showValue: showValues,
                      backgroundColor: cardBg,
                      borderColor: borderColor,
                      titleColor: subText,
                      valueColor: darkText,
                      iconWidget: _buildBriefcaseWithBadge(
                        iconColor: iconGray,
                        badgeBg: cardBg,
                        badgeIcon: Icons.close_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 4. الاستئذان المعتمد (Left in RTL)
                  Expanded(
                    child: _buildMetricCard(
                      date: currentDate,
                      title: 'approved_leave'.tr,
                      value: model.localizedApprovedLeaveHours,
                      showValue: showValues,
                      backgroundColor: cardBg,
                      borderColor: borderColor,
                      titleColor: subText,
                      valueColor: darkText,
                      iconWidget: Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                        color: iconGray,
                      ),
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

  Widget _buildBriefcaseWithBadge({
    required Color iconColor,
    required Color badgeBg,
    required IconData badgeIcon,
  }) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            IconlyLight.work,
            size: 18,
            color: iconColor,
          ),
          Positioned(
            bottom: -1,
            left: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                badgeIcon,
                size: 9,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String date,
    required String title,
    required String value,
    required bool showValue,
    required Color backgroundColor,
    required Color borderColor,
    required Color titleColor,
    required Color valueColor,
    required Widget iconWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date (Top right in RTL)
          Text(
            date,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: titleColor.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),

          // Icon + Title aligned together on the Right in RTL (Figma 1:1)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Value (Only shown in active and onBreak states per Figma)
          if (showValue) ...[
            const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}
