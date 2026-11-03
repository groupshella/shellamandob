import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/core/network/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/employee/network/models/network_models.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class MyNetworkController extends GetxController implements GetxService {
  final ApiClient apiClient;

  MyNetworkController({required this.apiClient});

  bool _isLoadingOverview = false;
  bool _isLoadingList = false;
  bool _isScheduling = false;
  String _selectedFilter = 'all'; // all, active, idle, near_milestone
  String _searchQuery = '';

  NetworkOverviewModel? _overview;
  List<SupervisedMarketerModel> _marketers = [];

  bool get isLoadingOverview => _isLoadingOverview;
  bool get isLoadingList => _isLoadingList;
  bool get isScheduling => _isScheduling;
  String get selectedFilter => _selectedFilter;
  NetworkOverviewModel? get overview => _overview;
  List<SupervisedMarketerModel> get marketers => _marketers;

  @override
  void onInit() {
    super.onInit();
    fetchNetworkData();
  }

  Future<void> fetchNetworkData() async {
    await Future.wait([
      fetchOverview(),
      fetchMarketers(),
    ]);
  }

  Future<void> fetchOverview() async {
    _isLoadingOverview = true;
    update();
    try {
      Response response = await apiClient.getData(AppConstants.marketerNetworkOverviewUri);
      if (response.statusCode == 200 && response.body['status'] == 'success') {
        _overview = NetworkOverviewModel.fromJson(response.body['data']);
      }
    } catch (e) {
      debugPrint('Error fetching network overview: $e');
    } finally {
      _isLoadingOverview = false;
      update();
    }
  }

  Future<void> fetchMarketers() async {
    _isLoadingList = true;
    update();
    try {
      String uri = '${AppConstants.marketerNetworkListUri}?status=$_selectedFilter';
      if (_searchQuery.trim().isNotEmpty) {
        uri += '&search=${Uri.encodeComponent(_searchQuery.trim())}';
      }
      Response response = await apiClient.getData(uri);
      if (response.statusCode == 200 && response.body['status'] == 'success') {
        List<dynamic> list = response.body['data']['marketers'] ?? [];
        _marketers = list.map((m) => SupervisedMarketerModel.fromJson(m)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching marketers list: $e');
    } finally {
      _isLoadingList = false;
      update();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      fetchMarketers();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchMarketers();
  }

  Future<bool> scheduleActivationVisit({
    required int subMarketerId,
    required DateTime date,
    String? notes,
  }) async {
    _isScheduling = true;
    update();
    try {
      Map<String, dynamic> body = {
        'sub_marketer_id': subMarketerId,
        'scheduled_date': date.toIso8601String().substring(0, 19).replaceAll('T', ' '),
        'notes': notes ?? '',
      };
      Response response = await apiClient.postData(
        AppConstants.marketerScheduleActivationVisitUri,
        body,
      );
      if (response.statusCode == 200 && response.body['status'] == 'success') {
        showCustomSnackBar('activation_visit_scheduled_success'.tr, isError: false);
        return true;
      } else {
        showCustomSnackBar(response.body['message'] ?? 'failed_to_schedule_visit'.tr, isError: true);
        return false;
      }
    } catch (e) {
      showCustomSnackBar('error_occurred'.tr, isError: true);
      return false;
    } finally {
      _isScheduling = false;
      update();
    }
  }
}
