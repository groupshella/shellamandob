import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Top Title Row
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF111B18)),
                  onPressed: onBackTap,
                )
              else
                const SizedBox(width: 40),
              Expanded(
                child: Text(
                  'productivity_title'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111B18),
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
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111B18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    IconlyLight.calendar,
                    size: 20,
                    color: Color(0xFF111B18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
