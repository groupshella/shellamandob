import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/employee_warning_model.dart';

class EmployeeWarningsBottomSheet extends StatelessWidget {
  final List<EmployeeWarningModel> warnings;

  const EmployeeWarningsBottomSheet({super.key, required this.warnings});

  static const Color _redColor = Color(0xFFDC2626);
  static const Color _redBg = Color(0xFFFEE2E2);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF555555);

  static Future<void> show(BuildContext context, List<EmployeeWarningModel> warnings) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EmployeeWarningsBottomSheet(warnings: warnings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Close 'X' and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
              Text(
                'warnings'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkText,
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 20),

          // Warnings Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _redBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row inside container: Title + Pill badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'warnings'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _redColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _redColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${warnings.length} ${'warning_single'.tr}',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Warning items
                ...warnings.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          w.title,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _redColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        w.date,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          color: _subText,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
