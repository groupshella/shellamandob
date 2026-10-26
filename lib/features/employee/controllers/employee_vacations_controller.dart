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
  final String? attachment;
  final String? createdAt;

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
    this.attachment,
    this.createdAt,
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
      attachment: json['attachment']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class MarketerLeaveQuotaModel {
  final int annualTotal;
  final int annualUsed;
  final int annualRemaining;
  final bool annualExhausted;
  final int sickTotal;
  final int sickUsed;
  final int sickRemaining;
  final bool sickExhausted;

  MarketerLeaveQuotaModel({
    required this.annualTotal,
    required this.annualUsed,
    required this.annualRemaining,
    required this.annualExhausted,
    required this.sickTotal,
    required this.sickUsed,
    required this.sickRemaining,
    required this.sickExhausted,
  });

  factory MarketerLeaveQuotaModel.fromJson(Map<String, dynamic> json) {
    return MarketerLeaveQuotaModel(
      annualTotal: int.tryParse('${json['annual_total']}') ?? 21,
      annualUsed: int.tryParse('${json['annual_used']}') ?? 0,
      annualRemaining: int.tryParse('${json['annual_remaining']}') ?? 21,
      annualExhausted: json['annual_exhausted'] == true || json['annual_exhausted'] == 1,
      sickTotal: int.tryParse('${json['sick_total']}') ?? 30,
      sickUsed: int.tryParse('${json['sick_used']}') ?? 0,
      sickRemaining: int.tryParse('${json['sick_remaining']}') ?? 30,
      sickExhausted: json['sick_exhausted'] == true || json['sick_exhausted'] == 1,
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

  String? _lastErrorMessage;
  String? get lastErrorMessage => _lastErrorMessage;

  List<MarketerLeaveModel> _leavesList = [];
  List<MarketerLeaveModel> get leavesList => _leavesList;

  MarketerLeaveQuotaModel? _quota;
  MarketerLeaveQuotaModel? get quota => _quota;

  bool get isAnnualLeaveExhausted => _quota?.annualExhausted ?? false;
  bool get isSickLeaveExhausted => _quota?.sickExhausted ?? false;

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

        if (response.body['quota'] is Map) {
          _quota = MarketerLeaveQuotaModel.fromJson(
            Map<String, dynamic>.from(response.body['quota']),
          );
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

  Future<MarketerLeaveModel?> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    String? filePath,
  }) async {
    _isSubmitting = true;
    _lastErrorMessage = null;
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

        if (response.body != null && response.body['data'] is Map) {
          return MarketerLeaveModel.fromJson(Map<String, dynamic>.from(response.body['data']));
        }
        return _leavesList.isNotEmpty ? _leavesList.first : null;
      } else {
        if (response.body != null && response.body['message'] != null) {
          _lastErrorMessage = response.body['message'].toString();
        }
      }
    } catch (e) {
      debugPrint('Error submitting leave: $e');
      _lastErrorMessage = e.toString();
    } finally {
      _isSubmitting = false;
      update();
    }
    return null;
  }
}
