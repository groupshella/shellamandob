class DynamicGiftCampaignModel {
  bool? success;
  bool? available;
  bool? isEligible;
  String? eligibilityReason;
  String? eligibilityMessage;
  CampaignDetails? campaign;

  DynamicGiftCampaignModel({
    this.success,
    this.available,
    this.isEligible,
    this.eligibilityReason,
    this.eligibilityMessage,
    this.campaign,
  });

  DynamicGiftCampaignModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true || json['success'] == 1 || json['success'] == 'true';
    available = json['available'] == true || json['available'] == 1 || json['available'] == 'true';
    isEligible = json['is_eligible'] == true || json['is_eligible'] == 1 || json['is_eligible'] == 'true';
    eligibilityReason = json['eligibility_reason']?.toString();
    eligibilityMessage = json['eligibility_message']?.toString();
    campaign = json['campaign'] != null ? CampaignDetails.fromJson(json['campaign']) : null;
  }
}

class CampaignDetails {
  int? id;
  String? title;
  String? description;
  String? image;
  String? campaignType;
  String? targetAudience;
  int? storeId;
  CampaignStore? store;
  List<SelectableGiftItem>? selectableItems;

  CampaignDetails({
    this.id,
    this.title,
    this.description,
    this.image,
    this.campaignType,
    this.targetAudience,
    this.storeId,
    this.store,
    this.selectableItems,
  });

  CampaignDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    campaignType = json['campaign_type'];
    targetAudience = json['target_audience'];
    storeId = json['store_id'];
    store = json['store'] != null ? CampaignStore.fromJson(json['store']) : null;
    if (json['selectable_items'] != null) {
      selectableItems = <SelectableGiftItem>[];
      json['selectable_items'].forEach((v) {
        selectableItems!.add(SelectableGiftItem.fromJson(v));
      });
    }
  }
}

class CampaignStore {
  int? id;
  String? name;
  String? logo;
  String? coverPhoto;
  double? rating;
  String? deliveryTime;

  CampaignStore({
    this.id,
    this.name,
    this.logo,
    this.coverPhoto,
    this.rating,
    this.deliveryTime,
  });

  CampaignStore.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    coverPhoto = json['cover_photo'];
    rating = json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 4.9 : 4.9;
    deliveryTime = json['delivery_time'] ?? '20-30 دقيقة';
  }
}

class SelectableGiftItem {
  int? campaignItemId;
  int? itemId;
  String? name;
  String? image;
  double? originalPrice;
  double? discountPrice;
  bool? isFree;
  String? description;
  bool? inStock;

  SelectableGiftItem({
    this.campaignItemId,
    this.itemId,
    this.name,
    this.image,
    this.originalPrice,
    this.discountPrice,
    this.isFree,
    this.description,
    this.inStock,
  });

  SelectableGiftItem.fromJson(Map<String, dynamic> json) {
    campaignItemId = json['campaign_item_id'];
    itemId = json['item_id'];
    name = json['name'];
    image = json['image_full_url'] ?? json['image'];
    originalPrice = json['original_price'] != null ? double.tryParse(json['original_price'].toString()) ?? 0.0 : 0.0;
    discountPrice = json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) ?? 0.0 : 0.0;
    isFree = json['is_free'] == true || json['is_free'] == 1 || json['is_free'] == 'true';
    description = json['description'];
    inStock = json['in_stock'] == true || json['in_stock'] == 1 || json['in_stock'] == 'true' || json['in_stock'] == null;
  }
}
