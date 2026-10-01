import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/core/network/api_client.dart';

class MarketerLeaveModel {
  final int id;
  final String type;
  final String typeLabel;
  final String status;
  final String statusLabel;
  final String dateAndDuration;
  final String? startDate;
  final String? endDate;
  final int days;
  final String? reason;
  final String? rejectReason;

  MarketerLeaveModel({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    required this.dateAndDuration,
    this.startDate,
    this.endDate,
    this.days = 1,
    this.reason,
    this.rejectReason,
  });

  factory MarketerLeaveModel.fromJson(Map<String, dynamic> json) {
    return MarketerLeaveModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? 'annual_leave',
      typeLabel: json['type_label']?.toString() ?? 'إجازة سنوية',
      status: json['status']?.toString() ?? 'under_review',
      statusLabel: json['status_label']?.toString() ?? 'قيد المراجعة',
      dateAndDuration: json['date_and_duration']?.toString() ?? '—',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      days: json['days'] is int ? json['days'] : int.tryParse('${json['days']}') ?? 1,
      reason: json['reason']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
    );
  }
}

class EmployeeVacationsController extends GetxController implements GetxService {
  final ApiClient apiClient;
  EmployeeVacationsController({required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  List<MarketerLeaveModel> _leavesList = [];
  List<MarketerLeaveModel> get leavesList => _leavesList;

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    _isLoading = true;
    update();
    try {
      final response = await apiClient.getData('/api/v1/customer/marketer/leaves');
      if (response.statusCode == 200 && response.body != null) {
        final dynamic rawData = response.body['data'] ?? response.body;
        if (rawData is List) {
          _leavesList = rawData
              .map((item) => MarketerLeaveModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else {
          _leavesList = [];
        }
      } else {
        _leavesList = [];
      }
    } catch (e) {
      debugPrint('Error fetching leaves: $e');
      _leavesList = [];
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    String? filePath,
  }) async {
    _isSubmitting = true;
    update();
    try {
      final Map<String, String> fields = {
        'type': type,
        'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        'end_date': '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      };

      Response response;
      if (filePath != null && filePath.isNotEmpty) {
        final List<MultipartBody> multipart = [
          MultipartBody('attachment', XFile(filePath)),
        ];
        response = await apiClient.postMultipartData(
          '/api/v1/customer/marketer/leaves',
          fields,
          multipart,
        );
      } else {
        response = await apiClient.postData(
          '/api/v1/customer/marketer/leaves',
          fields,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchLeaves();
        _isSubmitting = false;
        update();
        return true;
      }
    } catch (e) {
      debugPrint('Error submitting leave: $e');
    } finally {
      _isSubmitting = false;
      update();
    }
    return false;
  }
}
