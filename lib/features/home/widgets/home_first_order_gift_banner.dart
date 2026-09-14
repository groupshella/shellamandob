import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';
import 'package:sixam_mart/features/campaign/widgets/gift_store_picker_sheet.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class HomeFirstOrderGiftBanner extends StatelessWidget {
  const HomeFirstOrderGiftBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizationController) {
        final bool isLtr = localizationController.isLtr;

        return GetBuilder<ProfileController>(
          builder: (profileController) {
            final bool isLoggedIn = AuthHelper.isLoggedIn();
            final bool profileClaimed = isLoggedIn &&
                (profileController.userInfoModel?.hasClaimedFirstOrderGift ?? false);

            return GetBuilder<DynamicGiftController>(
              builder: (giftController) {
                // Silently fetch campaign data if not loaded
                if (giftController.giftCampaign == null && !giftController.isLoading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (giftController.giftCampaign == null && !giftController.isLoading) {
                      giftController.fetchFirstOrderGift();
                    }
                  });
                }

                // Keep the banner visible even after the gift is used; instead of
                // hiding, we block the action and show "already used".
                final bool claimed = profileClaimed ||
                    giftController.isRedeemed ||
                    (isLoggedIn &&
                        giftController.giftCampaign != null &&
                        giftController.giftCampaign?.isEligible == false);

                void showUsedMessage() {
                  showCustomSnackBar(
                    isLtr
                        ? 'You have already used this offer'
                        : 'لقد استفدت من هذا العرض مسبقاً',
                    isError: false,
                  );
                }

                // Scan First: open the QR scanner — unless already used, then block.
                void handleTap() {
                  if (claimed) {
                    showUsedMessage();
                    return;
                  }
                  Get.toNamed(RouteHelper.getQr_screen());
                }

                final String title = isLtr ? 'Free 1st Order Gift! 🎁' : 'هدية أول طلب مجانية! 🎁';
                final String freeTag = isLtr ? '100% FREE' : 'مجاناً 100%';
                final String subtitle = claimed
                    ? (isLtr
                        ? 'You have already claimed this gift'
                        : 'لقد استفدت من هذا العرض مسبقاً')
                    : (isLtr
                        ? 'Scan the store QR at the counter to pick & claim your gift'
                        : 'امسح رمز الفرع عند الكاونتر لاختيار هديتك واستلامها');
                final String buttonText = claimed
                    ? (isLtr ? 'Used ✓' : 'تم الاستفادة ✓')
                    : (isLtr ? 'Scan Now' : 'امسح الآن');

                return Directionality(
                  textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                      opacity: claimed ? 0.55 : 1.0,
                      child: GestureDetector(
                    onTap: handleTap,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F5A2C),
                            Color(0xFF1E824C),
                            Color(0xFF146033),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E824C).withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Subtle Background Ambient Glow
                            Positioned(
                              top: -20,
                              left: isLtr ? null : -20,
                              right: isLtr ? -20 : null,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                            ),

                            // Main Compact Content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 1. Gift Icon Box with Sparkle
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2ECC71), Color(0xFF1E824C)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(
                                          Icons.card_giftcard_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        Positioned(
                                          top: 3,
                                          right: isLtr ? null : 3,
                                          left: isLtr ? 3 : null,
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            size: 9,
                                            color: Color(0xFFFFD54F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // 2. Title, Subtitle, Free Tag
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isLtr ? 13.0 : 13.5,
                                                  fontWeight: FontWeight.w800,
                                                  fontFamily: isLtr ? 'Roboto' : 'Tajawal',
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Golden "100% Free" Tag
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFFD54F),
                                                    Color(0xFFFFB300),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                freeTag,
                                                style: TextStyle(
                                                  color: const Color(0xFF7C2D12),
                                                  fontSize: isLtr ? 9.0 : 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  fontFamily: isLtr ? 'Roboto' : 'Tajawal',
                                                  height: 1.1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: isLtr ? 10.0 : 10.5,
                                            fontFamily: isLtr ? 'Roboto' : 'Tajawal',
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // 3. Action Button: "Scan Now" with QR Scanner Icon
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.qr_code_scanner_rounded,
                                          size: 14,
                                          color: Color(0xFF0F5A2C),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          buttonText,
                                          style: TextStyle(
                                            color: const Color(0xFF0F5A2C),
                                            fontSize: isLtr ? 11.0 : 11.5,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: isLtr ? 'Roboto' : 'Tajawal',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                      ),
                      if (!claimed) ...[
                        const SizedBox(height: 6),
                        _buildChooseStoreLink(context, isLtr),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChooseStoreLink(BuildContext context, bool isLtr) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault + 2),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: InkWell(
          onTap: () => showGiftStorePicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_rounded,
                    size: 14, color: Color(0xFF1E824C)),
                const SizedBox(width: 4),
                Text(
                  isLtr
                      ? 'Camera not working? Choose store'
                      : 'كاميرتك لا تعمل؟ اختر المتجر',
                  style: const TextStyle(
                    color: Color(0xFF1E824C),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Tajawal',
                    decoration: TextDecoration.underline,
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
