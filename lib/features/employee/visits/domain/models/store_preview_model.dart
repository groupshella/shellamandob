class StorePreviewModel {
  final StorePreviewInfo store;
  final StorePreviewReadiness readiness;
  final List<StorePreviewSchedule> schedules;
  final List<StorePreviewItem> items;

  StorePreviewModel({
    required this.store,
    required this.readiness,
    required this.schedules,
    required this.items,
  });

  factory StorePreviewModel.fromJson(Map<String, dynamic> json) {
    final storeMap = json['store'] is Map
        ? Map<String, dynamic>.from(json['store'] as Map)
        : <String, dynamic>{};
    final readinessMap = json['readiness'] is Map
        ? Map<String, dynamic>.from(json['readiness'] as Map)
        : <String, dynamic>{};
    final rawSchedules = json['schedules'] is List ? json['schedules'] as List : [];
    final rawItems = json['items'] is List ? json['items'] as List : [];

    return StorePreviewModel(
      store: StorePreviewInfo.fromJson(storeMap),
      readiness: StorePreviewReadiness.fromJson(readinessMap),
      schedules: rawSchedules
          .whereType<Map>()
          .map((e) => StorePreviewSchedule.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      items: rawItems
          .whereType<Map>()
          .map((e) => StorePreviewItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class StorePreviewInfo {
  final int id;
  final String name;
  final String? specialty;
  final String? address;
  final String? phone;
  final String? logoFullUrl;
  final String? coverPhotoFullUrl;
  final bool open;
  final bool active;
  final String? deliveryTime;
  final double minimumOrder;

  StorePreviewInfo({
    required this.id,
    required this.name,
    this.specialty,
    this.address,
    this.phone,
    this.logoFullUrl,
    this.coverPhotoFullUrl,
    required this.open,
    required this.active,
    this.deliveryTime,
    required this.minimumOrder,
  });

  factory StorePreviewInfo.fromJson(Map<String, dynamic> json) {
    return StorePreviewInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      specialty: json['specialty']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      logoFullUrl: json['logo_full_url']?.toString(),
      coverPhotoFullUrl: json['cover_photo_full_url']?.toString(),
      open: json['open'] == true || json['open'] == 1,
      active: json['active'] == true || json['active'] == 1,
      deliveryTime: json['delivery_time']?.toString(),
      minimumOrder: (json['minimum_order'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StorePreviewReadiness {
  final int totalItems;
  final int activeItems;
  final int itemsWithoutImage;
  final int itemsWithoutPrice;
  final bool hasLogo;
  final bool hasCover;
  final bool workingHoursConfigured;
  final bool isReady;

  StorePreviewReadiness({
    required this.totalItems,
    required this.activeItems,
    required this.itemsWithoutImage,
    required this.itemsWithoutPrice,
    required this.hasLogo,
    required this.hasCover,
    required this.workingHoursConfigured,
    required this.isReady,
  });

  factory StorePreviewReadiness.fromJson(Map<String, dynamic> json) {
    return StorePreviewReadiness(
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      activeItems: (json['active_items'] as num?)?.toInt() ?? 0,
      itemsWithoutImage: (json['items_without_image'] as num?)?.toInt() ?? 0,
      itemsWithoutPrice: (json['items_without_price'] as num?)?.toInt() ?? 0,
      hasLogo: json['has_logo'] == true || json['has_logo'] == 1,
      hasCover: json['has_cover'] == true || json['has_cover'] == 1,
      workingHoursConfigured:
          json['working_hours_configured'] == true || json['working_hours_configured'] == 1,
      isReady: json['is_ready'] == true || json['is_ready'] == 1,
    );
  }
}

class StorePreviewSchedule {
  final int day;
  final String openingTime;
  final String closingTime;

  StorePreviewSchedule({
    required this.day,
    required this.openingTime,
    required this.closingTime,
  });

  factory StorePreviewSchedule.fromJson(Map<String, dynamic> json) {
    return StorePreviewSchedule(
      day: (json['day'] as num?)?.toInt() ?? 0,
      openingTime: (json['opening_time'] ?? '').toString(),
      closingTime: (json['closing_time'] ?? '').toString(),
    );
  }
}

class StorePreviewItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double discount;
  final int? stock;
  final int status;
  final String? imageFullUrl;
  final bool hasImage;
  final bool hasPrice;

  StorePreviewItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.discount,
    this.stock,
    required this.status,
    this.imageFullUrl,
    required this.hasImage,
    required this.hasPrice,
  });

  factory StorePreviewItem.fromJson(Map<String, dynamic> json) {
    return StorePreviewItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] != null ? (json['stock'] as num?)?.toInt() : null,
      status: (json['status'] as num?)?.toInt() ?? 0,
      imageFullUrl: json['image_full_url']?.toString(),
      hasImage: json['has_image'] == true || json['has_image'] == 1,
      hasPrice: json['has_price'] == true || json['has_price'] == 1,
    );
  }
}
