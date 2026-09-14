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
  final List<String> _tabLabels = ['الكل', 'مكتملة', 'معلّقة'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          color: isSelected ? _primaryGreen : const Color(0xFFF6F5F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _tabLabels[index],
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),

            // Commissions List
            Expanded(
              child: GetBuilder<MarketerController>(
                builder: (controller) {
                  final txns = controller.transactions;
                  final filtered = txns.where((t) {
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
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'no_commissions_yet'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by date/section
                  final Map<String, List<Map<String, dynamic>>> grouped = {};
                  for (final item in filtered) {
                    final section = (item['section'] ?? item['group_date'] ?? 'اليوم').toString();
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
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),

                          // Group Items
                          ...items.map((item) {
                            final isPending = (item['status'] ?? '').toString() == 'pending' ||
                                (item['status'] ?? '').toString() == 'معلّقة';
                            final amount = item['amount'] ?? item['reward'] ?? 20;
                            final title = (item['title'] ?? 'مكافأة إحالة راكب جديدة').toString();
                            final time = (item['time'] ?? item['date'] ?? 'اليوم، 2:30 م').toString();
                            final statusLabel = isPending
                                ? (item['pending_label'] ?? 'معلّقة - متبقي 7 أيام').toString()
                                : (item['completed_label'] ?? 'مكتملة').toString();

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  // Coin Icon Container
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      IconlyLight.paper,
                                      size: 20,
                                      color: isPending ? const Color(0xFFD97706) : _primaryGreen,
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
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            color: Color(0xFF98A2B3),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isPending ? const Color(0xFFD97706) : _primaryGreen,
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
                                          color: isPending ? const Color(0xFFD97706) : _primaryGreen,
                                        ),
                                      ),
                                      SarCurrencyWidget(
                                        size: 15,
                                        color: isPending ? const Color(0xFFD97706) : _primaryGreen,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 16, color: Color(0xFFF3F4F6)),
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
