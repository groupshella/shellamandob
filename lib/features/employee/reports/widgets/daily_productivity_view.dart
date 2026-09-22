import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../models/marketer_productivity_model.dart';
import '../../visits/screens/daily_visits_screen.dart';

class DailyProductivityView extends StatelessWidget {
  final DailyProductivityModel data;

  const DailyProductivityView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);
        final textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF3F4F6);
        final innerItemBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top 4 KPI Cards Grid
              _buildKpiGrid(data.kpis, cardBg, borderColor, dividerColor, subTextColor),

              const SizedBox(height: 16),

              // 2. Daily Target Progress Card (الهدف اليومي)
              _buildDailyTargetCard(data.dailyTarget, cardBg, borderColor, textColor, subTextColor, isDark),

              const SizedBox(height: 20),

              // 3. Day Timeline (تفاصيل اليوم)
              _buildTimelineSection(data.timeline, cardBg, borderColor, textColor, subTextColor, isDark),

              const SizedBox(height: 20),

              // 4. Signed Agreements (الاتفاقيات الموقعة)
              _buildSignedAgreementsSection(data.signedAgreements, cardBg, borderColor, textColor, subTextColor, dividerColor),

              const SizedBox(height: 20),

              // 5. Upcoming Follow-ups (المتابعات القادمة)
              _buildUpcomingFollowUpsSection(data.upcomingFollowUps, cardBg, borderColor, textColor, subTextColor, innerItemBg),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // 1. Top 4 KPI Grid matching Figma Frame 2085665812
  Widget _buildKpiGrid(
    ProductivityKpis kpis,
    Color cardBg,
    Color borderColor,
    Color dividerColor,
    Color subTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          // Row 1: الزيارات الناجحة & ساعات العمل
          Row(
            children: [
              Expanded(
                child: _buildKpiItem(
                  title: 'successful_visits_label'.tr,
                  value: kpis.successfulVisitsText,
                  valueColor: const Color(0xFF30913F),
                  subTextColor: subTextColor,
                ),
              ),
              Container(width: 1, height: 44, color: dividerColor),
              Expanded(
                child: _buildKpiItem(
                  title: 'work_hours_label'.tr,
                  value: kpis.workHours,
                  valueColor: const Color(0xFF30913F),
                  subTextColor: subTextColor,
                ),
              ),
            ],
          ),
          Divider(height: 20, thickness: 1, color: dividerColor),
          // Row 2: الإنذارات & الاتفاقيات الموقعة
          Row(
            children: [
              Expanded(
                child: _buildKpiItem(
                  title: 'warnings_label'.tr,
                  value: kpis.warningsText,
                  valueColor: const Color(0xFFDC2626),
                  subTextColor: subTextColor,
                  icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                ),
              ),
              Container(width: 1, height: 44, color: dividerColor),
              Expanded(
                child: _buildKpiItem(
                  title: 'signed_agreements_label'.tr,
                  value: kpis.signedContractsText,
                  valueColor: const Color(0xFF7861A6),
                  subTextColor: subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem({
    required String title,
    required String value,
    required Color valueColor,
    required Color subTextColor,
    Widget? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                icon,
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 2. Daily Target Progress Card
  Widget _buildDailyTargetCard(
    DailyTargetInfo target,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    final progress = (target.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
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
                  color: textColor,
                ),
              ),
              Text(
                target.targetText,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF30913F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: isDark ? const Color(0xFF252B37) : const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            target.subtitle,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Day Timeline (تفاصيل اليوم)
  Widget _buildTimelineSection(
    List<TimelineItem> timeline,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'day_details_label'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              final isLast = (index == timeline.length - 1);
              return _buildTimelineRow(item, isLast, textColor, subTextColor, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    TimelineItem item,
    bool isLast,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    Color dotColor = const Color(0xFF9CA3AF);
    if (item.statusColor == 'green') dotColor = const Color(0xFF30913F);
    if (item.statusColor == 'orange') dotColor = const Color(0xFFF59E0B);
    if (item.statusColor == 'red') dotColor = const Color(0xFFDC2626);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 58,
            child: Text(
              item.time,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11,
                color: subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Vertical line and indicator dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Title & optional badge
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.statusColor == 'green'
                            ? (isDark ? const Color(0xFF1E3A2B) : const Color(0xFFDCFCE7))
                            : (isDark ? const Color(0xFF3B2A15) : const Color(0xFFFEF3C7)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: item.statusColor == 'green'
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Signed Agreements (الاتفاقيات الموقعة)
  Widget _buildSignedAgreementsSection(
    List<SignedAgreementItem> agreements,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color dividerColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'signed_agreements_label'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agreements.length,
            separatorBuilder: (_, __) => Divider(height: 16, thickness: 0.8, color: dividerColor),
            itemBuilder: (context, index) {
              final a = agreements[index];
              final isGreen = a.statusColor == 'green';
              final isDark = Theme.of(context).brightness == Brightness.dark || Get.find<ThemeController>().darkTheme;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.storeName,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.time,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGreen
                          ? (isDark ? const Color(0xFF1E3A2B) : const Color(0xFFDCFCE7))
                          : (isDark ? const Color(0xFF3B2A15) : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      a.status,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isGreen ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 5. Upcoming Follow-ups (المتابعات القادمة)
  Widget _buildUpcomingFollowUpsSection(
    List<UpcomingFollowUpItem> followUps,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color innerItemBg,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'upcoming_follow_ups_label'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => const DailyVisitsScreen());
                },
                child: Text(
                  'view_all_action'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30913F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: followUps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final f = followUps[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: innerItemBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.datetimeText,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f.storeName,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f.note,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
