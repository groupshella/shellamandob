import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/marketer_productivity_controller.dart';
import '../widgets/productivity_header.dart';
import '../widgets/productivity_calendar_picker.dart';
import '../widgets/daily_productivity_view.dart';
import '../widgets/period_productivity_view.dart';

class DailyPerformanceSummaryScreen extends StatelessWidget {
  const DailyPerformanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketerProductivityController>(
      init: Get.put(MarketerProductivityController()),
      builder: (controller) {
        final dateText = (controller.viewMode == ProductivityViewMode.daily)
            ? (controller.dailyData?.dateFormatted ?? 'اليوم ، 20 سبتمبر 2026')
            : (controller.periodData?.dateRangeFormatted ?? '13 سبتمبر 2026 - 20 سبتمبر 2026');

        final canPop = Navigator.canPop(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
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

                // Main Content (Daily or Period)
                Expanded(
                  child: controller.isLoading && controller.dailyData == null && controller.periodData == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF30913F),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF30913F),
                          onRefresh: () => controller.fetchProductivity(),
                          child: controller.viewMode == ProductivityViewMode.daily
                              ? (controller.dailyData != null
                                  ? DailyProductivityView(data: controller.dailyData!)
                                  : const SizedBox.shrink())
                              : (controller.periodData != null
                                  ? PeriodProductivityView(
                                      data: controller.periodData!,
                                      expandedDayIndex: controller.expandedDayIndex,
                                      onDayToggle: controller.toggleDayExpanded,
                                    )
                                  : const SizedBox.shrink()),
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
