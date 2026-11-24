import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/offline_visit_sync_manager.dart';

class OfflineSyncBannerWidget extends StatelessWidget {
  const OfflineSyncBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OfflineVisitSyncManager>()) {
      Get.put(OfflineVisitSyncManager());
    }

    final syncManager = Get.find<OfflineVisitSyncManager>();

    return Obx(() {
      final count = syncManager.pendingCount.value;
      if (count == 0) return const SizedBox.shrink();

      final isSyncing = syncManager.isSyncing.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF0C7), // warm warning light amber
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFEDF89)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF79009),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'يوجد $count زيارة محفوظة محلياً بدون إنترنت',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A271A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ستتم المزامنة تلقائياً عند استعادة الاتصال',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF93370D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isSyncing
                  ? null
                  : () async {
                      final synced = await syncManager.syncPendingVisits();
                      if (synced > 0) {
                        Get.snackbar(
                          'نجاح المزامنة',
                          'تمت مزامنة $synced زيارات مع الخادم بنجاح',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF027A48),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB54708),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'مزامنة الآن',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
