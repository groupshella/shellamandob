class MarketerLeadModel {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? neighborhood;
  final bool isClaimedByMe;

  const MarketerLeadModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.neighborhood,
    this.isClaimedByMe = false,
  });

  factory MarketerLeadModel.fromJson(Map<String, dynamic> json) {
    return MarketerLeadModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude'] != null ? double.tryParse('${json['latitude']}') : null,
      longitude: json['longitude'] != null ? double.tryParse('${json['longitude']}') : null,
      neighborhood: json['neighborhood']?.toString(),
      isClaimedByMe: json['is_claimed_by_me'] == true || json['is_claimed_by_me'] == 1,
    );
  }
}
