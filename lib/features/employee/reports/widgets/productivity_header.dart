import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

class ProductivityHeader extends StatelessWidget {
  final String dateText;
  final VoidCallback onCalendarTap;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const ProductivityHeader({
    super.key,
    required this.dateText,
    required this.onCalendarTap,
    this.onBackTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final headerBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final dateBarBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return Container(
          color: headerBg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Top Title Row
              Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back_ios
                            : Icons.arrow_back_ios_new,
                        size: 20,
                        color: textColor,
                      ),
                      onPressed: onBackTap,
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'productivity_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 12),

              // Date Bar with Calendar Icon
              InkWell(
                onTap: onCalendarTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: dateBarBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateText,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        IconlyLight.calendar,
                        size: 20,
                        color: textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
