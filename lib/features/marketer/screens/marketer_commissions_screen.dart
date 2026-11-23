import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';

/// Actual Returns Statement Screen ("بيان العوائد الفعلية") matching Figma node 9632:35186
class MarketerCommissionsScreen extends StatefulWidget {
  const MarketerCommissionsScreen({super.key});

  @override
  State<MarketerCommissionsScreen> createState() => _MarketerCommissionsScreenState();
}

class _MarketerCommissionsScreenState extends State<MarketerCommissionsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _amberText = Color(0xFFEC9C18);

  int _selectedTabIndex = 0;
  String? _selectedPeriodFilter; // 'today' | 'week' | 'month' | 'date'
  DateTime? _selectedCustomDate;
  List<String> get _tabLabels => ['filter_all'.tr, 'filter_completed'.tr, 'filter_pending'.tr];

  void _showFilterBottomSheet(BuildContext context, bool isDark, Color headlineColor) {
    String? tempPeriod = _selectedPeriodFilter;
    DateTime tempDate = _selectedCustomDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final modalBg = isDark ? const Color(0xFF1C2028) : Colors.white;
            final cardFill = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
            final dateStr =
                '${tempDate.day.toString().padLeft(2, '0')}/${tempDate.month.toString().padLeft(2, '0')}/${tempDate.year}';

            Widget buildPeriodChip(String key, String label) {
              final bool active = tempPeriod == key;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setModalState(() {
                      tempPeriod = active ? null : key;
                    });
                  },
                  child: Container(
                    height: 37,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? _primaryGreen : cardFill,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: active ? Colors.white : headlineColor,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: modalBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header (Figma 9632:35495)
                    Row(
                      children: [
                        const SizedBox(width: 28),
                        Expanded(
                          child: Text(
                            'filter_title'.tr,
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
                          onTap: () => Navigator.of(ctx).pop(),
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

                    // Section Title: الفترة الزمنية (Figma 9632:35502)
                    Text(
                      'time_period_label'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: headlineColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker Input Box (Figma 9632:35504)
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: tempDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempDate = picked;
                            tempPeriod = 'date';
                          });
                        }
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: cardFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tempPeriod == 'date'
                                ? _primaryGreen
                                : cardFill,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 33,
                              height: 33,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2E2344)
                                    : const Color(0xFFDFD3F5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/image/figma_filter_calendar.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                dateStr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: headlineColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3 Quick Period Chips (Figma 9632:35509: اليوم | هذا الأسبوع | هذا الشهر)
                    Row(
                      children: [
                        buildPeriodChip('today', 'today_filter'.tr),
                        const SizedBox(width: 16),
                        buildPeriodChip('week', 'this_week_filter'.tr),
                        const SizedBox(width: 16),
                        buildPeriodChip('month', 'this_month_filter'.tr),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Confirm Button: تم (Figma 9632:35516)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPeriodFilter = tempPeriod;
                            _selectedCustomDate = tempPeriod == 'date' ? tempDate : null;
                          });
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'done_action'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final surfaceBg = isDark ? const Color(0xFF121418) : Colors.white;
    final headlineColor = isDark ? Colors.white : _darkText;
    final mutedText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
    final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: surfaceBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header matching Figma 9632:35189
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: isRtl ? Matrix4.identity() : Matrix4.rotationY(math.pi),
                          child: SvgPicture.asset(
                            'assets/image/figma_comm_arrow_right.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(headlineColor, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'actual_returns_statement'.tr,
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
                    onTap: () => _showFilterBottomSheet(context, isDark, headlineColor),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/image/figma_comm_filter.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            _selectedPeriodFilter != null ? _primaryGreen : headlineColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Filter Chips (Figma 9632:35193 - radius 4, #30913F active / #F6F6F6 inactive)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: List.generate(_tabLabels.length, (index) {
                  final isSelected = _selectedTabIndex == index;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _primaryGreen
                              : (isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F6F6)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _tabLabels[index],
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : mutedText,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 3. Commissions List
            Expanded(
              child: GetBuilder<MarketerController>(
                builder: (controller) {
                  if (controller.isLoading && controller.data == null) {
                    return SkeletonLoadingWidgets.listCardsSkeleton(isDark: isDark, itemCount: 5);
                  }

                  final List<dynamic> rawTxns = controller.transactions;

                  final filtered = rawTxns.where((t) {
                    if (_selectedTabIndex != 0) {
                      final status = (t['status'] ?? '').toString();
                      if (_selectedTabIndex == 1) {
                        final isComp = status == 'approved' ||
                            status == 'completed' ||
                            status == 'paid' ||
                            status == 'معتمدة' ||
                            status == 'مكتملة' ||
                            status == 'مكتمل' ||
                            status == 'مستحق';
                        if (!isComp) return false;
                      } else if (_selectedTabIndex == 2) {
                        final isPend = status == 'pending' ||
                            status == 'معلّقة' ||
                            status.contains('بانتظار');
                        if (!isPend) return false;
                      }
                    }

                    if (_selectedPeriodFilter != null) {
                      final rawDate = (t['joined_at'] ?? t['created_at'] ?? '').toString();
                      final parsed = DateTime.tryParse(rawDate);
                      if (parsed != null) {
                        final now = DateTime.now();
                        if (_selectedPeriodFilter == 'today') {
                          if (parsed.year != now.year ||
                              parsed.month != now.month ||
                              parsed.day != now.day) {
                            return false;
                          }
                        } else if (_selectedPeriodFilter == 'week') {
                          if (now.difference(parsed).inDays > 7) return false;
                        } else if (_selectedPeriodFilter == 'month') {
                          if (parsed.year != now.year || parsed.month != now.month) {
                            return false;
                          }
                        } else if (_selectedPeriodFilter == 'date' &&
                            _selectedCustomDate != null) {
                          if (parsed.year != _selectedCustomDate!.year ||
                              parsed.month != _selectedCustomDate!.month ||
                              parsed.day != _selectedCustomDate!.day) {
                            return false;
                          }
                        }
                      }
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      color: _primaryGreen,
                      onRefresh: controller.loadDashboard,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: Center(
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
                                      color: mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by date/section
                  final Map<String, List<Map<String, dynamic>>> grouped = {};
                  for (final item in filtered) {
                    final map = Map<String, dynamic>.from(item as Map);
                    final section = (map['section'] ?? map['group_date'] ?? 'today'.tr).toString();
                    grouped.putIfAbsent(section, () => []).add(map);
                  }

                  return RefreshIndicator(
                    color: _primaryGreen,
                    onRefresh: controller.loadDashboard,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: grouped.length,
                      itemBuilder: (context, gIdx) {
                        final sectionKey = grouped.keys.elementAt(gIdx);
                        final items = grouped[sectionKey]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header Date (Figma 9632:35208 - 16px Bold #707784)
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 6),
                              child: Text(
                                sectionKey,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: mutedText,
                                ),
                              ),
                            ),

                            // Group Items
                            ...items.map((item) {
                              final statusStr = (item['status'] ?? '').toString();
                              final isPending = statusStr == 'pending' || statusStr == 'معلّقة';
                              final amount = item['amount'] ?? item['reward'] ?? 0;
                              final title = (item['title'] ?? 'new_passenger_referral_reward'.tr).toString();
                              final time = (item['time'] ?? item['date'] ?? '').toString();
                              final statusLabel = isPending
                                  ? (item['pending_label'] ?? 'filter_pending'.tr).toString()
                                  : (item['completed_label'] ?? 'completed_status'.tr).toString();

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: dividerColor, width: 0.8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Coin Icon Container (40x40, radius 12)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isPending
                                            ? (isDark ? const Color(0xFF332512) : const Color(0xFFFEF3DC))
                                            : (isDark ? const Color(0xFF132D1B) : const Color(0xFFE6F9F0)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        isPending
                                            ? 'assets/image/figma_comm_coin_amber.svg'
                                            : 'assets/image/figma_comm_coin_green.svg',
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Title, Time, Status
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          if (time.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              time,
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 11,
                                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 2),
                                          Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isPending ? _amberText : _primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Amount (+XX with green SAR SVG)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '+$amount',
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: _primaryGreen,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        SvgPicture.asset(
                                          'assets/image/figma_comm_sar_green.svg',
                                          width: 13,
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
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
