import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import '../controllers/employee_shift_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class EmployeeHeaderWidget extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final bool? isDark;

  const EmployeeHeaderWidget({
    super.key,
    this.onNotificationTap,
    this.isDark,
  });

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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action: Notification button only (matching Figma)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
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
                          // Unread notification badge dot if there are warnings or alerts
                          if (hasWarnings)
                            Positioned(
                              top: 10,
                              right: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(), // Keeps the button properly aligned
                ],
              ),
              const SizedBox(height: 12),

              // Greeting & Question
              Text(
                greeting,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ready_to_start_day'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: subText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

