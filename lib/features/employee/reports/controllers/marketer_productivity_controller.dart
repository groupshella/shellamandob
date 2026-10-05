import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../models/marketer_productivity_model.dart';

enum ProductivityViewMode { daily, period }

class MarketerProductivityController extends GetxController {
  bool isLoading = false;
  ProductivityViewMode viewMode = ProductivityViewMode.daily;

  DateTime selectedDate = DateTime.now();
  DateTime rangeStartDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime rangeEndDate = DateTime.now();

  bool isCalendarOpen = false;
  int expandedDayIndex = -1;

  DailyProductivityModel? dailyData;
  PeriodProductivityModel? periodData;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    rangeEndDate = selectedDate;
    rangeStartDate = selectedDate.subtract(const Duration(days: 6));
    fetchProductivity();
  }

  void toggleCalendar() {
    isCalendarOpen = !isCalendarOpen;
    update();
  }

  void toggleDayExpanded(int index) {
    if (expandedDayIndex == index) {
      expandedDayIndex = -1;
    } else {
      expandedDayIndex = index;
    }
    update();
  }

  void selectSingleDate(DateTime date) {
    selectedDate = date;
    viewMode = ProductivityViewMode.daily;
    isCalendarOpen = false;
    update();
    fetchProductivity();
  }

  void selectDateRange(DateTime start, DateTime end) {
    rangeStartDate = start;
    rangeEndDate = end;
    viewMode = ProductivityViewMode.period;
    isCalendarOpen = false;
    update();
    fetchProductivity();
  }

  Future<void> fetchProductivity({bool notify = true}) async {
    isLoading = true;
    if (notify) update();

    final dateFormat = DateFormat('yyyy-MM-dd');
    String query = '';
    if (viewMode == ProductivityViewMode.daily) {
      query = '?date=${dateFormat.format(selectedDate)}';
    } else {
      query = '?start_date=${dateFormat.format(rangeStartDate)}&end_date=${dateFormat.format(rangeEndDate)}';
    }

    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData('${AppConstants.marketerProductivityUri}$query');
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          final data = res.body['data'];
          if (data['type'] == 'period') {
            periodData = PeriodProductivityModel.fromJson(data);
          } else {
            dailyData = DailyProductivityModel.fromJson(data);
          }
          isLoading = false;
          if (notify) update();
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ [MarketerProductivityController] error: $e');
    }

    // Genuine empty state when server has no visits or shifts yet
    _initEmptyData();
    isLoading = false;
    if (notify) update();
  }

  void _initEmptyData() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = DateFormat('EEEE ، d MMMM y', 'ar').format(selectedDate);
    if (viewMode == ProductivityViewMode.daily) {
      dailyData = DailyProductivityModel(
        date: dateFormat.format(selectedDate),
        dateFormatted: formattedDate,
        kpis: ProductivityKpis(
          successfulVisits: 0,
          successfulVisitsText: '0 زيارة',
          workHours: '00:00',
          workSeconds: 0,
          warningsCount: 0,
          warningsText: '0 إنذار',
          signedContracts: 0,
          signedContractsText: '0 اتفاقية',
        ),
        dailyTarget: DailyTargetInfo(
          target: 16,
          achieved: 0,
          targetText: '0 / 16',
          remaining: 16,
          percentage: 0,
          subtitle: 'متبقي 16 زيارات — 0%',
        ),
        timeline: [],
        signedAgreements: [],
        upcomingFollowUps: [],
      );
    } else {
      periodData = PeriodProductivityModel(
        startDate: dateFormat.format(rangeStartDate),
        endDate: dateFormat.format(rangeEndDate),
        dateRangeFormatted: '${dateFormat.format(rangeStartDate)} - ${dateFormat.format(rangeEndDate)}',
        targetProgress: DailyTargetInfo(
          target: 16,
          achieved: 0,
          targetText: '0 / 16',
          remaining: 16,
          percentage: 0,
          subtitle: '0%',
        ),
        kpis: PeriodKpis(
          warningsCount: 0,
          warningsText: '0 إنذار',
          workHours: '00:00',
          signedContracts: 0,
          signedContractsText: '0 اتفاقية',
        ),
        days: [],
        signedAgreements: [],
        periodSummary: PeriodSummaryInfo(
          totalWorkHours: '00:00',
          totalVisits: 0,
          totalSignedContracts: 0,
          totalWarnings: 0,
          totalDistanceKm: '0 كم',
          totalScheduledFollowups: 0,
        ),
      );
    }
  }
}
