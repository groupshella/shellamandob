import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'visit_summary_screen.dart';

class VisitPhotoDocumentationScreen extends StatelessWidget {
  final StoreVisitModel visit;

  const VisitPhotoDocumentationScreen({
    super.key,
    required this.visit,
  });

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _screenBg = Color(0xFFF8F9FA);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF6B7280);
  static const Color _badgeBg = Color(0xFFFEE2E2);
  static const Color _badgeBorder = Color(0xFFFECACA);
  static const Color _badgeText = Color(0xFFDC2626);
  static const Color _badgeDot = Color(0xFFEF4444);
  static const Color _statusGreenBg = Color(0xFFEBFEEB);

  String _formatCapturedTime(DateTime? time) {
    if (time == null) return '';
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('hh:mm a', lang).format(time);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreVisitsController>(
      builder: (controller) {
        final currentVisit = controller.activeVisit ?? visit;
        final bool isFrontCaptured = controller.frontImagePath != null && controller.frontImagePath!.isNotEmpty;
        final bool isInsideCaptured = controller.insideImagePath != null && controller.insideImagePath!.isNotEmpty;
        final bool canContinue = isFrontCaptured || isInsideCaptured;

        return Scaffold(
          backgroundColor: _screenBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: _darkText, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'visit_documentation'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card 1: Storefront Photo
                _buildPhotoCard(
                  context: context,
                  title: 'storefront_photo'.tr,
                  badgeText: 'rear_camera'.tr,
                  instructionText: 'capture_storefront_instruction'.tr,
                  buttonText: 'take_storefront_photo'.tr,
                  imagePath: controller.frontImagePath,
                  capturedTime: controller.frontPhotoCapturedTime,
                  isCaptured: isFrontCaptured,
                  onCapture: () => controller.captureFrontImage(),
                ),

                const SizedBox(height: 16),

                // Card 2: Inside Store Photo
                _buildPhotoCard(
                  context: context,
                  title: 'inside_store_photo'.tr,
                  badgeText: 'front_camera'.tr,
                  instructionText: 'capture_inside_store_instruction'.tr,
                  buttonText: 'take_inside_store_photo'.tr,
                  imagePath: controller.insideImagePath,
                  capturedTime: controller.insidePhotoCapturedTime,
                  isCaptured: isInsideCaptured,
                  onCapture: () => controller.captureInsideImage(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          Get.to(() => VisitSummaryScreen(visit: currentVisit));
                        }
                      : () {
                          Get.snackbar(
                            'warning'.tr.isNotEmpty && 'warning'.tr != 'warning' ? 'warning'.tr : 'تنبيه',
                            'capture_storefront_instruction'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFFEF2F2),
                            colorText: const Color(0xFF991B1B),
                            margin: const EdgeInsets.all(16),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canContinue ? _primaryGreen : const Color(0xFFE2E4E6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'continue_action'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: canContinue ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoCard({
    required BuildContext context,
    required String title,
    required String badgeText,
    required String instructionText,
    required String buttonText,
    required String? imagePath,
    required DateTime? capturedTime,
    required bool isCaptured,
    required VoidCallback onCapture,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Red Camera Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _badgeBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _badgeDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _badgeText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Subtitle instruction
          Text(
            instructionText,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _subText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Captured state vs Uncaptured action
          if (isCaptured) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Green check circle
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _statusGreenBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: _primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text: Documented - Captured at [Time]
                      Expanded(
                        child: Text(
                          '${'documented_captured_at'.tr} ${_formatCapturedTime(capturedTime ?? DateTime.now())}',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _primaryGreen,
                          ),
                        ),
                      ),

                      // Small preview thumbnail if file exists
                      if (imagePath != null && File(imagePath).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePath),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Retake Photo Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: onCapture,
                      icon: const Icon(IconlyLight.camera, size: 18, color: Color(0xFF374151)),
                      label: Text(
                        'retake_photo'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Capture Photo Action Box
            InkWell(
              onTap: onCapture,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD1D5DB),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconlyLight.camera,
                        color: Color(0xFF4B5563),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
