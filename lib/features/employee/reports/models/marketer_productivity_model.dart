class DailyProductivityModel {
  final String date;
  final String dateFormatted;
  final ProductivityKpis kpis;
  final DailyTargetInfo dailyTarget;
  final List<TimelineItem> timeline;
  final List<SignedAgreementItem> signedAgreements;
  final List<UpcomingFollowUpItem> upcomingFollowUps;

  DailyProductivityModel({
    required this.date,
    required this.dateFormatted,
    required this.kpis,
    required this.dailyTarget,
    required this.timeline,
    required this.signedAgreements,
    required this.upcomingFollowUps,
  });

  factory DailyProductivityModel.fromJson(Map<String, dynamic> json) {
    return DailyProductivityModel(
      date: json['date']?.toString() ?? '',
      dateFormatted: json['date_formatted']?.toString() ?? '',
      kpis: ProductivityKpis.fromJson(json['kpis'] ?? {}),
      dailyTarget: DailyTargetInfo.fromJson(json['daily_target'] ?? {}),
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineItem.fromJson(e))
              .toList() ??
          [],
      signedAgreements: (json['signed_agreements'] as List<dynamic>?)
              ?.map((e) => SignedAgreementItem.fromJson(e))
              .toList() ??
          [],
      upcomingFollowUps: (json['upcoming_follow_ups'] as List<dynamic>?)
              ?.map((e) => UpcomingFollowUpItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProductivityKpis {
  final int successfulVisits;
  final String successfulVisitsText;
  final String workHours;
  final int workSeconds;
  final int warningsCount;
  final String warningsText;
  final int signedContracts;
  final String signedContractsText;

  ProductivityKpis({
    required this.successfulVisits,
    required this.successfulVisitsText,
    required this.workHours,
    required this.workSeconds,
    required this.warningsCount,
    required this.warningsText,
    required this.signedContracts,
    required this.signedContractsText,
  });

  factory ProductivityKpis.fromJson(Map<String, dynamic> json) {
    return ProductivityKpis(
      successfulVisits: (json['successful_visits'] as num?)?.toInt() ?? 12,
      successfulVisitsText: json['successful_visits_text']?.toString() ?? '12 زيارة',
      workHours: json['work_hours']?.toString() ?? '7س 40د',
      workSeconds: (json['work_seconds'] as num?)?.toInt() ?? 27600,
      warningsCount: (json['warnings_count'] as num?)?.toInt() ?? 1,
      warningsText: json['warnings_text']?.toString() ?? '1 إنذار',
      signedContracts: (json['signed_contracts'] as num?)?.toInt() ?? 2,
      signedContractsText: json['signed_contracts_text']?.toString() ?? '2 اتفاقية',
    );
  }
}

class DailyTargetInfo {
  final int target;
  final int achieved;
  final String targetText;
  final int remaining;
  final int percentage;
  final String subtitle;

  DailyTargetInfo({
    required this.target,
    required this.achieved,
    required this.targetText,
    required this.remaining,
    required this.percentage,
    required this.subtitle,
  });

  factory DailyTargetInfo.fromJson(Map<String, dynamic> json) {
    return DailyTargetInfo(
      target: (json['target'] as num?)?.toInt() ?? 16,
      achieved: (json['achieved'] as num?)?.toInt() ?? 12,
      targetText: json['target_text']?.toString() ?? '16 / 12',
      remaining: (json['remaining'] as num?)?.toInt() ?? 4,
      percentage: (json['percentage'] as num?)?.toInt() ?? 75,
      subtitle: json['subtitle']?.toString() ?? 'متبقي 4 زيارات — 75%',
    );
  }
}

class TimelineItem {
  final String time;
  final String title;
  final String? subtitle;
  final String statusColor;
  final String type;

  TimelineItem({
    required this.time,
    required this.title,
    this.subtitle,
    required this.statusColor,
    required this.type,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      time: json['time']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      statusColor: json['status_color']?.toString() ?? 'gray',
      type: json['type']?.toString() ?? 'visit',
    );
  }
}

class SignedAgreementItem {
  final int id;
  final String storeName;
  final String time;
  final String status;
  final String statusType;
  final String statusColor;

  SignedAgreementItem({
    required this.id,
    required this.storeName,
    required this.time,
    required this.status,
    required this.statusType,
    required this.statusColor,
  });

  factory SignedAgreementItem.fromJson(Map<String, dynamic> json) {
    return SignedAgreementItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      storeName: json['store_name']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusType: json['status_type']?.toString() ?? 'signed',
      statusColor: json['status_color']?.toString() ?? 'green',
    );
  }
}

class UpcomingFollowUpItem {
  final int id;
  final String datetimeText;
  final String storeName;
  final String note;

  UpcomingFollowUpItem({
    required this.id,
    required this.datetimeText,
    required this.storeName,
    required this.note,
  });

  factory UpcomingFollowUpItem.fromJson(Map<String, dynamic> json) {
    return UpcomingFollowUpItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      datetimeText: json['datetime_text']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}

class PeriodProductivityModel {
  final String startDate;
  final String endDate;
  final String dateRangeFormatted;
  final DailyTargetInfo targetProgress;
  final PeriodKpis kpis;
  final List<PeriodDayItem> days;
  final List<SignedAgreementItem> signedAgreements;
  final PeriodSummaryInfo periodSummary;

  PeriodProductivityModel({
    required this.startDate,
    required this.endDate,
    required this.dateRangeFormatted,
    required this.targetProgress,
    required this.kpis,
    required this.days,
    required this.signedAgreements,
    required this.periodSummary,
  });

  factory PeriodProductivityModel.fromJson(Map<String, dynamic> json) {
    return PeriodProductivityModel(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      dateRangeFormatted: json['date_range_formatted']?.toString() ?? '',
      targetProgress: DailyTargetInfo.fromJson(json['target_progress'] ?? {}),
      kpis: PeriodKpis.fromJson(json['kpis'] ?? {}),
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => PeriodDayItem.fromJson(e))
              .toList() ??
          [],
      signedAgreements: (json['signed_agreements'] as List<dynamic>?)
              ?.map((e) => SignedAgreementItem.fromJson(e))
              .toList() ??
          [],
      periodSummary: PeriodSummaryInfo.fromJson(json['period_summary'] ?? {}),
    );
  }
}

class PeriodKpis {
  final int warningsCount;
  final String warningsText;
  final String workHours;
  final int signedContracts;
  final String signedContractsText;

  PeriodKpis({
    required this.warningsCount,
    required this.warningsText,
    required this.workHours,
    required this.signedContracts,
    required this.signedContractsText,
  });

  factory PeriodKpis.fromJson(Map<String, dynamic> json) {
    return PeriodKpis(
      warningsCount: (json['warnings_count'] as num?)?.toInt() ?? 4,
      warningsText: json['warnings_text']?.toString() ?? '4 إنذار',
      workHours: json['work_hours']?.toString() ?? '7س 40د',
      signedContracts: (json['signed_contracts'] as num?)?.toInt() ?? 2,
      signedContractsText: json['signed_contracts_text']?.toString() ?? '2 اتفاقية',
    );
  }
}

class PeriodDayItem {
  final String dayName;
  final String date;
  final String dateFormatted;
  final int visitsCount;
  final int contractsCount;
  final int warningsCount;
  final PeriodDayDetails details;

  PeriodDayItem({
    required this.dayName,
    required this.date,
    required this.dateFormatted,
    required this.visitsCount,
    required this.contractsCount,
    required this.warningsCount,
    required this.details,
  });

  factory PeriodDayItem.fromJson(Map<String, dynamic> json) {
    return PeriodDayItem(
      dayName: json['day_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      dateFormatted: json['date_formatted']?.toString() ?? '',
      visitsCount: (json['visits_count'] as num?)?.toInt() ?? 0,
      contractsCount: (json['contracts_count'] as num?)?.toInt() ?? 0,
      warningsCount: (json['warnings_count'] as num?)?.toInt() ?? 0,
      details: PeriodDayDetails.fromJson(json['details'] ?? {}),
    );
  }
}

class PeriodDayDetails {
  final String successfulVisits;
  final String workHours;
  final String warningsCount;
  final String contractsCount;

  PeriodDayDetails({
    required this.successfulVisits,
    required this.workHours,
    required this.warningsCount,
    required this.contractsCount,
  });

  factory PeriodDayDetails.fromJson(Map<String, dynamic> json) {
    return PeriodDayDetails(
      successfulVisits: json['successful_visits']?.toString() ?? '',
      workHours: json['work_hours']?.toString() ?? '',
      warningsCount: json['warnings_count']?.toString() ?? '',
      contractsCount: json['contracts_count']?.toString() ?? '',
    );
  }
}

class PeriodSummaryInfo {
  final String totalWorkHours;
  final int totalVisits;
  final int totalSignedContracts;
  final int totalWarnings;
  final String totalDistanceKm;
  final int totalScheduledFollowups;

  PeriodSummaryInfo({
    required this.totalWorkHours,
    required this.totalVisits,
    required this.totalSignedContracts,
    required this.totalWarnings,
    required this.totalDistanceKm,
    required this.totalScheduledFollowups,
  });

  factory PeriodSummaryInfo.fromJson(Map<String, dynamic> json) {
    return PeriodSummaryInfo(
      totalWorkHours: json['total_work_hours']?.toString() ?? '31س 10د',
      totalVisits: (json['total_visits'] as num?)?.toInt() ?? 54,
      totalSignedContracts: (json['total_signed_contracts'] as num?)?.toInt() ?? 5,
      totalWarnings: (json['total_warnings'] as num?)?.toInt() ?? 2,
      totalDistanceKm: json['total_distance_km']?.toString() ?? '142 كم',
      totalScheduledFollowups: (json['total_scheduled_followups'] as num?)?.toInt() ?? 8,
    );
  }
}
