import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../models/marketer_productivity_model.dart';

enum ProductivityViewMode { daily, period }

class MarketerProductivityController extends GetxController {
  bool isLoading = true;
  bool hasError = false;
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
    dailyData = null;
    update();
    fetchProductivity();
  }

  void selectDateRange(DateTime start, DateTime end) {
    rangeStartDate = start;
    rangeEndDate = end;
    viewMode = ProductivityViewMode.period;
    isCalendarOpen = false;
    periodData = null;
    update();
    fetchProductivity();
  }

  Future<void> fetchProductivity({bool notify = true}) async {
    isLoading = true;
    hasError = false;
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
          hasError = false;
          if (notify) update();
          return;
        }
      }
      hasError = true;
    } catch (e) {
      debugPrint('❌ [MarketerProductivityController] error: $e');
      hasError = true;
    }

    isLoading = false;
    if (notify) update();
  }
}
