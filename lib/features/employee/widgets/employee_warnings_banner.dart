import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';
import 'employee_warnings_bottom_sheet.dart';

class EmployeeWarningsBanner extends StatelessWidget {
  final bool? isDark;
  const EmployeeWarningsBanner({super.key, this.isDark});

  static const Color _redColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final redBg = dark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final warnings = controller.warnings;
        final int count = controller.shiftModel.warningCount > 0
            ? controller.shiftModel.warningCount
            : warnings.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: () {
              EmployeeWarningsBottomSheet.show(context, warnings);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: redBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title (Right in RTL)
                  Text(
                    'warnings'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _redColor,
                    ),
                  ),

                  // Badge (Left in RTL)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _redColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count ${'warning_single'.tr}',
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
            ),
          ),
        );
      },
    );
  }
}
