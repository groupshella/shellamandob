import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

class MarketerCommissionsScreen extends StatefulWidget {
  const MarketerCommissionsScreen({super.key});

  @override
  State<MarketerCommissionsScreen> createState() => _MarketerCommissionsScreenState();
}

class _MarketerCommissionsScreenState extends State<MarketerCommissionsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  int _selectedTabIndex = 0;
  List<String> get _tabLabels => ['filter_all'.tr, 'filter_completed'.tr, 'filter_pending'.tr];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            MarketerHeader(title: 'actual_returns_statement'.tr),

            // Top Filter Tabs (Matching Figma Image 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: List.generate(_tabLabels.length, (index) {
                  final isSelected = _selectedTabIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _primaryGreen
                              : (isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8)),
                          borderRadius: BorderRadius.circular(10),
                          border: isDark && !isSelected
                              ? Border.all(color: const Color(0xFF2C3240))
                              : null,
                        ),
                        child: Text(
                          _tabLabels[index],
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Divider(height: 1, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),

            // Commissions List
            Expanded(
              child: GetBuilder<MarketerController>(
                builder: (controller) {
                  final List<dynamic> rawTxns = controller.transactions.isNotEmpty
                      ? controller.transactions
                      : [
                          {
                            'title': 'supervisor_commission_new_marketer'.tr,
                            'date': 'today_sample_time'.tr,
                            'status': 'pending',
                            'amount': 40,
                            'section': 'today'.tr,
                            'pending_label': 'pending_days_remaining_7_sample'.tr,
                          },
                          {
                            'title': 'new_client_join_commission'.tr,
                            'date': 'today_sample_time'.tr,
                            'status': 'pending',
                            'amount': 40,
                            'section': 'today'.tr,
                            'pending_label': 'pending_days_remaining_7_sample'.tr,
                          },
                          {
                            'title': 'new_client_join_commission'.tr,
                            'date': 'today_sample_time'.tr,
                            'status': 'completed',
                            'amount': 20,
                            'section': 'today'.tr,
                            'completed_label': 'completed_status'.tr,
                          },
                          {
                            'title': 'new_client_join_commission'.tr,
                            'date': 'أمس، 2:30 م',
                            'status': 'pending',
                            'amount': 20,
                            'section': 'yesterday'.tr,
                            'pending_label': 'pending_days_remaining_7_sample'.tr,
                          },
                          {
                            'title': 'new_client_join_commission'.tr,
                            'date': 'الأربعاء, 8 مارس 2026، 2:30 م',
                            'status': 'completed',
                            'amount': 20,
                            'section': 'الأربعاء, 8 مارس 2026',
                            'completed_label': 'completed_status'.tr,
                          },
                        ];

                  final filtered = rawTxns.where((t) {
                    if (_selectedTabIndex == 0) return true;
                    final status = (t['status'] ?? '').toString();
                    if (_selectedTabIndex == 1) {
                      return status == 'approved' || status == 'completed' || status == 'معتمدة' || status == 'مكتملة' || status == 'مكتمل';
                    }
                    if (_selectedTabIndex == 2) {
                      return status == 'pending' || status == 'معلّقة';
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconlyLight.document,
                            size: 54,
                            color: isDark ? const Color(0xFF4B5563) : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'no_commissions_yet'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by date/section
                  final Map<String, List<Map<String, dynamic>>> grouped = {};
                  for (final item in filtered) {
                    final section = (item['section'] ?? item['group_date'] ?? 'today'.tr).toString();
                    grouped.putIfAbsent(section, () => []).add(item);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, sectionIndex) {
                      final sectionKey = grouped.keys.elementAt(sectionIndex);
                      final items = grouped[sectionKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header Date
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8),
                            child: Text(
                              sectionKey,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                              ),
                            ),
                          ),

                          // Group Items
                          ...items.map((item) {
                            final isPending = (item['status'] ?? '').toString() == 'pending' ||
                                (item['status'] ?? '').toString() == 'معلّقة';
                            final amount = item['amount'] ?? item['reward'] ?? 20;
                            final title = (item['title'] ?? 'new_passenger_referral_reward'.tr).toString();
                            final time = (item['time'] ?? item['date'] ?? 'today_sample_time'.tr).toString();
                            final statusLabel = isPending
                                ? (item['pending_label'] ?? 'pending_days_remaining_7_sample'.tr).toString()
                                : (item['completed_label'] ?? 'completed_status'.tr).toString();

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  // Coin Icon Container
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? (isDark ? const Color(0xFF332512) : const Color(0xFFFEF3C7))
                                          : (isDark ? const Color(0xFF1E3A24) : const Color(0xFFD1FAE5)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      IconlyLight.paper,
                                      size: 20,
                                      color: isPending
                                          ? const Color(0xFFD97706)
                                          : (isDark ? const Color(0xFF4ADE80) : _primaryGreen),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Title and time and status
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : _darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF98A2B3),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isPending
                                                ? const Color(0xFFD97706)
                                                : (isDark ? const Color(0xFF4ADE80) : _primaryGreen),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Amount
                                  Row(
                                    children: [
                                      Text(
                                        '+$amount ',
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: isPending
                                              ? const Color(0xFFD97706)
                                              : (isDark ? const Color(0xFF4ADE80) : _primaryGreen),
                                        ),
                                      ),
                                      SarCurrencyWidget(
                                        size: 15,
                                        color: isPending
                                            ? const Color(0xFFD97706)
                                            : (isDark ? const Color(0xFF4ADE80) : _primaryGreen),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          Divider(height: 16, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
