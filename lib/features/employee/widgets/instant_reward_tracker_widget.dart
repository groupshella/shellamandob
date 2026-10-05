import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/visits/controllers/store_visits_controller.dart';

class InstantRewardTrackerWidget extends StatefulWidget {
  final bool? isDark;

  const InstantRewardTrackerWidget({super.key, this.isDark});

  @override
  State<InstantRewardTrackerWidget> createState() => _InstantRewardTrackerWidgetState();
}

class _InstantRewardTrackerWidgetState extends State<InstantRewardTrackerWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark ??
        (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = dark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return GetBuilder<StoreVisitsController>(
      init: Get.isRegistered<StoreVisitsController>()
          ? Get.find<StoreVisitsController>()
          : Get.put(StoreVisitsController(), permanent: true),
      builder: (controller) {
        // ── Collapsed / Minimized View with Mini Details ──
        if (!_isExpanded) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => setState(() => _isExpanded = true),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wallet icon + Title & Total earnings
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF30913F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          IconlyBold.wallet,
                          size: 16,
                          color: Color(0xFF30913F),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مكافآت اليوم:',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${controller.todayEarnings.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF30913F),
                        ),
                      ),
                    ],
                  ),

                  // Mini details micro-chips as requested
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF252B37) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'عقود: ${controller.todayContractsCount}',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF252B37) : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD97706).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'تفعيل: ${controller.todayQaidhaCount}',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: subText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // ── Expanded Full View ──
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
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
              // Header Row: Title, Refresh & Collapse Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF30913F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          IconlyBold.wallet,
                          size: 20,
                          color: Color(0xFF30913F),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'عداد مكافآت التأسيس الفورية',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'تحديث لحظي ومباشر مع كل تعاقد وتفعيل',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => controller.loadRewardSettings(),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: subText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => setState(() => _isExpanded = false),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 20,
                            color: subText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Today's Earnings Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: dark
                        ? [const Color(0xFF1B382B), const Color(0xFF12281D)]
                        : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF30913F).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أرباح ومكافآت اليوم',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: dark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              controller.todayEarnings.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: dark ? Colors.white : const Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ر.س',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: dark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30913F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'مباشر',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Breakdown Row: Contracts & Qaidha
              Row(
                children: [
                  // Contract Signing Card
                  Expanded(
                    child: _buildRewardSubCard(
                      dark: dark,
                      title: 'توقيع العقد',
                      rate: '+${controller.contractSigningReward.toStringAsFixed(0)} ر.س',
                      count: controller.todayContractsCount,
                      countLabel: 'عقد اليوم',
                      icon: IconlyLight.document,
                      accentColor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Qaidha / Promo Activation Card
                  Expanded(
                    child: _buildRewardSubCard(
                      dark: dark,
                      title: 'تفعيل قيدها / عروض',
                      rate: '+${controller.qaidhaActivationReward.toStringAsFixed(0)} ر.س',
                      count: controller.todayQaidhaCount,
                      countLabel: 'تفعيل اليوم',
                      icon: IconlyLight.discount,
                      accentColor: const Color(0xFFD97706),
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

  Widget _buildRewardSubCard({
    required bool dark,
    required String title,
    required String rate,
    required int count,
    required String countLabel,
    required IconData icon,
    required Color accentColor,
  }) {
    final subBg = dark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
    final subBorder = dark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: subBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: accentColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rate,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$count ',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              Text(
                countLabel,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
