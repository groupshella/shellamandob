import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
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

  int _selectedTabIndex = 0; // 0: الكل, 1: معتمدة, 2: معلقة

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (locCtrl) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: !widget.isRoot,
            leading: widget.isRoot
                ? null
                : IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      locCtrl.isLtr ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
                      color: _darkText,
                    ),
                  ),
            title: Text(
              'wallet_and_earnings'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: GetBuilder<MarketerController>(
              builder: (c) {
                final txns = c.transactions;
                final filtered = txns.where((t) {
                  if (_selectedTabIndex == 0) return true;
                  final status = (t['status'] ?? '').toString();
                  if (_selectedTabIndex == 1) {
                    return status == 'approved' || status == 'completed' || status == 'paid';
                  }
                  if (_selectedTabIndex == 2) {
                    return status == 'pending' || status == 'registered_only';
                  }
                  return true;
                }).toList();

                final progress = (c.balance / c.minTransferAmount).clamp(0.0, 1.0);

                return RefreshIndicator(
                  color: _primaryGreen,
                  onRefresh: c.loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Wallet Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF165B25),
                                Color(0xFF237A33),
                                Color(0xFF30913F),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3030913F),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'available_balance_withdraw'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      color: Color(0xFFD1FAE5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${'marketer_code_label'.tr}: ${c.code}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    c.balance.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const SarCurrencyWidget(size: 18, color: Colors.white),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Progress bar towards minimum withdrawal
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'min_withdraw_limit'.tr}: ${c.minTransferAmount.toStringAsFixed(0)} ${'sar'.tr}',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 12,
                                          color: Color(0xFFD1FAE5),
                                        ),
                                      ),
                                      Text(
                                        '${(progress * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Withdraw Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showWithdrawDialog(context, c),
                                  icon: const Icon(IconlyLight.wallet, size: 20, color: _primaryGreen),
                                  label: Text(
                                    'request_payout_bank'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title & Filter Tabs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'commissions_and_transfers_log'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _darkText,
                              ),
                            ),
                            Row(
                              children: [
                                _buildTabChip(0, 'filter_all'.tr),
                                const SizedBox(width: 4),
                                _buildTabChip(1, 'tab_approved'.tr),
                                const SizedBox(width: 4),
                                _buildTabChip(2, 'tab_pending'.tr),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Transactions List
                        if (filtered.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(IconlyLight.document, size: 48, color: Color(0xFFD1D5DB)),
                                const SizedBox(height: 10),
                                Text(
                                  'no_transactions_yet'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
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
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final hasPaid = item['has_paid'] == true || item['status'] == 'paid';
                          final reward = double.tryParse('${item['reward'] ?? 1.0}') ?? 1.0;
                          final customer = (item['customer'] ?? 'عميل').toString();
                          final title = (item['title'] ?? 'عمولة إحالة').toString();
                          final date = (item['date'] ?? '').toString();
                          final time = (item['time'] ?? '').toString();

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x04000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: hasPaid ? const Color(0xFFF0FDF4) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      hasPaid ? IconlyLight.arrowUp : IconlyLight.timeCircle,
                                      color: hasPaid ? _primaryGreen : const Color(0xFF6B7280),
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
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$customer • $date $time',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 11,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '+${reward.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: hasPaid ? _primaryGreen : const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    SarCurrencyWidget(
                                      size: 12,
                                      color: hasPaid ? _primaryGreen : const Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
  }

  Widget _buildTabChip(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, MarketerController c) {
    if (c.balance < c.minTransferAmount) {
      showCustomSnackBar(
        '${'min_withdraw_limit'.tr}: ${c.minTransferAmount.toStringAsFixed(0)} ${'sar'.tr}. ${'available_balance_withdraw'.tr}: ${c.balance.toStringAsFixed(2)} ${'sar'.tr}',
        isError: true,
      );
      return;
    }

    final bankCtrl = TextEditingController();
    final ibanCtrl = TextEditingController();
    final holderCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'request_payout_title'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: holderCtrl,
              style: const TextStyle(fontFamily: 'Tajawal'),
              decoration: InputDecoration(
                labelText: 'full_name_bank_account'.tr,
                labelStyle: const TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bankCtrl,
              style: const TextStyle(fontFamily: 'Tajawal'),
              decoration: InputDecoration(
                labelText: 'bank_name_hint'.tr,
                labelStyle: const TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ibanCtrl,
              style: const TextStyle(fontFamily: 'Tajawal'),
              decoration: InputDecoration(
                labelText: 'iban_hint'.tr,
                labelStyle: const TextStyle(fontFamily: 'Tajawal'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                if (holderCtrl.text.trim().isEmpty || bankCtrl.text.trim().isEmpty || ibanCtrl.text.trim().isEmpty) {
                  showCustomSnackBar('fill_all_bank_fields'.tr);
                  return;
                }
                Navigator.pop(ctx);
                showCustomSnackBar('payout_request_received'.tr, isError: false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'confirm_payout_request'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
