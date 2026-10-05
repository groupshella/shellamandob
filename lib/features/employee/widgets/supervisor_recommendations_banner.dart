import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import '../controllers/supervisor_recommendations_controller.dart';

class SupervisorRecommendationsBanner extends StatelessWidget {
  final bool? isDark;
  const SupervisorRecommendationsBanner({super.key, this.isDark});

  static const Color _lightBg = Color(0xFFE8EEFA);
  static const Color _darkBg = Color(0xFF1B283F);
  static const Color _lightText = Color(0xFF0E4AAC);
  static const Color _darkText = Color(0xFF93C5FD);

  @override
  Widget build(BuildContext context) {
    final dark = isDark ??
        (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? _darkBg : _lightBg;
    final primaryColor = dark ? _darkText : _lightText;

    if (!Get.isRegistered<SupervisorRecommendationsController>()) {
      Get.put(SupervisorRecommendationsController());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(RouteHelper.getSupervisorRecommendationsRoute());
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right side in RTL (or left in LTR) - Title
                Row(
                  children: [
                    Text(
                      'supervisor_recommendations'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GetBuilder<SupervisorRecommendationsController>(
                      builder: (recCtrl) {
                        if (recCtrl.unreadCount > 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E4AAC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${recCtrl.unreadCount}',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),

                // Left side in RTL (or right in LTR) - Arrow navigation
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
