class VisitBranchModel {
  String branchName;
  bool underSameStoreSupervision;
  String? address;
  double? latitude;
  double? longitude;
  int? detectedZoneId;
  String? detectedZoneName;
  bool? isInSpecialistZone;
  bool isCheckingZone;

  VisitBranchModel({
    this.branchName = '',
    this.underSameStoreSupervision = true,
    this.address,
    this.latitude,
    this.longitude,
    this.detectedZoneId,
    this.detectedZoneName,
    this.isInSpecialistZone,
    this.isCheckingZone = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'branch_name': branchName.trim(),
      'under_same_store_supervision': underSameStoreSupervision,
      if (address != null && address!.trim().isNotEmpty) 'address': address!.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (detectedZoneId != null) 'detected_zone_id': detectedZoneId,
      if (isInSpecialistZone != null) 'is_in_specialist_zone': isInSpecialistZone,
    };
  }
}
