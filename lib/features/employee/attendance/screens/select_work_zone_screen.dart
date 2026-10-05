import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import '../controllers/attendance_controller.dart';
import '../../services/marketer_shift_service.dart';
import 'attendance_stepper_screen.dart';

class SelectWorkZoneScreen extends StatelessWidget {
  const SelectWorkZoneScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MarketerShiftService>()) {
      Get.put(MarketerShiftService(apiClient: Get.find()), permanent: true);
    }
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121418) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final selectedCardBg = isDark ? const Color(0xFF1B3822) : const Color(0xFFF1FBF2);
    final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB);
    final radioBorder = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : _subText;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            MarketerHeader(title: 'select_work_area'.tr),

            Expanded(
              child: GetBuilder<AttendanceController>(
                builder: (controller) {
                  if (controller.isLoadingZones) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subtitles or Locked Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (controller.isZoneLocked) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedCardBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _primaryGreen.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_rounded, color: _primaryGreen, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${'work_zone_locked'.tr}: ${controller.selectedZone?.name ?? ''}',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              'choose_zone_before_tour'.tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'must_be_within_specified_range'.tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // List of zones
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: controller.zones.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final zone = controller.zones[index];
                            final isSelected = controller.selectedZone?.id == zone.id;

                            return InkWell(
                              onTap: controller.isZoneLocked
                                  ? null
                                  : () => controller.selectZone(zone),
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedCardBg : cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? _primaryGreen : borderColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Radio circle (Left in RTL)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? _primaryGreen : radioBorder,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _primaryGreen,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),

                                    // Zone details (Right in RTL)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          zone.name,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? _primaryGreen : textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${zone.plannedVisits} ${'planned_visits'.tr}',
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 12,
                                            color: textSub,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom CTA
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.selectedZone == null
                                ? null
                                : () {
                                    if (controller.isZoneLocked) {
                                      Get.to(() => const AttendanceStepperScreen());
                                    } else {
                                      _showZoneLockModal(context, controller);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              controller.isZoneLocked
                                  ? 'continue_to_attendance'.tr
                                  : 'confirm_work_zone'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showZoneLockModal(BuildContext context, AttendanceController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1B3822) : const Color(0xFFF1FBF2);
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : _subText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GetBuilder<AttendanceController>(
        builder: (attCtrl) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'confirm_work_zone'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'confirm_zone_lock_notice'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: textSub,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Zone Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      attCtrl.selectedZone?.name ?? '',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${attCtrl.selectedZone?.plannedVisits ?? 0} ${'planned_visits'.tr}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        color: textSub,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button 1: تأكيد المنطقة
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: attCtrl.isLockingZone
                      ? null
                      : () async {
                          await attCtrl.lockZoneApi(
                            onSuccess: () {
                              Navigator.of(ctx).pop();
                              Get.to(() => const AttendanceStepperScreen());
                            },
                            onError: (error) {
                              showCustomSnackBar(error, isError: true);
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: attCtrl.isLockingZone
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'confirm_zone_btn'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Button 2: العودة للاختيار
              SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: attCtrl.isLockingZone ? null : () => Navigator.of(ctx).pop(),
                  child: Text(
                    'back_to_selection'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textSub,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
