import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import '../../../../common/controllers/theme_controller.dart';
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

  String _formatCapturedTime(DateTime? time) {
    if (time == null) return '';
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('hh:mm a', lang).format(time);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final screenBg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final badgeBg = isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2);
        final badgeBorder = isDark ? const Color(0xFF5A2323) : const Color(0xFFFECACA);
        final badgeTextColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        const badgeDot = Color(0xFFEF4444);
        final statusGreenBg = isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB);
        final bottomBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final capturedBoxBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
        final disabledBtnBg = isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6);

        return GetBuilder<StoreVisitsController>(
          init: Get.isRegistered<StoreVisitsController>()
              ? Get.find<StoreVisitsController>()
              : Get.put(StoreVisitsController(), permanent: true),
          autoRemove: false,
          builder: (controller) {
            final currentVisit = controller.activeVisit ?? visit;
            final bool isFrontCaptured = controller.frontImagePath != null && controller.frontImagePath!.isNotEmpty;
            final bool isInsideCaptured = controller.insideImagePath != null && controller.insideImagePath!.isNotEmpty;
            final int capturedCount = (isFrontCaptured ? 1 : 0) + (isInsideCaptured ? 1 : 0);
            final int remainingCount = 2 - capturedCount;
            final bool canContinue = capturedCount > 0;

            String buttonLabel;
            if (remainingCount == 0) {
              buttonLabel = 'continue_documentation'.tr;
            } else if (remainingCount == 1) {
              buttonLabel = 'capture_remaining_photos_1'.tr;
            } else {
              buttonLabel = 'capture_remaining_photos_2'.tr;
            }

            return Scaffold(
              backgroundColor: screenBg,
              appBar: AppBar(
                backgroundColor: cardBg,
                elevation: 0.5,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  'visit_documentation'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Storefront Photo (كاميرا خلفية)
                    _buildPhotoCard(
                      context: context,
                      title: 'photo_storefront_title'.tr,
                      badgeLabel: 'photo_rear_camera'.tr,
                      instructionText: 'photo_storefront_desc'.tr,
                      buttonText: 'capture_photo_btn'.tr,
                      imagePath: controller.frontImagePath,
                      capturedTime: controller.frontPhotoCapturedTime,
                      isCaptured: isFrontCaptured,
                      onCapture: () => controller.captureFrontImage(),
                      cardBg: cardBg,
                      darkText: darkText,
                      subText: subText,
                      borderColor: borderColor,
                      badgeBg: badgeBg,
                      badgeBorder: badgeBorder,
                      badgeTextColor: badgeTextColor,
                      badgeDot: badgeDot,
                      statusGreenBg: statusGreenBg,
                      capturedBoxBg: capturedBoxBg,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    // Card 2: Inside Store Photo (كاميرا أمامية)
                    _buildPhotoCard(
                      context: context,
                      title: 'photo_inside_title'.tr,
                      badgeLabel: 'photo_front_camera'.tr,
                      instructionText: 'photo_inside_desc'.tr,
                      buttonText: 'capture_photo_btn'.tr,
                      imagePath: controller.insideImagePath,
                      capturedTime: controller.insidePhotoCapturedTime,
                      isCaptured: isInsideCaptured,
                      onCapture: () => controller.captureInsideImage(),
                      cardBg: cardBg,
                      darkText: darkText,
                      subText: subText,
                      borderColor: borderColor,
                      badgeBg: badgeBg,
                      badgeBorder: badgeBorder,
                      badgeTextColor: badgeTextColor,
                      badgeDot: badgeDot,
                      statusGreenBg: statusGreenBg,
                      capturedBoxBg: capturedBoxBg,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bottomBarBg,
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                  boxShadow: const [
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
                                'alert'.tr,
                                'take_at_least_one_photo'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: isDark ? const Color(0xFF3B1818) : const Color(0xFFFEF2F2),
                                colorText: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                                margin: const EdgeInsets.all(16),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canContinue ? _primaryGreen : disabledBtnBg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: canContinue ? Colors.white : subText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPhotoCard({
    required BuildContext context,
    required String title,
    required String badgeLabel,
    required String instructionText,
    required String buttonText,
    required String? imagePath,
    required DateTime? capturedTime,
    required bool isCaptured,
    required VoidCallback onCapture,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
    required Color badgeBg,
    required Color badgeBorder,
    required Color badgeTextColor,
    required Color badgeDot,
    required Color statusGreenBg,
    required Color capturedBoxBg,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
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
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: badgeDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
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
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Captured state vs Uncaptured action
          if (isCaptured) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: capturedBoxBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
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
                          color: statusGreenBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 1),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: _primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text: تم التوثيق - التقطت [الوقت]
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
                      icon: Icon(IconlyLight.camera, size: 18, color: darkText),
                      label: Text(
                        'retake_photo'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: cardBg,
                        side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB), width: 1),
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
                  color: capturedBoxBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
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
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconlyLight.camera,
                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      buttonText,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
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
