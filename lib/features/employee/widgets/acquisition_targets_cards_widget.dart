import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';

/// Home screen monthly acquisition target cards matching Figma:
/// 1. استقطاب المتاجر (Green progress bar & store icon)
/// 2. استقطاب المسوقين (Purple progress bar & users icon)
class AcquisitionTargetsCardsWidget extends StatelessWidget {
  final bool? isDark;

  const AcquisitionTargetsCardsWidget({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final dark = isDark ??
        (Get.isRegistered<ThemeController>() &&
            Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor =
        dark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);
    final titleColor = dark ? Colors.white : const Color(0xFF111B18);
    final subTextColor =
        dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final trackBg = dark ? const Color(0xFF252B37) : const Color(0xFFE5E7EB);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final model = controller.shiftModel;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _buildTargetCard(
                title: 'stores_acquisition_title'.tr,
                percent: model.storesPercent,
                target: model.storesTarget,
                remaining: model.storesRemaining,
                achieved: model.storesAchieved,
                accentColor: const Color(0xFF30913F),
                badgeBg: dark
                    ? const Color(0xFF132D1B)
                    : const Color(0xFFEBFEEB),
                icon: Icons.storefront_outlined,
                cardBg: cardBg,
                borderColor: borderColor,
                titleColor: titleColor,
                subTextColor: subTextColor,
                trackBg: trackBg,
              ),
              const SizedBox(height: 12),
              _buildTargetCard(
                title: 'marketers_acquisition_title'.tr,
                percent: model.marketersPercent,
                target: model.marketersTarget,
                remaining: model.marketersRemaining,
                achieved: model.marketersAchieved,
                accentColor: const Color(0xFF7861A6),
                badgeBg: dark
                    ? const Color(0xFF2C203E)
                    : const Color(0xFFF3E8FF),
                icon: Icons.groups_outlined,
                cardBg: cardBg,
                borderColor: borderColor,
                titleColor: titleColor,
                subTextColor: subTextColor,
                trackBg: trackBg,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetCard({
    required String title,
    required int percent,
    required int target,
    required int remaining,
    required int achieved,
    required Color accentColor,
    required Color badgeBg,
    required IconData icon,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subTextColor,
    required Color trackBg,
  }) {
    final progress = (percent / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: trackBg,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'target_word'.tr} $target',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
              Text(
                '$remaining ${'remaining_word'.tr}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
              Text(
                '$achieved ${'completed_word'.tr}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
