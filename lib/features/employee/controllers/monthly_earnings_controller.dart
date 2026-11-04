import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/core/network/api_client.dart';
import 'package:sixam_mart/features/employee/models/monthly_earnings_model.dart';

class MonthlyEarningsController extends GetxController implements GetxService {
  final ApiClient apiClient;
  MonthlyEarningsController({required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedMonth = DateTime.now().toIso8601String().substring(0, 7);
  String get selectedMonth => _selectedMonth;

  MonthlyEarningsModel? _earningsData;
  MonthlyEarningsModel? get earningsData => _earningsData;

  @override
  void onInit() {
    super.onInit();
    fetchMonthlyEarnings(_selectedMonth);
  }

  void changeMonth(String month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      fetchMonthlyEarnings(month);
    }
  }

  Future<void> fetchMonthlyEarnings(String month) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await apiClient.getData(
        '/api/v1/customer/marketer/earnings/monthly?month=$month',
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        final data = body['data'] is Map<String, dynamic> ? body['data'] : body;
        _earningsData = MonthlyEarningsModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        _errorMessage = response.body?['message']?.toString() ?? 'فشل تحميل بيانات المستحقات الشهرية';
      }
    } catch (e) {
      debugPrint('Error fetching monthly earnings: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> refreshCurrentMonth() async {
    await fetchMonthlyEarnings(_selectedMonth);
  }
}

