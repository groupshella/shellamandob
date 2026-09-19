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
  final String workedTimeText;
  final int breakSeconds;
  final int overtimeSeconds;
  final String overtimeHoursText;
  final int approvedLeaveSeconds;
  final String approvedLeaveHoursText;
  final int totalVisits;
  final int completedVisits;
  final int upcomingVisits;
  final int followUpVisits;
  final List<EmployeeWarningModel> warnings;
  final int warningCount;

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
    this.totalVisits = 0,
    this.completedVisits = 0,
    this.upcomingVisits = 0,
    this.followUpVisits = 0,
    this.warnings = const [],
    this.warningCount = 0,
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
    int? totalVisits,
    int? completedVisits,
    int? upcomingVisits,
    int? followUpVisits,
    List<EmployeeWarningModel>? warnings,
    int? warningCount,
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
      totalVisits: totalVisits ?? this.totalVisits,
      completedVisits: completedVisits ?? this.completedVisits,
      upcomingVisits: upcomingVisits ?? this.upcomingVisits,
      followUpVisits: followUpVisits ?? this.followUpVisits,
      warnings: warnings ?? this.warnings,
      warningCount: warningCount ?? this.warningCount,
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
