class ZoneStoreDemandModel {
  final int id;
  final int? visitId;
  final int? storeId;
  final String storeName;
  final String address;
  final double? latitude;
  final double? longitude;
  final int? zoneId;
  final String contractStatus; // not_contracted | contracted | active
  final String managerName;
  final String phone;
  final String crNumber;
  final int nearbyCustomers1km;
  final int nearbyCustomers2km;
  final int waitingCustomersCount;
  final int storeMarketersCount;

  const ZoneStoreDemandModel({
    required this.id,
    this.visitId,
    this.storeId,
    required this.storeName,
    this.address = '',
    this.latitude,
    this.longitude,
    this.zoneId,
    this.contractStatus = 'not_contracted',
    this.managerName = '',
    this.phone = '',
    this.crNumber = '',
    this.nearbyCustomers1km = 0,
    this.nearbyCustomers2km = 0,
    this.waitingCustomersCount = 0,
    this.storeMarketersCount = 0,
  });

  factory ZoneStoreDemandModel.fromJson(Map<String, dynamic> json) {
    return ZoneStoreDemandModel(
      id: int.tryParse('${json['id']}') ?? 0,
      visitId: json['visit_id'] != null ? int.tryParse('${json['visit_id']}') : null,
      storeId: json['store_id'] != null ? int.tryParse('${json['store_id']}') : null,
      storeName: json['store_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude'] != null ? double.tryParse('${json['latitude']}') : null,
      longitude: json['longitude'] != null ? double.tryParse('${json['longitude']}') : null,
      zoneId: json['zone_id'] != null ? int.tryParse('${json['zone_id']}') : null,
      contractStatus: json['contract_status']?.toString() ?? 'not_contracted',
      managerName: json['manager_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      crNumber: json['cr_number']?.toString() ?? '',
      nearbyCustomers1km: int.tryParse('${json['nearby_customers_1km']}') ?? 0,
      nearbyCustomers2km: int.tryParse('${json['nearby_customers_2km']}') ?? 0,
      waitingCustomersCount: int.tryParse('${json['waiting_customers_count']}') ?? 0,
      storeMarketersCount: int.tryParse('${json['store_marketers_count']}') ?? 0,
    );
  }
}
