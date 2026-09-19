import 'package:get/get.dart';
import 'employee_warning_model.dart';

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
  final int breakSeconds;
  final String overtimeHoursText;
  final String approvedLeaveHoursText;
  final int totalVisits;
  final int completedVisits;
  final int upcomingVisits;
  final int followUpVisits;
  final List<EmployeeWarningModel> warnings;

  const EmployeeShiftModel({
    this.status = ShiftStatus.notStarted,
    this.employeeName = 'أحمد محمد',
    this.startTimeText = '08:30 ص',
    this.actualWorkSeconds = 9346, // 02:35:46
    this.breakSeconds = 0,
    this.overtimeHoursText = '00:20 ساعة',
    this.approvedLeaveHoursText = '00:30 ساعة',
    this.totalVisits = 3,
    this.completedVisits = 1,
    this.upcomingVisits = 4,
    this.followUpVisits = 2,
    this.warnings = const [
      EmployeeWarningModel(
        id: '1',
        title: 'delay_submitting_visit_report',
        date: '10 سبتمبر',
      ),
      EmployeeWarningModel(
        id: '2',
        title: 'leaving_work_zone_without_permission',
        date: '8 سبتمبر',
      ),
    ],
  });

  EmployeeShiftModel copyWith({
    ShiftStatus? status,
    String? employeeName,
    String? startTimeText,
    int? actualWorkSeconds,
    int? breakSeconds,
    String? overtimeHoursText,
    String? approvedLeaveHoursText,
    int? totalVisits,
    int? completedVisits,
    int? upcomingVisits,
    int? followUpVisits,
    List<EmployeeWarningModel>? warnings,
  }) {
    return EmployeeShiftModel(
      status: status ?? this.status,
      employeeName: employeeName ?? this.employeeName,
      startTimeText: startTimeText ?? this.startTimeText,
      actualWorkSeconds: actualWorkSeconds ?? this.actualWorkSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      overtimeHoursText: overtimeHoursText ?? this.overtimeHoursText,
      approvedLeaveHoursText: approvedLeaveHoursText ?? this.approvedLeaveHoursText,
      totalVisits: totalVisits ?? this.totalVisits,
      completedVisits: completedVisits ?? this.completedVisits,
      upcomingVisits: upcomingVisits ?? this.upcomingVisits,
      followUpVisits: followUpVisits ?? this.followUpVisits,
      warnings: warnings ?? this.warnings,
    );
  }

  String get localizedStartTime {
    final lang = Get.locale?.languageCode ?? 'ar';
    if (lang == 'ar') return startTimeText;
    return startTimeText.replaceAll('ص', 'AM').replaceAll('م', 'PM');
  }

  String get localizedOvertimeHours {
    final lang = Get.locale?.languageCode ?? 'ar';
    if (lang == 'ar') return overtimeHoursText;
    final timePart = overtimeHoursText.replaceAll(RegExp(r'[^0-9:]'), '').trim();
    return '$timePart ${'hour_unit'.tr}';
  }

  String get localizedApprovedLeaveHours {
    final lang = Get.locale?.languageCode ?? 'ar';
    if (lang == 'ar') return approvedLeaveHoursText;
    final timePart = approvedLeaveHoursText.replaceAll(RegExp(r'[^0-9:]'), '').trim();
    return '$timePart ${'hour_unit'.tr}';
  }
}
