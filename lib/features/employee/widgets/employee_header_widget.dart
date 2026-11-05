import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../models/employee_shift_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';

class EmployeeHeaderWidget extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final bool? isDark;

  const EmployeeHeaderWidget({
    super.key,
    this.onNotificationTap,
    this.isDark,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
    final iconBg = dark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        String name = controller.shiftModel.employeeName;
        if (name.trim().isEmpty && Get.isRegistered<ProfileController>()) {
          final userInfo = Get.find<ProfileController>().userInfoModel;
          if (userInfo != null) {
            name = '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim();
          }
        }
        final String greeting = name.trim().isNotEmpty ? '${'hello'.tr} $name' : 'hello'.tr;
        final bool hasWarnings = controller.shiftModel.warningCount > 0 || controller.warnings.isNotEmpty;
        bool hasUnreadNotif = false;
        if (Get.isRegistered<NotificationController>()) {
          final notifCtrl = Get.find<NotificationController>();
          hasUnreadNotif = notifCtrl.hasUnread.value || notifCtrl.hasNotification;
        }
        final bool showBadge =
            hasWarnings || hasUnreadNotif || controller.status == ShiftStatus.onBreak;
        final bool isNotStarted = controller.status == ShiftStatus.notStarted;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Notification button on the far Left in RTL (Figma 1:1)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: onNotificationTap ?? () => Get.toNamed(RouteHelper.getNotificationRoute()),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          IconlyLight.notification,
                          size: 22,
                          color: darkText,
                        ),
                        if (showBadge)
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: _primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Row 2: Greeting & Conditional Subtitle on the Right in RTL (Figma 1:1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isNotStarted) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ready_to_start_day'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
