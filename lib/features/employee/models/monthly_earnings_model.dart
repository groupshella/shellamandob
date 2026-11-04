class MonthlyEarningsModel {
  final String status;
  final String month;
  final String calculatedAt;
  final GrowthSpecialistInfo specialist;
  final ConfigVersionsInfo configVersions;
  final WorkingDaysInfo workingDays;
  final Layer1Salary layer1Salary;
  final Layer2Incentive layer2Incentive;
  final Layer3Network layer3Network;
  final Layer4Direct layer4Direct;
  final EarningsSummary summary;

  MonthlyEarningsModel({
    required this.status,
    required this.month,
    required this.calculatedAt,
    required this.specialist,
    required this.configVersions,
    required this.workingDays,
    required this.layer1Salary,
    required this.layer2Incentive,
    required this.layer3Network,
    required this.layer4Direct,
    required this.summary,
  });

  factory MonthlyEarningsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyEarningsModel(
      status: json['status']?.toString() ?? 'provisional',
      month: json['month']?.toString() ?? '',
      calculatedAt: json['calculated_at']?.toString() ?? '',
      specialist: GrowthSpecialistInfo.fromJson(json['specialist'] is Map ? json['specialist'] : {}),
      configVersions: ConfigVersionsInfo.fromJson(json['config_versions'] is Map ? json['config_versions'] : {}),
      workingDays: WorkingDaysInfo.fromJson(json['working_days'] is Map ? json['working_days'] : {}),
      layer1Salary: Layer1Salary.fromJson(json['layer1_salary'] is Map ? json['layer1_salary'] : {}),
      layer2Incentive: Layer2Incentive.fromJson(json['layer2_incentive'] is Map ? json['layer2_incentive'] : {}),
      layer3Network: Layer3Network.fromJson(json['layer3_network'] is Map ? json['layer3_network'] : {}),
      layer4Direct: Layer4Direct.fromJson(json['layer4_direct'] is Map ? json['layer4_direct'] : {}),
      summary: EarningsSummary.fromJson(json['summary'] is Map ? json['summary'] : {}),
    );
  }
}

class GrowthSpecialistInfo {
  final int id;
  final String name;
  final String phone;

  GrowthSpecialistInfo({required this.id, required this.name, required this.phone});

  factory GrowthSpecialistInfo.fromJson(Map<String, dynamic> json) {
    return GrowthSpecialistInfo(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class ConfigVersionsInfo {
  final int salaryConfigVersionId;
  final int incentiveConfigVersionId;

  ConfigVersionsInfo({required this.salaryConfigVersionId, required this.incentiveConfigVersionId});

  factory ConfigVersionsInfo.fromJson(Map<String, dynamic> json) {
    return ConfigVersionsInfo(
      salaryConfigVersionId: json['salary_config_version_id'] is int ? json['salary_config_version_id'] : int.tryParse('${json['salary_config_version_id']}') ?? 0,
      incentiveConfigVersionId: json['incentive_config_version_id'] is int ? json['incentive_config_version_id'] : int.tryParse('${json['incentive_config_version_id']}') ?? 0,
    );
  }
}

class WorkingDaysInfo {
  final String baselineMode;
  final int totalBaselineDays;
  final int approvedLeaveDays;
  final int effectiveWorkingDays;

  WorkingDaysInfo({
    required this.baselineMode,
    required this.totalBaselineDays,
    required this.approvedLeaveDays,
    required this.effectiveWorkingDays,
  });

  factory WorkingDaysInfo.fromJson(Map<String, dynamic> json) {
    return WorkingDaysInfo(
      baselineMode: json['baseline_mode']?.toString() ?? 'fixed_contractual',
      totalBaselineDays: json['total_baseline_days'] is int ? json['total_baseline_days'] : int.tryParse('${json['total_baseline_days']}') ?? 22,
      approvedLeaveDays: json['approved_leave_days'] is int ? json['approved_leave_days'] : int.tryParse('${json['approved_leave_days']}') ?? 0,
      effectiveWorkingDays: json['effective_working_days'] is int ? json['effective_working_days'] : int.tryParse('${json['effective_working_days']}') ?? 22,
    );
  }
}

class Layer1Salary {
  final double baseContractualSalary;
  final double dailySalaryRate;
  final int approvedUnpaidLeaveDays;
  final double unpaidLeaveDeduction;
  final double netCalculatedSalary;

  Layer1Salary({
    required this.baseContractualSalary,
    required this.dailySalaryRate,
    required this.approvedUnpaidLeaveDays,
    required this.unpaidLeaveDeduction,
    required this.netCalculatedSalary,
  });

  factory Layer1Salary.fromJson(Map<String, dynamic> json) {
    return Layer1Salary(
      baseContractualSalary: (json['base_contractual_salary'] as num?)?.toDouble() ?? 0.0,
      dailySalaryRate: (json['daily_salary_rate'] as num?)?.toDouble() ?? 0.0,
      approvedUnpaidLeaveDays: json['approved_unpaid_leave_days'] is int ? json['approved_unpaid_leave_days'] : int.tryParse('${json['approved_unpaid_leave_days']}') ?? 0,
      unpaidLeaveDeduction: (json['unpaid_leave_deduction'] as num?)?.toDouble() ?? 0.0,
      netCalculatedSalary: (json['net_calculated_salary'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Layer2Incentive {
  final int baseMonthlyTarget;
  final int adjustedMonthlyTarget;
  final int activatedContractsCount;
  final double achievementPercentage;
  final bool isQualified;
  final double minimumQualificationPercent;
  final int contractsNeededToQualify;
  final double standardIncentiveEarned;
  final int overTargetContractsCount;
  final double overTargetBonusEarned;
  final double totalConfirmedIncentive;
  final double displayedPerContractRate;
  final PendingContractsStats pendingContracts;

  Layer2Incentive({
    required this.baseMonthlyTarget,
    required this.adjustedMonthlyTarget,
    required this.activatedContractsCount,
    required this.achievementPercentage,
    required this.isQualified,
    required this.minimumQualificationPercent,
    required this.contractsNeededToQualify,
    required this.standardIncentiveEarned,
    required this.overTargetContractsCount,
    required this.overTargetBonusEarned,
    required this.totalConfirmedIncentive,
    required this.displayedPerContractRate,
    required this.pendingContracts,
  });

  factory Layer2Incentive.fromJson(Map<String, dynamic> json) {
    return Layer2Incentive(
      baseMonthlyTarget: json['base_monthly_target'] is int ? json['base_monthly_target'] : int.tryParse('${json['base_monthly_target']}') ?? 352,
      adjustedMonthlyTarget: json['adjusted_monthly_target'] is int ? json['adjusted_monthly_target'] : int.tryParse('${json['adjusted_monthly_target']}') ?? 352,
      activatedContractsCount: json['activated_contracts_count'] is int ? json['activated_contracts_count'] : int.tryParse('${json['activated_contracts_count']}') ?? 0,
      achievementPercentage: (json['achievement_percentage'] as num?)?.toDouble() ?? 0.0,
      isQualified: BooleanOrFalse(json['is_qualified']),
      minimumQualificationPercent: (json['minimum_qualification_percent'] as num?)?.toDouble() ?? 30.0,
      contractsNeededToQualify: json['contracts_needed_to_qualify'] is int ? json['contracts_needed_to_qualify'] : int.tryParse('${json['contracts_needed_to_qualify']}') ?? 0,
      standardIncentiveEarned: (json['standard_incentive_earned'] as num?)?.toDouble() ?? 0.0,
      overTargetContractsCount: json['over_target_contracts_count'] is int ? json['over_target_contracts_count'] : int.tryParse('${json['over_target_contracts_count']}') ?? 0,
      overTargetBonusEarned: (json['over_target_bonus_earned'] as num?)?.toDouble() ?? 0.0,
      totalConfirmedIncentive: (json['total_confirmed_incentive'] as num?)?.toDouble() ?? 0.0,
      displayedPerContractRate: (json['displayed_per_contract_rate'] as num?)?.toDouble() ?? 6.39,
      pendingContracts: PendingContractsStats.fromJson(json['pending_contracts'] is Map ? json['pending_contracts'] : {}),
    );
  }

  static bool BooleanOrFalse(dynamic val) {
    if (val is bool) return val;
    if (val is num) return val == 1;
    if (val is String) return val.toLowerCase() == 'true' || val == '1';
    return false;
  }
}

class PendingContractsStats {
  final int count;
  final int expiringThisMonthCount;
  final double potentialIncrementalIncentive;

  PendingContractsStats({
    required this.count,
    required this.expiringThisMonthCount,
    required this.potentialIncrementalIncentive,
  });

  factory PendingContractsStats.fromJson(Map<String, dynamic> json) {
    return PendingContractsStats(
      count: json['count'] is int ? json['count'] : int.tryParse('${json['count']}') ?? 0,
      expiringThisMonthCount: json['expiring_this_month_count'] is int ? json['expiring_this_month_count'] : int.tryParse('${json['expiring_this_month_count']}') ?? 0,
      potentialIncrementalIncentive: (json['potential_incremental_incentive'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Layer3Network {
  final int activeSupervisedMarketersCount;
  final double networkSupervisionCommissions;
  final double milestoneBonusesEarned;
  final double totalNetworkEarnings;

  Layer3Network({
    required this.activeSupervisedMarketersCount,
    required this.networkSupervisionCommissions,
    required this.milestoneBonusesEarned,
    required this.totalNetworkEarnings,
  });

  factory Layer3Network.fromJson(Map<String, dynamic> json) {
    return Layer3Network(
      activeSupervisedMarketersCount: json['active_supervised_marketers_count'] is int ? json['active_supervised_marketers_count'] : int.tryParse('${json['active_supervised_marketers_count']}') ?? 0,
      networkSupervisionCommissions: (json['network_supervision_commissions'] as num?)?.toDouble() ?? 0.0,
      milestoneBonusesEarned: (json['milestone_bonuses_earned'] as num?)?.toDouble() ?? 0.0,
      totalNetworkEarnings: (json['total_network_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Layer4Direct {
  final int registeredUsersCount;
  final int qualifiedFirstOrdersCount;
  final double customerAcquisitionCommissions;

  Layer4Direct({
    required this.registeredUsersCount,
    required this.qualifiedFirstOrdersCount,
    required this.customerAcquisitionCommissions,
  });

  factory Layer4Direct.fromJson(Map<String, dynamic> json) {
    return Layer4Direct(
      registeredUsersCount: json['registered_users_count'] is int ? json['registered_users_count'] : int.tryParse('${json['registered_users_count']}') ?? 0,
      qualifiedFirstOrdersCount: json['qualified_first_orders_count'] is int ? json['qualified_first_orders_count'] : int.tryParse('${json['qualified_first_orders_count']}') ?? 0,
      customerAcquisitionCommissions: (json['customer_acquisition_commissions'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EarningsSummary {
  final double layer1SalaryTotal;
  final double layer2IncentiveTotal;
  final double layer3NetworkTotal;
  final double layer4DirectTotal;
  final double totalMonthlyEarnings;

  EarningsSummary({
    required this.layer1SalaryTotal,
    required this.layer2IncentiveTotal,
    required this.layer3NetworkTotal,
    required this.layer4DirectTotal,
    required this.totalMonthlyEarnings,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      layer1SalaryTotal: (json['layer1_salary_total'] as num?)?.toDouble() ?? 0.0,
      layer2IncentiveTotal: (json['layer2_incentive_total'] as num?)?.toDouble() ?? 0.0,
      layer3NetworkTotal: (json['layer3_network_total'] as num?)?.toDouble() ?? 0.0,
      layer4DirectTotal: (json['layer4_direct_total'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyEarnings: (json['total_monthly_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

