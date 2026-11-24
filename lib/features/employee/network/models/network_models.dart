class NetworkOverviewModel {
  final int totalSubMarketers;
  final int activeMarketersCount;
  final int idleMarketersCount;
  final int todayNetworkCustomers;
  final double monthlySupervisionCommission;
  final double supervisionCommissionRate;
  final double directEarnings;
  final int directCustomersCount;
  final double teamEarnings;
  final int teamCustomersCount;
  final int growthSpecialistsCount;
  final int freelanceMarketersCount;
  final int driversCount;
  final List<IdleMarketerSummaryModel> idleMarketers;
  final List<DriverLeadSummaryModel> addedDrivers;

  NetworkOverviewModel({
    required this.totalSubMarketers,
    required this.activeMarketersCount,
    required this.idleMarketersCount,
    required this.todayNetworkCustomers,
    required this.monthlySupervisionCommission,
    required this.supervisionCommissionRate,
    this.directEarnings = 0.0,
    this.directCustomersCount = 0,
    this.teamEarnings = 0.0,
    this.teamCustomersCount = 0,
    this.growthSpecialistsCount = 0,
    this.freelanceMarketersCount = 0,
    this.driversCount = 0,
    this.idleMarketers = const [],
    this.addedDrivers = const [],
  });

  factory NetworkOverviewModel.fromJson(Map<String, dynamic> json) {
    var rawIdle = json['idle_marketers'] as List<dynamic>? ?? [];
    var rawDrivers = json['added_drivers'] as List<dynamic>? ?? [];
    return NetworkOverviewModel(
      totalSubMarketers: json['total_sub_marketers'] as int? ?? 0,
      activeMarketersCount: json['active_marketers_count'] as int? ?? 0,
      idleMarketersCount: json['idle_marketers_count'] as int? ?? 0,
      todayNetworkCustomers: json['today_network_customers'] as int? ?? 0,
      monthlySupervisionCommission: (json['monthly_supervision_commission'] as num?)?.toDouble() ?? 0.0,
      supervisionCommissionRate: (json['supervision_commission_rate'] as num?)?.toDouble() ?? 0.50,
      directEarnings: (json['direct_earnings'] as num?)?.toDouble() ?? 0.0,
      directCustomersCount: json['direct_customers_count'] as int? ?? 0,
      teamEarnings: (json['team_earnings'] as num?)?.toDouble() ?? 0.0,
      teamCustomersCount: json['team_customers_count'] as int? ?? 0,
      growthSpecialistsCount: json['growth_specialists_count'] as int? ?? 0,
      freelanceMarketersCount: json['freelance_marketers_count'] as int? ?? 0,
      driversCount: json['drivers_count'] as int? ?? 0,
      idleMarketers: rawIdle.map((e) => IdleMarketerSummaryModel.fromJson(e)).toList(),
      addedDrivers: rawDrivers.map((e) => DriverLeadSummaryModel.fromJson(e)).toList(),
    );
  }
}

class DriverLeadSummaryModel {
  final int id;
  final String name;
  final String phone;
  final String vehicleType;
  final String? joinedAtText;
  final int customersCount;
  final double returnAmount;
  final String? avatar;

  DriverLeadSummaryModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    this.joinedAtText,
    this.customersCount = 0,
    this.returnAmount = 0.0,
    this.avatar,
  });

  factory DriverLeadSummaryModel.fromJson(Map<String, dynamic> json) {
    return DriverLeadSummaryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? 'motorcycle',
      joinedAtText: json['joined_at_text'] as String?,
      customersCount: json['customers_count'] as int? ?? 0,
      returnAmount: (json['return_amount'] as num?)?.toDouble() ?? 0.0,
      avatar: json['avatar'] as String?,
    );
  }
}

class IdleMarketerSummaryModel {
  final int marketerId;
  final int userId;
  final String name;
  final String profession;
  final String? joinedAt;
  final int customersCount;
  final String? phone;
  final String? avatar;

  IdleMarketerSummaryModel({
    required this.marketerId,
    required this.userId,
    required this.name,
    required this.profession,
    this.joinedAt,
    required this.customersCount,
    this.phone,
    this.avatar,
  });

  factory IdleMarketerSummaryModel.fromJson(Map<String, dynamic> json) {
    return IdleMarketerSummaryModel(
      marketerId: json['marketer_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      profession: json['profession'] as String? ?? 'كاشير',
      joinedAt: json['joined_at'] as String?,
      customersCount: json['customers_count'] as int? ?? 0,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

class SupervisedMarketerModel {
  final int marketerId;
  final int userId;
  final String name;
  final String phone;
  final String? avatar;
  final String marketerType;
  final String? storeName;
  final String status;
  final double dailyRegistrationRate7d;
  final int totalReferrals;
  final int qualifiedCustomersCount;
  final int milestoneTarget;
  final double milestoneProgressPct;
  final bool milestone300Achieved;
  final bool isIdle;
  final int daysSinceLastRegistration;
  final String? lastActivityAt;

  SupervisedMarketerModel({
    required this.marketerId,
    required this.userId,
    required this.name,
    required this.phone,
    this.avatar,
    required this.marketerType,
    this.storeName,
    required this.status,
    required this.dailyRegistrationRate7d,
    required this.totalReferrals,
    required this.qualifiedCustomersCount,
    required this.milestoneTarget,
    required this.milestoneProgressPct,
    required this.milestone300Achieved,
    required this.isIdle,
    required this.daysSinceLastRegistration,
    this.lastActivityAt,
  });

  factory SupervisedMarketerModel.fromJson(Map<String, dynamic> json) {
    return SupervisedMarketerModel(
      marketerId: json['marketer_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      marketerType: json['marketer_type'] as String? ?? 'freelance',
      storeName: json['store_name'] as String?,
      status: json['status'] as String? ?? 'approved',
      dailyRegistrationRate7d: (json['daily_registration_rate_7d'] as num?)?.toDouble() ?? 0.0,
      totalReferrals: json['total_referrals'] as int? ?? 0,
      qualifiedCustomersCount: json['qualified_customers_count'] as int? ?? 0,
      milestoneTarget: json['milestone_target'] as int? ?? 300,
      milestoneProgressPct: (json['milestone_progress_pct'] as num?)?.toDouble() ?? 0.0,
      milestone300Achieved: json['milestone_300_achieved'] as bool? ?? false,
      isIdle: json['is_idle'] as bool? ?? false,
      daysSinceLastRegistration: json['days_since_last_registration'] as int? ?? 0,
      lastActivityAt: json['last_activity_at'] as String?,
    );
  }
}

