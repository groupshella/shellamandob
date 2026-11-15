import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/employee/controllers/monthly_earnings_controller.dart';
import 'package:sixam_mart/features/employee/models/monthly_earnings_model.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

class GrowthSpecialistEarningsScreen extends StatefulWidget {
  final bool isRoot;
  const GrowthSpecialistEarningsScreen({super.key, this.isRoot = false});

  @override
  State<GrowthSpecialistEarningsScreen> createState() => _GrowthSpecialistEarningsScreenState();
}

class _GrowthSpecialistEarningsScreenState extends State<GrowthSpecialistEarningsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MonthlyEarningsController>()) {
      Get.put(MonthlyEarningsController(apiClient: Get.find()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color bgColor = isDark ? const Color(0xFF121418) : Colors.white;
    final Color gridContainerBg = isDark ? const Color(0xFF181C23) : const Color(0xFFF3F4F6);
    final Color cardBg = isDark ? const Color(0xFF1E232C) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    final Color subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final Color borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final Color innerBoxBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF5F6F8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'earnings_and_dues'.tr,
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
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textColor,
                  size: 18,
                ),
                onPressed: () => Get.back(),
              ),
      ),
      body: GetBuilder<MonthlyEarningsController>(
        init: Get.isRegistered<MonthlyEarningsController>()
            ? Get.find<MonthlyEarningsController>()
            : null,
        builder: (controller) {
          if (controller.isLoading) {
            return SkeletonLoadingWidgets.earningsDashboardSkeleton(isDark: isDark);
          }

          if (controller.errorMessage != null && controller.earningsData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: subTextColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => controller.refreshCurrentMonth(),
                      child: Text(
                        'retry'.tr,
                        style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = controller.earningsData;
          if (data == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            color: _primaryGreen,
            onRefresh: () => controller.refreshCurrentMonth(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Total Net Monthly Earnings Card (Figma 9727-24487 / 9721-23186 / 9727-24756)
                  _buildTotalEarningsCard(data, isDark),
                  const SizedBox(height: 16),

                  // 2. Gray Rounded Container holding the 2x2 Grid with Protruding Top Circle Icons
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 28, 12, 14),
                    decoration: BoxDecoration(
                      color: gridContainerBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // Row 1: Right in RTL = الراتب التعاقدي الأساسي | Left in RTL = حوافز تفعيل العقود
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Layer 1: الراتب التعاقدي الأساسي
                              Expanded(
                                child: _buildLayer1Card(
                                  data.layer1Salary,
                                  data.workingDays,
                                  isDark,
                                  cardBg,
                                  innerBoxBg,
                                  textColor,
                                  subTextColor,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Layer 2: حوافز تفعيل العقود
                              Expanded(
                                child: _buildLayer2Card(
                                  data.layer2Incentive,
                                  isDark,
                                  cardBg,
                                  innerBoxBg,
                                  textColor,
                                  subTextColor,
                                  borderColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Row 2: Right in RTL = إشراف ومكافآت الشبكة | Left in RTL = اكتساب العملاء المباشر
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Layer 3: إشراف ومكافآت الشبكة
                              Expanded(
                                child: _buildLayer3Card(
                                  data.layer3Network,
                                  isDark,
                                  cardBg,
                                  innerBoxBg,
                                  textColor,
                                  subTextColor,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Layer 4: اكتساب العملاء المباشر
                              Expanded(
                                child: _buildLayer4Card(
                                  data.layer4Direct,
                                  isDark,
                                  cardBg,
                                  innerBoxBg,
                                  textColor,
                                  subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding (larger when shown inside root bottom navigation bar)
                  SizedBox(height: widget.isRoot ? 95 : 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Top Gradient Card with Decorative Translucent Circles & SarCurrencyWidget matching Figma 1:1
  Widget _buildTotalEarningsCard(MonthlyEarningsModel data, bool isDark) {
    String formattedDate = data.calculatedAt;
    try {
      final parsed = DateTime.tryParse(data.calculatedAt);
      if (parsed != null) {
        formattedDate = DateFormat('dd-MM-yyyy').format(parsed);
      }
    } catch (_) {}

    final String formattedTotal = data.summary.totalMonthlyEarnings.toStringAsFixed(2);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F7A36),
            Color(0xFF31A64D),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F30913F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative Soft Translucent Circles on the left side matching Figma
          Positioned(
            left: -25,
            top: -25,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: 35,
            bottom: -45,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Foreground Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'total_net_monthly_earnings'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SarCurrencyWidget(
                        size: 26,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTotal,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'last_calculation'.trParams({'date': formattedDate}),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Layer 1: الراتب التعاقدي الأساسي
  Widget _buildLayer1Card(
    Layer1Salary salary,
    WorkingDaysInfo workingDays,
    bool isDark,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
  ) {
    return _buildBaseGridCard(
      isDark: isDark,
      cardBg: cardBg,
      textColor: textColor,
      iconWidget: Icon(
        IconlyBold.wallet,
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        size: 22,
      ),
      title: 'contractual_base_salary'.tr,
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildCurrencyAmountRow(
            salary.baseContractualSalary.toStringAsFixed(2),
            textColor,
          ),
          label: 'contractual_base_salary'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: Text(
            '${workingDays.totalBaselineDays} ${'day'.tr}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          label: 'approved_working_days'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildDailyRateRow(
            salary.dailySalaryRate.toStringAsFixed(2),
            textColor,
          ),
          label: 'daily_rate'.tr,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Layer 2: حوافز تفعيل العقود
  Widget _buildLayer2Card(
    Layer2Incentive incentive,
    bool isDark,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    final double percent = (incentive.achievementPercentage / 100).clamp(0.0, 1.0);
    final String percentText = incentive.achievementPercentage == 0 && !incentive.isQualified
        ? '0.0%'
        : '${incentive.achievementPercentage.round()} %';

    return _buildBaseGridCard(
      isDark: isDark,
      cardBg: cardBg,
      textColor: textColor,
      iconWidget: _buildContractIncentiveIcon(isDark),
      title: 'contract_activation_incentives'.tr,
      middleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Right in RTL = الإنجاز: X / Y عقد | Left in RTL = Green Pill Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'achievement_contracts_label'.trParams({
                    'count': '${incentive.activatedContractsCount}',
                    'target': '${incentive.adjustedMonthlyTarget}',
                  }),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  percentText,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF4ADE80) : _primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress Bar (with small green dot indicator on right when 0% matching Figma 9727-24487)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent > 0 ? percent : 0.03,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
              minHeight: 5,
            ),
          ),
          if (!incentive.isQualified) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A241C) : const Color(0xFFFEF9EC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF45341B) : const Color(0xFFFDE68A).withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 13,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF4B5563),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'threshold_warning_short'.trParams({
                        'count': '${incentive.contractsNeededToQualify}',
                        'percent': '30',
                      }),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 8.5,
                        height: 1.35,
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildCurrencyAmountRow(
            incentive.standardIncentiveEarned.toStringAsFixed(2),
            textColor,
          ),
          label: 'standard_incentive_earned'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildCurrencyAmountRow(
            incentive.displayedPerContractRate.toStringAsFixed(2),
            textColor,
          ),
          label: 'displayed_contract_rate'.tr,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Layer 3: إشراف ومكافآت الشبكة
  Widget _buildLayer3Card(
    Layer3Network network,
    bool isDark,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
  ) {
    return _buildBaseGridCard(
      isDark: isDark,
      cardBg: cardBg,
      textColor: textColor,
      iconWidget: Icon(
        IconlyBold.user3,
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        size: 22,
      ),
      title: 'network_supervision_rewards'.tr,
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: Text(
            '${network.activeSupervisedMarketersCount} ${'marketer_count_unit'.tr}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          label: 'active_marketers_supervised'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildCurrencyAmountRow(
            network.networkSupervisionCommissions.toStringAsFixed(2),
            textColor,
          ),
          label: 'direct_network_commissions'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildCurrencyAmountRow(
            network.milestoneBonusesEarned.toStringAsFixed(2),
            textColor,
          ),
          label: 'team_milestone_rewards'.tr,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Layer 4: اكتساب العملاء المباشر (With QR Code Icon matching Figma)
  Widget _buildLayer4Card(
    Layer4Direct direct,
    bool isDark,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
  ) {
    return _buildBaseGridCard(
      isDark: isDark,
      cardBg: cardBg,
      textColor: textColor,
      iconWidget: Icon(
        Icons.qr_code_scanner_rounded,
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        size: 22,
      ),
      title: 'direct_customer_acquisition'.tr,
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: Text(
            '${direct.registeredUsersCount} ${'customer'.tr}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          label: 'registered_users_personal_code'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: Text(
            '${direct.qualifiedFirstOrdersCount} ${'orders_count_unit'.tr}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          label: 'qualified_first_orders'.tr,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          valueWidget: _buildCurrencyAmountRow(
            direct.customerAcquisitionCommissions.toStringAsFixed(2),
            textColor,
          ),
          label: 'total_acquisition_commissions'.tr,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  Widget _buildContractIncentiveIcon(bool isDark) {
    final Color iconColor = isDark ? Colors.white : const Color(0xFF1F2937);
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          IconlyBold.bag2,
          color: iconColor,
          size: 22,
        ),
        Positioned(
          bottom: 4,
          child: Icon(
            Icons.add,
            size: 10,
            color: isDark ? const Color(0xFF1E232C) : Colors.white,
          ),
        ),
      ],
    );
  }

  /// Currency Amount Row with SarCurrencyWidget on the left of the number (matching Figma)
  Widget _buildCurrencyAmountRow(String amountStr, Color textColor) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SarCurrencyWidget(size: 13, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              amountStr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Daily Rate Row: "3.00 [SAR] / يوم" matching Figma
  Widget _buildDailyRateRow(String rateStr, Color textColor) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SarCurrencyWidget(size: 12, color: textColor),
                const SizedBox(width: 3),
                Text(
                  rateStr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ' / ${'day'.tr}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Base Grid Card with Protruding Top Circle Icon Dome matching Figma 1:1
  Widget _buildBaseGridCard({
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Widget iconWidget,
    required String title,
    Widget? middleWidget,
    required List<Widget> boxes,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Main Card Body
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 26, 10, 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Optional Middle Content (Progress Bar + Warning for Layer 2)
                  if (middleWidget != null) middleWidget,
                ],
              ),

              // Sub boxes stacked vertically at the bottom of the card
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < boxes.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    boxes[i],
                  ],
                ],
              ),
            ],
          ),
        ),

        // Protruding Top Circle Dome containing the Icon
        Positioned(
          top: -20,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
        ),
      ],
    );
  }

  /// Sub-box container inside grid card (Clean borderless soft gray box matching Figma)
  Widget _buildStatBox({
    required Color innerBoxBg,
    required Widget valueWidget,
    required String label,
    required Color subTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: innerBoxBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          valueWidget,
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
