import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class InvoiceBottomSheet extends StatelessWidget {
  final OrderModel order;
  final List<OrderDetailsModel>? orderDetails;

  const InvoiceBottomSheet({super.key, required this.order, this.orderDetails});

  String _formatPrice(double? price) {
    if (price == null) return '0.00';
    return price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final String currency = isArabic ? 'ord_sar'.tr : 'SAR';

    final double total = order.orderAmount ?? 0;
    final double delivery = order.deliveryCharge ?? 0;
    final double serviceFee = order.additionalCharge ?? 0;
    final double tax = order.totalTaxAmount ?? 0;
    final double discount = order.storeDiscountAmount ?? 0;
    final double coupon = order.couponDiscountAmount ?? 0;
    final double tips = order.dmTips ?? 0;

    // Subtotal calculation (Total - Delivery - Tax - Service - Tips + Discounts)
    final double subTotal =
        total - delivery - serviceFee - tax - tips + discount + coupon;

    final double savings = discount + coupon;

    final String paymentMethod =
        (order.paymentMethod ?? '').replaceAll('_', ' ');
    final String paymentStatus = order.paymentStatus == 'paid'
        ? (isArabic ? 'مدفوع' : 'Paid')
        : (isArabic ? 'غير مدفوع' : 'Unpaid');

    final String customerName =
        Get.find<ProfileController>().userInfoModel?.fName ?? '';
    final String customerPhone =
        order.deliveryAddress?.contactPersonNumber ?? '';
    final String storeName = order.store?.name ?? '';
    final String storeLogo = order.store?.logoFullUrl ?? '';
    final String vatNumber = order.store?.tax?.toString() ?? '';

    return Container(
      width: context.width,
      constraints: BoxConstraints(maxHeight: context.height * 0.90),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Header Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
              Text(
                isArabic ? 'الفاتورة' : 'Invoice',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Store Info Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Placeholder for QR
                        Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.qr_code_2,
                              size: 40, color: Theme.of(context).disabledColor),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (storeLogo.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CustomImage(
                                    image: storeLogo,
                                    height: 40,
                                    width: 60,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(storeName,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault)),
                              if (vatNumber.isNotEmpty)
                                Text(
                                    '${isArabic ? 'الرقم الضريبي:' : 'VAT No:'} $vatNumber',
                                    style: robotoRegular.copyWith(
                                        fontSize: 10,
                                        color:
                                            Theme.of(context).disabledColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- Invoice Title Box ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.1)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${isArabic ? 'رقم الفاتورة' : 'Invoice No'}: #${order.id}',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Data List ---
                    if (customerName.isNotEmpty)
                      _buildDataRow(isArabic ? 'اسم العميل' : 'Customer Name',
                          customerName),
                    if (customerPhone.isNotEmpty)
                      _buildDataRow(isArabic ? 'رقم الهاتف' : 'Phone Number',
                          customerPhone,
                          forceLtr: true),

                    if (order.createdAt != null) ...[
                      _buildDataRow(
                          isArabic ? 'تاريخ الفاتورة' : 'Invoice Date',
                          DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(order.createdAt!))),
                      _buildDataRow(
                          isArabic ? 'وقت الإصدار' : 'Issue Time',
                          DateFormat('HH:mm a')
                              .format(DateTime.parse(order.createdAt!))),
                    ],
                    _buildDataRow(isArabic ? 'طريقة الدفع' : 'Payment Method',
                        paymentMethod),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'حالة الدفع' : 'Payment Status',
                              style: robotoMedium.copyWith(
                                  fontSize: 11,
                                  color: Theme.of(context).disabledColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withValues(alpha: 0.1),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.2)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('[ $paymentStatus ]',
                                style: robotoMedium.copyWith(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- Items Table ---
                    if (orderDetails != null && orderDetails!.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: Text(isArabic ? 'المنتج' : 'Item',
                                    style: robotoBold.copyWith(fontSize: 11))),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(isArabic ? 'الكمية' : 'Qty',
                                        style: robotoBold.copyWith(
                                            fontSize: 11)))),
                            Expanded(
                                flex: 2,
                                child: Center(
                                    child: Text(
                                        isArabic ? 'سعر الوحدة' : 'Unit Price',
                                        style: robotoBold.copyWith(
                                            fontSize: 11)))),
                            Expanded(
                                flex: 2,
                                child: Align(
                                    alignment: isArabic
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Text(isArabic ? 'الإجمالي' : 'Total',
                                        style: robotoBold.copyWith(
                                            fontSize: 11)))),
                          ],
                        ),
                      ),
                      ...orderDetails!.map((detail) {
                        final String itemName = detail.itemDetails?.name ??
                            (isArabic ? 'منتج' : 'Item');
                        final double price = detail.price ?? 0;
                        final int qty = detail.quantity ?? 1;
                        final double lineTotal = price * qty;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.1),
                                    style: BorderStyle.solid)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Text(itemName,
                                      style:
                                          robotoMedium.copyWith(fontSize: 11))),
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(qty.toString(),
                                          style: robotoMedium.copyWith(
                                              fontSize: 11)))),
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Text(_formatPrice(price),
                                          style: robotoMedium.copyWith(
                                              fontSize: 11)),
                                      Text(currency,
                                          style: robotoRegular.copyWith(
                                              fontSize: 9,
                                              color: Theme.of(context)
                                                  .disabledColor)),
                                    ],
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: isArabic
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Text(_formatPrice(lineTotal),
                                          style: robotoMedium.copyWith(
                                              fontSize: 11)),
                                      Text(currency,
                                          style: robotoRegular.copyWith(
                                              fontSize: 9,
                                              color: Theme.of(context)
                                                  .disabledColor)),
                                    ],
                                  )),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ] else ...[
                      // If orderDetails not available yet
                      Center(
                        child: Text(
                            isArabic
                                ? 'لم يتم تحميل المنتجات'
                                : 'Items not loaded',
                            style: robotoRegular.copyWith(
                                fontSize: 11,
                                color: Theme.of(context).disabledColor)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // --- Summary List ---
                    _buildSummaryRow(
                        isArabic ? 'إجمالي المنتجات' : 'Items Total',
                        subTotal,
                        currency),
                    if (discount > 0)
                      _buildSummaryRow(
                          isArabic ? 'الخصم' : 'Discount', discount, currency),
                    if (coupon > 0)
                      _buildSummaryRow(isArabic ? 'كوبون الخصم' : 'Coupon',
                          coupon, currency),
                    if (tax > 0 || serviceFee > 0)
                      _buildSummaryRow(
                          isArabic ? 'رسوم الخدمة والضريبة' : 'Service & Tax',
                          tax + serviceFee,
                          currency),
                    if (order.orderType == 'delivery')
                      _buildSummaryRow(
                          isArabic ? 'رسوم التوصيل' : 'Delivery Fee',
                          delivery,
                          currency,
                          isFree: delivery == 0),
                    if (tips > 0)
                      _buildSummaryRow(
                          isArabic ? 'إكرامية السائق' : 'Driver Tips',
                          tips,
                          currency),

                    if (savings > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.2),
                                    style: BorderStyle.solid))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isArabic ? 'وفّرت في هذا الطلب' : 'You saved',
                                style: robotoBold.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF22C55E))),
                            Text('${_formatPrice(savings)} $currency',
                                style: robotoBold.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF22C55E))),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // --- Grand Total Box ---
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'الإجمالي المدفوع' : 'Grand Total',
                              style: robotoBold.copyWith(fontSize: 13)),
                          Text('${_formatPrice(total)} $currency',
                              style: robotoBold.copyWith(fontSize: 15)),
                        ],
                      ),
                    ),

                    // --- Footer Message ---
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.2),
                                  style: BorderStyle.solid))),
                      alignment: Alignment.center,
                      child: Text(
                        '${isArabic ? 'شكراً لطلبكم من' : 'Thank you for ordering from'} $storeName',
                        style: robotoBold.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).disabledColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool forceLtr = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: robotoMedium.copyWith(
                  fontSize: 11, color: const Color(0xFF64748B))),
          Text(
            value,
            style: robotoBold.copyWith(fontSize: 12),
            textDirection: forceLtr ? ui.TextDirection.ltr : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, String currency,
      {bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: robotoMedium.copyWith(
                  fontSize: 11, color: const Color(0xFF64748B))),
          Text(
            isFree
                ? (Get.locale?.languageCode == 'ar' ? 'مجاناً' : 'Free')
                : '${_formatPrice(value)} $currency',
            style: robotoBold.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
