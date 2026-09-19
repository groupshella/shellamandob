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
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                MarketerHeader(title: 'confirm_attendance'.tr),

                // 3-Step Stepper Bar
                _buildStepperBar(controller.currentStep),

                // Step Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentStep(context, controller),
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
  Widget _buildStepperBar(int currentStep) {
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
          ),
          _buildStepConnector(isCompleted: currentStep >= 2),

          // 2. الصورة
          _buildStepNode(
            index: 1,
            title: 'photo_label'.tr,
            icon: IconlyLight.camera,
            isActive: currentStep == 1,
            isCompleted: currentStep > 1,
          ),
          _buildStepConnector(isCompleted: currentStep >= 1),

          // 1. الموقع
          _buildStepNode(
            index: 0,
            title: 'location_label'.tr,
            icon: IconlyLight.location,
            isActive: currentStep == 0,
            isCompleted: currentStep > 0,
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
  }) {
    Color circleColor;
    Color iconColor;

    if (isActive) {
      circleColor = _primaryGreen;
      iconColor = Colors.white;
    } else if (isCompleted) {
      circleColor = const Color(0xFFEBFEEB);
      iconColor = _primaryGreen;
    } else {
      circleColor = const Color(0xFFF3F4F6);
      iconColor = const Color(0xFF9CA3AF);
    }

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
              color: isActive || isCompleted ? _primaryGreen : const Color(0xFFE5E7EB),
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
            color: isActive ? _primaryGreen : _subText,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isCompleted ? _primaryGreen : const Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, AttendanceController controller) {
    switch (controller.currentStep) {
      case 0:
        return _buildGeofenceStep(context, controller);
      case 1:
        return _buildSelfieStep(context, controller);
      case 2:
      default:
        return _buildSuccessStep(context, controller);
    }
  }

  // STEP 1: الموقع والجغرافيا (Geofence View)
  Widget _buildGeofenceStep(BuildContext context, AttendanceController controller) {
    final isInside = controller.geofenceStatus == GeofenceStatus.inside;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تأكيد موقعك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'يجب أن تكون داخل النطاق المحدد لبدء الدوام.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: _subText,
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
              color: isInside ? const Color(0xFFEBFEEB) : const Color(0xFFFEECEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isInside ? Icons.check_circle : Icons.error_outline,
                  size: 18,
                  color: isInside ? _primaryGreen : const Color(0xFFE53935),
                ),
                const SizedBox(width: 8),
                Text(
                  isInside ? 'أنت داخل النطاق' : 'حدث خطأ ما (خارج النطاق)',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isInside ? _primaryGreen : const Color(0xFFE53935),
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
                child: const Text(
                  'متابعة',
                  style: TextStyle(
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
                child: const Text(
                  'حاول مرة أخرى',
                  style: TextStyle(
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
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'طلب تغيير المنطقة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
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
  Widget _buildSelfieStep(BuildContext context, AttendanceController controller) {
    final hasPhoto = controller.selfieImage != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'التقاط صورة التحقق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'التقط صورة مباشرة للتحقق من حضورك ومظهرك المهني.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: _subText,
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
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: hasPhoto ? _primaryGreen : const Color(0xFFE5E7EB),
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
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: Colors.green, size: 8),
                                  SizedBox(width: 6),
                                  Text(
                                    'كاميرا أمامية',
                                    style: TextStyle(
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
                            const Text(
                              'اضغط للالتقاط بكاميرا السيلفي',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: _subText,
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
                color: const Color(0xFFEBFEEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 18, color: _primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'تم التقاط الصورة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
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
                child: const Text(
                  'متابعة',
                  style: TextStyle(
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
              child: const Text(
                'إعادة التقاط الصورة',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _subText,
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
                label: const Text(
                  'التقاط الصورة',
                  style: TextStyle(
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
              icon: const Icon(IconlyLight.image, size: 18, color: _subText),
              label: const Text(
                'أو اختيار صورة من المعرض',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _subText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 3: شاشة نجاح وتأكيد بداية العمل (Success View)
  Widget _buildSuccessStep(BuildContext context, AttendanceController controller) {
    final attendanceDateTime = controller.attendanceConfirmedTime ?? DateTime.now();

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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEBFEEB),
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
          const Text(
            'تم تأكيد بداية العمل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          const Text(
            'تم تأكيد بداية العمل، نلفت انتباهك أن سبب التقاط الصورة هو التأكد من المظهر العام والمهنية.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _subText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Start Time Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FBF2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'وقت بدء العمل',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: _subText,
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
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: _subText,
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
              child: const Text(
                'استكشاف الزيارات الميدانية',
                style: TextStyle(
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
    String selectedReason = 'خطأ في اختيار المنطقة';
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'طلب تغيير المنطقة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'سيتم إرسال الطلب للمشرف للموافقة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: _subText,
                  ),
                ),
                const SizedBox(height: 20),

                // Reason dropdown
                const Text(
                  'سبب التغيير',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F5F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      items: [
                        'خطأ في اختيار المنطقة',
                        'إعادة توزيع الزيارات',
                        'طلب من المشرف',
                        'سبب آخر',
                      ].map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: _darkText,
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
                const Text(
                  'ملاحظة إضافية (اختياري)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'add_details_if_needed'.tr,
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: const Color(0xFFF6F5F8),
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
                        'تم إرسال الطلب',
                        'بانتظار موافقة المشرف، سيتم إشعارك فور الاعتماد.',
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
                    child: const Text(
                      'إرسال الطلب للمشرف',
                      style: TextStyle(
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
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _subText,
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
