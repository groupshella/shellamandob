// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final String? contactPersonNumber;
  final bool? createAccount;
  final String guestId;

  const OrderSuccessfulScreen({
    super.key,
    required this.orderID,
    this.contactPersonNumber,
    this.createAccount = false,
    required this.guestId,
  });

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  bool? _isCashOnDeliveryActive = false;
  String? orderId;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID ?? '0';
    if (widget.orderID != null) {
      if (widget.orderID!.contains('?')) {
        final parts = widget.orderID!.split('?');
        final String id = parts[0].trim();
        orderId = id;
      }
    }

    Get.find<OrderController>().trackOrder(
      orderId.toString(),
      null,
      false,
      contactNumber: widget.contactPersonNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        body: GetBuilder<OrderController>(builder: (orderController) {
          double earnedPoints = 0;
          bool success = true;
          bool parcel = false;
          bool isPosOrder = false;
          double? maximumCodOrderAmount;

          if (orderController.trackModel != null) {
            final OrderModel track = orderController.trackModel!;
            final double purchasePoint = (Get.find<SplashController>()
                        .configModel
                        ?.loyaltyPointItemPurchasePoint ??
                    0)
                .toDouble();
            final double orderAmount = track.orderAmount ?? 0.0;
            earnedPoints = (orderAmount / 100) * purchasePoint;

            isPosOrder = track.orderType == 'pos';
            success = track.paymentStatus == 'paid' ||
                track.paymentMethod == 'cash_on_delivery' ||
                track.paymentMethod == 'partial_payment';
            parcel = track.paymentMethod == 'parcel';

            // Clear cart when payment is confirmed as paid
            if (success && track.paymentStatus == 'paid') {
              Get.find<CheckoutController>().clearCartOnPaymentConfirmed();
            }

            final userAddress = AddressHelper.getUserAddressFromSharedPref();
            if (userAddress?.zoneData != null) {
              for (final ZoneData zData in userAddress!.zoneData!) {
                for (final Modules m in zData.modules ?? []) {
                  if (m.id == Get.find<SplashController>().module?.id) {
                    maximumCodOrderAmount = m.pivot?.maximumCodOrderAmount;
                    break;
                  }
                }
                if (zData.id == userAddress.zoneId) {
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
              }
            }

            if (!success &&
                !(Get.isDialogOpen ?? false) &&
                track.orderStatus != 'canceled' &&
                Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
              Future.delayed(const Duration(seconds: 1), () {
                Get.dialog(
                  PaymentFailedDialog(
                    orderID: orderId,
                    isCashOnDelivery: _isCashOnDeliveryActive,
                    orderAmount: earnedPoints,
                    maxCodOrderAmount: maximumCodOrderAmount,
                    orderType: parcel ? 'parcel' : 'delivery',
                    guestId: widget.guestId,
                  ),
                  barrierDismissible: false,
                );
              });
            }
          }

          if (orderController.trackModel == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22A45D)),
            );
          }

          final OrderModel order = orderController.trackModel!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault, vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: FooterView(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Animated Celebration Checkmark
                      _buildSuccessIcon(success),
                      const SizedBox(height: 18),

                      // 2. Title & Subtitle
                      Text(
                        success
                            ? isPosOrder
                                ? 'تم دفع طلب الكاشير بنجاح!'
                                : parcel
                                    ? 'you_placed_the_parcel_request_successfully'.tr
                                    : 'you_placed_the_order_successfully'.tr
                            : 'your_order_is_failed_to_place'.tr,
                        textAlign: TextAlign.center,
                        style: robotoBold.copyWith(
                          fontSize: 22,
                          color: const Color(0xFF121C19),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          success
                              ? isPosOrder
                                  ? 'تم تأكيد الفاتورة وربطها بحسابك بنجاح في نظام الكاشير.'
                                  : parcel
                                      ? 'your_parcel_request_is_placed_successfully'.tr
                                      : 'your_order_is_placed_successfully'.tr
                              : 'your_order_is_failed_to_place_because'.tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: const Color(0xFF7A8B84),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Digital Receipt Card
                      _buildReceiptCard(order, isPosOrder),
                      const SizedBox(height: 16),

                      // 4. Loyalty Points Earned Card (if applicable)
                      if (success &&
                          earnedPoints.floor() > 0 &&
                          (Get.find<SplashController>()
                                      .configModel
                                      ?.loyaltyPointStatus ??
                                  0) ==
                              1 &&
                          AuthHelper.isLoggedIn()) ...[
                        _buildLoyaltyPointsBadge(earnedPoints.floor()),
                        const SizedBox(height: 16),
                      ],

                      // 5. Create Account Banner (for guests)
                      if (widget.createAccount ?? false) ...[
                        _buildCreateAccountPrompt(),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 12),

                      // 6. Action Buttons
                      _buildActionButtons(order, earnedPoints),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSuccessIcon(bool success) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: (success ? const Color(0xFF22A45D) : const Color(0xFFE53935))
            .withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: success ? const Color(0xFF22A45D) : const Color(0xFFE53935),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (success
                        ? const Color(0xFF22A45D)
                        : const Color(0xFFE53935))
                    .withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            success ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(OrderModel order, bool isPosOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Store & Order ID Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22A45D).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPosOrder
                          ? Icons.storefront_rounded
                          : Icons.receipt_long_rounded,
                      size: 16,
                      color: const Color(0xFF22A45D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.store?.name ??
                        (isPosOrder ? 'طلب كاشير POS' : 'طلب شلة'),
                    style: robotoBold.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF121C19),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: order.id?.toString() ?? orderId ?? ''));
                  showCustomSnackBar('تم نسخ رقم الطلب', isError: false);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8ECEB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${order.id ?? orderId}',
                        style: robotoBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF22A45D),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.copy_rounded,
                        size: 12,
                        color: Color(0xFF7A8B84),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE8ECEB)),

          // Date Row
          if (order.createdAt != null) ...[
            _buildReceiptRow(
              'تاريخ وتوقيت الطلب',
              DateConverter.isoStringToLocalDateOnly(order.createdAt!),
            ),
            const SizedBox(height: 10),
          ],

          // Payment Method Row
          _buildReceiptRow(
            'طريقة الدفع',
            order.paymentMethod == 'wallet'
                ? 'محفظة شلة'
                : order.paymentMethod == 'digital_payment' ||
                        order.paymentMethod == 'pos'
                    ? 'دفع إلكتروني (مدى / فيزا)'
                    : order.paymentMethod?.tr ?? 'دفع إلكتروني',
            customValueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF22A45D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: Color(0xFF22A45D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentStatus == 'paid'
                        ? 'مدفوع بالكامل'
                        : order.paymentStatus?.tr ?? 'مدفوع',
                    style: robotoBold.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF22A45D),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Total Paid Amount Row
          const Divider(height: 20, color: Color(0xFFE8ECEB)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ الإجمالي المدفوع',
                style: robotoBold.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF121C19),
                ),
              ),
              Text(
                PriceConverter.convertPrice(order.orderAmount),
                style: robotoBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF22A45D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {Widget? customValueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 12,
            color: const Color(0xFF7A8B84),
          ),
        ),
        customValueWidget ??
          Text(
            value,
            style: robotoMedium.copyWith(
              fontSize: 12,
              color: const Color(0xFF121C19),
            ),
          ),
      ],
    );
  }

  Widget _buildLoyaltyPointsBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF22A45D).withValues(alpha: 0.12),
            const Color(0xFF55E795).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF22A45D).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF22A45D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مبروك! حصلت على $points نقطة ولاء',
                  style: robotoBold.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF121C19),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تمت إضافة النقاط تلقائياً إلى رصيد محفظتك لاستخدامها لاحقاً.',
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF7A8B84),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountPrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'and_create_account_successfully'.tr,
            style: robotoMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              if (ResponsiveHelper.isDesktop(context)) {
                Get.dialog(const Center(
                    child: AuthDialogWidget(
                        exitFromApp: false, backFromThis: false)));
              } else {
                Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
              }
            },
            child: Text(
              'sign_in'.tr,
              style: robotoBold.copyWith(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, double earnedPoints) {
    return Column(
      children: [
        // Primary Button: Back to Home
        CustomButton(
          buttonText: 'العودة للرئيسية',
          onPressed: () {
            if (AuthHelper.isLoggedIn()) {
              Get.find<AuthController>()
                  .saveEarningPoint(earnedPoints.toStringAsFixed(0));
            }
            Get.offAllNamed(RouteHelper.getInitialRoute());
          },
        ),
        const SizedBox(height: 12),

        // Secondary Button: View Order Details / Receipt
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: Color(0xFFE8ECEB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            backgroundColor: Colors.white,
          ),
          onPressed: () {
            final int? id = order.id ?? int.tryParse(orderId ?? '');
            if (id != null) {
              Get.toNamed(RouteHelper.getOrderDetailsRoute(id,
                  fromNotification: false));
            } else {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_outlined,
                size: 18,
                color: Color(0xFF121C19),
              ),
              const SizedBox(width: 8),
              Text(
                'عرض تفاصيل الفاتورة',
                style: robotoBold.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF121C19),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
