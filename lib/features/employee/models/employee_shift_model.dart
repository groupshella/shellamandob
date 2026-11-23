import 'package:get/get.dart';
import 'employee_warning_model.dart';
import 'training_lesson_model.dart';

enum ShiftStatus {
  notStarted, // لم يبدأ الدوام
  active,     // أنت على رأس العمل
  onBreak,    // في استراحة
}

class EmployeeShiftModel {
  final ShiftStatus status;
  final String employeeName;
  final String startTimeText;
  final int actualWorkSeconds;
  final String workedTimeText;
  final int breakSeconds;
  final int overtimeSeconds;
  final String overtimeHoursText;
  final int approvedLeaveSeconds;
  final String approvedLeaveHoursText;
  final int dailyTargetVisits;
  final int totalVisits;
  final int completedVisits;
  final int upcomingVisits;
  final int followUpVisits;
  final List<EmployeeWarningModel> warnings;
  final int warningCount;
  // Monthly acquisition targets (Home screen progress cards)
  final int storesTarget;
  final int storesAchieved;
  final int storesRemaining;
  final int storesPercent;
  final int marketersTarget;
  final int marketersAchieved;
  final int marketersRemaining;
  final int marketersPercent;
  final DailyPerformanceReportModel? performanceReport;

  const EmployeeShiftModel({
    this.status = ShiftStatus.notStarted,
    this.employeeName = '',
    this.startTimeText = '--:--',
    this.actualWorkSeconds = 0,
    this.workedTimeText = '',
    this.breakSeconds = 0,
    this.overtimeSeconds = 0,
    this.overtimeHoursText = '',
    this.approvedLeaveSeconds = 0,
    this.approvedLeaveHoursText = '',
    this.dailyTargetVisits = 8,
    this.totalVisits = 0,
    this.completedVisits = 0,
    this.upcomingVisits = 0,
    this.followUpVisits = 0,
    this.warnings = const [],
    this.warningCount = 0,
    this.storesTarget = 120,
    this.storesAchieved = 0,
    this.storesRemaining = 120,
    this.storesPercent = 0,
    this.marketersTarget = 150,
    this.marketersAchieved = 0,
    this.marketersRemaining = 150,
    this.marketersPercent = 0,
    this.performanceReport,
  });

  EmployeeShiftModel copyWith({
    ShiftStatus? status,
    String? employeeName,
    String? startTimeText,
    int? actualWorkSeconds,
    String? workedTimeText,
    int? breakSeconds,
    int? overtimeSeconds,
    String? overtimeHoursText,
    int? approvedLeaveSeconds,
    String? approvedLeaveHoursText,
    int? dailyTargetVisits,
    int? totalVisits,
    int? completedVisits,
    int? upcomingVisits,
    int? followUpVisits,
    List<EmployeeWarningModel>? warnings,
    int? warningCount,
    int? storesTarget,
    int? storesAchieved,
    int? storesRemaining,
    int? storesPercent,
    int? marketersTarget,
    int? marketersAchieved,
    int? marketersRemaining,
    int? marketersPercent,
    DailyPerformanceReportModel? performanceReport,
  }) {
    return EmployeeShiftModel(
      status: status ?? this.status,
      employeeName: employeeName ?? this.employeeName,
      startTimeText: startTimeText ?? this.startTimeText,
      actualWorkSeconds: actualWorkSeconds ?? this.actualWorkSeconds,
      workedTimeText: workedTimeText ?? this.workedTimeText,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      overtimeSeconds: overtimeSeconds ?? this.overtimeSeconds,
      overtimeHoursText: overtimeHoursText ?? this.overtimeHoursText,
      approvedLeaveSeconds: approvedLeaveSeconds ?? this.approvedLeaveSeconds,
      approvedLeaveHoursText: approvedLeaveHoursText ?? this.approvedLeaveHoursText,
      dailyTargetVisits: dailyTargetVisits ?? this.dailyTargetVisits,
      totalVisits: totalVisits ?? this.totalVisits,
      completedVisits: completedVisits ?? this.completedVisits,
      upcomingVisits: upcomingVisits ?? this.upcomingVisits,
      followUpVisits: followUpVisits ?? this.followUpVisits,
      warnings: warnings ?? this.warnings,
      warningCount: warningCount ?? this.warningCount,
      storesTarget: storesTarget ?? this.storesTarget,
      storesAchieved: storesAchieved ?? this.storesAchieved,
      storesRemaining: storesRemaining ?? this.storesRemaining,
      storesPercent: storesPercent ?? this.storesPercent,
      marketersTarget: marketersTarget ?? this.marketersTarget,
      marketersAchieved: marketersAchieved ?? this.marketersAchieved,
      marketersRemaining: marketersRemaining ?? this.marketersRemaining,
      marketersPercent: marketersPercent ?? this.marketersPercent,
      performanceReport: performanceReport ?? this.performanceReport,
    );
  }

  String get localizedStartTime {
    if (startTimeText.isEmpty || startTimeText == '--:--') return '--:--';
    final lang = Get.locale?.languageCode ?? 'ar';
    if (lang == 'ar') return startTimeText;
    return startTimeText.replaceAll('ص', 'AM').replaceAll('م', 'PM');
  }

  String get localizedWorkedTime {
    if (actualWorkSeconds > 0) {
      final int h = actualWorkSeconds ~/ 3600;
      final int m = (actualWorkSeconds % 3600) ~/ 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${'hour_unit'.tr}';
    }
    if (workedTimeText.isNotEmpty) {
      final lang = Get.locale?.languageCode ?? 'ar';
      if (lang == 'ar') return workedTimeText;
      final timePart = workedTimeText.replaceAll(RegExp(r'[^0-9:]'), '').trim();
      return '$timePart ${'hour_unit'.tr}';
    }
    return '00:00 ${'hour_unit'.tr}';
  }

  String get localizedOvertimeHours {
    if (overtimeHoursText.isNotEmpty) {
      final lang = Get.locale?.languageCode ?? 'ar';
      if (lang == 'ar') return overtimeHoursText;
      final timePart = overtimeHoursText.replaceAll(RegExp(r'[^0-9:]'), '').trim();
      return '$timePart ${'hour_unit'.tr}';
    }
    if (overtimeSeconds > 0) {
      final int h = overtimeSeconds ~/ 3600;
      final int m = (overtimeSeconds % 3600) ~/ 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${'hour_unit'.tr}';
    }
    return '00:00 ${'hour_unit'.tr}';
  }

  String get localizedApprovedLeaveHours {
    if (approvedLeaveHoursText.isNotEmpty) {
      final lang = Get.locale?.languageCode ?? 'ar';
      if (lang == 'ar') return approvedLeaveHoursText;
      final timePart = approvedLeaveHoursText.replaceAll(RegExp(r'[^0-9:]'), '').trim();
      return '$timePart ${'hour_unit'.tr}';
    }
    if (approvedLeaveSeconds > 0) {
      final int h = approvedLeaveSeconds ~/ 3600;
      final int m = (approvedLeaveSeconds % 3600) ~/ 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${'hour_unit'.tr}';
    }
    return '00:00 ${'hour_unit'.tr}';
  }
}
