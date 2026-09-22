import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'visit_summary_screen.dart';
import 'active_store_visit_screen.dart';
import '../../attendance/screens/select_work_zone_screen.dart';

class DailyVisitsScreen extends StatefulWidget {
  const DailyVisitsScreen({super.key});

  @override
  State<DailyVisitsScreen> createState() => _DailyVisitsScreenState();
}

class _DailyVisitsScreenState extends State<DailyVisitsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<StoreVisitsController>()) {
        Get.put(StoreVisitsController(), permanent: true);
      } else {
        Get.find<StoreVisitsController>().loadVisits();
      }
    });
  }

  static String _tr(String key, String fallback, [Map<String, String>? params]) {
    final res = key.tr;
    if (res == key || res.isEmpty) {
      if (params != null) {
        String output = fallback;
        params.forEach((k, v) => output = output.replaceAll('@$k', v));
        return output;
      }
      return fallback;
    }
    if (params != null) {
      return key.trParams(params);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoreVisitsController>()) {
      Get.put(StoreVisitsController(), permanent: true);
    }

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final headingText = isDark ? Colors.white : const Color(0xFF1F2937);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final dateText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final btnGreyBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6);
        final btnGreyText = isDark ? Colors.white70 : const Color(0xFF43474F);
        final counterBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF8FAF8);
        final counterBorder = isDark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: Text(
              _tr('today_visits', 'زيارات اليوم'),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            backgroundColor: cardBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => Get.find<StoreVisitsController>().loadVisits(),
                icon: Icon(Icons.refresh_rounded, color: btnGreyText),
              ),
            ],
          ),
      body: SafeArea(
        child: GetBuilder<StoreVisitsController>(
          builder: (controller) {
            final visits = controller.allVisits;
            final currentDate = DateFormat('EEEE، d MMMM y', Get.locale?.languageCode ?? 'ar').format(DateTime.now());

            return RefreshIndicator(
              color: _primaryGreen,
              onRefresh: () => controller.loadVisits(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // 1. Top Summary Header Card (Figma Container 8903:32637)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border(
                          bottom: BorderSide(color: borderColor, width: 0.8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title: زيارات منطقة غرب الرياض
                          Text(
                            _tr('visits_in_zone', 'زيارات منطقة @zone', {'zone': controller.zoneName}),
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: headingText,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Subtitle: الأحد، 14 سبتمبر 2025
                          Text(
                            currentDate,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: dateText,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 3 Metric Counter Boxes in a Row
                          Row(
                            children: [
                              // 1. المخططة (Right in RTL / start)
                              Expanded(
                                child: _buildCounterBox(
                                  count: controller.scheduledVisitsCount,
                                  label: _tr('scheduled_label', 'المخططة'),
                                  valueColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
                                  bgColor: counterBg,
                                  borderColor: counterBorder,
                                  labelColor: dateText,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 2. مكتملة (Center)
                              Expanded(
                                child: _buildCounterBox(
                                  count: controller.completedVisitsCount,
                                  label: _tr('completed', 'مكتملة'),
                                  valueColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
                                  bgColor: counterBg,
                                  borderColor: counterBorder,
                                  labelColor: dateText,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 3. متابعة (Left in RTL / end)
                              Expanded(
                                child: _buildCounterBox(
                                  count: controller.followUpVisitsCount,
                                  label: _tr('follow_up_label', 'متابعة'),
                                  valueColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF7861A6),
                                  bgColor: counterBg,
                                  borderColor: counterBorder,
                                  labelColor: dateText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Action Button: طلب تغيير المنطقة
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => const SelectWorkZoneScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: btnGreyBg,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _tr('request_zone_change', 'طلب تغيير المنطقة'),
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: btnGreyText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 2. Visits Cards List
                  if (controller.isLoading && visits.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: _primaryGreen),
                      ),
                    )
                  else if (visits.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          _tr('no_visits_found', 'لا توجد زيارات متاحة حالياً'),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: dateText,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final visit = visits[index];
                            final isFirstUpcoming = visit.visitStatus == StoreVisitStatus.scheduled &&
                                visits.where((v) => v.visitStatus == StoreVisitStatus.scheduled).firstOrNull?.id == visit.id;

                            return _buildVisitCard(
                              context: context,
                              visit: visit,
                              controller: controller,
                              isPrimaryAction: isFirstUpcoming || visit.visitStatus == StoreVisitStatus.inProgress,
                              isDark: isDark,
                              cardBg: cardBg,
                              headingText: headingText,
                              subText: subText,
                              btnGreyBg: btnGreyBg,
                              btnGreyText: btnGreyText,
                              darkText: darkText,
                            );
                          },
                          childCount: visits.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        ),
      ),
    );
      },
    );
  }

  // Summary Counter Box (Figma Container 8903:32643)
  Widget _buildCounterBox({
    required int count,
    required String label,
    required Color valueColor,
    required Color bgColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: labelColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Visit Card Matching Figma Container 8895:71648
  Widget _buildVisitCard({
    required BuildContext context,
    required StoreVisitModel visit,
    required StoreVisitsController controller,
    required bool isPrimaryAction,
    required bool isDark,
    required Color cardBg,
    required Color headingText,
    required Color subText,
    required Color btnGreyBg,
    required Color btnGreyText,
    required Color darkText,
  }) {
    final statusConfig = _getStatusConfig(visit.visitStatus, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (visit.visitStatus == StoreVisitStatus.completed) {
              Get.to(() => VisitSummaryScreen(visit: visit, isReadOnly: true));
            } else if (visit.visitStatus == StoreVisitStatus.followUp) {
              controller.resumeVisit(visit);
              Get.to(() => VisitSummaryScreen(visit: visit, isReadOnly: false));
            } else if (visit.visitStatus == StoreVisitStatus.inProgress) {
              controller.resumeVisit(visit);
              Get.to(() => ActiveStoreVisitScreen(visit: visit));
            } else {
              _showStartVisitConfirmationBottomSheet(
                context,
                visit,
                controller,
                cardBg: cardBg,
                darkText: darkText,
                subText: subText,
                btnGreyBg: btnGreyBg,
                btnGreyText: btnGreyText,
                isDark: isDark,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1: Header with Store Name + Address (Start) & Status Badge (End)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Store Info (Start in RTL)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.storeName,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: headingText,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  visit.address,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: subText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                IconlyLight.location,
                                size: 14,
                                color: subText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Status Badge (End in RTL)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusConfig.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusConfig.label,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusConfig.textColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2: Metadata (Distance & Time Slot)
                Row(
                  children: [
                    // Distance
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${visit.distanceKm} ${_tr('distance_km', 'كم')}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: subText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          IconlyLight.discovery,
                          size: 14,
                          color: subText,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Time Slot
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          visit.localizedTimeSlot,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: subText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          IconlyLight.timeCircle,
                          size: 14,
                          color: subText,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Row 3: Action Button (بدء الزيارة / متابعة الزيارة / عرض التقرير)
                _buildCardActionButton(
                  context: context,
                  visit: visit,
                  controller: controller,
                  isPrimaryAction: isPrimaryAction,
                  btnGreyBg: btnGreyBg,
                  btnGreyText: btnGreyText,
                  cardBg: cardBg,
                  darkText: darkText,
                  subText: subText,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardActionButton({
    required BuildContext context,
    required StoreVisitModel visit,
    required StoreVisitsController controller,
    required bool isPrimaryAction,
    required Color btnGreyBg,
    required Color btnGreyText,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required bool isDark,
  }) {
    if (visit.visitStatus == StoreVisitStatus.completed) {
      return SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => VisitSummaryScreen(visit: visit, isReadOnly: true));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: btnGreyBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _tr('view_report', 'عرض التقرير'),
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: btnGreyText,
            ),
          ),
        ),
      );
    }

    if (visit.visitStatus == StoreVisitStatus.followUp) {
      return SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            controller.resumeVisit(visit);
            Get.to(() => VisitSummaryScreen(visit: visit, isReadOnly: false));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _tr('follow_up_action', 'متابعة المتجر'),
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (visit.visitStatus == StoreVisitStatus.inProgress) {
      return SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            controller.resumeVisit(visit);
            Get.to(() => ActiveStoreVisitScreen(visit: visit));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _tr('resume_visit', 'متابعة الزيارة'),
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Scheduled or Follow-up visit
    final isGreen = isPrimaryAction;
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          _showStartVisitConfirmationBottomSheet(
            context,
            visit,
            controller,
            cardBg: cardBg,
            darkText: darkText,
            subText: subText,
            btnGreyBg: btnGreyBg,
            btnGreyText: btnGreyText,
            isDark: isDark,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isGreen ? _primaryGreen : btnGreyBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _tr('start_visit_action', 'بدء الزيارة'),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isGreen ? Colors.white : btnGreyText,
          ),
        ),
      ),
    );
  }

  // Confirmation Bottom Sheet (Figma Frame 8895:71422 - As defult for first time)
  void _showStartVisitConfirmationBottomSheet(
    BuildContext context,
    StoreVisitModel visit,
    StoreVisitsController controller, {
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color btnGreyBg,
    required Color btnGreyText,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title: بدء زيارة [اسم المتجر] ؟
              Text(
                _tr('start_visit_confirm_title', 'بدء زيارة @store ؟', {'store': visit.storeName}),
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle: سيتم تسجيل وقت وموقع بدء الزيارة
              Text(
                _tr('start_visit_confirm_subtitle', 'سيتم تسجيل وقت وموقع بدء الزيارة بدقة'),
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: subText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Confirm Button: بدء الزيارة
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    controller.startVisit(visit);
                    Get.to(() => ActiveStoreVisitScreen(visit: visit));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _tr('start_visit_action', 'بدء الزيارة'),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel Button: إلغاء
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnGreyBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _tr('cancel', 'إلغاء'),
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: btnGreyText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _StatusConfig _getStatusConfig(StoreVisitStatus status, bool isDark) {
    switch (status) {
      case StoreVisitStatus.scheduled:
        return _StatusConfig(
          label: _tr('upcoming_single', 'قادمة'),
          textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        );
      case StoreVisitStatus.inProgress:
        return _StatusConfig(
          label: _tr('in_progress_single', 'جارية'),
          textColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF30913F),
          backgroundColor: isDark ? const Color(0xFF14532D) : const Color(0xFFECFDF5),
        );
      case StoreVisitStatus.completed:
        return _StatusConfig(
          label: _tr('completed_single', 'مكتملة'),
          textColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          backgroundColor: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
        );
      case StoreVisitStatus.followUp:
        return _StatusConfig(
          label: _tr('needs_follow_up', 'متابعة مطلوبة'),
          textColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF7861A6),
          backgroundColor: isDark ? const Color(0xFF3B1F56) : const Color(0xFFDFD3F5),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const _StatusConfig({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });
}
