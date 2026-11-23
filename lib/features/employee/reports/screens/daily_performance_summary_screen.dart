import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import '../controllers/marketer_productivity_controller.dart';
import '../widgets/productivity_header.dart';
import '../widgets/productivity_calendar_picker.dart';
import '../widgets/daily_productivity_view.dart';
import '../widgets/period_productivity_view.dart';

class DailyPerformanceSummaryScreen extends StatelessWidget {
  const DailyPerformanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final scaffoldBg = isDark ? const Color(0xFF121418) : const Color(0xFFF9FAFB);

        return GetBuilder<MarketerProductivityController>(
          init: Get.put(MarketerProductivityController()),
          builder: (controller) {
            final dateText = (controller.viewMode == ProductivityViewMode.daily)
                ? (controller.dailyData?.dateFormatted ?? 'today'.tr)
                : (controller.periodData?.dateRangeFormatted ?? '');

            final canPop = Navigator.canPop(context);
            final isPeriod = controller.viewMode == ProductivityViewMode.period;
            final hasActiveData = isPeriod ? controller.periodData != null : controller.dailyData != null;

            return Scaffold(
              backgroundColor: scaffoldBg,
              body: SafeArea(
                child: Column(
                  children: [
                    // Top Header with title "الإنتاجية" and interactive date bar
                    ProductivityHeader(
                      dateText: dateText,
                      showBackButton: canPop,
                      onBackTap: () => Get.back(),
                      onCalendarTap: controller.toggleCalendar,
                    ),

                    // Expanded Calendar Picker when toggled open
                    if (controller.isCalendarOpen)
                      ProductivityCalendarPicker(
                        initialDate: controller.selectedDate,
                        rangeStart: controller.rangeStartDate,
                        rangeEnd: controller.rangeEndDate,
                        onSingleDateSelected: controller.selectSingleDate,
                        onRangeSelected: controller.selectDateRange,
                        onClose: controller.toggleCalendar,
                      ),

                    // Main Content (Shimmer while loading, Error Retry, or Real Data)
                    Expanded(
                      child: controller.isLoading && !hasActiveData
                          ? (isPeriod
                              ? SkeletonLoadingWidgets.productivityPeriodSkeleton(isDark: isDark)
                              : SkeletonLoadingWidgets.productivityDailySkeleton(isDark: isDark))
                          : (!hasActiveData && controller.hasError)
                              ? _buildRetryState(controller, isDark)
                              : RefreshIndicator(
                                  color: const Color(0xFF30913F),
                                  onRefresh: () => controller.fetchProductivity(),
                                  child: isPeriod
                                      ? (controller.periodData != null
                                          ? PeriodProductivityView(
                                              data: controller.periodData!,
                                              expandedDayIndex: controller.expandedDayIndex,
                                              onDayToggle: controller.toggleDayExpanded,
                                            )
                                          : SkeletonLoadingWidgets.productivityPeriodSkeleton(isDark: isDark))
                                      : (controller.dailyData != null
                                          ? DailyProductivityView(data: controller.dailyData!)
                                          : SkeletonLoadingWidgets.productivityDailySkeleton(isDark: isDark)),
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

  Widget _buildRetryState(MarketerProductivityController controller, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF111B18);
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: subTextColor),
            const SizedBox(height: 12),
            Text(
              'something_went_wrong'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchProductivity(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30913F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'retry_btn'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
