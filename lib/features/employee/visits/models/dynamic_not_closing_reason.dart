import 'not_closing_reason.dart';

class DynamicNotClosingReason {
  final int id;
  final String code;
  final String titleAr;
  final String? titleEn;
  final String? headlineAr;
  final String? headlineEn;
  final int sortOrder;

  const DynamicNotClosingReason({
    required this.id,
    required this.code,
    required this.titleAr,
    this.titleEn,
    this.headlineAr,
    this.headlineEn,
    required this.sortOrder,
  });

  factory DynamicNotClosingReason.fromJson(Map<String, dynamic> json) {
    return DynamicNotClosingReason(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] ?? 'other').toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      titleEn: json['title_en']?.toString(),
      headlineAr: json['headline_ar']?.toString(),
      headlineEn: json['headline_en']?.toString(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  String localizedTitle(bool isEn) {
    if (isEn && titleEn != null && titleEn!.trim().isNotEmpty) {
      return titleEn!.trim();
    }
    return titleAr.trim().isNotEmpty ? titleAr.trim() : code;
  }

  String? localizedHeadline(bool isEn) {
    if (isEn && headlineEn != null && headlineEn!.trim().isNotEmpty) {
      return headlineEn!.trim();
    }
    if (headlineAr != null && headlineAr!.trim().isNotEmpty) {
      return headlineAr!.trim();
    }
    return null;
  }

  static List<DynamicNotClosingReason> fallbackList() {
    return NotClosingReason.values.asMap().entries.map((entry) {
      final r = entry.value;
      return DynamicNotClosingReason(
        id: entry.key + 1,
        code: r.key,
        titleAr: r.label,
        titleEn: r.label,
        sortOrder: entry.key + 1,
      );
    }).toList();
  }
}
