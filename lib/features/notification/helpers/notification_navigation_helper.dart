import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/employee/controllers/employee_navigation_controller.dart';
import 'package:sixam_mart/features/employee/screens/employee_vacations_screen.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// Routes a tapped notification to the most relevant screen based on its type.
class NotificationNavigationHelper {
  const NotificationNavigationHelper._();

  static void open(NotificationModel model) {
    final type = (model.data?.type ?? '').toLowerCase();
    final title = model.data?.title ?? '';
    final desc = model.data?.description ?? '';
    final text = '$title $desc'.trim().toLowerCase();

    bool has(List<String> keys) =>
        keys.any((k) => type.contains(k) || text.contains(k));

    // 1. Marketer Leave / Vacations / Permissions
    if (type == 'leave_status' ||
        type == 'marketer_leave_status' ||
        type == 'leave' ||
        type == 'vacation' ||
        type == 'permission' ||
        has(['إجازة', 'إجازه', 'استئذان', 'اجازة', 'مرضية', 'سنوية'])) {
      Get.to(() => const EmployeeVacationsScreen());
      return;
    }

    // 1.1. Marketer Zone Update (تحديث النطاق الجغرافي)
    if (type == 'marketer_zone_updated' ||
        type == 'zone_update' ||
        type == 'zone' ||
        has(['نطاق', 'منطقة', 'زون', 'zone'])) {
      if (Get.isRegistered<EmployeeNavigationController>()) {
        Get.find<EmployeeNavigationController>().changeIndex(1);
      }
      _showDetailDialog(
        title: title.isNotEmpty ? title : 'تحديث النطاق الجغرافي',
        description: desc.isNotEmpty ? desc : 'تم تحديث نطاق عملك الميداني من قبل الإدارة.',
        icon: Icons.map_outlined,
        iconColor: const Color(0xFF30913F),
      );
      return;
    }

    // 2. Recommendations from Admin
    if (type == 'recommendation' || has(['توصية', 'توصيه', 'توجيه'])) {
      _showDetailDialog(
        title: title.isNotEmpty ? title : 'توصية إدارية',
        description: desc,
        icon: Icons.tips_and_updates_outlined,
        iconColor: const Color(0xFF2F73C8),
      );
      return;
    }

    // 3. Warnings / Alerts
    if (type == 'warning' || type == 'alert' || has(['إنذار', 'انذار', 'تنبيه', 'مخالفة'])) {
      _showDetailDialog(
        title: title.isNotEmpty ? title : 'تنبيه إداري',
        description: desc,
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFD64545),
      );
      return;
    }

    // 4. Visits / Follow-ups / Contracts
    if (type == 'visit' ||
        type == 'followup' ||
        type == 'follow_up' ||
        type == 'contract' ||
        has(['متابعة', 'متابعه', 'زيارة', 'زياره', 'عقد', 'اتفاقية'])) {
      if (Get.isRegistered<EmployeeNavigationController>()) {
        Get.find<EmployeeNavigationController>().changeIndex(1);
        Get.back<void>();
      }
      return;
    }

    // 5. Kaidha / Wallet
    if (has(['qidha', 'قيدها'])) {
      Get.toNamed<void>(RouteHelper.getKaidhaWallet());
      return;
    }
    if (has(['wallet', 'fund', 'credit', 'debit', 'loyalty', 'point', 'رصيد', 'محفظ', 'ولاء', 'نقاط'])) {
      Get.toNamed<void>(RouteHelper.getWalletRoute(fromNotification: true));
      return;
    }

    // 6. Generic Detail Dialog for other notifications
    if (title.isNotEmpty || desc.isNotEmpty) {
      _showDetailDialog(
        title: title.isNotEmpty ? title : 'إشعار',
        description: desc,
        icon: Icons.notifications_outlined,
        iconColor: const Color(0xFF30913F),
      );
    }
  }

  static void _showDetailDialog({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF30913F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back<void>(),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
