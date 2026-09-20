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

  DateTime selectedDate = DateTime(2026, 9, 20);
  DateTime rangeStartDate = DateTime(2026, 9, 13);
  DateTime rangeEndDate = DateTime(2026, 9, 20);

  bool isCalendarOpen = false;
  int expandedDayIndex = 2; // Default Monday expanded as in Figma

  DailyProductivityModel? dailyData;
  PeriodProductivityModel? periodData;

  @override
  void onInit() {
    super.onInit();
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

    // Fallback Mock Data matching Figma (Node 8949:41978)
    _initFallbackData();
    isLoading = false;
    if (notify) update();
  }

  void _initFallbackData() {
    if (viewMode == ProductivityViewMode.daily) {
      dailyData = DailyProductivityModel(
        date: '2026-09-20',
        dateFormatted: 'اليوم ، 20 سبتمبر 2026',
        kpis: ProductivityKpis(
          successfulVisits: 12,
          successfulVisitsText: '12 زيارة',
          workHours: '7س 40د',
          workSeconds: 27600,
          warningsCount: 1,
          warningsText: '1 إنذار',
          signedContracts: 2,
          signedContractsText: '2 اتفاقية',
        ),
        dailyTarget: DailyTargetInfo(
          target: 16,
          achieved: 12,
          targetText: '16 / 12',
          remaining: 4,
          percentage: 75,
          subtitle: 'متبقي 4 زيارات — 75%',
        ),
        timeline: [
          TimelineItem(time: '08:15 ص', title: 'بدء الدوام', type: 'shift_start', statusColor: 'gray'),
          TimelineItem(time: '09:02 ص', title: 'زيارة سوبرماركت النور', subtitle: 'زيارة ناجحة', statusColor: 'green', type: 'visit'),
          TimelineItem(time: '10:10 ص', title: 'زيارة ماركت المدينة', subtitle: 'زيارة ناجحة', statusColor: 'green', type: 'visit'),
          TimelineItem(time: '11:05 ص', title: 'توقيع اتفاقية', subtitle: 'تم التوقيع', statusColor: 'green', type: 'contract'),
          TimelineItem(time: '11:50 ص', title: 'زيارة متجر الهلال', subtitle: 'زيارة غير مكتملة', statusColor: 'orange', type: 'visit'),
          TimelineItem(time: '02:10 م', title: 'الإنذار الثاني', subtitle: null, statusColor: 'red', type: 'warning'),
          TimelineItem(time: '03:30 م', title: 'زيارة بقالة الأصالة', subtitle: 'زيارة ناجحة', statusColor: 'green', type: 'visit'),
          TimelineItem(time: '04:45 م', title: 'إنهاء الدوام', type: 'shift_end', statusColor: 'gray'),
        ],
        signedAgreements: [
          SignedAgreementItem(
            id: 1,
            storeName: 'سوبرماركت النور',
            time: '09:45 ص',
            status: 'التفعيل جاري',
            statusType: 'activating',
            statusColor: 'orange',
          ),
          SignedAgreementItem(
            id: 2,
            storeName: 'ماركت المدينة',
            time: '11:50 ص',
            status: 'تم التوقيع',
            statusType: 'signed',
            statusColor: 'green',
          ),
        ],
        upcomingFollowUps: [
          UpcomingFollowUpItem(
            id: 101,
            datetimeText: 'الثلاثاء — 10:00 ص',
            storeName: 'متجر الهلال',
            note: 'بانتظار موافقة المالك',
          ),
          UpcomingFollowUpItem(
            id: 102,
            datetimeText: 'الأربعاء — 11:30 ص',
            storeName: 'بقالة الرياض',
            note: 'طلب عرض مختلف',
          ),
        ],
      );
    } else {
      periodData = PeriodProductivityModel(
        startDate: '2026-09-13',
        endDate: '2026-09-20',
        dateRangeFormatted: '13 سبتمبر 2026 - 20 سبتمبر 2026',
        targetProgress: DailyTargetInfo(
          target: 16,
          achieved: 12,
          targetText: '16 / 12',
          remaining: 4,
          percentage: 75,
          subtitle: 'متبقي 4 زيارات — 75%',
        ),
        kpis: PeriodKpis(
          warningsCount: 4,
          warningsText: '4 إنذار',
          workHours: '7س 40د',
          signedContracts: 2,
          signedContractsText: '2 اتفاقية',
        ),
        days: [
          PeriodDayItem(
            dayName: 'السبت',
            date: '2026-09-13',
            dateFormatted: '13 سبتمبر',
            visitsCount: 14,
            contractsCount: 1,
            warningsCount: 0,
            details: PeriodDayDetails(
              successfulVisits: '14 / 16',
              workHours: '8س 00د',
              warningsCount: '0 إنذار',
              contractsCount: '1 اتفاقية',
            ),
          ),
          PeriodDayItem(
            dayName: 'الأحد',
            date: '2026-09-14',
            dateFormatted: '14 سبتمبر',
            visitsCount: 16,
            contractsCount: 2,
            warningsCount: 0,
            details: PeriodDayDetails(
              successfulVisits: '16 / 16',
              workHours: '7س 50د',
              warningsCount: '0 إنذار',
              contractsCount: '2 اتفاقية',
            ),
          ),
          PeriodDayItem(
            dayName: 'الإثنين',
            date: '2026-09-15',
            dateFormatted: '15 سبتمبر',
            visitsCount: 12,
            contractsCount: 0,
            warningsCount: 1,
            details: PeriodDayDetails(
              successfulVisits: '12 / 16',
              workHours: '7س 45د',
              warningsCount: '1 إنذار',
              contractsCount: '0 اتفاقية',
            ),
          ),
          PeriodDayItem(
            dayName: 'الثلاثاء',
            date: '2026-09-16',
            dateFormatted: '16 سبتمبر',
            visitsCount: 12,
            contractsCount: 2,
            warningsCount: 1,
            details: PeriodDayDetails(
              successfulVisits: '12 / 16',
              workHours: '7س 30د',
              warningsCount: '1 إنذار',
              contractsCount: '2 اتفاقية',
            ),
          ),
        ],
        signedAgreements: [
          SignedAgreementItem(
            id: 1,
            storeName: 'سوبرماركت النور',
            time: '09:45 ص',
            status: 'التفعيل جاري',
            statusType: 'activating',
            statusColor: 'orange',
          ),
          SignedAgreementItem(
            id: 2,
            storeName: 'ماركت المدينة',
            time: '11:50 ص',
            status: 'تم التوقيع',
            statusType: 'signed',
            statusColor: 'green',
          ),
        ],
        periodSummary: PeriodSummaryInfo(
          totalWorkHours: '31س 10د',
          totalVisits: 54,
          totalSignedContracts: 5,
          totalWarnings: 2,
          totalDistanceKm: '142 كم',
          totalScheduledFollowups: 8,
        ),
      );
    }
  }
}
