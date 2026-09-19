import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum RequestType {
  sickLeave('إجازة مرضية', Icons.medical_services_outlined, Color(0xFFEF4444)),
  annualLeave('إجازة سنوية', Icons.flight_takeoff_outlined, Color(0xFF3B82F6)),
  permission('استئذان ساعي', Icons.hourglass_empty_rounded, Color(0xFFF59E0B));

  final String title;
  final IconData icon;
  final Color color;

  const RequestType(this.title, this.icon, this.color);

  String get localizedTitle {
    switch (this) {
      case RequestType.sickLeave:
        return 'sick_leave'.tr;
      case RequestType.annualLeave:
        return 'annual_leave'.tr;
      case RequestType.permission:
        return 'hourly_permission'.tr;
    }
  }
}

enum RequestStatus {
  underReview('قيد المراجعة', Color(0xFFF59E0B), Icons.access_time_rounded),
  approved('مقبول من المنشأة', Color(0xFF10B981), Icons.check_circle_outline_rounded),
  rejected('مرفوض', Color(0xFFEF4444), Icons.cancel_outlined);

  final String label;
  final Color color;
  final IconData icon;

  const RequestStatus(this.label, this.color, this.icon);

  String get localizedLabel {
    switch (this) {
      case RequestStatus.underReview:
        return 'under_review'.tr;
      case RequestStatus.approved:
        return 'approved'.tr;
      case RequestStatus.rejected:
        return 'rejected'.tr;
    }
  }
}

class EmployeeRequestModel {
  final String id;
  final RequestType type;
  final RequestStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? attachmentName;
  final String? rejectReason;
  final DateTime createdAt;

  const EmployeeRequestModel({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachmentName,
    this.rejectReason,
    required this.createdAt,
  });

  String get localizedReason {
    if (reason.startsWith('req_')) return reason.tr;
    return reason;
  }

  String? get localizedRejectReason {
    if (rejectReason == null) return null;
    if (rejectReason!.startsWith('req_')) return rejectReason!.tr;
    return rejectReason;
  }
}
