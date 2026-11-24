import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'offline_visit_storage_service.dart';

class OfflineVisitSyncManager extends GetxController {
  static OfflineVisitSyncManager get to => Get.find<OfflineVisitSyncManager>();

  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxString lastSyncMessage = ''.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    refreshPendingCount();
    _initConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && pendingCount.value > 0 && !isSyncing.value) {
        debugPrint('🌐 [OfflineVisitSyncManager] Network restored. Triggering auto sync...');
        syncPendingVisits();
      }
    });
  }

  Future<void> refreshPendingCount() async {
    pendingCount.value = await OfflineVisitStorageService.getPendingCount();
  }

  /// Manually or automatically trigger sync for all locally saved visits
  Future<int> syncPendingVisits() async {
    if (isSyncing.value) return 0;

    final pendingList = await OfflineVisitStorageService.getPendingVisits();
    if (pendingList.isEmpty) {
      pendingCount.value = 0;
      return 0;
    }

    if (!Get.isRegistered<ApiClient>()) {
      debugPrint('⚠️ [OfflineVisitSyncManager] ApiClient not registered.');
      return 0;
    }

    isSyncing.value = true;
    int successCount = 0;

    for (final item in pendingList) {
      if (item.syncStatus == 'syncing') continue;

      try {
        await OfflineVisitStorageService.updateVisitStatus(item.clientUuid, 'syncing');

        final apiClient = Get.find<ApiClient>();
        final multipartFiles = <MultipartBody>[];

        if (item.frontImagePath != null && File(item.frontImagePath!).existsSync()) {
          multipartFiles.add(MultipartBody('front_image_0', XFile(item.frontImagePath!)));
        }
        if (item.insideImagePath != null && File(item.insideImagePath!).existsSync()) {
          multipartFiles.add(MultipartBody('inside_image_0', XFile(item.insideImagePath!)));
        }
        if (item.contractSignaturePath != null && File(item.contractSignaturePath!).existsSync()) {
          multipartFiles.add(MultipartBody('contract_signature_0', XFile(item.contractSignaturePath!)));
        }

        final payload = {
          'visits': [item.toJson()],
        };

        final Response res;
        if (multipartFiles.isNotEmpty) {
          final fields = <String, String>{
            'visits': jsonEncode(payload['visits']),
          };
          res = await apiClient.postMultipartData('/api/v1/customer/marketer/visits/sync-batch', fields, multipartFiles);
        } else {
          res = await apiClient.postData('/api/v1/customer/marketer/visits/sync-batch', payload);
        }

        if (res.statusCode == 200 && res.body != null && res.body['status'] == 'success') {
          await OfflineVisitStorageService.removeVisit(item.clientUuid);
          successCount++;
          debugPrint('✅ [OfflineVisitSyncManager] Synced visit: ${item.storeName} (${item.clientUuid})');
        } else {
          final errorMsg = res.body?['message'] ?? 'فشلت مزامنة الزيارة مع الخادم';
          await OfflineVisitStorageService.updateVisitStatus(item.clientUuid, 'failed', error: errorMsg);
        }
      } catch (e) {
        debugPrint('❌ [OfflineVisitSyncManager] Error syncing ${item.clientUuid}: $e');
        await OfflineVisitStorageService.updateVisitStatus(item.clientUuid, 'failed', error: e.toString());
      }
    }

    isSyncing.value = false;
    await refreshPendingCount();

    if (successCount > 0) {
      lastSyncMessage.value = 'تمت مزامنة $successCount زيارات معلقة بنجاح';
    }

    return successCount;
  }
}
