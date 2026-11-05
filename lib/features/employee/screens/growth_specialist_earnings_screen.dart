import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/controllers/monthly_earnings_controller.dart';
import 'package:sixam_mart/features/employee/models/monthly_earnings_model.dart';

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
    final isDark = Get.find<ThemeController>().darkTheme;
    final bgColor = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111B18);
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final innerBoxBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'earnings_and_dues'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: !widget.isRoot,
        leading: widget.isRoot
            ? null
            : IconButton(
                icon: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? IconlyLight.arrowRight2
                      : IconlyLight.arrowLeft2,
                  color: textColor,
                  size: 22,
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
            return const Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            );
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
                      child: Text('retry'.tr, style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white)),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Total Net Monthly Earnings Card (Figma 1:1)
                  _buildTotalEarningsCard(data, isDark),
                  const SizedBox(height: 16),

                  // 2. 2x2 Performance Grid (Figma 1:1)
                  // Row 1: Layer 1 (Salary - Right in RTL) & Layer 2 (Incentive - Left in RTL)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layer 1: الراتب التعاقدي الأساسي
                      Expanded(
                        child: _buildLayer1Card(
                          data.layer1Salary,
                          data.workingDays,
                          cardBg,
                          innerBoxBg,
                          textColor,
                          subTextColor,
                          borderColor,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Layer 2: حوافز تفعيل العقود
                      Expanded(
                        child: _buildLayer2Card(
                          data.layer2Incentive,
                          cardBg,
                          innerBoxBg,
                          textColor,
                          subTextColor,
                          borderColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Layer 3 (Network - Right in RTL) & Layer 4 (Direct - Left in RTL)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layer 3: إشراف ومكافآت الشبكة
                      Expanded(
                        child: _buildLayer3Card(
                          data.layer3Network,
                          cardBg,
                          innerBoxBg,
                          textColor,
                          subTextColor,
                          borderColor,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Layer 4: اكتساب العملاء المباشر
                      Expanded(
                        child: _buildLayer4Card(
                          data.layer4Direct,
                          cardBg,
                          innerBoxBg,
                          textColor,
                          subTextColor,
                          borderColor,
                        ),
                      ),
                    ],
                  ),

                  // Bottom padding for navigation bar
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Top Gradient Card matching Figma 1:1
  Widget _buildTotalEarningsCard(MonthlyEarningsModel data, bool isDark) {
    String formattedDate = data.calculatedAt;
    try {
      final parsed = DateTime.tryParse(data.calculatedAt);
      if (parsed != null) {
        formattedDate = DateFormat('dd-MM-yyyy').format(parsed);
      }
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2EA846),
            Color(0xFF1B7F33),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'total_net_monthly_earnings'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                NumberFormat('#,##0.00').format(data.summary.totalMonthlyEarnings),
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ر.س',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'last_calculation'.trParams({'date': formattedDate}),
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
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
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return _buildBaseGridCard(
      cardBg: cardBg,
      borderColor: borderColor,
      textColor: textColor,
      icon: IconlyLight.wallet,
      title: 'contractual_base_salary'.tr,
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${salary.baseContractualSalary.toStringAsFixed(2)} ر.س',
          label: 'contractual_base_salary'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${workingDays.totalBaselineDays} ${'day'.tr}',
          label: 'approved_working_days'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${salary.dailySalaryRate.toStringAsFixed(2)} ر.س / ${'day'.tr}',
          label: 'daily_rate'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Layer 2: حوافز تفعيل العقود
  Widget _buildLayer2Card(
    Layer2Incentive incentive,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    final double percent = (incentive.achievementPercentage / 100).clamp(0.0, 1.0);
    final String percentText = '${incentive.achievementPercentage.round()}%';

    return _buildBaseGridCard(
      cardBg: cardBg,
      borderColor: borderColor,
      textColor: textColor,
      icon: IconlyLight.work,
      title: 'contract_activation_incentives'.tr,
      middleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  percentText,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
              minHeight: 5,
            ),
          ),
          if (!incentive.isQualified) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'threshold_warning_short'.trParams({
                  'count': '${incentive.contractsNeededToQualify}',
                  'percent': '30',
                }),
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 9,
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${incentive.standardIncentiveEarned.toStringAsFixed(2)} ر.س',
          label: 'standard_incentive_earned'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${incentive.displayedPerContractRate.toStringAsFixed(2)} ر.س',
          label: 'displayed_contract_rate'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Layer 3: إشراف ومكافآت الشبكة
  Widget _buildLayer3Card(
    Layer3Network network,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return _buildBaseGridCard(
      cardBg: cardBg,
      borderColor: borderColor,
      textColor: textColor,
      icon: IconlyLight.user3,
      title: 'network_supervision_rewards'.tr,
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${network.activeSupervisedMarketersCount} ${'marketer_count_unit'.tr}',
          label: 'active_marketers_supervised'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${network.networkSupervisionCommissions.toStringAsFixed(2)} ر.س',
          label: 'direct_network_commissions'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${network.milestoneBonusesEarned.toStringAsFixed(2)} ر.س',
          label: 'team_milestone_rewards'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Layer 4: اكتساب العملاء المباشر
  Widget _buildLayer4Card(
    Layer4Direct direct,
    Color cardBg,
    Color innerBoxBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return _buildBaseGridCard(
      cardBg: cardBg,
      borderColor: borderColor,
      textColor: textColor,
      icon: IconlyLight.user2,
      title: 'direct_customer_acquisition'.tr,
      boxes: [
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${direct.registeredUsersCount} ${'customer'.tr}',
          label: 'registered_users_personal_code'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${direct.qualifiedFirstOrdersCount} ${'orders_count_unit'.tr}',
          label: 'qualified_first_orders'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        _buildStatBox(
          innerBoxBg: innerBoxBg,
          borderColor: borderColor,
          value: '${direct.customerAcquisitionCommissions.toStringAsFixed(2)} ر.س',
          label: 'total_acquisition_commissions'.tr,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  /// Reusable Base Grid Card matching Figma
  Widget _buildBaseGridCard({
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required String title,
    Widget? middleWidget,
    required List<Widget> boxes,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Icon Container at Top Center
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F1F3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF475467),
              size: 20,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Optional Middle Content (Progress Bar for Layer 2)
          if (middleWidget != null) middleWidget,

          // Sub boxes stacked vertically
          for (int i = 0; i < boxes.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            boxes[i],
          ],
        ],
      ),
    );
  }

  /// Sub-box container inside grid card
  Widget _buildStatBox({
    required Color innerBoxBg,
    required Color borderColor,
    required String value,
    required String label,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: innerBoxBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
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
