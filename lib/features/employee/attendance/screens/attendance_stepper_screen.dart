import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import '../../controllers/employee_navigation_controller.dart';
import '../../controllers/employee_shift_controller.dart';
import '../../models/employee_shift_model.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/attendance_geofence_map_widget.dart';

class AttendanceStepperScreen extends StatelessWidget {
  const AttendanceStepperScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(
      builder: (controller) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = isDark ? const Color(0xFF121418) : Colors.white;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                MarketerHeader(title: 'confirm_attendance'.tr),

                // 3-Step Stepper Bar
                _buildStepperBar(controller.currentStep, isDark),

                // Step Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentStep(context, controller, isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Stepper Header: 1: الموقع, 2: الصورة, 3: تأكيد
  Widget _buildStepperBar(int currentStep, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3. تأكيد
          _buildStepNode(
            index: 2,
            title: 'confirm_label'.tr,
            icon: Icons.check,
            isActive: currentStep == 2,
            isCompleted: currentStep > 2,
            isDark: isDark,
          ),
          _buildStepConnector(isCompleted: currentStep >= 2, isDark: isDark),

          // 2. الصورة
          _buildStepNode(
            index: 1,
            title: 'photo_label'.tr,
            icon: IconlyLight.camera,
            isActive: currentStep == 1,
            isCompleted: currentStep > 1,
            isDark: isDark,
          ),
          _buildStepConnector(isCompleted: currentStep >= 1, isDark: isDark),

          // 1. الموقع
          _buildStepNode(
            index: 0,
            title: 'location_label'.tr,
            icon: IconlyLight.location,
            isActive: currentStep == 0,
            isCompleted: currentStep > 0,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int index,
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
    required bool isDark,
  }) {
    Color circleColor;
    Color iconColor;

    if (isActive) {
      circleColor = _primaryGreen;
      iconColor = Colors.white;
    } else if (isCompleted) {
      circleColor = isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB);
      iconColor = isDark ? const Color(0xFF4CAF50) : _primaryGreen;
    } else {
      circleColor = isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6);
      iconColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    }

    final borderColor = isActive || isCompleted
        ? _primaryGreen
        : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB));
    final textColor = isActive
        ? _primaryGreen
        : (isDark ? const Color(0xFF9CA3AF) : _subText);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted, required bool isDark}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isCompleted
            ? _primaryGreen
            : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, AttendanceController controller, bool isDark) {
    switch (controller.currentStep) {
      case 0:
        return _buildGeofenceStep(context, controller, isDark);
      case 1:
        return _buildSelfieStep(context, controller, isDark);
      case 2:
      default:
        return _buildSuccessStep(context, controller, isDark);
    }
  }

  // STEP 1: الموقع والجغرافيا (Geofence View)
  Widget _buildGeofenceStep(BuildContext context, AttendanceController controller, bool isDark) {
    final isInside = controller.geofenceStatus == GeofenceStatus.inside;
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : _subText;
    final statusBg = isInside
        ? (isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB))
        : (isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFEECEB));
    final statusColor = isInside
        ? (isDark ? const Color(0xFF4CAF50) : _primaryGreen)
        : const Color(0xFFE53935);
    final outlineBorder = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'confirm_your_location'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'must_be_within_specified_range'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: textSub,
            ),
          ),
          const SizedBox(height: 20),

          // Google Map Geofence Container
          const AttendanceGeofenceMapWidget(),

          const SizedBox(height: 16),

          // Status Banner (Inside or Error)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isInside ? Icons.check_circle : Icons.error_outline,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isInside ? 'you_are_inside_geofence'.tr : 'outside_geofence_error'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Action Buttons
          if (isInside) ...[
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.setStep(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'continue_label'.tr.isNotEmpty ? 'continue_label'.tr : 'continue'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => controller.checkGeofence(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'try_again'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => _showChangeZoneBottomSheet(context, controller),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: outlineBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'request_change_zone'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 2: التقاط صورة التحقق الذاتية (Selfie Verification View)
  Widget _buildSelfieStep(BuildContext context, AttendanceController controller, bool isDark) {
    final hasPhoto = controller.selfieImage != null;
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : _subText;
    final frameBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFF9FAFB);
    final frameBorder = hasPhoto
        ? _primaryGreen
        : (isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB));
    final badgeBg = isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB);
    final badgeColor = isDark ? const Color(0xFF4CAF50) : _primaryGreen;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'take_verification_photo'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'take_verification_photo_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: textSub,
            ),
          ),
          const SizedBox(height: 24),

          // Camera Frame Container (Clickable)
          Center(
            child: GestureDetector(
              onTap: () => controller.captureSelfie(),
              child: Container(
                width: 290,
                height: 310,
                decoration: BoxDecoration(
                  color: frameBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: frameBorder,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: hasPhoto
                      ? Image.file(
                          File(controller.selfieImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle, color: Colors.green, size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    'front_camera'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Icon(
                              IconlyLight.camera,
                              size: 64,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'tap_to_capture_selfie'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: textSub,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (hasPhoto) ...[
            // Green badge: تم التقاط الصورة
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 18, color: badgeColor),
                  const SizedBox(width: 8),
                  Text(
                    'photo_captured'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Button 1: متابعة
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.completeAttendance(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'continue_label'.tr.isNotEmpty ? 'continue_label'.tr : 'continue'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Button 2: إعادة التقاط الصورة
            TextButton(
              onPressed: () => controller.captureSelfie(),
              child: Text(
                'retake_photo'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textSub,
                ),
              ),
            ),
          ] else ...[
            // Button: التقاط الصورة
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => controller.captureSelfie(),
                icon: const Icon(IconlyLight.camera, color: Colors.white, size: 20),
                label: Text(
                  'capture_photo'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Secondary option: اختيار من المعرض
            TextButton.icon(
              onPressed: () => controller.captureSelfie(fromGallery: true),
              icon: Icon(IconlyLight.image, size: 18, color: textSub),
              label: Text(
                'choose_from_gallery'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSub,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 3: شاشة نجاح وتأكيد بداية العمل (Success View)
  Widget _buildSuccessStep(BuildContext context, AttendanceController controller, bool isDark) {
    final attendanceDateTime = controller.attendanceConfirmedTime ?? DateTime.now();
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : _subText;
    final glowColor = isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB);
    final cardBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFF1FBF2);
    final cardBorder = _primaryGreen.withValues(alpha: isDark ? 0.35 : 0.2);

    // Dynamic Start Time
    String formattedTime = '';
    if (Get.isRegistered<EmployeeShiftController>()) {
      final shiftModel = Get.find<EmployeeShiftController>().shiftModel;
      if (shiftModel.status == ShiftStatus.active &&
          shiftModel.startTimeText.isNotEmpty &&
          shiftModel.startTimeText != '--:--') {
        formattedTime = shiftModel.localizedStartTime;
      }
    }
    if (formattedTime.isEmpty) {
      formattedTime = DateFormat('hh:mm a', Get.locale?.languageCode ?? 'ar').format(attendanceDateTime);
    }

    // Dynamic Date
    final formattedDate = DateFormat('EEEE، d MMMM y', Get.locale?.languageCode ?? 'ar').format(attendanceDateTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Giant Green Checkmark with glow
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor,
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryGreen,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 42),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'work_start_confirmed_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'work_start_confirmed_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Start Time Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  'shift_start_time'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Final Button: استكشاف الزيارات الميدانية
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (Get.isRegistered<EmployeeShiftController>()) {
                  Get.find<EmployeeShiftController>().startShift();
                }
                Get.until((route) => route.settings.name == RouteHelper.employeeMain || route.isFirst);
                if (Get.isRegistered<EmployeeNavigationController>()) {
                  Get.find<EmployeeNavigationController>().changeIndex(1); // go to visits tab
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
                'explore_field_visits'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Change Zone Bottom Sheet
  void _showChangeZoneBottomSheet(BuildContext context, AttendanceController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final inputBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : _subText;
    String selectedReason = 'wrong_zone_selected'.tr;
    final TextEditingController notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
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
                  'request_change_zone'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'change_request_supervisor_notice'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 20),

                // Reason dropdown
                Text(
                  'reason_for_change'.tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      dropdownColor: sheetBg,
                      isExpanded: true,
                      items: [
                        'wrong_zone_selected'.tr,
                        'redistribute_visits'.tr,
                        'supervisor_request'.tr,
                        'other_reason'.tr,
                      ].map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: textDark,
                              ),
                            ),
                          )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedReason = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes input
                Text(
                  'additional_note_optional'.tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Tajawal', color: textDark),
                  decoration: InputDecoration(
                    hintText: 'add_details_if_needed'.tr,
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.submitChangeZoneRequest(
                        reason: selectedReason,
                        notes: notesCtrl.text,
                      );
                      Navigator.of(ctx).pop();
                      Get.snackbar(
                        'request_sent_title'.tr,
                        'request_sent_waiting_supervisor'.tr,
                        backgroundColor: _primaryGreen,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'send_request_to_supervisor'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'cancel'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
