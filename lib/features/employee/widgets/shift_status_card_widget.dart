import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../models/employee_shift_model.dart';
import '../visits/controllers/store_visits_controller.dart';

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
    final dark = isDark ??
        (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final model = controller.shiftModel;
        final status = controller.status;
        final isActive = status == ShiftStatus.active;
        final isOnBreak = status == ShiftStatus.onBreak;

        final int targetVisits = model.totalVisits > 0
            ? model.totalVisits
            : StoreVisitsController.dailyTargetVisits;
        final int completedVisits = model.completedVisits;
        final int remainingVisits = (targetVisits - completedVisits).clamp(0, targetVisits);
        final double progress =
            targetVisits > 0 ? (completedVisits / targetVisits).clamp(0.0, 1.0) : 0.0;
        final int percentage = (progress * 100).round();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _primaryGreen,
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
              // Top Row: Status Title & Dot (Right in RTL) + Conditional Pill Badge (Left in RTL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title + Dot (Right in RTL)
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
                          _buildStatusDot(status),
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

                  // Pill Badge (Left in RTL — hidden in active state per Figma)
                  _buildPillBadge(status, dark),
                ],
              ),
              const SizedBox(height: 14),

              // Inner "الهدف اليومي" (Daily Target) Box — matches all 3 Figma states
              if (status == ShiftStatus.notStarted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF252B37) : const Color(0xFFFAFDFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dark ? const Color(0xFF2B3240) : const Color(0xFFD9E8DC),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'daily_target_label'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$targetVisits ${'visit_unit_text'.tr}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dark ? const Color(0xFF81C784) : _primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF252B37) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'daily_target_label'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '$targetVisits / $completedVisits',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: dark ? const Color(0xFF81C784) : _primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: _primaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'remaining_visits_stat'.trParams({
                          'remaining': '$remainingVisits',
                          'percentage': '$percentage',
                        }),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subText,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // Action Buttons according to status
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
                // Active Buttons: طلب الراحة (أخضر يمين) & إنهاء الدوام (رمادي ناعم يسار)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : (onRequestBreak ?? () => controller.requestBreak()),
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
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: controller.isLoading
                              ? null
                              : (onEndShift ?? () => controller.endShift()),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                dark ? const Color(0xFF252B37) : const Color(0xFFF5F6F7),
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
                              color: darkText,
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
                    onPressed: controller.isLoading
                        ? null
                        : (onResumeWork ?? () => controller.resumeWork()),
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

  Widget _buildStatusDot(ShiftStatus status) {
    if (status == ShiftStatus.active) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF3EC856).withValues(alpha: 0.22),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3EC856),
            ),
          ),
        ),
      );
    }

    final Color dotColor = status == ShiftStatus.onBreak
        ? const Color(0xFFF59E0B)
        : const Color(0xFF555555);

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
    );
  }

  Widget _buildPillBadge(ShiftStatus status, bool isDark) {
    // In Figma State 2 (active), there is no pill badge on the left
    if (status == ShiftStatus.active) {
      return const SizedBox.shrink();
    }

    String label;
    Color bgColor;
    Color textColor;

    if (status == ShiftStatus.onBreak) {
      label = 'break'.tr;
      bgColor = isDark ? const Color(0xFF3B2E15) : const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    } else {
      label = 'inactive'.tr;
      bgColor = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
      textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
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
