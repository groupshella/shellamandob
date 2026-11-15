import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/merchant_promo_model.dart';

class MerchantPromoLibraryBottomSheet extends StatelessWidget {
  final int? storeId;
  final String? visitId;
  final String storeName;

  const MerchantPromoLibraryBottomSheet({
    super.key,
    this.storeId,
    this.visitId,
    required this.storeName,
  });

  static void show(BuildContext context, {int? storeId, String? visitId, required String storeName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MerchantPromoLibraryBottomSheet(
        storeId: storeId,
        visitId: visitId,
        storeName: storeName,
      ),
    );
  }

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme;
    final sheetBg = isDark ? const Color(0xFF141923) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111827);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF1F5F9);

    return GetBuilder<StoreVisitsController>(
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<StoreVisitsController>()) {
            Get.find<StoreVisitsController>().loadMerchantPromos(reload: true);
          }
        });
      },
      builder: (controller) {
        final promos = controller.merchantPromos;

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button & title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF222938) : const Color(0xFFF3F4F6),
                        ),
                        child: Icon(Icons.close_rounded, size: 20, color: darkText),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'ready_offers_for_merchant'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36), // Balanced spacer for centered title
                  ],
                ),
              ),

              Divider(height: 1, color: borderColor),

              // Scrollable list of promo cards
              if (controller.isLoadingPromos)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: _primaryGreen)),
                )
              else if (promos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Text(
                      'no_promos_available_now'.tr,
                      style: TextStyle(fontFamily: 'Tajawal', color: subText),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shrinkWrap: true,
                    itemCount: promos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, index) {
                      final promo = promos[index];
                      final isActivated = controller.activatedPromoIds.contains(promo.id);

                      return _buildFigmaTicketCard(
                        promo: promo,
                        index: index,
                        isActivated: isActivated,
                        isDark: isDark,
                        darkText: darkText,
                        subText: subText,
                        onActivate: () async {
                          final success = await controller.activatePromoForStore(
                            promoId: promo.id,
                            storeId: storeId,
                            visitId: visitId,
                          );
                          if (success) {
                            Get.snackbar(
                              'promo_activated_success'.tr,
                              'promo_linked_to_store'.trParams({'promo': promo.titleAr, 'store': storeName}),
                              backgroundColor: const Color(0xFFE8F5E9),
                              colorText: _primaryGreen,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a pixel-perfect perforated ticket cutout card matching Figma Node 9688:27514
  Widget _buildFigmaTicketCard({
    required MerchantPromoModel promo,
    required int index,
    required bool isActivated,
    required bool isDark,
    required Color darkText,
    required Color subText,
    required VoidCallback onActivate,
  }) {
    // Determine style theme based on promo code or index
    final Color badgeBg;
    final Color badgeText;
    final Color ribbonBg;
    final Color ribbonHoleColor;
    final String ribbonText;

    if (promo.code.contains('FREE') || index == 1) {
      // Free Delivery Purple Theme
      ribbonBg = isDark ? const Color(0xFF2C2442) : const Color(0xFFE8E0FC);
      badgeBg = isDark ? const Color(0xFF1B3828) : const Color(0xFFEBFDF2);
      badgeText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      ribbonHoleColor = isDark ? const Color(0xFF141923) : Colors.white;
      ribbonText = 'free_delivery_vertical_badge'.tr;
    } else if (promo.code.contains('500') || index == 2) {
      // Partner Red/Pink Theme
      ribbonBg = isDark ? const Color(0xFF3F2025) : const Color(0xFFFFE0E2);
      badgeBg = isDark ? const Color(0xFF1B3828) : const Color(0xFFEBFDF2);
      badgeText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      ribbonHoleColor = isDark ? const Color(0xFF141923) : Colors.white;
      ribbonText = '${'discount_label'.tr} 25%';
    } else {
      // Founding Green Theme (Default)
      ribbonBg = isDark ? const Color(0xFF1E3827) : const Color(0xFFDCFCE7);
      badgeBg = isDark ? const Color(0xFF1B3828) : const Color(0xFFEBFDF2);
      badgeText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      ribbonHoleColor = isDark ? const Color(0xFF141923) : Colors.white;
      ribbonText = '${'discount_label'.tr} 50%';
    }

    final cardBg = isDark ? const Color(0xFF1C222E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF2B3342) : const Color(0xFFE2E8F0);

    // Format validity display string
    final validityText = (promo.validUntil != null && promo.validUntil!.isNotEmpty)
        ? 'valid_until_date'.trParams({'date': promo.validUntil!})
        : (index == 1 ? 'valid_for_days'.trParams({'days': '7'}) : 'valid_until_date'.trParams({'date': '25,يونيو,2026'}));

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActivated ? _primaryGreen : borderCol,
          width: isActivated ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Right perforated ribbon (in RTL this sits at the start/right side)
            _buildPerforatedRibbon(
              ribbonBg: ribbonBg,
              ribbonHoleColor: ribbonHoleColor,
              text: ribbonText,
              isDark: isDark,
            ),

            // Content body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Code button with copy icon + Category Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Promo code with copy capability
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: promo.code));
                            Get.snackbar(
                              'copied'.tr,
                              promo.code,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              colorText: darkText,
                              duration: const Duration(seconds: 2),
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF283040) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded, size: 14, color: darkText),
                                const SizedBox(width: 6),
                                Text(
                                  promo.code,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Green Pill Category Badge (e.g. عرض التأسيس)
                        if (promo.badge != null && promo.badge!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              promo.badge!,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeText,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Offer Title
                    Text(
                      promo.titleAr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),

                    // Offer Description
                    if (promo.descriptionAr != null && promo.descriptionAr!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        promo.descriptionAr!,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: subText,
                          height: 1.45,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Bottom Row: Validity string + Activate Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          validityText,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            color: subText,
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: isActivated ? null : onActivate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              disabledBackgroundColor: isDark ? const Color(0xFF1B3828) : const Color(0xFFE8F5E9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              isActivated ? '${'promo_activated_for_store'.tr} ✓' : 'activate_offer_btn'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActivated ? _primaryGreen : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the left/right perforated vertical coupon ribbon matching Figma
  Widget _buildPerforatedRibbon({
    required Color ribbonBg,
    required Color ribbonHoleColor,
    required String text,
    required bool isDark,
  }) {
    return Container(
      width: 50,
      color: ribbonBg,
      child: Stack(
        children: [
          // Center vertical Rotated Text
          Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Perforated edge with semi-circular punch holes
          Positioned(
            left: 0,
            top: 6,
            bottom: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (i) => Container(
                  width: 7,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ribbonHoleColor,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
