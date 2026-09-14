import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';
import 'package:sixam_mart/util/images.dart';

class FigmaGiftCartView extends StatelessWidget {
  final DynamicGiftController controller;

  const FigmaGiftCartView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicGiftController>(
      builder: (ctrl) {
        final item = ctrl.selectedItem;
        final hasItem = item != null;
        final totalQty = ctrl.totalGiftQuantity;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111B18), size: 18),
              onPressed: () => ctrl.setStep(0), // Back to store view
            ),
            title: const Text(
              'السّلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B18),
                fontFamily: 'Tajawal',
              ),
            ),
            actions: [
              if (hasItem)
                TextButton(
                  onPressed: () => ctrl.clearCart(),
                  child: const Text(
                    'أفرغ السلة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
            ],
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Expanded(
                  child: hasItem
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Cart Item Card (Figma Screen 3)
                              _buildCartItemCard(ctrl, item),
                            ],
                          ),
                        )
                      : _buildEmptyCartView(ctrl),
                ),

                // Bottom Checkout Sheet (Figma Screen 3)
                _buildBottomCheckoutSheet(ctrl, hasItem, totalQty),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Cart Item Card
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCartItemCard(DynamicGiftController ctrl, dynamic item) {
    final originalPrice = item.originalPrice != null && item.originalPrice > 0
        ? item.originalPrice.toStringAsFixed(2)
        : null;
    final itemId = item.campaignItemId ?? item.itemId ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Red Badge "هدية ترحيبية مجانية"
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.image != null && item.image.toString().isNotEmpty
                      ? CustomImage(
                          image: item.image.toString(),
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 40,
                            color: Color(0xFF30913F),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCD1625),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'هدية ترحيبية مجانية',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title & Delete Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name ?? 'الهدية المجانية',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111B18),
                          fontFamily: 'Tajawal',
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => ctrl.clearCart(),
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                if (item.description != null && item.description.toString().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.description.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Tajawal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),

                // Price & Counter Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price Row with SAR Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (originalPrice != null) ...[
                          Text(
                            originalPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Image.asset(Images.sar, height: 9, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 8),
                        ],
                        const Text(
                          '00.0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111B18),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(width: 3),
                        Image.asset(Images.sar, height: 13, color: const Color(0xFF111B18)),
                      ],
                    ),

                    // Counter Pill: - 1 +
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30913F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => ctrl.decrementQuantity(itemId),
                            child: const Icon(Icons.remove, size: 15, color: Colors.white),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '1',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ctrl.incrementQuantity(itemId, item),
                            child: const Icon(Icons.add, size: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Empty Cart State
  // ─────────────────────────────────────────────────────────────────
  Widget _buildEmptyCartView(DynamicGiftController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EE),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: 40,
                  color: Color(0xFF30913F),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'السلة فارغة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B18),
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'لم تقم باختيار هديتك المجانية بعد',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ctrl.setStep(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30913F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'اختيار هدية الآن',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Bottom Checkout Sheet
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBottomCheckoutSheet(
    DynamicGiftController ctrl,
    bool hasItem,
    int totalQty,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yellow Alert Box: خصم الحملة بنسبة (100%).
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF1DA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF6C878).withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 17, color: Color(0xFF9A6700)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إخصم الحملة بنسبة (%100).',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111B18),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Total Container: الإجمالي (1) 00.00 ر.س
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي ($totalQty)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '00.00',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF30913F),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(width: 3),
                      Image.asset(Images.sar, height: 14, color: const Color(0xFF30913F)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Confirm Order Button: تأكيد الطلب
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasItem && !ctrl.isLoading
                    ? () => ctrl.generateGiftQr() // Generates QR & Goes to Screen 4
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30913F),
                  disabledBackgroundColor: const Color(0xFF9CA3AF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: ctrl.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'تأكيد الطلب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
