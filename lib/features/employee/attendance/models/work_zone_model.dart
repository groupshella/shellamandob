class WorkZoneModel {
  final int id;
  final String name;
  final int plannedVisits;
  final bool isLocked;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const WorkZoneModel({
    required this.id,
    required this.name,
    required this.plannedVisits,
    this.isLocked = false,
    this.latitude = 24.7136,
    this.longitude = 46.6753,
    this.radiusMeters = 1000,
  });

  WorkZoneModel copyWith({
    int? id,
    String? name,
    int? plannedVisits,
    bool? isLocked,
    double? latitude,
    double? longitude,
    double? radiusMeters,
  }) {
    return WorkZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      plannedVisits: plannedVisits ?? this.plannedVisits,
      isLocked: isLocked ?? this.isLocked,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }

  factory WorkZoneModel.fromJson(Map<String, dynamic> json, {int? lockedZoneId}) {
    final int id = int.tryParse('${json['id']}') ?? 0;
    return WorkZoneModel(
      id: id,
      name: (json['name'] ?? json['zone_name'] ?? 'منطقة $id').toString(),
      plannedVisits: int.tryParse('${json['planned_visits'] ?? json['visits_count'] ?? 8}') ?? 8,
      isLocked: lockedZoneId != null && lockedZoneId == id,
      latitude: double.tryParse('${json['latitude'] ?? json['lat'] ?? 24.6500}') ?? 24.6500,
      longitude: double.tryParse('${json['longitude'] ?? json['lng'] ?? 46.6000}') ?? 46.6000,
      radiusMeters: double.tryParse('${json['radius_meters'] ?? json['radius'] ?? 1200}') ?? 1200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'planned_visits': plannedVisits,
      'is_locked': isLocked,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
    };
  }

  static const List<WorkZoneModel> defaultZones = [
    WorkZoneModel(
      id: 2,
      name: 'غرب الرياض',
      plannedVisits: 8,
      latitude: 24.6500,
      longitude: 46.6000,
      radiusMeters: 1200,
    ),
    WorkZoneModel(
      id: 1,
      name: 'شمال الرياض',
      plannedVisits: 6,
      latitude: 24.8000,
      longitude: 46.6500,
      radiusMeters: 1200,
    ),
    WorkZoneModel(
      id: 3,
      name: 'شرق الرياض',
      plannedVisits: 5,
      latitude: 24.7500,
      longitude: 46.8000,
      radiusMeters: 1200,
    ),
    WorkZoneModel(
      id: 4,
      name: 'جنوب الرياض',
      plannedVisits: 7,
      latitude: 24.6000,
      longitude: 46.7000,
      radiusMeters: 1200,
    ),
    WorkZoneModel(
      id: 5,
      name: 'وسط الرياض',
      plannedVisits: 10,
      latitude: 24.7136,
      longitude: 46.6753,
      radiusMeters: 1500,
    ),
    WorkZoneModel(
      id: 6,
      name: 'غرب جدة',
      plannedVisits: 8,
      latitude: 21.5433,
      longitude: 39.1728,
      radiusMeters: 1200,
    ),
    WorkZoneModel(
      id: 7,
      name: 'شمال جدة',
      plannedVisits: 6,
      latitude: 21.6500,
      longitude: 39.1500,
      radiusMeters: 1200,
    ),
  ];
}
