import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

/// Bottom Sheet for Pending Balance (Figma 9632:35312 - الرصيد المعلق)
class MarketerPendingBalanceSheet extends StatelessWidget {
  const MarketerPendingBalanceSheet({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _amberColor = Color(0xFFF5A623);
  static const Color _darkText = Color(0xFF111B18);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MarketerPendingBalanceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final headlineColor = isDark ? Colors.white : _darkText;

    return GetBuilder<MarketerController>(
      builder: (c) {
        final pendingAmount = c.pendingBalance.toStringAsFixed(0);
        final remainingDays = c.pendingDays > 0 ? c.pendingDays : 4;

        final double totalComm = c.lifetimeEarnings > 0
            ? c.lifetimeEarnings
            : (c.balance + c.pendingBalance);
        final totalDisplay = totalComm.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header: Title centered + Close SVG button (Figma 9632:35313)
                Row(
                  children: [
                    const SizedBox(width: 28),
                    Expanded(
                      child: Text(
                        'pending_balance_modal_title'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: headlineColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/image/figma_bank_close.svg',
                            width: 25,
                            height: 25,
                            colorFilter: isDark
                                ? const ColorFilter.mode(Colors.white70, BlendMode.srcIn)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Two Stat Boxes (Figma 9632:35318)
                // In RTL: Right box = إجمالي العمولات (green), Left box = معلّق (amber)
                Row(
                  children: [
                    // Right Box in RTL: إجمالي العمولات (Figma 9632:35319)
                    Expanded(
                      child: Container(
                        height: 92,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132D1B) : const Color(0xFFEBFEEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0x8C3EC856),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'total_commissions_label'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  totalDisplay,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryGreen,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const SarCurrencyWidget(
                                  size: 22,
                                  color: _primaryGreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Left Box in RTL: معلّق (Figma 9632:35327)
                    Expanded(
                      child: Container(
                        height: 92,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF332512)
                              : const Color(0x2EF5A623),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0x4DF5A623),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'filter_pending'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _amberColor.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  pendingAmount,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: _amberColor,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const SarCurrencyWidget(
                                  size: 22,
                                  color: _amberColor,
                                ),
                              ],
                            ),
                            Text(
                              '${'remaining_days'.tr} $remainingDays ${'days'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _amberColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Explanatory Note Text (Figma 9632:35337)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'pending_balance_modal_desc'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: headlineColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
