class ContractActivationModel {
  final int storeId;
  final String storeName;
  final String contractNumber;
  final DateTime? signedAt;
  final DateTime? expiresAt;
  final int elapsedDays;
  final int remainingDays;
  final String timerColor; // green, orange, red
  final String timerStatusText;
  final String activationStatus; // pending, activated, expired
  final String? standPhotoPath;
  final String? cashierSystemName;
  final int? firstOrderId;
  final DateTime? firstOrderAt;
  final int progressPercentage;
  final int completedItems;
  final int totalItems;
  final List<ChecklistItemModel> items;
  final String? issueNotes;

  ContractActivationModel({
    required this.storeId,
    required this.storeName,
    required this.contractNumber,
    this.signedAt,
    this.expiresAt,
    required this.elapsedDays,
    required this.remainingDays,
    required this.timerColor,
    required this.timerStatusText,
    required this.activationStatus,
    this.standPhotoPath,
    this.cashierSystemName,
    this.firstOrderId,
    this.firstOrderAt,
    required this.progressPercentage,
    required this.completedItems,
    required this.totalItems,
    required this.items,
    this.issueNotes,
  });

  factory ContractActivationModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<ChecklistItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => ChecklistItemModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    return ContractActivationModel(
      storeId: json['store_id'] is int ? json['store_id'] : int.tryParse(json['store_id']?.toString() ?? '0') ?? 0,
      storeName: json['store_name']?.toString() ?? '',
      contractNumber: json['contract_number']?.toString() ?? '',
      signedAt: json['signed_at'] != null ? DateTime.tryParse(json['signed_at'].toString()) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      elapsedDays: json['elapsed_days'] is int ? json['elapsed_days'] : int.tryParse(json['elapsed_days']?.toString() ?? '0') ?? 0,
      remainingDays: json['remaining_days'] is int ? json['remaining_days'] : int.tryParse(json['remaining_days']?.toString() ?? '0') ?? 0,
      timerColor: json['timer_color']?.toString() ?? 'green',
      timerStatusText: json['timer_status_text']?.toString() ?? '',
      activationStatus: json['activation_status']?.toString() ?? 'pending',
      standPhotoPath: json['stand_photo_path']?.toString(),
      cashierSystemName: json['cashier_system_name']?.toString(),
      firstOrderId: json['first_order_id'] is int ? json['first_order_id'] : int.tryParse(json['first_order_id']?.toString() ?? ''),
      firstOrderAt: json['first_order_at'] != null ? DateTime.tryParse(json['first_order_at'].toString()) : null,
      progressPercentage: json['progress_percentage'] is int ? json['progress_percentage'] : int.tryParse(json['progress_percentage']?.toString() ?? '0') ?? 0,
      completedItems: json['completed_items'] is int ? json['completed_items'] : int.tryParse(json['completed_items']?.toString() ?? '0') ?? 0,
      totalItems: json['total_items'] is int ? json['total_items'] : int.tryParse(json['total_items']?.toString() ?? '0') ?? 0,
      items: parsedItems,
      issueNotes: json['issue_notes']?.toString(),
    );
  }
}

class ChecklistItemModel {
  final String key;
  final String titleAr;
  final String titleEn;
  final String type; // manual, manual_input, camera_photo, system_auto
  final bool isRequired;
  String status; // not_started, in_progress, completed
  dynamic value;
  final String? updatedAt;
  final bool isReadonly;

  ChecklistItemModel({
    required this.key,
    required this.titleAr,
    required this.titleEn,
    required this.type,
    required this.isRequired,
    required this.status,
    this.value,
    this.updatedAt,
    required this.isReadonly,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      key: json['key']?.toString() ?? '',
      titleAr: json['title_ar']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      type: json['type']?.toString() ?? 'manual',
      isRequired: json['is_required'] == true || json['is_required'] == 1 || json['is_required'] == '1',
      status: json['status']?.toString() ?? 'not_started',
      value: json['value'],
      updatedAt: json['updated_at']?.toString(),
      isReadonly: json['is_readonly'] == true || json['is_readonly'] == 1 || json['is_readonly'] == '1',
    );
  }

  String getLocalizedTitle(String langCode) {
    return langCode == 'ar' ? titleAr : (titleEn.isNotEmpty ? titleEn : titleAr);
  }
}

