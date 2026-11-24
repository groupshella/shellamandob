import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/employee/controllers/monthly_earnings_controller.dart';
import 'package:sixam_mart/features/employee/models/monthly_earnings_model.dart';
import 'monthly_scorecard_screen.dart';
import 'transactions_history_screen.dart';
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
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final bool isDark = themeCtrl.darkTheme;
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
                  // 1. Hero Wallet & Withdrawable Balance Card (Figma 10033:51112 / 9727:24487)
                  _buildFigmaHeroWalletCard(controller, isDark),
                  const SizedBox(height: 14),

                  // 2. Quick Access Banner to Monthly Performance & KPI Card (Figma 10033:52131)
                  InkWell(
                    onTap: () => Get.to(() => const MonthlyScorecardScreen()),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E232C) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF142A1B) : const Color(0xFFEBFEEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/image/figma_r15_r16/trend_up.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(_primaryGreen, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'my_monthly_kpi_card_title'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'my_monthly_kpi_card_subtitle'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: isDark ? Colors.white70 : const Color(0xFF111B18),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        const SizedBox(height: 16),

                        // 3. Transactions History Preview Card (Figma 10033:52059) inside the gray container
                        _buildTransactionsPreviewCard(controller, isDark, cardBg, textColor, subTextColor),
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
      },
    );
  }

  /// Hero Green Gradient Wallet Card matching Figma 10033:51112 (9727:24487 / 9721:23186 / 9727:24756)
  Widget _buildFigmaHeroWalletCard(MonthlyEarningsController controller, bool isDark) {
    final bool canWithdraw = controller.withdrawableBalance >= controller.minWithdrawalAmount;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E7A2C),
            Color(0xFF30913F),
            Color(0xFF3EC856),
          ],
          stops: [0.0, 0.45, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 9.6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: -64,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: -4,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Right side in RTL: Withdrawable Balance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'available_for_withdrawal'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Color(0xFFCBE4CF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SarCurrencyWidget(size: 24, color: Colors.white),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    controller.withdrawableBalance.toStringAsFixed(2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Left side in RTL: Reserved / Under Processing Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'under_processing_review'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Color(0xFFCBE4CF),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SarCurrencyWidget(size: 15, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  controller.reservedBalance.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Soft Mint Action Button (Figma 10033:51132) with Dark Mode adaptation
                SizedBox(
                  height: 46,
                  child: Material(
                    color: isDark ? const Color(0xFF193521) : const Color(0xFFCFEBD3),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: canWithdraw
                          ? () => _showWithdrawalSheet(context, controller, isDark)
                          : () {
                              Get.snackbar(
                                'min_withdrawal_toast_title'.tr,
                                'min_withdrawal_toast_body'.trParams({
                                  'amount': controller.minWithdrawalAmount.toStringAsFixed(0),
                                }),
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF1F2937),
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                              );
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/image/figma_r15_r16/withdraw_icon.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              isDark ? const Color(0xFF86EFAC) : _primaryGreen,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            canWithdraw
                                ? 'request_withdrawal_with_min'.trParams({
                                    'amount': controller.minWithdrawalAmount.toStringAsFixed(0),
                                  })
                                : '${'min_withdrawal_prefix'.tr} ( ${controller.minWithdrawalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF86EFAC) : _primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SarCurrencyWidget(
                            size: 14,
                            color: isDark ? const Color(0xFF86EFAC) : _primaryGreen,
                          ),
                          Text(
                            ' )',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF86EFAC) : _primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Transactions History Preview Card inside gray container (Figma 10033:52059)
  Widget _buildTransactionsPreviewCard(
    MonthlyEarningsController controller,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subTextColor,
  ) {
    final allTx = SpecialistTransactionItem.fromController(controller);
    final previewItems = allTx.take(3).toList();
    final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE8ECEF);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
            blurRadius: 6,
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
                'transactions_history_title'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              InkWell(
                onTap: () => Get.to(() => const TransactionsHistoryScreen()),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'view_all_label'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (previewItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'no_transactions_yet'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ),
            )
          else
            ...previewItems.asMap().entries.map((entry) {
              final tx = entry.value;
              final isLast = entry.key == previewItems.length - 1;
              final amountColor = tx.isWithdrawal ? const Color(0xFFEC9C18) : _primaryGreen;
              final iconBg = tx.isWithdrawal
                  ? (isDark ? const Color(0xFF332611) : const Color(0xFFFEF3DC))
                  : (isDark ? const Color(0xFF142A1B) : const Color(0xFFF0FDF4));

              final locale = Get.locale?.languageCode ?? 'ar';
              String timeStr;
              try {
                timeStr = DateFormat('h:mm a - dd/MM', locale).format(tx.date);
              } catch (_) {
                timeStr = DateFormat('HH:mm - dd/MM').format(tx.date);
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: isLast
                    ? null
                    : BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: dividerColor, width: 0.8),
                        ),
                      ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          tx.isWithdrawal
                              ? 'assets/image/figma_r15_r16/send_withdraw.svg'
                              : 'assets/image/figma_r15_r16/received_deposit.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(amountColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.localizedTitle,
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
                            timeStr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SarCurrencyWidget(size: 16, color: amountColor),
                          const SizedBox(width: 4),
                          Text(
                            '${tx.amount.toStringAsFixed(1)} ${tx.isWithdrawal ? '-' : '+'}',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: amountColor,
                            ),
                          ),
                        ],
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

  /// R15: Modal Bottom Sheet for Withdrawal Request with Full Validation
  void _showWithdrawalSheet(BuildContext context, MonthlyEarningsController controller, bool isDark) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController(text: controller.withdrawableBalance.toStringAsFixed(0));
    final ibanCtrl = TextEditingController(text: controller.savedBankInfo?['iban']?.toString() ?? '');
    final nameCtrl = TextEditingController(text: controller.savedBankInfo?['beneficiary_name']?.toString() ?? '');
    final bankCtrl = TextEditingController(text: controller.savedBankInfo?['bank_name']?.toString() ?? '');

    final sheetBg = isDark ? const Color(0xFF1E232C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final fieldBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'request_payout_dialog_title'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${'processing_expected_duration'.tr}: ${controller.processingDurationLabel}',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subTextColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // Amount Field
                    _buildTextField(
                      controller: amountCtrl,
                      label: 'withdraw_amount_label'.tr,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      fieldBg: fieldBg,
                      textColor: textColor,
                      borderColor: borderColor,
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0) return 'enter_valid_amount'.tr;
                        if (val < controller.minWithdrawalAmount) {
                          return '${'min_withdraw_limit'.tr}: ${controller.minWithdrawalAmount.toStringAsFixed(0)} ${'sar'.tr}';
                        }
                        if (val > controller.withdrawableBalance) {
                          return 'insufficient_withdrawable_balance'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // IBAN Field
                    _buildTextField(
                      controller: ibanCtrl,
                      label: 'iban_number_label'.tr,
                      hint: 'SA0000000000000000000000',
                      fieldBg: fieldBg,
                      textColor: textColor,
                      borderColor: borderColor,
                      validator: (v) {
                        final trimmed = (v ?? '').trim();
                        if (trimmed.isEmpty) return 'iban_required'.tr;
                        if (!trimmed.toUpperCase().startsWith('SA') || trimmed.length < 15) {
                          return 'invalid_iban_format'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Beneficiary Name
                    _buildTextField(
                      controller: nameCtrl,
                      label: 'account_holder_name_label'.tr,
                      hint: 'beneficiary_name_hint'.tr,
                      fieldBg: fieldBg,
                      textColor: textColor,
                      borderColor: borderColor,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'beneficiary_name_required'.tr : null,
                    ),
                    const SizedBox(height: 12),

                    // Bank Name
                    _buildTextField(
                      controller: bankCtrl,
                      label: 'bank_name_label'.tr,
                      hint: 'bank_name_hint'.tr,
                      fieldBg: fieldBg,
                      textColor: textColor,
                      borderColor: borderColor,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'bank_name_required'.tr : null,
                    ),
                    const SizedBox(height: 22),

                    // Submit Button with double-click prevention
                    GetBuilder<MonthlyEarningsController>(
                      builder: (c) => SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: c.isSubmittingWithdrawal
                              ? null
                              : () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    final amt = double.parse(amountCtrl.text.trim());
                                    final ok = await c.submitWithdrawalRequest(
                                      amount: amt,
                                      iban: ibanCtrl.text.trim().toUpperCase(),
                                      beneficiaryName: nameCtrl.text.trim(),
                                      bankName: bankCtrl.text.trim(),
                                    );
                                    if (ok && ctx.mounted) {
                                      Navigator.of(ctx).pop();
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: c.isSubmittingWithdrawal
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                )
                              : Text(
                                  'confirm_and_submit_payout'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper TextField for bottom sheet
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color fieldBg,
    required Color textColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: fieldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryGreen, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
