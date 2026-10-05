import 'package:flutter/material.dart';
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
    final sheetBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

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
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B4455) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer_rounded, size: 20, color: _primaryGreen),
                            const SizedBox(width: 8),
                            Text(
                              'مكتبة العروض الجاهزة للتاجر',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'عروض حصرية لدعم إغلاق التعاقد مع: $storeName',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: subText, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // List of Promo Cards
              if (controller.isLoadingPromos)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: _primaryGreen)),
                )
              else if (promos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'لا توجد عروض متاحة حالياً',
                      style: TextStyle(fontFamily: 'Tajawal', color: subText),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: promos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final promo = promos[index];
                      final isActivated = controller.activatedPromoIds.contains(promo.id);

                      return _buildPromoCard(
                        promo: promo,
                        isActivated: isActivated,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
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
                              'تم تفعيل العرض بنجاح',
                              'تم ربط عرض (${promo.titleAr}) بمتجر $storeName',
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

  Widget _buildPromoCard({
    required MerchantPromoModel promo,
    required bool isActivated,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color darkText,
    required Color subText,
    required VoidCallback onActivate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActivated ? _primaryGreen : borderColor,
          width: isActivated ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (promo.badge != null && promo.badge!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    promo.badge!,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  promo.code,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            promo.titleAr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
          if (promo.descriptionAr != null && promo.descriptionAr!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              promo.descriptionAr!,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: subText,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isActivated ? null : onActivate,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActivated ? const Color(0xFF81C784) : _primaryGreen,
                disabledBackgroundColor: isDark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActivated ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                    size: 16,
                    color: isActivated ? _primaryGreen : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActivated ? 'تم تفعيل العرض للمتجر ✓' : 'تفعيل العرض للمتجر الآن',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActivated ? _primaryGreen : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
