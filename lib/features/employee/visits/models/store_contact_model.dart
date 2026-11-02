class StoreContactModel {
  final int? id;
  final int? storeId;
  final int? marketerVisitId;
  final int? addedByUserId;
  final String name;
  final String role; // owner, partner, manager, cashier, worker, other
  final String phone;
  final String? nationality;
  final String preferredLanguage; // ar, en, ur, bn, tl
  final bool whatsappConsent;
  final DateTime? consentAt;
  final String? notes;
  final DateTime? createdAt;

  const StoreContactModel({
    this.id,
    this.storeId,
    this.marketerVisitId,
    this.addedByUserId,
    required this.name,
    required this.role,
    required this.phone,
    this.nationality,
    this.preferredLanguage = 'ar',
    this.whatsappConsent = false,
    this.consentAt,
    this.notes,
    this.createdAt,
  });

  factory StoreContactModel.fromJson(Map<String, dynamic> json) {
    return StoreContactModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      storeId: json['store_id'] is int ? json['store_id'] as int : int.tryParse(json['store_id']?.toString() ?? ''),
      marketerVisitId: json['marketer_visit_id'] is int ? json['marketer_visit_id'] as int : int.tryParse(json['marketer_visit_id']?.toString() ?? ''),
      addedByUserId: json['added_by_user_id'] is int ? json['added_by_user_id'] as int : int.tryParse(json['added_by_user_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'other',
      phone: json['phone']?.toString() ?? '',
      nationality: json['nationality']?.toString(),
      preferredLanguage: json['preferred_language']?.toString() ?? 'ar',
      whatsappConsent: json['whatsapp_consent'] == true || json['whatsapp_consent'] == 1 || json['whatsapp_consent'] == '1',
      consentAt: json['consent_at'] != null ? DateTime.tryParse(json['consent_at'].toString()) : null,
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (marketerVisitId != null) 'marketer_visit_id': marketerVisitId,
      if (addedByUserId != null) 'added_by_user_id': addedByUserId,
      'name': name,
      'role': role,
      'phone': phone,
      if (nationality != null) 'nationality': nationality,
      'preferred_language': preferredLanguage,
      'whatsapp_consent': whatsappConsent,
      if (consentAt != null) 'consent_at': consentAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  StoreContactModel copyWith({
    int? id,
    int? storeId,
    int? marketerVisitId,
    int? addedByUserId,
    String? name,
    String? role,
    String? phone,
    String? nationality,
    String? preferredLanguage,
    bool? whatsappConsent,
    DateTime? consentAt,
    String? notes,
  }) {
    return StoreContactModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      marketerVisitId: marketerVisitId ?? this.marketerVisitId,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      whatsappConsent: whatsappConsent ?? this.whatsappConsent,
      consentAt: consentAt ?? this.consentAt,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

