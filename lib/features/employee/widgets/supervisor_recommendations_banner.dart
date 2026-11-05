import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
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
                // Right side in RTL - Title only (without numeric circle badge per Figma)
                Text(
                  'supervisor_recommendations'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),

                // Left side in RTL - Left-pointing chevron (<) matching Figma
                Icon(
                  IconlyLight.arrowLeft2,
                  size: 20,
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
