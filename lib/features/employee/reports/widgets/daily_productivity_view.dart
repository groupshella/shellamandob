import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../models/marketer_productivity_model.dart';
import '../../visits/screens/daily_visits_screen.dart';

/// Daily Productivity View faithfully matching Figma Frame 8949:41979
/// Specifications:
/// - 4 KPI Cards: Two rows, each with 2 distinct cards (width: 168px, height: 68px, borderRadius: 18px, boxShadow: 0px 1px 6px rgba(0,0,0,0.05)).
/// - Daily Target Card: borderRadius 18px, badge "16 / 12" in #E8F5E9 (#30913F 12px Bold), Progress Bar (height: 8px, borderRadius: 4px), Subtitle (12px #555555).
/// - Day Timeline Card: borderRadius 18px, title "تفاصيل اليوم" (13px Bold), continuous dashed/solid vertical track with timeline steps.
/// - Signed Agreements Card: borderRadius 18px, title "الاتفاقيات الموقعة" (13px Bold), badge statuses.
/// - Upcoming Follow-ups Card: borderRadius 18px, title "المتابعات القادمة" (13px Bold) + "عرض الكل".
class DailyProductivityView extends StatelessWidget {
  final DailyProductivityModel data;

  const DailyProductivityView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF3F4F6);
        final innerItemBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top 4 Individual KPI Cards Grid (Figma Frame 2085665812)
              _buildKpiGrid(data.kpis, cardBg, borderColor, subTextColor, isDark),

              const SizedBox(height: 12),

              // 2. Three Targets Row (الهدف اليومي للزيارات | تارجت التجار شهرياً | تارجت شبكة المسوقين)
              _buildTargetsRow(
                dailyTarget: data.dailyTarget,
                storesTarget: data.monthlyStoresTarget,
                marketersTarget: data.monthlyMarketersTarget,
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subTextColor: subTextColor,
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              // 3. Day Timeline (Figma 8954:2715 - تفاصيل اليوم)
              _buildTimelineSection(data.timeline, cardBg, borderColor, textColor, subTextColor, isDark),

              const SizedBox(height: 12),

              // 4. Signed Agreements (Figma 8954:2814 - الاتفاقيات الموقعة)
              _buildSignedAgreementsSection(data.signedAgreements, cardBg, borderColor, textColor, subTextColor, dividerColor, isDark),

              const SizedBox(height: 12),

              // 5. Upcoming Follow-ups (Figma 8954:2834 - المتابعات القادمة)
              _buildUpcomingFollowUpsSection(data.upcomingFollowUps, cardBg, borderColor, textColor, subTextColor, innerItemBg),

              const SizedBox(height: 96),
            ],
          ),
        );
      },
    );
  }

  // 1. Top 4 KPI Cards (Figma Frame 2085665812 - 2 rows of 2 separate 18px rounded cards)
  Widget _buildKpiGrid(
    ProductivityKpis kpis,
    Color cardBg,
    Color borderColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Column(
      children: [
        // Row 1 (RTL): ساعات العمل (start/right) & الزيارات الناجحة (end/left)
        Row(
          children: [
            Expanded(
              child: _buildIndividualKpiCard(
                title: 'work_hours_label'.tr,
                value: kpis.workHours,
                valueColor: const Color(0xFF30913F),
                cardBg: cardBg,
                borderColor: borderColor,
                subTextColor: subTextColor,
                isDark: isDark,
                svgAsset: 'assets/image/figma_prod_work_hours.svg',
                iconColor: const Color(0xFF30913F),
                iconBg: isDark ? const Color(0xFF132D1B) : const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIndividualKpiCard(
                title: 'successful_visits_label'.tr,
                value: kpis.successfulVisitsText,
                valueColor: const Color(0xFF30913F),
                cardBg: cardBg,
                borderColor: borderColor,
                subTextColor: subTextColor,
                isDark: isDark,
                svgAsset: 'assets/image/figma_prod_visits.svg',
                iconColor: const Color(0xFF30913F),
                iconBg: isDark ? const Color(0xFF132D1B) : const Color(0xFFE8F5E9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 2 (RTL): الاتفاقيات الموقعة (start/right) & الإنذارات (end/left)
        Row(
          children: [
            Expanded(
              child: _buildIndividualKpiCard(
                title: 'signed_agreements_label'.tr,
                value: kpis.signedContractsText,
                valueColor: const Color(0xFF7861A6),
                cardBg: cardBg,
                borderColor: borderColor,
                subTextColor: subTextColor,
                isDark: isDark,
                svgAsset: 'assets/image/figma_prod_agreements.svg',
                iconColor: const Color(0xFF7861A6),
                iconBg: isDark ? const Color(0xFF2C203E) : const Color(0xFFF3E8FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIndividualKpiCard(
                title: 'warnings_label'.tr,
                value: kpis.warningsText,
                valueColor: const Color(0xFFDC2626),
                cardBg: cardBg,
                borderColor: borderColor,
                subTextColor: subTextColor,
                isDark: isDark,
                svgAsset: 'assets/image/figma_prod_danger.svg',
                iconColor: const Color(0xFFDC2626),
                iconBg: isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndividualKpiCard({
    required String title,
    required String value,
    required Color valueColor,
    required Color cardBg,
    required Color borderColor,
    required Color subTextColor,
    required bool isDark,
    required String svgAsset,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              svgAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Three Targets Row (Figma: الهدف اليومي للزيارات | تارجت التجار شهرياً | تارجت شبكة المسوقين)
  Widget _buildTargetsRow({
    required DailyTargetInfo dailyTarget,
    required DailyTargetInfo storesTarget,
    required DailyTargetInfo marketersTarget,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCompactTargetCard(
            title: 'daily_visits_target_title'.tr,
            target: dailyTarget,
            unitText: 'visits_unit'.tr,
            accentColor: const Color(0xFF30913F),
            badgeBg: isDark ? const Color(0xFF132D1B) : const Color(0xFFE8F5E9),
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactTargetCard(
            title: 'monthly_merchants_target_title'.tr,
            target: storesTarget,
            unitText: 'contracts_unit'.tr,
            accentColor: const Color(0xFF30913F),
            badgeBg: isDark ? const Color(0xFF132D1B) : const Color(0xFFE8F5E9),
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactTargetCard(
            title: 'marketers_network_target_title'.tr,
            target: marketersTarget,
            unitText: 'marketers_unit'.tr,
            accentColor: const Color(0xFF7861A6),
            progressGradient: const LinearGradient(
              colors: [Color(0xFF7861A6), Color(0xFFA188D1)],
            ),
            badgeBg: isDark ? const Color(0xFF2C203E) : const Color(0xFFF3E8FF),
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTargetCard({
    required String title,
    required DailyTargetInfo target,
    required String unitText,
    required Color accentColor,
    Gradient? progressGradient,
    required Color badgeBg,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    final progress = (target.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 34,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252B37) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progressGradient == null ? accentColor : null,
                  gradient: progressGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                target.targetText,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${'remaining_word'.tr} ${target.remaining} $unitText - ${target.percentage}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Day Timeline (Figma Container 8954:2715 - 18px rounded)
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'day_details_label'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          if (timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'no_activity_today'.tr,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subTextColor),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final item = timeline[index];
                final isLast = index == timeline.length - 1;
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
    Color dotColor = const Color(0xFF30913F);
    if (item.type == 'warning') {
      dotColor = const Color(0xFFDC2626);
    } else if (item.type == 'contract') {
      dotColor = const Color(0xFF7861A6);
    } else if (item.type == 'incomplete') {
      dotColor = const Color(0xFFF59E0B);
    } else if (item.type == 'shift') {
      dotColor = const Color(0xFF6B7280);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator (Dot + Line)
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
                    width: 1,
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.time,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        color: dotColor,
                        fontWeight: FontWeight.w600,
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

  // 4. Signed Agreements (Figma Container 8954:2814 - 18px rounded)
  Widget _buildSignedAgreementsSection(
    List<SignedAgreementItem> agreements,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color dividerColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'signed_agreements_label'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          if (agreements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'no_contracts_today'.tr,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subTextColor),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: agreements.length,
              separatorBuilder: (_, __) => Divider(height: 18, color: dividerColor),
              itemBuilder: (context, index) {
                final a = agreements[index];
                final isGreen = a.status.contains('تم') || a.status.contains('مكتمل');
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isGreen
                                ? (isDark ? const Color(0xFF1E3A2B) : const Color(0xFFDCFCE7))
                                : (isDark ? const Color(0xFF3B2A15) : const Color(0xFFFEF3C7)),
                            borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/image/figma_prod_arrow_left.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(subTextColor, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // 5. Upcoming Follow-ups (Figma Container 8954:2834 - 18px rounded)
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
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
                  fontSize: 13,
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
          if (followUps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'no_followups_scheduled'.tr,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subTextColor),
                ),
              ),
            )
          else
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
