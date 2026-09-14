class PosCheckoutOrderModel {
  String? orderId;
  String? orderType;
  double? orderAmount;
  double? couponDiscountAmount;
  double? storeDiscountAmount;
  double? totalTaxAmount;
  String? orderNote;
  String? checkoutStatus;
  String? paymentStatus;
  DateTime? expiresAt;
  bool? isClaimed;
  PosStoreModel? store;
  List<PosOrderItemModel>? items;

  PosCheckoutOrderModel({
    this.orderId,
    this.orderType,
    this.orderAmount,
    this.couponDiscountAmount,
    this.storeDiscountAmount,
    this.totalTaxAmount,
    this.orderNote,
    this.checkoutStatus,
    this.paymentStatus,
    this.expiresAt,
    this.isClaimed,
    this.store,
    this.items,
  });

  factory PosCheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    List<PosOrderItemModel> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      for (var item in json['items']) {
        itemsList.add(PosOrderItemModel.fromJson(item));
      }
    }

    return PosCheckoutOrderModel(
      orderId: json['order_id']?.toString(),
      orderType: json['order_type']?.toString(),
      orderAmount: (json['order_amount'] ?? 0.0).toDouble(),
      couponDiscountAmount: (json['coupon_discount_amount'] ?? 0.0).toDouble(),
      storeDiscountAmount: (json['store_discount_amount'] ?? 0.0).toDouble(),
      totalTaxAmount: (json['total_tax_amount'] ?? 0.0).toDouble(),
      orderNote: json['order_note']?.toString(),
      checkoutStatus: json['checkout_status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      isClaimed: json['is_claimed'] == true,
      store: json['store'] != null ? PosStoreModel.fromJson(json['store']) : null,
      items: itemsList,
    );
  }
}

class PosStoreModel {
  int? id;
  String? name;
  String? logo;
  String? phone;
  String? address;

  PosStoreModel({this.id, this.name, this.logo, this.phone, this.address});

  factory PosStoreModel.fromJson(Map<String, dynamic> json) {
    return PosStoreModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class PosOrderItemModel {
  int? id;
  String? name;
  double? price;
  int? quantity;
  double? discount;
  double? lineTotal;
  String? image;
  dynamic variation;
  dynamic addOns;

  PosOrderItemModel({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.discount,
    this.lineTotal,
    this.image,
    this.variation,
    this.addOns,
  });

  factory PosOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PosOrderItemModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? 1).toInt(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      lineTotal: (json['line_total'] ?? 0.0).toDouble(),
      image: json['image']?.toString(),
      variation: json['variation'],
      addOns: json['add_ons'],
    );
  }
}
