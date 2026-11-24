import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/core/network/api_client.dart';
import 'package:sixam_mart/features/employee/models/monthly_earnings_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

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

  // Withdrawal & Wallet State (R15)
  bool _isWithdrawalLoading = false;
  bool get isWithdrawalLoading => _isWithdrawalLoading;

  bool _isSubmittingWithdrawal = false;
  bool get isSubmittingWithdrawal => _isSubmittingWithdrawal;

  double _withdrawableBalance = 0.0;
  double get withdrawableBalance => _withdrawableBalance;

  double _reservedBalance = 0.0;
  double get reservedBalance => _reservedBalance;

  double _lifetimeEarnings = 0.0;
  double get lifetimeEarnings => _lifetimeEarnings;

  double _withdrawnTotal = 0.0;
  double get withdrawnTotal => _withdrawnTotal;

  double _minWithdrawalAmount = 200.0;
  double get minWithdrawalAmount => _minWithdrawalAmount;

  String _processingDurationLabel = '3 أيام';
  String get processingDurationLabel => _processingDurationLabel;

  Map<String, dynamic>? _savedBankInfo;
  Map<String, dynamic>? get savedBankInfo => _savedBankInfo;

  List<dynamic> _withdrawalsHistory = [];
  List<dynamic> get withdrawalsHistory => _withdrawalsHistory;

  @override
  void onInit() {
    super.onInit();
    fetchMonthlyEarnings(_selectedMonth);
    fetchWithdrawalInfo();
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

  /// GET /api/v1/customer/marketer/withdrawals
  Future<void> fetchWithdrawalInfo() async {
    _isWithdrawalLoading = true;
    update();

    try {
      final response = await apiClient.getData(AppConstants.marketerWithdrawalsUri);
      if (response.statusCode == 200 && response.body != null && response.body['data'] != null) {
        final data = response.body['data'];
        _withdrawableBalance = (data['withdrawable_balance'] is num) ? (data['withdrawable_balance'] as num).toDouble() : 0.0;
        _reservedBalance = (data['reserved_balance'] is num) ? (data['reserved_balance'] as num).toDouble() : 0.0;
        _lifetimeEarnings = (data['lifetime_earnings'] is num) ? (data['lifetime_earnings'] as num).toDouble() : 0.0;
        _withdrawnTotal = (data['withdrawn_total'] is num) ? (data['withdrawn_total'] as num).toDouble() : 0.0;

        if (data['saved_bank_info'] != null) {
          _savedBankInfo = Map<String, dynamic>.from(data['saved_bank_info']);
        }

        if (data['withdrawal_settings'] != null) {
          final settings = data['withdrawal_settings'];
          _minWithdrawalAmount = (settings['min_withdrawal_amount'] is num) ? (settings['min_withdrawal_amount'] as num).toDouble() : 200.0;
          _processingDurationLabel = settings['processing_duration_label_ar']?.toString() ?? '3 أيام';
        }

        if (data['withdrawals'] is List) {
          _withdrawalsHistory = List<dynamic>.from(data['withdrawals']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching withdrawal info: $e');
    } finally {
      _isWithdrawalLoading = false;
      update();
    }
  }

  /// POST /api/v1/customer/marketer/withdraw
  Future<bool> submitWithdrawalRequest({
    required double amount,
    required String iban,
    required String beneficiaryName,
    required String bankName,
  }) async {
    if (_isSubmittingWithdrawal) return false;

    if (amount < _minWithdrawalAmount) {
      showCustomSnackBar('${'min_withdraw_limit'.tr}: ${_minWithdrawalAmount.toStringAsFixed(0)} ${'sar'.tr}', isError: true);
      return false;
    }

    if (amount > _withdrawableBalance) {
      showCustomSnackBar('insufficient_withdrawable_balance'.tr, isError: true);
      return false;
    }

    _isSubmittingWithdrawal = true;
    update();

    try {
      final response = await apiClient.postData(
        AppConstants.marketerWithdrawUri,
        {
          'amount': amount,
          'iban': iban.trim(),
          'beneficiary_name': beneficiaryName.trim(),
          'bank_name': bankName.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar(response.body?['message']?.toString() ?? 'withdrawal_request_success'.tr, isError: false);
        await fetchWithdrawalInfo();
        return true;
      } else {
        final msg = response.body?['message']?.toString() ?? 'withdrawal_request_failed'.tr;
        showCustomSnackBar(msg, isError: true);
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting withdrawal request: $e');
      showCustomSnackBar('something_went_wrong'.tr, isError: true);
      return false;
    } finally {
      _isSubmittingWithdrawal = false;
      update();
    }
  }

  Future<void> refreshCurrentMonth() async {
    await fetchMonthlyEarnings(_selectedMonth);
    await fetchWithdrawalInfo();
  }
}


