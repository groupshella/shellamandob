import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';

class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF111B18),
                  ),
                ),
                const Spacer(),
                Text(
                  'new_chat'.tr,
                  style: const TextStyle(
                    color: Color(0xFF111B18),
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    height: 1.60,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40), // Balance the back button
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Contact Admin Option
            _buildOptionCard(
              title: 'contact_shela_admin'.tr,
              subtitle: 'contact_admin_subtitle'.tr,
              bgColor: const Color(0xFFF1EEF8),
              onTap: () {
                Get.toNamed(RouteHelper.getChatRoute(
                  notificationBody: NotificationBodyModel(
                    notificationType: NotificationType.message,
                    adminId: 0,
                    name: 'الدعم الفني',
                  ),
                ));
              },
            ),
            const SizedBox(height: 16),
            // Contact Specific Store Option
            _buildOptionCard(
              title: 'contact_specific_store'.tr,
              subtitle: 'contact_store_subtitle'.tr,
              bgColor: const Color(0xFFEEF2FC),
              onTap: () {
                Get.toNamed(RouteHelper.chatSearch);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              Images.messages_v2,
              width: 24,
              height: 24,
              color: const Color(0xFF111B18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111B18),
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      height: 1.60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                      height: 1.60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF707784),
            ),
          ],
        ),
      ),
    );
  }
}
