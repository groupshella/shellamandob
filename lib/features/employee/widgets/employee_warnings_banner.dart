import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_shift_controller.dart';
import 'employee_warnings_bottom_sheet.dart';

class EmployeeWarningsBanner extends StatelessWidget {
  const EmployeeWarningsBanner({super.key});

  static const Color _redColor = Color(0xFFDC2626);
  static const Color _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final warnings = controller.warnings;
        final int count = controller.shiftModel.warningCount > 0
            ? controller.shiftModel.warningCount
            : warnings.length;

        if (count == 0 && warnings.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              if (warnings.isNotEmpty) {
                EmployeeWarningsBottomSheet.show(context, warnings);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _redBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title (Start)
                  Text(
                    'warnings'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _redColor,
                    ),
                  ),

                  // Badge (End)
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
