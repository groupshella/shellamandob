import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../models/marketer_productivity_model.dart';

/// Period Productivity View matching Figma Frame 8956:3247
class PeriodProductivityView extends StatelessWidget {
  final PeriodProductivityModel data;
  final int expandedDayIndex;
  final Function(int index) onDayToggle;

  const PeriodProductivityView({
    super.key,
    required this.data,
    required this.expandedDayIndex,
    required this.onDayToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final innerItemBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
        final innerBorderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF3F4F6);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Target Progress Header & 3 Mini KPI Cards (تحقيق الهدف)
              _buildPeriodTargetHeader(
                data.targetProgress,
                data.kpis,
                cardBg,
                borderColor,
                textColor,
                subTextColor,
                innerItemBg,
                innerBorderColor,
                isDark,
              ),

              const SizedBox(height: 12),

              // 2. Days Accordion List (قائمة الأيام)
              _buildDaysAccordionList(
                data.days,
                cardBg,
                borderColor,
                textColor,
                subTextColor,
                innerItemBg,
                innerBorderColor,
                isDark,
              ),

              const SizedBox(height: 12),

              // 3. Signed Agreements (الاتفاقيات الموقعة)
              _buildSignedAgreementsSection(
                data.signedAgreements,
                cardBg,
                borderColor,
                textColor,
                subTextColor,
                dividerColor,
                isDark,
              ),

              const SizedBox(height: 12),

              // 4. Previous Leaves (الإجازات السابقة - Real DB data)
              _buildPreviousLeavesSection(
                data.previousLeaves,
                cardBg,
                borderColor,
                textColor,
                subTextColor,
                dividerColor,
                isDark,
              ),

              const SizedBox(height: 12),

              // 5. Period Summary (ملخص الفترة)
              _buildPeriodSummarySection(
                data.periodSummary,
                cardBg,
                borderColor,
                textColor,
                subTextColor,
                innerItemBg,
                innerBorderColor,
                isDark,
              ),

              const SizedBox(height: 96),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration(Color cardBg, Color borderColor, bool isDark) {
    return BoxDecoration(
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
    );
  }

  // 1. Target Progress Header & 3 Top Badges (Figma 8956:3247)
  Widget _buildPeriodTargetHeader(
    DailyTargetInfo target,
    PeriodKpis kpis,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color innerItemBg,
    Color innerBorderColor,
    bool isDark,
  ) {
    final progress = (target.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      decoration: _cardDecoration(cardBg, borderColor, isDark),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'target_achievement_label'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132D1B) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  target.targetText,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF30913F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF252B37) : const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
            ),
          ),
          const SizedBox(height: 14),
          // 3 Mini Cards RTL Order: الاتفاقيات الموقعة (start) | ساعات العمل (middle) | الإنذارات (end)
          Row(
            children: [
              Expanded(
                child: _buildHeaderBadge(
                  title: 'signed_agreements_label'.tr,
                  value: kpis.signedContractsText,
                  color: const Color(0xFF7861A6),
                  innerItemBg: innerItemBg,
                  innerBorderColor: innerBorderColor,
                  subTextColor: subTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeaderBadge(
                  title: 'work_hours_label'.tr,
                  value: kpis.workHours,
                  color: const Color(0xFF30913F),
                  innerItemBg: innerItemBg,
                  innerBorderColor: innerBorderColor,
                  subTextColor: subTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeaderBadge(
                  title: 'warnings_label'.tr,
                  value: kpis.warningsText,
                  color: const Color(0xFFDC2626),
                  innerItemBg: innerItemBg,
                  innerBorderColor: innerBorderColor,
                  subTextColor: subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge({
    required String title,
    required String value,
    required Color color,
    required Color innerItemBg,
    required Color innerBorderColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: innerItemBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: innerBorderColor, width: 0.8),
      ),
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Days Accordion List matching Figma Frame 2085665814
  Widget _buildDaysAccordionList(
    List<PeriodDayItem> days,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color innerItemBg,
    Color innerBorderColor,
    bool isDark,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final day = days[index];
        final isExpanded = (expandedDayIndex == index);

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded
                  ? const Color(0xFF30913F).withValues(alpha: 0.5)
                  : borderColor,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row of the Day (Tappable)
              InkWell(
                onTap: () => onDayToggle(index),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Day Name & Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.dayName,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          Text(
                            day.dateFormatted,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Metric Chips
                      _buildChip(
                        count: '${day.visitsCount}',
                        label: 'visit_unit_text'.tr,
                        color: const Color(0xFFF59E0B),
                        subTextColor: subTextColor,
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        count: '${day.contractsCount}',
                        label: 'contract_unit_text'.tr,
                        color: const Color(0xFF7861A6),
                        subTextColor: subTextColor,
                      ),
                      if (day.warningsCount > 0) ...[
                        const SizedBox(width: 6),
                        _buildChip(
                          count: '${day.warningsCount}',
                          label: 'warning_unit_text'.tr,
                          color: const Color(0xFFDC2626),
                          subTextColor: subTextColor,
                        ),
                      ],

                      const SizedBox(width: 8),

                      // Figma Arrow SVG
                      SvgPicture.asset(
                        isExpanded
                            ? 'assets/image/figma_prod_arrow_up.svg'
                            : 'assets/image/figma_prod_arrow_down.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(subTextColor, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Content
              if (isExpanded) ...[
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: innerItemBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: innerBorderColor, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'successful_visits_label'.tr,
                              value: day.details.successfulVisits,
                              valueColor: const Color(0xFFF59E0B),
                              subTextColor: subTextColor,
                            ),
                          ),
                          Container(width: 1, height: 36, color: innerBorderColor),
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'work_hours_label'.tr,
                              value: day.details.workHours,
                              valueColor: const Color(0xFF30913F),
                              subTextColor: subTextColor,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 16, thickness: 0.8, color: innerBorderColor),
                      Row(
                        children: [
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'warnings_label'.tr,
                              value: day.details.warningsCount,
                              valueColor: const Color(0xFFDC2626),
                              subTextColor: subTextColor,
                            ),
                          ),
                          Container(width: 1, height: 36, color: innerBorderColor),
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'contract_unit_text'.tr,
                              value: day.details.contractsCount,
                              valueColor: const Color(0xFF7861A6),
                              subTextColor: subTextColor,
                            ),
                          ),
                        ],
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

  Widget _buildChip({
    required String count,
    required String label,
    required Color color,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 9,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedMetric({
    required String title,
    required String value,
    required Color valueColor,
    required Color subTextColor,
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
              fontSize: 10,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Signed Agreements Section
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
      decoration: _cardDecoration(cardBg, borderColor, isDark),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'no_contracts_today'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: agreements.length,
              separatorBuilder: (_, __) => Divider(height: 16, thickness: 0.8, color: dividerColor),
              itemBuilder: (context, index) {
                final a = agreements[index];
                final isGreen = a.statusColor == 'green';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    ),
                    const SizedBox(width: 8),
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

  // 4. Previous Leaves Section (Figma 8956:3247 - الإجازات السابقة)
  Widget _buildPreviousLeavesSection(
    List<PreviousLeaveItem> leaves,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color dividerColor,
    bool isDark,
  ) {
    return Container(
      decoration: _cardDecoration(cardBg, borderColor, isDark),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'previous_leaves_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          if (leaves.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'no_previous_leaves'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaves.length,
              separatorBuilder: (_, __) => Divider(height: 16, thickness: 0.8, color: dividerColor),
              itemBuilder: (context, index) {
                final leave = leaves[index];
                final Color pillBg;
                final Color pillText;
                if (leave.status == 'approved') {
                  pillBg = isDark ? const Color(0xFF1E3A2B) : const Color(0xFFDCFCE7);
                  pillText = const Color(0xFF16A34A);
                } else if (leave.status == 'rejected') {
                  pillBg = isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2);
                  pillText = const Color(0xFFDC2626);
                } else {
                  pillBg = isDark ? const Color(0xFF3B2A15) : const Color(0xFFFEF3C7);
                  pillText = const Color(0xFFD97706);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            leave.dateAndDuration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        leave.statusLabel,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: pillText,
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

  // 5. Period Summary Grid (6 cards matching Figma)
  Widget _buildPeriodSummarySection(
    PeriodSummaryInfo summary,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color innerItemBg,
    Color innerBorderColor,
    bool isDark,
  ) {
    return Container(
      decoration: _cardDecoration(cardBg, borderColor, isDark),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'period_summary_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.1,
            children: [
              _buildSummaryCard('total_work_hours_label'.tr, summary.totalWorkHours, innerItemBg, innerBorderColor, textColor, subTextColor),
              _buildSummaryCard('total_visits_label'.tr, '${summary.totalVisits}', innerItemBg, innerBorderColor, textColor, subTextColor),
              _buildSummaryCard('signed_agreements_label'.tr, '${summary.totalSignedContracts}', innerItemBg, innerBorderColor, textColor, subTextColor),
              _buildSummaryCard('warnings_label'.tr, '${summary.totalWarnings}', innerItemBg, innerBorderColor, textColor, subTextColor),
              _buildSummaryCard('covered_distance_label'.tr, summary.totalDistanceKm, innerItemBg, innerBorderColor, textColor, subTextColor),
              _buildSummaryCard('scheduled_followups_label'.tr, '${summary.totalScheduledFollowups}', innerItemBg, innerBorderColor, textColor, subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color innerItemBg,
    Color innerBorderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: innerItemBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: innerBorderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
