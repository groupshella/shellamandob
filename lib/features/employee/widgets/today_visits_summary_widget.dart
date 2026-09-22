import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';

class TodayVisitsSummaryWidget extends StatelessWidget {
  final VoidCallback? onStartNextVisit;
  final bool? isDark;

  const TodayVisitsSummaryWidget({
    super.key,
    this.onStartNextVisit,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = dark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final innerBg = dark ? const Color(0xFF252B37) : const Color(0xFFFAF9FB);
    final innerBorder = dark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final btnBg = dark ? const Color(0xFF2B3240) : const Color(0xFFF6F6F6);
    final btnText = dark ? Colors.white : const Color(0xFF43474F);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final model = controller.shiftModel;

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
              // Title: today_visits
              Text(
                'today_visits'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),

              // Row 1: مكتملة (Right in RTL) & إجمالي الزيارات (Left in RTL)
              Row(
                children: [
                  // مكتملة (Child 0 -> Far right in RTL)
                  Expanded(
                    child: _buildCounterCard(
                      label: 'completed'.tr,
                      count: model.completedVisits,
                      badgeColor: dark ? const Color(0xFF163E20) : const Color(0x1722C55E),
                      textColor: dark ? const Color(0xFF81C784) : const Color(0xFF22C55E),
                      innerBg: innerBg,
                      innerBorder: innerBorder,
                      subText: subText,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // إجمالي الزيارات (Child 1 -> Far left in RTL)
                  Expanded(
                    child: _buildCounterCard(
                      label: 'total_visits'.tr,
                      count: model.totalVisits,
                      badgeColor: dark ? const Color(0xFF1E3A5F) : const Color(0x173B82F6),
                      textColor: dark ? const Color(0xFF90CAF9) : const Color(0xFF3B82F6),
                      innerBg: innerBg,
                      innerBorder: innerBorder,
                      subText: subText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: قادمة (Right in RTL) & تحتاج متابعة (Left in RTL)
              Row(
                children: [
                  // قادمة (Child 0 -> Far right in RTL)
                  Expanded(
                    child: _buildCounterCard(
                      label: 'upcoming'.tr,
                      count: model.upcomingVisits,
                      badgeColor: dark ? const Color(0xFF3B2E15) : const Color(0x17F59E0B),
                      textColor: dark ? const Color(0xFFFFD54F) : const Color(0xFFF59E0B),
                      innerBg: innerBg,
                      innerBorder: innerBorder,
                      subText: subText,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // تحتاج متابعة (Child 1 -> Far left in RTL)
                  Expanded(
                    child: _buildCounterCard(
                      label: 'needs_follow_up'.tr,
                      count: model.followUpVisits,
                      badgeColor: dark ? const Color(0xFF2C2242) : const Color(0x177861A6),
                      textColor: dark ? const Color(0xFFCE93D8) : const Color(0xFF7861A6),
                      innerBg: innerBg,
                      innerBorder: innerBorder,
                      subText: subText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Button: بدء الزيارة التالية
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onStartNextVisit,
                  icon: Icon(
                    IconlyLight.location,
                    size: 20,
                    color: btnText,
                  ),
                  label: Text(
                    'start_next_visit'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: btnText,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterCard({
    required String label,
    required int count,
    required Color badgeColor,
    required Color textColor,
    required Color innerBg,
    required Color innerBorder,
    required Color subText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: innerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: innerBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label (Right in RTL)
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subText,
              ),
            ),
          ),

          // Badge (Left in RTL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
