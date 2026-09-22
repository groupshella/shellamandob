import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum StorePipelineStep {
  notMet('لم تتم المقابلة', Color(0xFF6B7280), Icons.person_off_outlined),
  presented('تم تقديم شلة', Color(0xFF3B82F6), Icons.campaign_outlined),
  interested('مهتم', Color(0xFF10B981), Icons.thumb_up_alt_outlined),
  gracePeriod('طلب مهلة', Color(0xFFF59E0B), Icons.hourglass_top_rounded),
  negotiating('تفاوض', Color(0xFF8B5CF6), Icons.handshake_outlined),
  contractSigned('تم توقيع العقد', Color(0xFF30913F), Icons.verified_outlined),
  rejected('رفض', Color(0xFFEF4444), Icons.cancel_outlined),
  notQualified('غير مؤهل', Color(0xFF9CA3AF), Icons.block_outlined);

  final String label;
  final Color color;
  final IconData icon;

  const StorePipelineStep(this.label, this.color, this.icon);

  String get localizedLabel {
    switch (this) {
      case StorePipelineStep.notMet:
        return 'pipeline_not_met'.tr;
      case StorePipelineStep.presented:
        return 'pipeline_presented'.tr;
      case StorePipelineStep.interested:
        return 'pipeline_interested'.tr;
      case StorePipelineStep.gracePeriod:
        return 'pipeline_grace_period'.tr;
      case StorePipelineStep.negotiating:
        return 'pipeline_negotiating'.tr;
      case StorePipelineStep.contractSigned:
        return 'pipeline_contract_signed'.tr;
      case StorePipelineStep.rejected:
        return 'pipeline_rejected'.tr;
      case StorePipelineStep.notQualified:
        return 'pipeline_not_qualified'.tr;
    }
  }
}

enum StoreVisitStatus {
  scheduled('مجدول', Color(0xFF3B82F6)),
  inProgress('قيد الزيارة', Color(0xFFF59E0B)),
  completed('مكتملة', Color(0xFF30913F)),
  followUp('متابعة مطلوبة', Color(0xFF8B5CF6));

  final String title;
  final Color color;

  const StoreVisitStatus(this.title, this.color);

  String get localizedTitle {
    switch (this) {
      case StoreVisitStatus.scheduled:
        return 'status_scheduled'.tr;
      case StoreVisitStatus.inProgress:
        return 'status_in_progress'.tr;
      case StoreVisitStatus.completed:
        return 'status_completed'.tr;
      case StoreVisitStatus.followUp:
        return 'status_follow_up'.tr;
    }
  }
}

class StoreVisitModel {
  final String id;
  final String storeName;
  final String managerName;
  final String phone;
  final String? interestStatus; // حالة الاهتمام: طلب مهلة, مهتم, مهتم جدًا, يحتاج متابعة, غير مهتم
  final int openingsCount; // عدد الفتحات
  final String crNumber; // رقم السجل التجاري
  final String address;
  final String category;
  final double distanceKm;
  final String timeSlot;
  final StorePipelineStep pipelineStep;
  final StoreVisitStatus visitStatus;
  final bool isQualifiedOutcome; // زيارة ناجحة ومكتملة الشروط
  final String? frontImagePath; // صورة واجهة المحل
  final String? insideImagePath; // صورة من داخل المحل
  final DateTime? nextFollowUpDate; // الموعد القادم
  final String? nextFollowUpCommitments; // الالتزامات المطلوبة
  final String? obstaclesNotes; // المعوقات والمشاكل
  final String? closingReason; // خيار الإغلاق
  final String? closingReasonOtherDetails; // تفاصيل أخرى للإدارة العليا
  final String? confidentialNotes; // التقرير السري للمشرف
  final String? contractSignaturePath;
  final bool onboardingCompleted;
  final int durationMinutes;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const StoreVisitModel({
    required this.id,
    required this.storeName,
    required this.managerName,
    required this.phone,
    this.interestStatus,
    this.openingsCount = 1,
    this.crNumber = '',
    required this.address,
    required this.category,
    this.distanceKm = 0.5,
    required this.timeSlot,
    this.pipelineStep = StorePipelineStep.notMet,
    this.visitStatus = StoreVisitStatus.scheduled,
    this.isQualifiedOutcome = false,
    this.frontImagePath,
    this.insideImagePath,
    this.nextFollowUpDate,
    this.nextFollowUpCommitments,
    this.obstaclesNotes,
    this.closingReason,
    this.closingReasonOtherDetails,
    this.confidentialNotes,
    this.contractSignaturePath,
    this.onboardingCompleted = false,
    this.durationMinutes = 0,
    this.startedAt,
    this.completedAt,
  });

  StoreVisitModel copyWith({
    String? id,
    String? storeName,
    String? managerName,
    String? phone,
    String? interestStatus,
    int? openingsCount,
    String? crNumber,
    String? address,
    String? category,
    double? distanceKm,
    String? timeSlot,
    StorePipelineStep? pipelineStep,
    StoreVisitStatus? visitStatus,
    bool? isQualifiedOutcome,
    String? frontImagePath,
    String? insideImagePath,
    DateTime? nextFollowUpDate,
    String? nextFollowUpCommitments,
    String? obstaclesNotes,
    String? closingReason,
    String? closingReasonOtherDetails,
    String? confidentialNotes,
    String? contractSignaturePath,
    bool? onboardingCompleted,
    int? durationMinutes,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return StoreVisitModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      managerName: managerName ?? this.managerName,
      phone: phone ?? this.phone,
      interestStatus: interestStatus ?? this.interestStatus,
      openingsCount: openingsCount ?? this.openingsCount,
      crNumber: crNumber ?? this.crNumber,
      address: address ?? this.address,
      category: category ?? this.category,
      distanceKm: distanceKm ?? this.distanceKm,
      timeSlot: timeSlot ?? this.timeSlot,
      pipelineStep: pipelineStep ?? this.pipelineStep,
      visitStatus: visitStatus ?? this.visitStatus,
      isQualifiedOutcome: isQualifiedOutcome ?? this.isQualifiedOutcome,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      insideImagePath: insideImagePath ?? this.insideImagePath,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      nextFollowUpCommitments: nextFollowUpCommitments ?? this.nextFollowUpCommitments,
      obstaclesNotes: obstaclesNotes ?? this.obstaclesNotes,
      closingReason: closingReason ?? this.closingReason,
      closingReasonOtherDetails: closingReasonOtherDetails ?? this.closingReasonOtherDetails,
      confidentialNotes: confidentialNotes ?? this.confidentialNotes,
      contractSignaturePath: contractSignaturePath ?? this.contractSignaturePath,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get localizedTimeSlot {
    final lang = Get.locale?.languageCode ?? 'ar';
    if (lang == 'ar') {
      return timeSlot;
    }
    return timeSlot
        .replaceAll('ص', 'AM')
        .replaceAll('م', 'PM')
        .split('-')
        .map((s) => s.trim())
        .join(' - ');
  }

  factory StoreVisitModel.fromJson(Map<String, dynamic> json) {
    StoreVisitStatus status = StoreVisitStatus.scheduled;
    final statusStr = json['visit_status']?.toString().toLowerCase() ?? 'scheduled';
    if (statusStr == 'completed') {
      status = StoreVisitStatus.completed;
    } else if (statusStr == 'follow_up' || statusStr == 'followup') {
      status = StoreVisitStatus.followUp;
    } else if (statusStr == 'in_progress' || statusStr == 'inprogress') {
      status = StoreVisitStatus.inProgress;
    }

    StorePipelineStep step = StorePipelineStep.notMet;
    final stepStr = json['pipeline_step']?.toString() ?? '';
    for (var s in StorePipelineStep.values) {
      if (s.name == stepStr) {
        step = s;
        break;
      }
    }

    if (step == StorePipelineStep.contractSigned) {
      status = StoreVisitStatus.completed;
    }

    return StoreVisitModel(
      id: json['id']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      managerName: json['manager_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      interestStatus: json['interest_status']?.toString() ?? 'مهتم جدًا',
      openingsCount: int.tryParse('${json['openings_count']}') ?? 1,
      crNumber: json['cr_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      distanceKm: double.tryParse('${json['distance_km']}') ?? 0.5,
      timeSlot: json['time_slot']?.toString() ?? '',
      pipelineStep: step,
      visitStatus: status,
      isQualifiedOutcome: step == StorePipelineStep.contractSigned ||
          json['is_qualified'] == 1 ||
          json['is_qualified'] == true,
      frontImagePath: json['front_image']?.toString(),
      insideImagePath: json['inside_image']?.toString(),
      nextFollowUpDate: step == StorePipelineStep.contractSigned
          ? null
          : (json['next_follow_up_date'] != null
              ? DateTime.tryParse('${json['next_follow_up_date']}')
              : null),
      nextFollowUpCommitments: json['next_follow_up_commitments']?.toString(),
      obstaclesNotes: json['obstacles_notes']?.toString(),
      closingReason: json['closing_reason']?.toString(),
      closingReasonOtherDetails: json['closing_reason_other_details']?.toString(),
      confidentialNotes: json['confidential_notes']?.toString(),
      contractSignaturePath: json['contract_signature_path']?.toString(),
      durationMinutes: int.tryParse('${json['duration_minutes']}') ?? 0,
      startedAt: json['started_at'] != null ? DateTime.tryParse('${json['started_at']}') : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse('${json['completed_at']}') : null,
    );
  }
}
