import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/core/network/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../models/supervisor_recommendation_model.dart';

class SupervisorRecommendationsController extends GetxController implements GetxService {
  final ApiClient? apiClient;

  SupervisorRecommendationsController({ApiClient? client})
      : apiClient = client ?? (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SupervisorRecommendationModel> _recommendations = [];
  List<SupervisorRecommendationModel> get recommendations => _recommendations;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  @override
  void onInit() {
    super.onInit();
    loadRecommendations(notify: false);
  }

  /// Groups recommendations by their dateGroup ('اليوم', 'الأربعاء 26 ,فبراير , 2026', etc.)
  Map<String, List<SupervisorRecommendationModel>> get groupedRecommendations {
    final Map<String, List<SupervisorRecommendationModel>> map = {};
    for (final rec in _recommendations) {
      final group = rec.dateGroup.isNotEmpty ? rec.dateGroup : 'اليوم';
      if (!map.containsKey(group)) {
        map[group] = [];
      }
      map[group]!.add(rec);
    }
    return map;
  }

  Future<void> loadRecommendations({bool notify = true}) async {
    _isLoading = true;
    if (notify) update();

    try {
      final client = apiClient ?? (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null);
      if (client != null) {
        final response = await client.getData(AppConstants.marketerRecommendationsUri);
        if (response.statusCode == 200 && response.body != null) {
          final data = response.body is Map ? response.body['data'] : response.body;
          if (data is Map && data['recommendations'] is List) {
            _recommendations = (data['recommendations'] as List)
                .map((e) => SupervisorRecommendationModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            _totalCount = int.tryParse('${data['total']}') ?? _recommendations.length;
            _unreadCount = int.tryParse('${data['unread']}') ?? 0;
          } else if (response.body is List) {
            _recommendations = (response.body as List)
                .map((e) => SupervisorRecommendationModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            _totalCount = _recommendations.length;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading supervisor recommendations: $e');
    } finally {
      // Keep first item expanded by default
      if (_recommendations.isNotEmpty) {
        _recommendations[0].isExpanded = true;
      }

      _isLoading = false;
      update();
    }
  }

  void toggleExpand(String id) {
    final index = _recommendations.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recommendations[index].isExpanded = !_recommendations[index].isExpanded;
      if (_recommendations[index].isExpanded && !_recommendations[index].isRead) {
        markAsRead(id);
      } else {
        update();
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _recommendations.indexWhere((r) => r.id == id);
    if (index != -1 && !_recommendations[index].isRead) {
      // optimistic update
      final old = _recommendations[index];
      _recommendations[index] = SupervisorRecommendationModel(
        id: old.id,
        supervisorName: old.supervisorName,
        supervisorRole: old.supervisorRole,
        supervisorAvatar: old.supervisorAvatar,
        title: old.title,
        content: old.content,
        isRead: true,
        dateGroup: old.dateGroup,
        isToday: old.isToday,
        timeText: old.timeText,
        createdAt: old.createdAt,
        isExpanded: old.isExpanded,
      );
      if (_unreadCount > 0) _unreadCount--;
      update();

      try {
        final client = apiClient ?? (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null);
        if (client != null && !id.startsWith('notif_')) {
          await client.postData('/api/v1/customer/marketer/recommendations/$id/read', {});
        }
      } catch (e) {
        debugPrint('Error marking recommendation read: $e');
      }
    }
  }

}
