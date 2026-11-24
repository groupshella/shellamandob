import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/network/api_client.dart';
import '../controllers/monthly_scorecard_controller.dart';

/// Figma Nodes: 10035:53067, 10038:56932, 10038:57168, 10039:57883,
/// 10040:59174, 10040:59318, 10040:59524
/// Full Multi-Language (.tr), Live Dark/Light ThemeController, and Exact Figma Badge/Medal Assets
class MonthlyScorecardScreen extends StatefulWidget {
  final bool isRoot;
  const MonthlyScorecardScreen({super.key, this.isRoot = false});

  @override
  State<MonthlyScorecardScreen> createState() => _MonthlyScorecardScreenState();
}

class _MonthlyScorecardScreenState extends State<MonthlyScorecardScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  static const String _badgeVisitsAsset =
      'assets/image/figma_r15_r16/badge_visits.png';
  static const String _badgeFirstOrderAsset =
      'assets/image/figma_r15_r16/badge_first_order.png';
  static const String _badgeShiftsAsset =
      'assets/image/figma_r15_r16/badge_shifts.png';
  static const String _badgeTrainingAsset =
      'assets/image/figma_r15_r16/badge_training.png';
  static const String _medalGoldAsset =
      'assets/image/figma_r15_r16/medal_rank_gold.png';
  static const String _medalSilverAsset =
      'assets/image/figma_r15_r16/medal_rank_silver.png';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MonthlyScorecardController>()) {
      Get.put(MonthlyScorecardController(apiClient: Get.find<ApiClient>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final bool isDark = themeCtrl.darkTheme;
        final Color bgColor = isDark ? const Color(0xFF121418) : Colors.white;
        final Color cardBg = isDark ? const Color(0xFF1E232C) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final Color subTextColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final Color borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              'my_monthly_kpi_card_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: !widget.isRoot,
            leading: widget.isRoot
                ? null
                : IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: textColor, size: 19),
                    onPressed: () => Get.back(),
                  ),
          ),
          body: GetBuilder<MonthlyScorecardController>(
            builder: (controller) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: _primaryGreen),
                );
              }

              if (controller.errorMessage != null &&
                  controller.scorecardData == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: subTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => controller.refreshCurrentMonth(),
                          child: Text(
                            'retry'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final scorecard = controller.scorecardData ?? {};
              final leaderboard = controller.leaderboardData ?? {};
              final double totalScore = (scorecard['total_score'] is num)
                  ? (scorecard['total_score'] as num).toDouble()
                  : 0.0;
              final bool isArabic =
                  (Get.locale?.languageCode ?? 'ar').startsWith('ar');
              final String tierLabel = isArabic
                  ? (scorecard['tier_label_ar']?.toString() ??
                      'kpi_needs_improvement'.tr)
                  : (scorecard['tier_label_en']?.toString() ??
                      scorecard['tier_label_ar']?.toString() ??
                      'kpi_needs_improvement'.tr);
              final List<dynamic> badges = (scorecard['badges'] is List)
                  ? List<dynamic>.from(scorecard['badges'])
                  : [];
              final Map<String, dynamic> breakdown = scorecard['breakdown']
                      is Map
                  ? Map<String, dynamic>.from(scorecard['breakdown'])
                  : <String, dynamic>{};
              final Map<String, dynamic> deductions =
                  scorecard['deductions'] is Map
                      ? Map<String, dynamic>.from(scorecard['deductions'])
                      : <String, dynamic>{};

              return RefreshIndicator(
                color: _primaryGreen,
                onRefresh: () => controller.refreshCurrentMonth(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPillSegmentedControl(controller, isDark, textColor),
                      const SizedBox(height: 16),
                      if (controller.selectedTabIndex == 0) ...[
                        _buildScoreSummaryCard(
                          totalScore: totalScore,
                          tierLabel: tierLabel,
                          month: controller.selectedMonth,
                          isDark: isDark,
                          cardBg: cardBg,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 14),
                        _buildBadgesCard(
                          badges: badges,
                          isArabic: isArabic,
                          isDark: isDark,
                          cardBg: cardBg,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 14),
                        _buildKpiBreakdownCard(
                          breakdown: breakdown,
                          isDark: isDark,
                          cardBg: cardBg,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        if (((deductions['warnings_count'] as num?)?.toInt() ??
                                0) >
                            0) ...[
                          const SizedBox(height: 14),
                          _buildDeductionsCard(deductions, isDark),
                        ],
                      ] else ...[
                        _buildRegionalRankHeroCard(
                          leaderboard: leaderboard,
                          totalScore: totalScore,
                          isDark: isDark,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        const SizedBox(height: 16),
                        _buildRegionalLeaderboardCard(
                          leaderboard: leaderboard,
                          isDark: isDark,
                          cardBg: cardBg,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          borderColor: borderColor,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPillSegmentedControl(
    MonthlyScorecardController controller,
    bool isDark,
    Color textColor,
  ) {
    final trackBg = isDark ? const Color(0xFF1E232C) : const Color(0xFFEFEFEF);
    final activePillBg = isDark ? const Color(0xFF2D3545) : Colors.white;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTabIndex(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.selectedTabIndex == 0
                      ? activePillBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: controller.selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'kpi_tab_my_performance'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: controller.selectedTabIndex == 0
                        ? textColor
                        : (isDark ? Colors.white60 : const Color(0xFF111B18)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTabIndex(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.selectedTabIndex == 1
                      ? activePillBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: controller.selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'kpi_tab_leaderboard'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: controller.selectedTabIndex == 1
                        ? textColor
                        : (isDark ? Colors.white60 : const Color(0xFF111B18)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummaryCard({
    required double totalScore,
    required String tierLabel,
    required String month,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    final double clampedPct = (totalScore / 100.0).clamp(0.0, 1.0);
    final Color ringColor = totalScore >= 70
        ? const Color(0xFF1E8E3E)
        : (totalScore >= 40
            ? const Color(0xFFF59E0B)
            : const Color(0xFFE11D48));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 78,
                  height: 78,
                  child: CircularProgressIndicator(
                    value: clampedPct,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: isDark
                        ? const Color(0xFF2B3240)
                        : const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                ),
                Text(
                  '${totalScore.round()}%',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tierLabel,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'kpi_eval_month_label'.trParams({'month': month}),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'kpi_score_based_on_real'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCard({
    required List<dynamic> badges,
    required bool isArabic,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    final String countLabel = badges.isEmpty
        ? 'kpi_zero_badges'.tr
        : (badges.length == 1
            ? 'kpi_one_badge'.tr
            : 'kpi_multi_badges'.trParams({'count': '${badges.length}'}));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'kpi_earned_badges'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                countLabel,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (badges.isEmpty)
            Text(
              'kpi_no_badges_yet'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: subTextColor,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final b = badges[index] is Map
                    ? Map<String, dynamic>.from(badges[index])
                    : <String, dynamic>{};
                final String badgeId = b['id']?.toString() ?? '';
                final String badgeName = isArabic
                    ? (b['name_ar']?.toString() ?? 'kpi_badge_default_name'.tr)
                    : (b['name_en']?.toString() ??
                        b['name_ar']?.toString() ??
                        'kpi_badge_default_name'.tr);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252B37) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _assetForBadge(badgeId, index),
                        width: 54,
                        height: 54,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badgeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.25,
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

  Widget _buildKpiBreakdownCard({
    required Map<String, dynamic> breakdown,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color borderColor,
  }) {
    final visits = breakdown['visits'] is Map
        ? Map<String, dynamic>.from(breakdown['visits'])
        : <String, dynamic>{};
    final activations = breakdown['activations'] is Map
        ? Map<String, dynamic>.from(breakdown['activations'])
        : <String, dynamic>{};
    final shifts = breakdown['shifts'] is Map
        ? Map<String, dynamic>.from(breakdown['shifts'])
        : <String, dynamic>{};
    final training = breakdown['training'] is Map
        ? Map<String, dynamic>.from(breakdown['training'])
        : <String, dynamic>{};

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'kpi_breakdown_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildKpiRow(
            title: 'kpi_metric_visits'.tr,
            score: (visits['score'] as num?)?.toDouble() ?? 0.0,
            maxScore: (visits['max_score'] as num?)?.toDouble() ?? 35.0,
            badgeAsset: _badgeVisitsAsset,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildKpiRow(
            title: 'kpi_metric_first_order'.tr,
            score: (activations['score'] as num?)?.toDouble() ?? 0.0,
            maxScore: (activations['max_score'] as num?)?.toDouble() ?? 30.0,
            badgeAsset: _badgeFirstOrderAsset,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildKpiRow(
            title: 'kpi_metric_shifts'.tr,
            score: (shifts['score'] as num?)?.toDouble() ?? 0.0,
            maxScore: (shifts['max_score'] as num?)?.toDouble() ?? 20.0,
            badgeAsset: _badgeShiftsAsset,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildKpiRow(
            title: 'kpi_metric_training'.tr,
            score: (training['score'] as num?)?.toDouble() ?? 0.0,
            maxScore: (training['max_score'] as num?)?.toDouble() ?? 15.0,
            badgeAsset: _badgeTrainingAsset,
            isDark: isDark,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow({
    required String title,
    required double score,
    required double maxScore,
    required String badgeAsset,
    required bool isDark,
    required Color textColor,
  }) {
    final double ratio =
        maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
    final String scoreText =
        '${maxScore.toStringAsFixed(0)} / ${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}';

    return Row(
      children: [
        Image.asset(
          badgeAsset,
          width: 26,
          height: 26,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Text(
                    scoreText,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 5,
                  backgroundColor: isDark
                      ? const Color(0xFF2B3240)
                      : const Color(0xFFE5E7EB),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_primaryGreen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeductionsCard(Map<String, dynamic> deductions, bool isDark) {
    final int count = (deductions['warnings_count'] as num?)?.toInt() ?? 0;
    final double points =
        (deductions['points_deducted'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B181A) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'kpi_deductions_warning'.trParams({
                'points': points.toStringAsFixed(0),
                'count': '$count',
              }),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalRankHeroCard({
    required Map<String, dynamic> leaderboard,
    required double totalScore,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    final int myRank = (leaderboard['my_rank'] as num?)?.toInt() ?? 0;
    final String medalAsset = myRank == 1 ? _medalGoldAsset : _medalSilverAsset;
    final String formattedScore =
        totalScore.toStringAsFixed(totalScore % 1 == 0 ? 0 : 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1F2333), Color(0xFF192722), Color(0xFF231F33)]
              : const [Color(0xFFEDE9FE), Color(0xFFECFDF5), Color(0xFFE0E7FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF4C1D95) : const Color(0xFFC4B5FD),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (myRank == 1 || myRank == 2)
            Image.asset(
              medalAsset,
              width: 80,
              height: 90,
              fit: BoxFit.contain,
            )
          else
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: myRank == 3
                      ? const [Color(0xFFFDBA74), Color(0xFFB45309)]
                      : const [Color(0xFF86EFAC), Color(0xFF15803D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    myRank > 0 ? '$myRank' : '-',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'TOP',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'kpi_my_regional_rank'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'kpi_total_points_label'.trParams({'points': formattedScore}),
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalLeaderboardCard({
    required Map<String, dynamic> leaderboard,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    final List<dynamic> members = leaderboard['top_members'] is List
        ? List<dynamic>.from(leaderboard['top_members'])
        : [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'kpi_regional_leaders'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'kpi_no_leaderboard_yet'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ),
            )
          else
            ...members.asMap().entries.map((entry) {
              final m = entry.value is Map
                  ? Map<String, dynamic>.from(entry.value)
                  : <String, dynamic>{};
              final int rank = (m['rank'] as num?)?.toInt() ?? (entry.key + 1);
              final String name = m['display_name']?.toString() ??
                  m['name']?.toString() ??
                  'kpi_specialist_fallback'.tr;
              final double score = (m['total_score'] is num)
                  ? (m['total_score'] as num).toDouble()
                  : 0.0;
              final bool isMe = m['is_current_user'] == true || m['is_me'] == true;
              final String formattedPts =
                  score.toStringAsFixed(score % 1 == 0 ? 0 : 1);

              final Color rankColor = rank == 1
                  ? const Color(0xFFF59E0B)
                  : (rank == 3
                      ? const Color(0xFFD97706)
                      : (isMe ? _primaryGreen : subTextColor));

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe
                      ? (isDark
                          ? const Color(0xFF142A1B)
                          : const Color(0xFFECFDF3))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isMe
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: borderColor,
                            width: 0.7,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: rankColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isMe ? '$name ${'kpi_you_suffix'.tr}' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                          color: isMe ? _primaryGreen : textColor,
                        ),
                      ),
                    ),
                    Text(
                      'kpi_points_suffix'.trParams({'points': formattedPts}),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isMe ? _primaryGreen : textColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _assetForBadge(String id, int index) {
    switch (id) {
      case 'growth_champion':
        return _badgeVisitsAsset;
      case 'speed_launcher':
        return _badgeFirstOrderAsset;
      case 'quality_guardian':
        return _badgeShiftsAsset;
      case 'certified_specialist':
        return _badgeTrainingAsset;
      default:
        const list = [
          _badgeVisitsAsset,
          _badgeFirstOrderAsset,
          _badgeShiftsAsset,
          _badgeTrainingAsset,
        ];
        return list[index % list.length];
    }
  }
}
