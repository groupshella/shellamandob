import 'package:get/get.dart';

class TrainingLessonModel {
  final int id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String category;
  final int durationMinutes;
  final int watchedSeconds;
  final int progressPercent;
  final bool isCompleted;

  const TrainingLessonModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.thumbnailUrl,
    this.videoUrl,
    this.category = 'value_pitch',
    this.durationMinutes = 10,
    this.watchedSeconds = 0,
    this.progressPercent = 0,
    this.isCompleted = false,
  });

  String get localizedTitle {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return isAr
        ? (titleAr.isNotEmpty ? titleAr : titleEn)
        : (titleEn.isNotEmpty ? titleEn : titleAr);
  }

  String get localizedDescription {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return isAr
        ? (descriptionAr.isNotEmpty ? descriptionAr : descriptionEn)
        : (descriptionEn.isNotEmpty ? descriptionEn : descriptionAr);
  }

  TrainingLessonModel copyWith({
    int? watchedSeconds,
    int? progressPercent,
    bool? isCompleted,
  }) {
    return TrainingLessonModel(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      category: category,
      durationMinutes: durationMinutes,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      progressPercent: progressPercent ?? this.progressPercent,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TrainingLessonModel.fromJson(Map<String, dynamic> json) {
    return TrainingLessonModel(
      id: int.tryParse('${json['id']}') ?? 0,
      titleAr: json['title_ar']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      category: json['category']?.toString() ?? 'value_pitch',
      durationMinutes: int.tryParse('${json['duration_minutes']}') ?? 10,
      watchedSeconds: int.tryParse('${json['watched_seconds']}') ?? 0,
      progressPercent: int.tryParse('${json['progress_percent']}') ?? 0,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
    );
  }
}

class DailyPerformanceReportModel {
  final int scorePercent;
  final List<String> strengthsAr;
  final List<String> strengthsEn;
  final List<String> improvementsAr;
  final List<String> improvementsEn;
  final TrainingLessonModel? suggestedLesson;

  const DailyPerformanceReportModel({
    this.scorePercent = 0,
    this.strengthsAr = const [],
    this.strengthsEn = const [],
    this.improvementsAr = const [],
    this.improvementsEn = const [],
    this.suggestedLesson,
  });

  List<String> get localizedStrengths {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return isAr
        ? (strengthsAr.isNotEmpty ? strengthsAr : strengthsEn)
        : (strengthsEn.isNotEmpty ? strengthsEn : strengthsAr);
  }

  List<String> get localizedImprovements {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return isAr
        ? (improvementsAr.isNotEmpty ? improvementsAr : improvementsEn)
        : (improvementsEn.isNotEmpty ? improvementsEn : improvementsAr);
  }

  factory DailyPerformanceReportModel.fromJson(Map<String, dynamic> json) {
    return DailyPerformanceReportModel(
      scorePercent: int.tryParse('${json['score_percent']}') ?? 0,
      strengthsAr: (json['strengths_ar'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      strengthsEn: (json['strengths_en'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      improvementsAr: (json['improvements_ar'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      improvementsEn: (json['improvements_en'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      suggestedLesson: json['suggested_lesson'] is Map
          ? TrainingLessonModel.fromJson(
              Map<String, dynamic>.from(json['suggested_lesson']),
            )
          : null,
    );
  }
}
