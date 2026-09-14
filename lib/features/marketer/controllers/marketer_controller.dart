import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/environment_config.dart';

/// Controller for the in-app "Coupon Marketer" feature.
/// Talks to the backend endpoints:
///   GET  /api/v1/customer/marketer/dashboard
///   POST /api/v1/customer/marketer/apply
class MarketerController extends GetxController implements GetxService {
  final ApiClient apiClient;
  MarketerController({required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Map<String, dynamic>? _data;
  Map<String, dynamic>? get data => _data;

  /// none | pending | approved | rejected | suspended
  String get status => (_data?['marketer_status'] ?? 'none').toString();

  String get code => (_data?['code'] ?? 'SHILLAH-R-0000').toString();
  String get qrLink => (_data?['qr_link'] ?? '${EnvironmentConfig.baseUrl}/join?ref=$code').toString();
  String get appDeepLink => (_data?['app_deep_link'] ?? 'shella://join?ref=$code').toString();
  String get shareText => (_data?['share_text'] ?? 'حمّل تطبيق شلة واستخدم كودي $code واحصل على مكافأة! $qrLink').toString();

  double get balance => double.tryParse('${_data?['balance'] ?? 0}') ?? 0.0;
  double get pendingBalance => double.tryParse('${_data?['pending_balance'] ?? 0}') ?? 0.0;
  int get pendingDays => int.tryParse('${_data?['pending_days'] ?? 0}') ?? 0;
  double get minTransferAmount => double.tryParse('${_data?['min_transfer_amount'] ?? 200}') ?? 200.0;
  double get commissionRate => double.tryParse('${_data?['commission_rate'] ?? 1.0}') ?? 1.0;

  int get todayReferred => int.tryParse('${_data?['today_referred'] ?? 0}') ?? 0;
  int get acquiredCustomers => int.tryParse('${_data?['acquired_customers'] ?? _data?['today_referred'] ?? 0}') ?? 0;
  int get totalScans => int.tryParse('${_data?['total_scans'] ?? 0}') ?? 0;
  int get hesitantCustomers => int.tryParse('${_data?['hesitant_customers'] ?? 0}') ?? 0;
  int get kpiGrowthPct => int.tryParse('${_data?['kpi_growth_pct'] ?? 12}') ?? 12;

  String get appliedAt {
    final raw = (_data?['applied_at'] ?? '').toString();
    if (raw.isNotEmpty) {
      try {
        final dt = DateTime.parse(raw);
        const arabicMonths = [
          'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
          'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
        ];
        return '${dt.day} ${arabicMonths[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return raw;
      }
    }
    final now = DateTime.now();
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${now.day} ${arabicMonths[now.month - 1]} ${now.year}';
  }

  List<dynamic> get transactions => (_data?['transactions'] as List?) ?? [];
  Map<String, dynamic> get funnel => (_data?['funnel'] is Map) ? Map<String, dynamic>.from(_data!['funnel']) : {};

  Future<void> loadDashboard({bool notify = true}) async {
    _isLoading = true;
    if (notify) update();
    try {
      // useEtag: false → always forces a fresh 200 response (avoids 304 with null body)
      final Response response = await apiClient.getData(
        '/api/v1/customer/marketer/dashboard',
        useEtag: false,
      );
      debugPrint('🔍 [MarketerController] status=${response.statusCode}, body=${response.body}');
      if (response.statusCode == 200 && response.body != null) {
        _data = Map<String, dynamic>.from(
            response.body['data'] ?? <String, dynamic>{'marketer_status': 'none'});
      } else {
        _data ??= {'marketer_status': 'none'};
      }
    } catch (e) {
      debugPrint('❌ [MarketerController] load error: $e');
      _data ??= {'marketer_status': 'none'};
    }
    _isLoading = false;
    update();
  }

  Future<bool> apply({
    required String firstName,
    required String lastName,
    required String phone,
    required String profession,
    XFile? documentFile,
    String? idNumber,
    String? notes,
  }) async {
    _isSubmitting = true;
    update();
    bool ok = false;
    try {
      final Map<String, String> body = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'profession': profession,
        'id_number': idNumber ?? phone,
        'notes': notes ?? '',
      };

      Response response;
      if (documentFile != null) {
        response = await apiClient.postMultipartData(
          '/api/v1/customer/marketer/apply',
          body,
          [MultipartBody('id_image', documentFile)],
        );
      } else {
        response = await apiClient.postData(
          '/api/v1/customer/marketer/apply',
          body,
        );
      }

      if (response.statusCode == 200) {
        ok = true;
        await loadDashboard();
      }
    } catch (e) {
      debugPrint('Marketer apply error: $e');
    }
    _isSubmitting = false;
    update();
    return ok;
  }
}
