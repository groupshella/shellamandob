import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/core/network/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class MonthlyScorecardController extends GetxController implements GetxService {
  final ApiClient apiClient;
  MonthlyScorecardController({required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedMonth = DateTime.now().toIso8601String().substring(0, 7);
  String get selectedMonth => _selectedMonth;

  Map<String, dynamic>? _scorecardData;
  Map<String, dynamic>? get scorecardData => _scorecardData;

  Map<String, dynamic>? _leaderboardData;
  Map<String, dynamic>? get leaderboardData => _leaderboardData;

  int _selectedTabIndex = 0; // 0: أدائي الشهري, 1: لوحة المتصدرين
  int get selectedTabIndex => _selectedTabIndex;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetchScorecard(_selectedMonth);
  }

  void changeMonth(String month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      fetchScorecard(month);
    }
  }

  Future<void> fetchScorecard(String month) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await apiClient.getData(
        '${AppConstants.marketerScorecardUri}?month=$month',
      );

      if (response.statusCode == 200 && response.body != null && response.body['data'] != null) {
        final data = response.body['data'];
        _scorecardData = data['scorecard'] != null ? Map<String, dynamic>.from(data['scorecard']) : null;
        _leaderboardData = data['leaderboard'] != null ? Map<String, dynamic>.from(data['leaderboard']) : null;
      } else {
        _errorMessage = response.body?['message']?.toString() ?? 'failed_to_load_scorecard'.tr;
      }
    } catch (e) {
      debugPrint('Error fetching monthly scorecard: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> refreshCurrentMonth() async {
    await fetchScorecard(_selectedMonth);
  }
}
