import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/controllers/monthly_earnings_controller.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

/// Unified real transaction item built from withdrawal requests + monthly earnings layers.
class SpecialistTransactionItem {
  final String id;
  final String titleKey;
  final double amount;
  final bool isWithdrawal; // true = withdrawal (amber), false = deposit (green)
  final DateTime date;
  final String? status;
  final String? rejectionReason;
  final String? iban;

  const SpecialistTransactionItem({
    required this.id,
    required this.titleKey,
    required this.amount,
    required this.isWithdrawal,
    required this.date,
    this.status,
    this.rejectionReason,
    this.iban,
  });

  String get localizedTitle => titleKey.tr;

  /// Builds real transactions list from MonthlyEarningsController (no mock data).
  static List<SpecialistTransactionItem> fromController(
    MonthlyEarningsController controller,
  ) {
    final List<SpecialistTransactionItem> items = [];

    // 1. Real Withdrawals History (R15)
    for (final raw in controller.withdrawalsHistory) {
      if (raw is! Map) continue;
      final w = Map<String, dynamic>.from(raw);
      final double amt = (w['amount'] is num)
          ? (w['amount'] as num).toDouble()
          : double.tryParse(w['amount']?.toString() ?? '0') ?? 0.0;
      final DateTime dt =
          DateTime.tryParse(w['created_at']?.toString() ?? '') ?? DateTime.now();

      items.add(
        SpecialistTransactionItem(
          id: 'w_${w['id'] ?? dt.millisecondsSinceEpoch}',
          titleKey: 'tx_withdrawal_balance',
          amount: amt,
          isWithdrawal: true,
          date: dt,
          status: w['status']?.toString(),
          rejectionReason: w['rejection_reason']?.toString(),
          iban: w['iban']?.toString(),
        ),
      );
    }

    // 2. Real Monthly Earnings Deposits (from live monthly earnings API)
    final data = controller.earningsData;
    if (data != null) {
      final DateTime calcDate =
          DateTime.tryParse(data.calculatedAt) ?? DateTime.now();

      if (data.summary.layer3NetworkTotal > 0) {
        items.add(
          SpecialistTransactionItem(
            id: 'dep_network_${data.month}',
            titleKey: 'tx_deposit_network_commission',
            amount: data.summary.layer3NetworkTotal,
            isWithdrawal: false,
            date: calcDate,
            status: 'credited',
          ),
        );
      }

      if (data.summary.layer1SalaryTotal > 0) {
        items.add(
          SpecialistTransactionItem(
            id: 'dep_salary_${data.month}',
            titleKey: 'tx_deposit_base_salary',
            amount: data.summary.layer1SalaryTotal,
            isWithdrawal: false,
            date: calcDate,
            status: 'credited',
          ),
        );
      }

      if (data.summary.layer4DirectTotal > 0) {
        items.add(
          SpecialistTransactionItem(
            id: 'dep_direct_${data.month}',
            titleKey: 'tx_deposit_direct_commissions',
            amount: data.summary.layer4DirectTotal,
            isWithdrawal: false,
            date: calcDate,
            status: 'credited',
          ),
        );
      }

      if (data.summary.layer2IncentiveTotal > 0) {
        items.add(
          SpecialistTransactionItem(
            id: 'dep_incentive_${data.month}',
            titleKey: 'tx_deposit_contract_incentive',
            amount: data.summary.layer2IncentiveTotal,
            isWithdrawal: false,
            date: calcDate,
            status: 'credited',
          ),
        );
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }
}

/// Figma Node 10034:52526 — Transactions History Screen (Full i18n + Dark/Light + Figma SVGs)
class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _amberWithdraw = Color(0xFFEC9C18);

  static const String _filterCandleSvg =
      'assets/image/figma_r15_r16/filter_candle.svg';
  static const String _sendWithdrawSvg =
      'assets/image/figma_r15_r16/send_withdraw.svg';
  static const String _receivedDepositSvg =
      'assets/image/figma_r15_r16/received_deposit.svg';

  String _selectedType = 'all';
  String _selectedStatus = 'all';

  String _formatDateGroupHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'date_today'.tr;
    if (diff == 1) return 'date_yesterday'.tr;
    try {
      final locale = Get.locale?.languageCode ?? 'ar';
      return DateFormat('EEEE, d MMMM y', locale).format(dt);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
  }

  String _formatTimeSubtitle(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;
    final locale = Get.locale?.languageCode ?? 'ar';

    String timeStr;
    try {
      timeStr = DateFormat('h:mm a', locale).format(dt);
    } catch (_) {
      timeStr = DateFormat('HH:mm').format(dt);
    }

    if (diff == 0) return '$timeStr - ${'date_today'.tr}';
    if (diff == 1) return '$timeStr - ${'date_yesterday'.tr}';
    return '$timeStr - ${DateFormat('dd/MM/yyyy').format(dt)}';
  }

  void _openFilterSheet(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E232C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111B18);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Widget buildChoice(String value, String labelKey) {
              final selected = _selectedStatus == value;
              return ChoiceChip(
                label: Text(
                  labelKey.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475467)),
                  ),
                ),
                selected: selected,
                selectedColor: _primaryGreen,
                backgroundColor:
                    isDark ? const Color(0xFF252B37) : const Color(0xFFF6F6F6),
                onSelected: (_) {
                  setModalState(() => _selectedStatus = value);
                  setState(() => _selectedStatus = value);
                },
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'filter_tx_status_title'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      buildChoice('all', 'filter_all'),
                      buildChoice('pending_review', 'status_pending_review'),
                      buildChoice('transferred', 'status_transferred_success'),
                      buildChoice('rejected', 'status_rejected'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'apply_filter_btn'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final bool isDark = themeCtrl.darkTheme;
        final Color bgColor = isDark ? const Color(0xFF121418) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final Color subTextColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final Color dividerColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE8ECEF);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              'transactions_history_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: textColor, size: 20),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                onPressed: () => _openFilterSheet(isDark),
                icon: SvgPicture.asset(
                  _filterCandleSvg,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          body: GetBuilder<MonthlyEarningsController>(
            builder: (controller) {
              final allItems =
                  SpecialistTransactionItem.fromController(controller);

              final filtered = allItems.where((tx) {
                if (_selectedType == 'withdrawal' && !tx.isWithdrawal) {
                  return false;
                }
                if (_selectedType == 'deposit' && tx.isWithdrawal) return false;
                if (_selectedStatus != 'all' && tx.isWithdrawal) {
                  if ((tx.status ?? '') != _selectedStatus) return false;
                }
                return true;
              }).toList();

              final Map<String, List<SpecialistTransactionItem>> grouped = {};
              for (final tx in filtered) {
                final key = _formatDateGroupHeader(tx.date);
                grouped.putIfAbsent(key, () => []).add(tx);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter Chips Row (Figma 10034:52534)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'filter_all', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'withdrawal', 'filter_withdrawal', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('deposit', 'filter_deposit', isDark),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: _primaryGreen,
                      onRefresh: () async {
                        await controller.fetchWithdrawalInfo();
                        await controller.refreshCurrentMonth();
                      },
                      child: filtered.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 100),
                                Icon(Icons.receipt_long_rounded,
                                    size: 48, color: subTextColor),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'no_matching_transactions'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: subTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                              itemCount: grouped.length,
                              itemBuilder: (context, groupIndex) {
                                final header =
                                    grouped.keys.elementAt(groupIndex);
                                final groupItems = grouped[header]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12, bottom: 8),
                                      child: Text(
                                        header,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF707784),
                                        ),
                                      ),
                                    ),
                                    ...groupItems.asMap().entries.map((entry) {
                                      final tx = entry.value;
                                      final isLast =
                                          entry.key == groupItems.length - 1;
                                      return _buildTransactionRow(
                                        tx: tx,
                                        isDark: isDark,
                                        textColor: textColor,
                                        subTextColor: subTextColor,
                                        dividerColor: dividerColor,
                                        showDivider: !isLast,
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String key, String labelKey, bool isDark) {
    final bool isSelected = _selectedType == key;
    return InkWell(
      onTap: () => setState(() => _selectedType = key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryGreen
              : (isDark ? const Color(0xFF1E232C) : const Color(0xFFF6F6F6)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          labelKey.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF707784)),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow({
    required SpecialistTransactionItem tx,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color dividerColor,
    required bool showDivider,
  }) {
    final Color amountColor = tx.isWithdrawal ? _amberWithdraw : _primaryGreen;
    final Color iconBg = tx.isWithdrawal
        ? (isDark ? const Color(0xFF332611) : const Color(0xFFFEF3DC))
        : (isDark ? const Color(0xFF142A1B) : const Color(0xFFF0FDF4));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: dividerColor, width: 0.8),
              ),
            )
          : null,
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
                tx.isWithdrawal ? _sendWithdrawSvg : _receivedDepositSvg,
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
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimeSubtitle(tx.date),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
                if (tx.rejectionReason != null &&
                    tx.rejectionReason!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.rejectionReason!,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10,
                      color: Color(0xFFD92D20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
  }
}
