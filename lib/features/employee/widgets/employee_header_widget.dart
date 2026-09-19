import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import '../controllers/employee_shift_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class EmployeeHeaderWidget extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const EmployeeHeaderWidget({super.key, this.onNotificationTap});

  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF555555);
  static const Color _iconBg = Color(0xFFF6F5F8);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final name = controller.shiftModel.employeeName;
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
                        color: _iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            IconlyLight.notification,
                            size: 22,
                            color: _darkText,
                          ),
                          // Unread notification badge dot if there are warnings or alerts
                          if (controller.warnings.isNotEmpty)
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
                '${'hello'.tr} $name',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ready_to_start_day'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _subText,
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

