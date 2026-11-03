import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_main_screen.dart';
import 'package:sixam_mart/util/styles.dart';

/// Screen displayed when a growth specialist applicant is rejected
/// but offered the Freelance Marketer opportunity.
/// Matches Figma 9645:14385 ("رفض الانضمام كأخصائي").
class MarketerFreelanceOfferScreen extends StatelessWidget {
  const MarketerFreelanceOfferScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : _darkText;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Exact Isometric 3D Phone & QR Projector Illustration from Figma
                    Image.asset(
                      'assets/image/freelance_offer_qr_hero.png',
                      width: 280,
                      height: 240,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    // Main Title: "عندنا لك فرصة ثانية مع شلة!"
                    Text(
                      'rejection_freelance_offer_title'.tr,
                      textAlign: TextAlign.center,
                      style: tajawalBold.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description paragraph 1
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'rejection_freelance_offer_desc_1'.tr,
                        textAlign: TextAlign.center,
                        style: tajawalMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Description paragraph 2
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'rejection_freelance_offer_desc_2'.tr,
                        textAlign: TextAlign.center,
                        style: tajawalMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Role Title: "المسوّق الحر"
                    Text(
                      'freelance_marketer_title'.tr,
                      textAlign: TextAlign.center,
                      style: tajawalBold.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Aligned Bullets List matching Figma 9645:14385
                    IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBulletItem('freelance_perk_1'.tr, textColor),
                          const SizedBox(height: 8),
                          _buildBulletItem('freelance_perk_2'.tr, textColor),
                          const SizedBox(height: 8),
                          _buildBulletItem('freelance_perk_3'.tr, textColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: "انضم كمسوق حر"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: GetBuilder<MarketerController>(
                builder: (controller) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              await controller.acceptFreelanceOffer();
                              Get.offAll(() => const MarketerMainScreen());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'join_as_freelance_marketer'.tr,
                              style: tajawalBold.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4.5,
          height: 4.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: textColor,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: tajawalMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
