import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_commissions_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_bank_transfer_sheet.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_pending_balance_sheet.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

class MarketerWalletScreen extends StatefulWidget {
  final bool isRoot;
  const MarketerWalletScreen({super.key, this.isRoot = false});

  @override
  State<MarketerWalletScreen> createState() => _MarketerWalletScreenState();
}

class _MarketerWalletScreenState extends State<MarketerWalletScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;

        return GetBuilder<LocalizationController>(
          builder: (locCtrl) {
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
              appBar: AppBar(
                backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: !widget.isRoot,
                leading: widget.isRoot
                    ? null
                    : IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          locCtrl.isLtr ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
                          color: isDark ? Colors.white : _darkText,
                        ),
                      ),
                title: Text(
                  'wallet_title'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : _darkText,
                  ),
                ),
              ),
              body: SafeArea(
                child: GetBuilder<MarketerController>(
                  builder: (c) {
                    if (c.isLoading && c.data == null) {
                      return SkeletonLoadingWidgets.vacationsSkeleton(isDark: isDark);
                    }
                    final filtered = c.transactions;

                    return RefreshIndicator(
                      color: _primaryGreen,
                      onRefresh: c.loadDashboard,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Hero Gradient Balance Card (Figma 10055:44761)
                            _buildHeroBalanceCard(context, c, isDark),
                            const SizedBox(height: 16),

                            // 2. Direct & Team Earnings Cards (Figma 10055:44780 & 10055:44795)
                            _buildDualEarningsCards(c, isDark),
                            const SizedBox(height: 20),

                            // 3. Recent Commissions Header (Figma 10055:44810)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'recent_commissions_title'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : _darkText,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.to(() => const MarketerCommissionsScreen()),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'view_all'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (filtered.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1C2028) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      IconlyLight.document,
                                      size: 48,
                                      color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'no_transactions_yet'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length > 5 ? 5 : filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final hasPaid = item['has_paid'] == true || item['status'] == 'paid';
                                  final reward = double.tryParse('${item['reward'] ?? 1.0}') ?? 1.0;
                                  final customer = (item['customer'] ?? 'customer'.tr).toString();
                                  final title = (item['title'] ?? 'referral_commission_title'.tr).toString();
                                  final date = (item['date'] ?? '').toString();
                                  final time = (item['time'] ?? '').toString();

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1C2028) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: hasPaid
                                                ? (isDark ? const Color(0xFF1E3A24) : const Color(0xFFF0FDF4))
                                                : (isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              hasPaid ? IconlyLight.arrowUp : IconlyLight.timeCircle,
                                              color: hasPaid
                                                  ? (isDark ? const Color(0xFF4ADE80) : _primaryGreen)
                                                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : _darkText,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$customer • $date $time',
                                                style: TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 11,
                                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '+${reward.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: hasPaid
                                                    ? (isDark ? const Color(0xFF4ADE80) : _primaryGreen)
                                                    : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            SarCurrencyWidget(
                                              size: 12,
                                              color: hasPaid
                                                  ? (isDark ? const Color(0xFF4ADE80) : _primaryGreen)
                                                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            SizedBox(height: widget.isRoot ? 90 : 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------- 1. Hero Balance Card (Figma 10055:44761)
  Widget _buildHeroBalanceCard(BuildContext context, MarketerController c, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.03, 0.03),
          end: const Alignment(0.93, 1.00),
          colors: isDark
              ? const [
                  Color(0xFF221A35),
                  Color(0xFF162D1D),
                  Color(0xFF221A35),
                ]
              : const [
                  Color(0xFFDFD3F5),
                  Color(0xFFEBFEEB),
                  Color(0xFFDFD3F5),
                ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inner Glass Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: ShapeDecoration(
              color: isDark
                  ? const Color(0xFF1C2028).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.42),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.80,
                  color: isDark ? const Color(0xFF2C3240) : Colors.white,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_balance'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white : _darkText,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SarCurrencyWidget(size: 28, color: isDark ? Colors.white : _darkText),
                      const SizedBox(width: 8),
                      Text(
                        c.balance.toStringAsFixed(c.balance.truncateToDouble() == c.balance ? 0 : 2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _primaryGreen,
                          fontSize: 36,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3 Mini Cards Row (Bank Transfer, Pending Balance, Today's Customers)
          Row(
            children: [
              // Card 1: Bank Transfer
              Expanded(
                child: GestureDetector(
                  onTap: () => MarketerBankTransferSheet.show(context),
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: _primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 8.90,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'bank_transfer'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'bank_transfer_min_desc'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Card 2: Pending Balance
              Expanded(
                child: GestureDetector(
                  onTap: () => MarketerPendingBalanceSheet.show(context),
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: isDark ? const Color(0xFF2C3240) : const Color(0x1E555555),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 8.90,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'pending_balance'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : _darkText,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SarCurrencyWidget(size: 13, color: isDark ? Colors.white : _darkText),
                            const SizedBox(width: 4),
                            Text(
                              c.pendingBalance.toStringAsFixed(0),
                              style: TextStyle(
                                color: isDark ? Colors.white : _darkText,
                                fontSize: 18,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.pendingBalance > 0
                              ? '${'remaining_days'.tr} ${c.pendingDays} ${'days'.tr}'
                              : 'no_pending_balance'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555),
                            fontSize: 9,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Card 3: Today's Customers
              Expanded(
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: isDark ? const Color(0xFF2C3240) : const Color(0x1E555555),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x07000000),
                        blurRadius: 8.90,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'today_customers'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : _darkText,
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c.todayReferred} ${'customer'.tr}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : _darkText,
                          fontSize: 15,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------- 2. Dual Earnings Cards (Figma 10055:44780 & 10055:44795)
  Widget _buildDualEarningsCards(MarketerController c, bool isDark) {
    return Row(
      children: [
        // Direct Earnings Card (Right in RTL)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162D1D) : const Color(0xFFFAFFFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3240) : const Color(0x7030913F),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/image/figma_freelance_marketer/wallet_direct_icon.svg',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'direct_earnings_title'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _darkText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SarCurrencyWidget(size: 14, color: _primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      c.directEarnings.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${c.directRate.toStringAsFixed(2)} ${'sar_per_customer'.tr}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF4ADE80) : _primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${c.directCustomersCount} ${'direct_customers_label'.tr}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Team Earnings Card (Left in RTL)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221A35) : const Color(0xFFF9F5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3240) : const Color(0x708B5CF6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/image/figma_freelance_marketer/wallet_team_icon.svg',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'team_earnings_title'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _darkText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SarCurrencyWidget(size: 14, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 4),
                    Text(
                      c.teamEarnings.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${c.teamRate.toStringAsFixed(2)} ${'sar_per_customer'.tr}',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${c.teamCustomersCount} ${'team_customers_label'.tr}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
