import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import '../controllers/employee_navigation_controller.dart';
import '../controllers/employee_shift_controller.dart';

class ShiftSmartAlertsBanner extends StatelessWidget {
  final bool? isDark;
  const ShiftSmartAlertsBanner({super.key, this.isDark});

  static const Color _amberBorder = Color(0xFFF59E0B);
  static const Color _amberText = Color(0xFFB45309);
  static const Color _blueBorder = Color(0xFF3B82F6);
  static const Color _blueText = Color(0xFF1D4ED8);

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final alerts = controller.shiftAlertsData;
        if (alerts == null) return const SizedBox.shrink();

        final List<dynamic> dueFollowUps = alerts['due_follow_ups'] ?? [];
        final Map<String, dynamic>? shiftInfo = alerts['shift_info'] != null ? Map<String, dynamic>.from(alerts['shift_info']) : null;
        final Map<String, dynamic>? targetProgress = alerts['target_progress'] != null ? Map<String, dynamic>.from(alerts['target_progress']) : null;

        final bool hasFollowUps = dueFollowUps.isNotEmpty;
        final bool isNearEnd = shiftInfo?['is_near_end'] == true;
        final bool isOverdue = shiftInfo?['is_overdue'] == true;

        if (!hasFollowUps && !isNearEnd && !isOverdue) {
          return const SizedBox.shrink();
        }

        final amberBg = dark ? const Color(0xFF38260D) : const Color(0xFFFFFBEB);
        final blueBg = dark ? const Color(0xFF0F2547) : const Color(0xFFEFF6FF);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 6),
          child: Column(
            children: [
              // 1. Follow-up Reminders Alert
              if (hasFollowUps) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: amberBg,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: _amberBorder.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _amberBorder.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: _amberBorder, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'follow_up_alert_title'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: _amberText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${'you_have'.tr} ${dueFollowUps.length} ${'due_follow_ups_today'.tr}',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: dark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (Get.isRegistered<EmployeeNavigationController>()) {
                            Get.find<EmployeeNavigationController>().changeIndex(2); // Visits Tab
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _amberBorder,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'view_action'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 2. Shift Ending / Target Alert
              if (isNearEnd || isOverdue) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: blueBg,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: _blueBorder.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _blueBorder.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOverdue ? Icons.timer_off_outlined : Icons.timer_outlined,
                          color: _blueBorder,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOverdue ? 'shift_overdue_title'.tr : 'shift_near_end_title'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: _blueText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              targetProgress != null
                                  ? '${'completed_visits_count'.tr}: ${targetProgress['completed_visits_today'] ?? 0} / ${targetProgress['daily_target_visits'] ?? 0}'
                                  : (shiftInfo?['minutes_remaining'] != null
                                      ? '${'remaining_minutes'.tr}: ${shiftInfo!['minutes_remaining']} ${'minute_unit'.tr}'
                                      : ''),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: dark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (Get.isRegistered<EmployeeNavigationController>()) {
                            Get.find<EmployeeNavigationController>().changeIndex(2); // Visits Tab
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blueBorder,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'complete_visits'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
