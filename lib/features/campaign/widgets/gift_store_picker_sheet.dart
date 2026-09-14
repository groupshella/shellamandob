import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';
import 'package:sixam_mart/features/campaign/screens/gift_location_verify_screen.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// Manual "choose store" alternative to the QR scanner, for customers whose
/// camera can't scan the branch QR. Same downstream flow: pick a store here →
/// FirstOrderGiftScreen(storeId) → product → cart → claim → handover.
Future<void> showGiftStorePicker(BuildContext context) async {
  final bool isLtr = Get.find<LocalizationController>().isLtr;
  final controller = Get.find<DynamicGiftController>();
  // Kick off the fetch as the sheet opens.
  controller.fetchGiftStores();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Directionality(
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded,
                      color: Color(0xFF30913F), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isLtr ? 'Choose a store' : 'اختر المتجر',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111B18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  isLtr
                      ? 'Camera not working? Pick the branch you are at to claim your gift.'
                      : 'كاميرتك لا تعمل؟ اختر الفرع الذي أنت فيه لاستلام هديتك.',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12.5,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: GetBuilder<DynamicGiftController>(
                builder: (c) {
                  if (c.isLoadingStores) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF30913F)),
                      ),
                    );
                  }
                  if (c.giftStores.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          isLtr
                              ? 'No participating stores right now.'
                              : 'لا توجد متاجر مشاركة حالياً.',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: c.giftStores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final store = c.giftStores[i];
                      final int? id = int.tryParse('${store['id']}');
                      final String name = '${store['name'] ?? ''}';
                      final String address = '${store['address'] ?? ''}';
                      final String logo = '${store['logo'] ?? ''}';
                      final double? sLat =
                          double.tryParse('${store['latitude'] ?? ''}');
                      final double? sLng =
                          double.tryParse('${store['longitude'] ?? ''}');
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: id == null
                            ? null
                            : () {
                                Get.back();
                                // If the store has coordinates, verify the
                                // customer is physically at the store before
                                // continuing to claim; otherwise go straight in.
                                if (sLat != null && sLng != null) {
                                  Get.to(() => GiftLocationVerifyScreen(
                                        storeId: id,
                                        storeName: name,
                                        storeLat: sLat,
                                        storeLng: sLng,
                                      ));
                                } else {
                                  Get.toNamed(
                                      RouteHelper.getFirstOrderGiftRoute(
                                          storeId: id));
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: const Color(0xFFEEF0F3)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomImage(
                                  image: logo,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111B18),
                                      ),
                                    ),
                                    if (address.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.location_on_rounded,
                                              size: 13,
                                              color: Color(0xFF9CA3AF)),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              address,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 11.5,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_left,
                                  color: Color(0xFF30913F)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
