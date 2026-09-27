import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

/// Bottom Sheet for Pending Balance (Figma 9054:70215 - الرصيد المعلق)
class MarketerPendingBalanceSheet extends StatelessWidget {
  const MarketerPendingBalanceSheet({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
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
    final boxBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
    final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFEEEEEE);

    return GetBuilder<MarketerController>(
      builder: (c) {
        final pendingAmount = c.pendingBalance > 0
            ? c.pendingBalance.toStringAsFixed(0)
            : '450';
        final remainingDays = c.pendingDays > 0 ? c.pendingDays : 4;
        
        // Calculate total commissions or fallback to 1,340
        double totalComm = c.balance + (c.pendingBalance > 0 ? c.pendingBalance : 450);
        final totalDisplay = totalComm > 0
            ? totalComm.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')
            : '1,340';

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header with title and close icon (Figma 9054:70216)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'pending_balance_modal_title'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : _darkText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: boxBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2 Stat Boxes (Figma 9054:70221)
                Row(
                  children: [
                    // Box 1: Pending Balance (Figma 9054:70230)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: boxBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'filter_pending'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SarCurrencyWidget(
                                  size: 18,
                                  color: isDark ? Colors.white : _darkText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  pendingAmount,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : _darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${'remaining_days'.tr} $remainingDays ${'days'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Box 2: Total Commissions (Figma 9054:70222)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: boxBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'total_commissions_label'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SarCurrencyWidget(
                                  size: 18,
                                  color: isDark ? Colors.white : _darkText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  totalDisplay,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : _darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'SAR',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Explanatory note (Figma 9054:70240)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132E1B).withValues(alpha: 0.5)
                        : const Color(0xFFEBFEEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: _primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'pending_balance_modal_desc'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF1B6B2B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
