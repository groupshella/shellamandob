import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../api/api_client.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../../../../core/widgets/skeleton_loading_widgets.dart';

/// Sub-Marketer Profile Screen ("ملف المسوق") matching Figma:
/// - Active state: node 9920:57174 (Green gradient milestone card, green bars, "نشط" badge)
/// - Needs follow-up / idle state: node 9937:87311 (Gold gradient milestone card, mixed gold/green bars, "بحاجة لمتابعة" badge with dot)
class SubMarketerProfileScreen extends StatefulWidget {
  final int marketerId;
  final String? fallbackName;

  const SubMarketerProfileScreen({
    super.key,
    required this.marketerId,
    this.fallbackName,
  });

  @override
  State<SubMarketerProfileScreen> createState() =>
      _SubMarketerProfileScreenState();
}

class _SubMarketerProfileScreenState extends State<SubMarketerProfileScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkGreen = Color(0xFF2A7836);
  static const Color _goldStart = Color(0xFFA98A3C);
  static const Color _goldEnd = Color(0xFFC4B15D);
  static const Color _barGreenTop = Color(0xFF3EC856);
  static const Color _barGoldTop = Color(0xFFBDA855);
  static const Color _barGoldBottom = Color(0xFFAB8D3F);

  static const String _arrowRightSvg =
      'assets/image/figma_marketer_profile_arrow_right.svg';
  static const String _sarWhiteSvg =
      'assets/image/figma_marketer_profile_sar_white.svg';
  static const String _sarDarkSvg =
      'assets/image/figma_marketer_profile_sar_dark.svg';

  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData(
          '/api/v1/customer/marketer/network/marketers/${widget.marketerId}',
        );
        if (res.statusCode == 200 && res.body?['data'] is Map) {
          _profile = Map<String, dynamic>.from(res.body['data']);
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final surfacePrimary = isDark ? const Color(0xFF1C2028) : Colors.white;
        final bodyBg =
            isDark ? const Color(0xFF121418) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final headlineText = isDark ? Colors.white : const Color(0xFF111B18);
        final darkText = isDark ? Colors.white : const Color(0xFF19201B);
        final subText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6C756E);
        final borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE4E9E5);

        final name =
            _profile?['name']?.toString() ?? widget.fallbackName ?? '-';
        final initial = name.trim().isNotEmpty ? name.trim().characters.first : 'م';
        final isActive = _profile?['is_active'] == true;
        final code = _profile?['code']?.toString() ?? '-';
        final joinedAt = _profile?['joined_at_text']?.toString() ?? '-';
        final milestoneTarget =
            int.tryParse('${_profile?['milestone_target']}') ?? 300;
        final milestoneAchieved =
            int.tryParse('${_profile?['milestone_achieved']}') ?? 0;
        final milestoneRemaining =
            int.tryParse('${_profile?['milestone_remaining']}') ?? 300;
        final milestonePct =
            int.tryParse('${_profile?['milestone_percentage']}') ?? 0;
        final bonusAmount =
            int.tryParse('${_profile?['milestone_bonus_amount']}') ?? 50;
        final totalCustomers =
            int.tryParse('${_profile?['total_customers']}') ?? 0;
        final supervisionCommission =
            double.tryParse('${_profile?['supervision_commission']}') ?? 0.0;
        final weeklyTotal = int.tryParse('${_profile?['weekly_total']}') ?? 0;
        final dailyAverage =
            double.tryParse('${_profile?['daily_average']}') ?? 0.0;
        final weeklyActivity = (_profile?['weekly_activity'] as List?)
                ?.whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        final accountStatusLabel = isAr
            ? (_profile?['account_status_label_ar']?.toString() ?? '-')
            : (_profile?['account_status_label_en']?.toString() ?? '-');
        final marketerTypeLabel = isAr
            ? (_profile?['marketer_type_label_ar']?.toString() ?? '-')
            : (_profile?['marketer_type_label_en']?.toString() ?? '-');
        final profession = _profile?['profession']?.toString() ?? '-';
        final lastRegText =
            _profile?['last_registration_text']?.toString() ?? '-';

        return Scaffold(
          backgroundColor: surfacePrimary,
          appBar: AppBar(
            backgroundColor: surfacePrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Transform(
                alignment: Alignment.center,
                transform: isRtl
                    ? Matrix4.identity()
                    : Matrix4.rotationY(math.pi),
                child: SvgPicture.asset(
                  _arrowRightSvg,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(headlineText, BlendMode.srcIn),
                ),
              ),
            ),
            title: Text(
              'marketer_profile_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: headlineText,
              ),
            ),
          ),
          body: _isLoading
              ? SkeletonLoadingWidgets.subMarketerProfileSkeleton(isDark: isDark)
              : RefreshIndicator(
                  color: _primaryGreen,
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. White Header Section ("MarketerDetails")
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: surfacePrimary,
                            border: Border(
                              bottom: BorderSide(
                                color: borderColor,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF132D1B)
                                      : const Color(0xFFE6F9F0),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: surfacePrimary,
                                    width: 2.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? const Color(0xFF132D1B)
                                          : const Color(0xFFE6F9F0),
                                      spreadRadius: 2,
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    height: 1.1,
                                    color: _primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStatusBadge(isActive, isDark),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF132D1B)
                                          : const Color(0xFFEAF7EC),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      marketerTypeLabel,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFF4ADE80)
                                            : const Color(0xFF195F29),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${'marketer_code_label'.tr} $code · ${'joined_on_label'.tr} $joinedAt',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 10,
                                  color: subText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Gray Rounded Content Container (#F6F5F8)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bodyBg,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 2a. 30-Day Milestone Gradient Card
                              _buildMilestoneCard(
                                isActive: isActive,
                                milestoneAchieved: milestoneAchieved,
                                milestoneTarget: milestoneTarget,
                                milestoneRemaining: milestoneRemaining,
                                milestonePct: milestonePct,
                                bonusAmount: bonusAmount,
                              ),

                              const SizedBox(height: 10),

                              // 2b. Two KPI Cards (إجمالي العملاء & عمولة الإشراف)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildKpiCard(
                                      valueWidget: Text(
                                        '$totalCustomers',
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          height: 1.4,
                                          color: darkText,
                                        ),
                                      ),
                                      label: 'total_customers_label'.tr,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      subText: subText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildKpiCard(
                                      valueWidget: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              _sarDarkSvg,
                                              width: 18.75,
                                              height: 21,
                                              colorFilter: isDark
                                                  ? const ColorFilter.mode(
                                                      Colors.white,
                                                      BlendMode.srcIn,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              supervisionCommission
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 19,
                                                fontWeight: FontWeight.w700,
                                                height: 1.4,
                                                color: darkText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      label: 'supervision_commission_label'.tr,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      subText: subText,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // 2c. Weekly Registration Activity Card ("نشاط التسجيل الأسبوعي")
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 0.8,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : const [
                                          BoxShadow(
                                            color: Color(0x0A1C3420),
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'weekly_registration_activity'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: darkText,
                                          ),
                                        ),
                                        Text(
                                          '$weeklyTotal ${'registrations_unit'.tr}',
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 9.5,
                                            color: subText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildWeeklyBarChart(
                                      weeklyActivity: weeklyActivity,
                                      isActive: isActive,
                                      dailyAverage: dailyAverage,
                                      borderColor: borderColor,
                                      subText: subText,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'daily_average_label'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 9.5,
                                            color: subText,
                                          ),
                                        ),
                                        Text(
                                          '$dailyAverage ${'registrations_unit'.tr}',
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: darkText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // 2d. Account Info Card ("معلومات الحساب")
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  15,
                                  15,
                                  15,
                                  7,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 0.8,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : const [
                                          BoxShadow(
                                            color: Color(0x0A1C3420),
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'account_info_section'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      label: 'marketer_type_label'.tr,
                                      value: marketerTypeLabel,
                                      darkText: darkText,
                                      subText: subText,
                                      borderColor: borderColor,
                                    ),
                                    _buildInfoRow(
                                      label: 'job_role_label'.tr,
                                      value: profession,
                                      darkText: darkText,
                                      subText: subText,
                                      borderColor: borderColor,
                                    ),
                                    _buildInfoRow(
                                      label: 'account_status_label'.tr,
                                      value: accountStatusLabel,
                                      darkText: darkText,
                                      subText: subText,
                                      borderColor: borderColor,
                                    ),
                                    _buildInfoRow(
                                      label: 'last_registration_label'.tr,
                                      value: lastRegText,
                                      darkText: darkText,
                                      subText: subText,
                                      borderColor: borderColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132D1B) : const Color(0xFFEAF7EC),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'active_badge'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF195F29),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3B2E15) : const Color(0xFFFFF7EB),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF9B5709),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'needs_follow_up'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF9B5709),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard({
    required bool isActive,
    required int milestoneAchieved,
    required int milestoneTarget,
    required int milestoneRemaining,
    required int milestonePct,
    required int bonusAmount,
  }) {
    final gradientColors =
        isActive ? [_darkGreen, _primaryGreen] : [_goldStart, _goldEnd];
    final subtleTextColor = isActive ? const Color(0xFFD9F0DD) : Colors.white;
    final subtitleColor = isActive ? const Color(0xFFD4EFD8) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: const Alignment(-0.7, -1.0),
          end: const Alignment(0.7, 1.0),
          colors: gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'thirty_day_goal_label'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 9.5,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: '$milestoneAchieved ',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        TextSpan(
                          text: '/ $milestoneTarget ${'customer_unit'.tr}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$milestonePct%',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (milestonePct / 100.0).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 9),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 9.5,
                height: 1.4,
                color: subtleTextColor,
              ),
              children: [
                TextSpan(text: '${'remaining_word'.tr} '),
                TextSpan(
                  text: '$milestoneRemaining ${'customer_unit'.tr}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: ' ${'for_achievement_bonus'.tr} '),
                TextSpan(
                  text: '$bonusAmount ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SvgPicture.asset(
                    _sarWhiteSvg,
                    width: 9,
                    height: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required Widget valueWidget,
    required String label,
    required Color cardBg,
    required Color borderColor,
    required Color subText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          valueWidget,
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              color: subText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart({
    required List<Map<String, dynamic>> weeklyActivity,
    required bool isActive,
    required double dailyAverage,
    required Color borderColor,
    required Color subText,
  }) {
    final maxCount = weeklyActivity.fold<int>(
      1,
      (prev, item) {
        final c = int.tryParse('${item['count']}') ?? 0;
        return c > prev ? c : prev;
      },
    );

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weeklyActivity.map((item) {
          final cnt = int.tryParse('${item['count']}') ?? 0;
          final dayLabel = item['day_label']?.toString() ?? '';
          final barHeight =
              cnt == 0 ? 14.0 : (16.0 + (cnt / maxCount) * 58.0).clamp(16.0, 74.0);
          final useGreen = isActive || (cnt > 0 && cnt >= dailyAverage);

          return SizedBox(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 15,
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: useGreen
                          ? [_barGreenTop, _primaryGreen]
                          : [_barGoldTop, _barGoldBottom],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 8.5,
                    color: subText,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color darkText,
    required Color subText,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }
}
