class SupervisorRecommendationModel {
  final String id;
  final String supervisorName;
  final String supervisorRole;
  final String? supervisorAvatar;
  final String title;
  final String content;
  final bool isRead;
  final String dateGroup;
  final bool isToday;
  final String timeText;
  final String createdAt;
  bool isExpanded;

  SupervisorRecommendationModel({
    required this.id,
    required this.supervisorName,
    required this.supervisorRole,
    this.supervisorAvatar,
    required this.title,
    required this.content,
    this.isRead = false,
    required this.dateGroup,
    this.isToday = false,
    required this.timeText,
    required this.createdAt,
    this.isExpanded = false,
  });

  factory SupervisorRecommendationModel.fromJson(Map<String, dynamic> json) {
    return SupervisorRecommendationModel(
      id: json['id']?.toString() ?? '',
      supervisorName: json['supervisor_name']?.toString() ?? 'مشرف الفريق',
      supervisorRole: json['supervisor_role']?.toString() ?? 'مشرف المبيعات',
      supervisorAvatar: json['supervisor_avatar']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      dateGroup: json['date_group']?.toString() ?? 'اليوم',
      isToday: json['is_today'] == true || json['is_today'] == 1,
      timeText: json['time_text']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isExpanded: json['is_expanded'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'supervisor_name': supervisorName,
    'supervisor_role': supervisorRole,
    'supervisor_avatar': supervisorAvatar,
    'title': title,
    'content': content,
    'is_read': isRead,
    'date_group': dateGroup,
    'is_today': isToday,
    'time_text': timeText,
    'created_at': createdAt,
    'is_expanded': isExpanded,
  };
}
