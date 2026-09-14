import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';

class FigmaGiftSuccessView extends StatelessWidget {
  final DynamicGiftController controller;

  const FigmaGiftSuccessView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.redemptionData;
    final storeName = data?['store_name'] ?? controller.giftCampaign?.campaign?.store?.name ?? 'متجر النخبة';
    final itemName = data?['item_name'] ?? controller.selectedItem?.name ?? 'الهدية المجانية';
    final claimDate = data?['claim_date'] ?? '26 أغسطس, 2026';
    final claimTime = data?['claim_time'] ?? '10:00 pm';
    final total = data?['total'] ?? '00.00';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111B18), size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Green Checkmark Graphic with Outer Ring & Floating Dots
                      Center(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Ring
                              Container(
                                width: 130,
                                height: 130,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEBF7EE),
                                  shape: BoxShape.circle,
                                ),
                              ),

                              // Inner Green Circle with White Checkmark
                              Container(
                                width: 90,
                                height: 90,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x334CAF50),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 54,
                                ),
                              ),

                              // Floating Particle Dots (Matching Figma Design)
                              Positioned(
                                top: 8,
                                left: 14,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC8E6C9),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 22,
                                right: 10,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFA5D6A7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 24,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC8E6C9),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 26,
                                right: 16,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF81C784),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title Text: تم تسليمك منتجك المجاني
                      const Text(
                        'تم تسليمك منتجك المجاني',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111B18),
                          fontFamily: 'Tajawal',
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Order Summary Container Card (Figma Screen 5)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Row 1: اسم المتجر
                            _buildReceiptRow('اسم المتجر', storeName),

                            const SizedBox(height: 14),

                            // Row 2: المنتج
                            _buildReceiptRow('المنتج المجاني', itemName),

                            const SizedBox(height: 14),

                            // Row 3: تاريخ الاستلام
                            _buildReceiptRow('تاريخ الاستلام', claimDate),

                            const SizedBox(height: 14),

                            // Row 4: وقت الاستلام
                            _buildReceiptRow('وقت الاستلام', claimTime),

                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 16),

                            // Row 4: إجمالي الطلب -> 00.0
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'إجمالي الطلب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF30913F),
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$total',
                                      style: const TextStyle(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button: تصفح بقية عروض المتجر
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // SECURITY: after the gift is handed over, do NOT return to the
                    // claim flow (setStep(0)) — that let the customer claim the free
                    // product again. Leave the gift flow entirely and open the real
                    // store to browse its other offers.
                    final int? storeId = controller.giftCampaign?.campaign?.store?.id ??
                        controller.giftCampaign?.campaign?.storeId;
                    if (storeId != null && storeId > 0) {
                      Get.offNamed(RouteHelper.getStoreRoute(id: storeId, page: 'campaign'));
                    } else {
                      Get.until((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF30913F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تصفح بقية عروض المتجر',
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
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111B18),
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(width: 12),
        // Constrain long values (e.g. long product names) so the row wraps/
        // ellipsizes instead of overflowing to the right.
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111B18),
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ],
    );
  }
}
