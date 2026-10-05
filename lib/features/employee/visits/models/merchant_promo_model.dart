class MerchantPromoModel {
  final int id;
  final String titleAr;
  final String? titleEn;
  final String code;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final String? badge;
  final String? descriptionAr;
  final String? descriptionEn;
  final bool isActive;
  final String? validUntil;

  const MerchantPromoModel({
    required this.id,
    required this.titleAr,
    this.titleEn,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.badge,
    this.descriptionAr,
    this.descriptionEn,
    this.isActive = true,
    this.validUntil,
  });

  factory MerchantPromoModel.fromJson(Map<String, dynamic> json) {
    return MerchantPromoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      titleAr: json['title_ar']?.toString() ?? '',
      titleEn: json['title_en']?.toString(),
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'percent',
      discountValue: (json['discount_value'] != null)
          ? double.tryParse(json['discount_value'].toString()) ?? 0.0
          : 0.0,
      minOrderAmount: (json['min_order_amount'] != null)
          ? double.tryParse(json['min_order_amount'].toString()) ?? 0.0
          : 0.0,
      badge: json['badge']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      validUntil: json['valid_until']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'badge': badge,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'is_active': isActive,
      'valid_until': validUntil,
    };
  }
}
