import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/marketer_productivity_model.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Target Progress Header & 3 Top Badges
          _buildPeriodTargetHeader(data.targetProgress, data.kpis),

          const SizedBox(height: 16),

          // 2. Days Accordion List (قائمة الأيام)
          _buildDaysAccordionList(data.days),

          const SizedBox(height: 20),

          // 3. Signed Agreements (الاتفاقيات الموقعة)
          _buildSignedAgreementsSection(data.signedAgreements),

          const SizedBox(height: 20),

          // 4. Period Summary (ملخص الفترة)
          _buildPeriodSummarySection(data.periodSummary),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // 1. Target Progress Header & 3 Top Badges
  Widget _buildPeriodTargetHeader(DailyTargetInfo target, PeriodKpis kpis) {
    final progress = (target.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F2), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'target_achievement_label'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
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
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
            ),
          ),
          const SizedBox(height: 16),
          // 3 Top Badges Row
          Row(
            children: [
              Expanded(
                child: _buildHeaderBadge(
                  title: 'warnings_label'.tr,
                  value: kpis.warningsText,
                  color: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeaderBadge(
                  title: 'work_hours_label'.tr,
                  value: kpis.workHours,
                  color: const Color(0xFF30913F),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeaderBadge(
                  title: 'signed_agreements_label'.tr,
                  value: kpis.signedContractsText,
                  color: const Color(0xFF7861A6),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
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
  Widget _buildDaysAccordionList(List<PeriodDayItem> days) {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded ? const Color(0xFF30913F).withValues(alpha: 0.4) : const Color(0xFFF0F0F2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header Row of the Day (Tappable)
              InkWell(
                onTap: () => onDayToggle(index),
                borderRadius: BorderRadius.circular(12),
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
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            day.dateFormatted,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
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
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        count: '${day.contractsCount}',
                        label: 'contract_unit_text'.tr,
                        color: const Color(0xFF7861A6),
                      ),
                      if (day.warningsCount > 0) ...[
                        const SizedBox(width: 6),
                        _buildChip(
                          count: '${day.warningsCount}',
                          label: 'warning_unit_text'.tr,
                          color: const Color(0xFFDC2626),
                        ),
                      ],

                      const SizedBox(width: 8),

                      // Arrow
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: const Color(0xFF9CA3AF),
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
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
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
                            ),
                          ),
                          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'work_hours_label'.tr,
                              value: day.details.workHours,
                              valueColor: const Color(0xFF30913F),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16, thickness: 0.8, color: Color(0xFFE5E7EB)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'warnings_label'.tr,
                              value: day.details.warningsCount,
                              valueColor: const Color(0xFFDC2626),
                            ),
                          ),
                          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                          Expanded(
                            child: _buildExpandedMetric(
                              title: 'contract_unit_text'.tr,
                              value: day.details.contractsCount,
                              valueColor: const Color(0xFF7861A6),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 9,
              color: Color(0xFF6B7280),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              color: Color(0xFF6B7280),
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
  Widget _buildSignedAgreementsSection(List<SignedAgreementItem> agreements) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F2), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'signed_agreements_label'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111B18),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agreements.length,
            separatorBuilder: (_, __) => const Divider(height: 16, thickness: 0.8, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final a = agreements[index];
              final isGreen = a.statusColor == 'green';
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.storeName,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.time,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGreen ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
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

  // 4. Period Summary Grid (6 cards matching Figma)
  Widget _buildPeriodSummarySection(PeriodSummaryInfo summary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F2), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'period_summary_title'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
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
              _buildSummaryCard('total_work_hours_label'.tr, summary.totalWorkHours),
              _buildSummaryCard('total_visits_label'.tr, '${summary.totalVisits}'),
              _buildSummaryCard('signed_agreements_label'.tr, '${summary.totalSignedContracts}'),
              _buildSummaryCard('warnings_label'.tr, '${summary.totalWarnings}'),
              _buildSummaryCard('covered_distance_label'.tr, summary.totalDistanceKm),
              _buildSummaryCard('scheduled_followups_label'.tr, '${summary.totalScheduledFollowups}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
