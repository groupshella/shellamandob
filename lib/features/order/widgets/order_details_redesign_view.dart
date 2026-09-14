// 🎨 REDESIGN: Order-details template ("طلباتي → تفاصيل الطلب").
//
// Terminal states (completed / cancelled) share one clean layout per the new
// designs: an optional state banner, the order details, payment, address, date
// and a "أعد طلب الأوردر" reorder button. Active states (preparing / on-the-way)
// keep the earlier illustration-hero layout until their own designs land.
//
// All the fee/total math is done by the parent (OrderDetailsScreen) and passed
// in pre-computed so this widget stays purely presentational (except the
// reorder action, which re-adds the order's items to the cart).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';

class OrderDetailsRedesignView extends StatelessWidget {
  final OrderModel order;
  final List<OrderDetailsModel> orderDetails;
  final bool parcel;
  final bool taxIncluded;
  final double itemsPrice;
  final double addOns;
  final double deliveryCharge;
  final double additionalCharge;
  final double extraPackagingCharge;
  final double discount;
  final double couponDiscount;
  final double referrerBonusAmount;
  final double tax;
  final double dmTips;
  final double total;

  const OrderDetailsRedesignView({
    super.key,
    required this.order,
    required this.orderDetails,
    required this.parcel,
    required this.taxIncluded,
    required this.itemsPrice,
    required this.addOns,
    required this.deliveryCharge,
    required this.additionalCharge,
    required this.extraPackagingCharge,
    required this.discount,
    required this.couponDiscount,
    required this.referrerBonusAmount,
    required this.tax,
    required this.dmTips,
    required this.total,
  });

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _ink = Color(0xFF121C19);
  static const Color _muted = Color(0xFF8A8A8A);
  static const Color _border = Color(0xFFEDEFF1);
  static const Color _summaryBg = Color(0xFFF7F8FA);
  static const Color _green = Color(0xFF1FA64A);
  static const Color _red = Color(0xFFE5484D);

  /// 'completed' | 'cancelled' | 'active'
  String get _statusGroup {
    switch ((order.orderStatus ?? '').toLowerCase().trim()) {
      case 'delivered':
        return 'completed';
      case 'canceled':
      case 'cancelled':
      case 'failed':
      case 'expired':
      case 'refund_requested':
      case 'refunded':
      case 'refund_request_canceled':
        return 'cancelled';
      default:
        return 'active';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String group = _statusGroup;
    if (group == 'active') return _activeLayout();
    return _terminalLayout(cancelled: group == 'cancelled');
  }

  // ════════════════════════════════════════════════════════════════════════
  // Terminal layout (completed / cancelled)
  // ════════════════════════════════════════════════════════════════════════
  Widget _terminalLayout({required bool cancelled}) {
    final Color accent = cancelled ? _red : _green;
    final double subTotal = itemsPrice + addOns;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cancelled) ...[
            _cancelledBanner(),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
          _sectionTitle('ord_order_details'.tr, accent: accent),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (!parcel && order.store != null) ...[
            _storeCard(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          if (!parcel && orderDetails.isNotEmpty) ...[
            _itemsCard(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          _summaryCard(subTotal),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _paymentBlock(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (!parcel && (order.deliveryAddress?.address ?? '').isNotEmpty) ...[
            _detailBlock('ord_delivery_address'.tr, order.deliveryAddress!.address!),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
          if ((order.createdAt ?? '').isNotEmpty) ...[
            _detailBlock('ord_order_date'.tr,
                DateConverter.dateTimeStringToDateTime(order.createdAt!)),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
          if (!cancelled && !AuthHelper.isGuestLoggedIn()) ...[
            _rateReviewCard(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          _reorderButton(),
        ],
      ),
    );
  }

  /// Warm gold banner shown for completed orders to prompt rating & review,
  /// or a clean green badge when the order has already been reviewed.
  Widget _rateReviewCard() {
    final bool isAlreadyReviewed = (order.isReviewed == 1) ||
        (orderDetails.isNotEmpty &&
            orderDetails.every((d) =>
                d.isReviewed == 1 ||
                (d.reviewRating != null && d.reviewRating! > 0)));

    if (isAlreadyReviewed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check_circle_rounded,
                  color: _green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Get.locale?.languageCode == 'ar'
                        ? 'تم تقييم هذا الطلب بنجاح ⭐'
                        : 'Order Reviewed Successfully ⭐',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Get.locale?.languageCode == 'ar'
                        ? 'شكراً لمشاركتنا رأيك القيم'
                        : 'Thank you for sharing your feedback',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              onPressed: _openRateReview,
              child: Text(
                Get.locale?.languageCode == 'ar' ? 'عرض التقييم' : 'View Review',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isDeliveryOrder =
        (order.orderType == 'delivery' || order.orderType == null);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.star_rounded,
                color: Color(0xFFF59E0B), size: 26),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'rate_review'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Get.locale?.languageCode == 'ar'
                      ? (isDeliveryOrder
                          ? 'شاركنا رأيك في الطلب والتوصيل'
                          : 'شاركنا رأيك في المنتجات والمطعم')
                      : 'Share your review on items & service',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _openRateReview,
            child: Text(
              Get.locale?.languageCode == 'ar' ? 'قيم الآن' : 'Rate Now',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openRateReview() {
    final List<OrderDetailsModel> uniqueDetails = [];
    final List<int?> idList = [];
    for (final orderDetail in orderDetails) {
      if (orderDetail.itemDetails != null &&
          !idList.contains(orderDetail.itemDetails!.id)) {
        uniqueDetails.add(orderDetail);
        idList.add(orderDetail.itemDetails!.id);
      }
    }
    final bool isDeliveryOrder =
        (order.orderType == 'delivery' || order.orderType == null);
    Get.toNamed(RouteHelper.getReviewRoute(),
        arguments: RateReviewScreen(
          orderDetailsList: uniqueDetails,
          deliveryMan: isDeliveryOrder ? order.deliveryMan : null,
          store: order.store,
          order: order,
          orderID: order.id,
        ));
  }

  /// Red strip shown for cancelled/failed/expired orders.
  Widget _cancelledBanner() {
    final String date = (order.createdAt ?? '').isNotEmpty
        ? DateConverter.dateTimeStringToDateOnly(order.createdAt!)
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall + 2,
      ),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date.isEmpty ? 'ord_order_cancelled'.tr : 'تم إلغاء الطلب بتاريخ $date',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _red,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          const Icon(Icons.error_outline, size: 20, color: _red),
        ],
      ),
    );
  }

  /// Green "أعد طلب الأوردر" button: re-adds the order's items to the cart and
  /// opens the cart.
  Widget _reorderButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _confirmReorder,
        child: Text(
          'ord_reorder'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.6,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Confirmation bottom sheet shown before reordering.
  void _confirmReorder() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeLarge,
          Dimensions.paddingSizeLarge,
          Dimensions.paddingSizeLarge,
          Dimensions.paddingSizeExtraLarge,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DCE1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'ord_reorder_confirm'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.4,
                color: _ink,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Get.back<void>();
                  _reorder();
                },
                child: Text(
                  'ord_yes_reorder'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F3F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Get.back<void>(),
                child: Text(
                  'ord_cancel'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: false,
    );
  }

  Future<void> _reorder() async {
    if (!Get.isRegistered<CartController>() || orderDetails.isEmpty) return;
    final CartController cart = Get.find<CartController>();
    try {
      // If cart has items from another store, clear it so reorder doesn't fail with different_store
      if (cart.cartList.isNotEmpty) {
        final currentStoreId = cart.cartList.first.item?.storeId;
        if (currentStoreId != null && order.store?.id != null && currentStoreId != order.store?.id) {
          await cart.clearCartList();
        }
      }

      bool anyAdded = false;
      for (final OrderDetailsModel d in orderDetails) {
        if (d.itemId == null) continue;
        final double unit = (d.price ?? 0) - (d.discountOnItem ?? 0);
        final OnlineCart online = OnlineCart(
          null,
          d.itemId,
          null,
          unit.toString(),
          '',
          [],
          [],
          d.quantity ?? 1,
          [],
          [],
          [],
          'Item',
          storeId: order.store?.id,
        );
        bool ok = await cart.addToCartOnline(online);
        if (!ok && cart.lastAddToCartErrorCode == 'different_store') {
          await cart.clearCartList();
          ok = await cart.addToCartOnline(online);
        }
        if (ok) {
          anyAdded = true;
        }
      }
      if (anyAdded) {
        Get.toNamed(RouteHelper.getCartRoute());
      } else {
        final String err = cart.lastAddToCartErrorCode ?? '';
        if (err == 'store_closed') {
          showCustomSnackBar('المتجر مغلق حالياً ولا يمكن استقبال طلبات'.tr);
        } else {
          showCustomSnackBar('تعذر إضافة المنتجات للسلة، يرجى المحاولة لاحقاً'.tr);
        }
      }
    } catch (_) {
      showCustomSnackBar('تعذر إضافة المنتجات للسلة'.tr);
    }
  }

  // ── Payment (card-style chip) ─────────────────────────────────────────────
  Widget _paymentBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockLabel('ord_payment_method'.tr),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall + 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              const Icon(Icons.credit_card_rounded, size: 22, color: _ink),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  _paymentLabel(),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A right-aligned label with its value below (address / date).
  Widget _detailBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockLabel(label),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 1.5,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _blockLabel(String text) => Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 1.6,
          color: _ink,
        ),
      );

  /// Structured option / add-on lines for an order item — each shown on its own
  /// tree-style row ("└ …") under the item name. `isAddon` picks the accent:
  /// green for extras, muted grey for the chosen option value.
  List<_OrderChoiceLine> _orderChoiceLines(OrderDetailsModel d) {
    final List<_OrderChoiceLine> out = <_OrderChoiceLine>[];
    final foodVars = d.foodVariation;
    if (foodVars != null) {
      for (final v in foodVars) {
        final List<String> chosen = <String>[];
        final vals = v.variationValues;
        if (vals != null) {
          for (final val in vals) {
            final String lvl = (val.level ?? '').trim();
            if (lvl.isNotEmpty) chosen.add(lvl);
          }
        }
        final String name = (v.name ?? '').trim();
        if (chosen.isNotEmpty) {
          out.add(_OrderChoiceLine(
            name.isEmpty ? chosen.join('، ') : '$name: ${chosen.join('، ')}',
            isAddon: false,
          ));
        }
      }
    }
    final addOns = d.addOns;
    if (addOns != null) {
      for (final a in addOns) {
        final String n = (a.name ?? '').trim();
        if (n.isEmpty) continue;
        final int q = a.quantity ?? 1;
        out.add(_OrderChoiceLine(q > 1 ? '$n ×$q' : n, isAddon: true));
      }
    }
    return out;
  }

  // ── Store card ────────────────────────────────────────────────────────────
  Widget _storeCard() {
    return _card(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImage(
              image: order.store?.logoFullUrl ?? '',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: Image.asset(Images.placeholder,
                  width: 48, height: 48, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.store?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _ink,
                  ),
                ),
                if ((order.store?.address ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.store!.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Items card ────────────────────────────────────────────────────────────
  Widget _itemsCard() {
    return _card(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: Column(
        children: List<Widget>.generate(orderDetails.length, (int index) {
          final OrderDetailsModel detail = orderDetails[index];
          final int quantity = detail.quantity ?? 1;
          final double original = (detail.price ?? 0) * quantity;
          final double discounted =
              ((detail.price ?? 0) - (detail.discountOnItem ?? 0)) * quantity;
          final bool hasDiscount = discounted < original;
          final String? desc = detail.itemDetails?.description;
          final List<_OrderChoiceLine> choiceLines = _orderChoiceLines(detail);
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Solid green index circle with a white number.
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.itemDetails?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _ink,
                        ),
                      ),
                      if ((desc ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          desc!.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            color: _muted,
                          ),
                        ),
                      ],
                      // Customer's chosen options / add-ons — each on its own
                      // tree-style line ("└ …") under the item name; extras in
                      // green so they stand apart from the plain option values.
                      if (choiceLines.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        ...choiceLines.map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '└ ${line.text}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                height: 1.35,
                                color: line.isAddon ? _green : _muted,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          Text(
                            PriceConverter.convertPrice(discounted),
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _green,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text(
                              PriceConverter.convertPrice(original),
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: _muted,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: _red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _summaryCard(double subTotal) {
    final double totalDiscount = discount + referrerBonusAmount;
    final double shipping = deliveryCharge + additionalCharge;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: _summaryBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('ord_items_total'.tr, subTotal),
          if (shipping > 0) _summaryRow('ord_shipping_fees'.tr, shipping),
          if (extraPackagingCharge > 0)
            _summaryRow('ord_packing_fee'.tr, extraPackagingCharge),
          if (!taxIncluded && tax > 0) _summaryRow('ord_tax'.tr, tax),
          if (dmTips > 0) _summaryRow('ord_driver_tip'.tr, dmTips),
          if (totalDiscount > 0)
            _summaryRow('ord_discount'.tr, totalDiscount, negative: true),
          if (couponDiscount > 0)
            _summaryRow('ord_coupon_code'.tr, couponDiscount, negative: true),
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Divider(height: 1, color: _border),
          ),
          Row(
            children: [
              Text(
                'ord_order_total'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _ink,
                ),
              ),
              const Spacer(),
              Text(
                PriceConverter.convertPrice(total),
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool negative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.6,
              color: _ink,
            ),
          ),
          const Spacer(),
          Text(
            '${negative ? '- ' : ''}${PriceConverter.convertPrice(value)}',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.6,
              color: negative ? _green : _ink,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared bits ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String text, {Color accent = _green}) {
    return Row(
      children: [
        Icon(Icons.bookmark, size: 20, color: accent),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.6,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  String _paymentLabel() {
    switch (order.paymentMethod) {
      case 'cash_on_delivery':
        return 'cash'.tr;
      case 'wallet':
        return 'wallet'.tr;
      case 'partial_payment':
        return 'partial_payment'.tr;
      case 'wallet_qidha':
        return 'ord_qidha'.tr;
      case 'offline_payment':
        return 'offline_payment'.tr;
      case 'digital_payment':
        return 'Credit Card';
      default:
        return (order.paymentMethod ?? '').tr;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // Active layout (preparing / on-the-way) — earlier illustration-hero design,
  // kept until those states get their own designs.
  // ════════════════════════════════════════════════════════════════════════
  Widget _activeLayout() {
    final _StatusVisual status = _StatusVisual.fromStatus(order.orderStatus);
    final double subTotal = itemsPrice + addOns;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusHeader(status),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _sectionTitle('ord_order_details'.tr),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (!parcel && order.store != null) ...[
            _storeCard(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          if (!parcel && orderDetails.isNotEmpty) ...[
            _itemsCard(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          _summaryCard(subTotal),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _paymentBlock(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (!parcel && (order.deliveryAddress?.address ?? '').isNotEmpty) ...[
            _detailBlock('ord_delivery_address'.tr, order.deliveryAddress!.address!),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
          if ((order.createdAt ?? '').isNotEmpty)
            _detailBlock('ord_order_date'.tr,
                DateConverter.dateTimeStringToDateTime(order.createdAt!)),
        ],
      ),
    );
  }

  Widget _statusHeader(_StatusVisual status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeLarge,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: status.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 141,
            child: Image.asset(
              status.illustration,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                Images.shella_bag,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            status.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.4,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${'order_id'.tr} #${order.id}',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: _ink,
              ),
            ),
          ),
          if ((order.otp ?? '').isNotEmpty &&
              (order.orderType ?? '') != 'take_away') ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _deliveryOtpCard(status),
          ],
        ],
      ),
    );
  }

  // رمز التسليم — يظهر للعميل ليعطيه للسائق عند الاستلام (تحقّق التوصيل)
  Widget _deliveryOtpCard(_StatusVisual status) {
    final String code = order.otp ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.accent.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock_outlined, size: 18, color: status.accent),
              const SizedBox(width: 6),
              Text(
                'ord_delivery_code'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // الأرقام تُعرض LTR دائماً حتى لا تنعكس خاناتها في واجهة RTL (3769 لا 9673)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((d) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 44,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: status.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: status.accent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  d,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: status.accent,
                  ),
                ),
              );
            }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ord_give_code_driver'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Color(0xff71807a),
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps a raw order status into the active-state hero: title, illustration and
/// accent colour.
class _StatusVisual {
  final String title;
  final String illustration;
  final Color accent;

  const _StatusVisual({
    required this.title,
    required this.illustration,
    required this.accent,
  });

  factory _StatusVisual.fromStatus(String? status) {
    switch ((status ?? '').toLowerCase().trim()) {
      case 'handover':
      case 'picked_up':
      case 'out_for_delivery':
        return _StatusVisual(
          title: 'ord_on_the_way'.tr,
          illustration: Images.onTheWayImage,
          accent: Color(0xFF1FA64A),
        );
      default:
        // pending / accepted / confirmed / processing
        return _StatusVisual(
          title: 'ord_being_prepared'.tr,
          illustration: Images.orderProccedImage,
          accent: Color(0xFF6B4EFF),
        );
    }
  }
}

/// One tree-style option/add-on line under an order item.
/// [isAddon] = true → a paid extra (shown green); false → a chosen option value.
class _OrderChoiceLine {
  final String text;
  final bool isAddon;

  const _OrderChoiceLine(this.text, {required this.isAddon});
}
