import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/home/screens/market_store_screen.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/dialog.dart/qidha_contract_request_dialog.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class QidhaStoreCardWidget extends StatelessWidget {
  final Store store;
  final bool isContracted;
  final bool isRequested;
  final VoidCallback? onRequestSent;

  const QidhaStoreCardWidget({
    super.key,
    required this.store,
    this.isContracted = false,
    this.isRequested = false,
    this.onRequestSent,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardBgColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF111B18);

    final String categoryName = (store.categoryDetails != null &&
            store.categoryDetails!.isNotEmpty &&
            store.categoryDetails!.first.name != null &&
            store.categoryDetails!.first.name!.isNotEmpty)
        ? '${store.categoryDetails!.first.name!} (اسم قسم )'
        : (store.address != null && store.address!.isNotEmpty
            ? store.address!
            : 'قسم عام');

    final String ratingStr = (store.avgRating != null && store.avgRating! > 0)
        ? store.avgRating!.toStringAsFixed(1)
        : '5.0';

    final String deliveryTime = (store.deliveryTime != null && store.deliveryTime!.isNotEmpty)
        ? store.deliveryTime!
        : '20 دقيقة';

    final bool isFreeDelivery = store.freeDelivery == true;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: CustomInkWell(
            radius: Dimensions.radiusDefault,
            onTap: () {
              if (isContracted) {
                // 1. Hyper Shella storefront (Store ID 1) -> Dedicated market storefront like Home services
                if (store.id == 1) {
                  Get.to<void>(() => MarketStoreScreen(
                        storeId: 1,
                        moduleId: store.moduleId ?? 1,
                        isHyperStorefront: true,
                      ));
                  return;
                }

                // 2. Food / Restaurants / Cafes
                final bool isFood = store.moduleId == 2 ||
                    store.moduleId == 6 ||
                    store.moduleId == 9;

                if (isFood) {
                  Get.toNamed(
                    RouteHelper.getStoreRoute(id: store.id, page: 'item'),
                    arguments: StoreScreen(store: store, fromModule: false),
                  );
                } else {
                  // 3. Regular retail / grocery / market stores
                  Get.to<void>(() => MarketStoreScreen(
                        storeId: store.id,
                        name: store.name,
                        logo: store.logoFullUrl,
                        cover: store.coverPhotoFullUrl,
                        rating: (store.avgRating ?? 0).toDouble(),
                        freeDelivery: store.freeDelivery ?? false,
                        deliveryTime: store.deliveryTime,
                        distance: (store.distance ?? 0).toDouble(),
                        useCoverHeader: true,
                      ));
                }
              } else {
                QidhaContractRequestDialog.show(
                  context,
                  store,
                  onRequestSent: onRequestSent,
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Banner Image (Height 96px) ────────────────────────
                SizedBox(
                  height: 96,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Banner Photo
                      Positioned.fill(
                        child: (store.coverPhotoFullUrl != null &&
                                store.coverPhotoFullUrl!.isNotEmpty)
                            ? CustomImage(
                                image: store.coverPhotoFullUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withValues(alpha: 0.15),
                                      primaryColor.withValues(alpha: 0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    size: 36,
                                    color: primaryColor.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                      ),

                      // Rating Badge on TOP-RIGHT (Figma: #9DFCA3)
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9DFCA3),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ratingStr,
                                style: tajawalMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall - 1,
                                  color: const Color(0xFF111B18),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Color(0xFF111B18),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Delivery & Time Badges on BOTTOM-LEFT of Banner (Figma)
                      Positioned(
                        bottom: 6,
                        left: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Free Delivery Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    Images.truck_delivery_v2,
                                    width: 14,
                                    height: 14,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFreeDelivery
                                        ? 'توصيل مجاني'
                                        : 'توصيل متاح',
                                    style: tajawalBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Delivery Time Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    Images.time_v2,
                                    width: 12,
                                    height: 12,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    deliveryTime,
                                    style: tajawalBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                                      color: textColor,
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

                // ── Overlapping Store Info Row (Height 76px) ──────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Logo on the RIGHT (Overlaps Banner by 20px)
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(
                              color: const Color(0xFFF6F5F8),
                              width: 4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: (store.logoFullUrl != null &&
                                    store.logoFullUrl!.isNotEmpty)
                                ? CustomImage(
                                    image: '${store.logoFullUrl}',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: primaryColor,
                                    child: const Center(
                                      child: Icon(
                                        Icons.storefront_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Store Info on the LEFT of Logo
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, right: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Line 1: Store Name on Right, Action Badge on Left
                              Row(
                                children: [
                                  // Store Name (Right side in RTL)
                                  Expanded(
                                    child: Text(
                                      store.name ?? '',
                                      textAlign: TextAlign.right,
                                      style: tajawalBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Action / Status Badge (Left side in RTL)
                                  if (isContracted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE7F7EA),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        border: Border.all(
                                            color: const Color(0xFF9DFCA3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            store.qidhaCreditLimit != null
                                                ? 'قيدها: ${PriceConverter.convertPrice(store.qidhaAvailableBalance ?? store.qidhaCreditLimit)}'
                                                : 'يدعم قيدها',
                                            style: tajawalBold.copyWith(
                                              fontSize: Dimensions.fontSizeExtraSmall,
                                              color: const Color(0xFF1B6B2F),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.credit_card_rounded,
                                            size: 13,
                                            color: Color(0xFF1B6B2F),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (isRequested)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF9C3),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        border: Border.all(
                                            color: const Color(0xFFFEF08A)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'تم الطلب',
                                            style: tajawalBold.copyWith(
                                              fontSize: Dimensions.fontSizeExtraSmall + 1,
                                              color: const Color(0xFFCA8A04),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.schedule_rounded,
                                            size: 12,
                                            color: Color(0xFFCA8A04),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        onTap: () {
                                          QidhaContractRequestDialog.show(
                                            context,
                                            store,
                                            onRequestSent: onRequestSent,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(Dimensions.radiusSmall),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.add_card_rounded,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'طلب تعاقد',
                                                style: tajawalBold.copyWith(
                                                  fontSize: Dimensions.fontSizeExtraSmall + 1,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Line 2: Category Name
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  categoryName,
                                  textAlign: TextAlign.right,
                                  style: tajawalBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
