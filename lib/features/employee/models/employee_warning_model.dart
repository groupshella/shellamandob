class EmployeeWarningModel {
  final String id;
  final String title;
  final String date;
  final String? reason;

  const EmployeeWarningModel({
    required this.id,
    required this.title,
    required this.date,
    this.reason,
  });

  factory EmployeeWarningModel.fromJson(Map<String, dynamic> json) {
    return EmployeeWarningModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    if (reason != null) 'reason': reason,
  };
}
