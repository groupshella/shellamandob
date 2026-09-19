// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/pos/controllers/pos_checkout_controller.dart';
import 'package:sixam_mart/features/pos/domain/models/pos_checkout_model.dart';
import 'package:sixam_mart/features/pos/domain/repositories/pos_checkout_repository.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PosCheckoutScreen extends StatefulWidget {
  final String token;

  const PosCheckoutScreen({super.key, required this.token});

  @override
  State<PosCheckoutScreen> createState() => _PosCheckoutScreenState();
}

class _PosCheckoutScreenState extends State<PosCheckoutScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PosCheckoutRepository>()) {
      Get.lazyPut(() => PosCheckoutRepository(apiClient: Get.find()),
          fenix: true);
    }
    if (!Get.isRegistered<PosCheckoutController>()) {
      Get.lazyPut(
          () => PosCheckoutController(
              repository: Get.find(), sharedPreferences: Get.find()),
          fenix: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<PosCheckoutController>()) {
        Get.find<PosCheckoutController>().resolveAndClaim(widget.token);
      }
      if (Get.find<AuthController>().isLoggedIn()) {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getUserInfo();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Modern Header
            _buildTopBar(context),

            // Content Body
            Expanded(
              child: GetBuilder<PosCheckoutController>(
                init: Get.find<PosCheckoutController>(),
                builder: (controller) {
                  if (controller.isLoading) {
                    return _buildLoadingState();
                  }

                  // 1. Unauthenticated Customer State
                  if (!isLoggedIn) {
                    return _buildAuthRequiredState();
                  }

                  // 2. Error / Expired State
                  if (controller.errorMessage != null ||
                      controller.order == null) {
                    return _buildErrorState(controller);
                  }

                  final PosCheckoutOrderModel order = controller.order!;

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: 12),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Store Card
                              _buildStoreHeader(order),
                              const SizedBox(height: 14),

                              // Order Items Details
                              _buildOrderItemsSection(order),
                              const SizedBox(height: 14),

                              // Price Breakdown
                              _buildPriceSummary(order),
                              const SizedBox(height: 14),

                              // Payment Method Selector
                              _buildPaymentMethodSection(controller, order),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Sticky Checkout Bar
                      _buildBottomPayBar(controller, order),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8ECEB), width: 1),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8ECEB)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF121C19),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'دفع طلب الكاشير',
                  style: robotoBold.copyWith(
                    fontSize: 17,
                    color: const Color(0xFF121C19),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الدفع عبر تطبيق شلة',
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF7A8B84),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF22A45D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 14,
                  color: Color(0xFF22A45D),
                ),
                const SizedBox(width: 4),
                Text(
                  'POS مباشر',
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF22A45D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF22A45D),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري جلب تفاصيل الطلب من الكاشير...',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: const Color(0xFF4A5550),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthRequiredState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF22A45D).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                size: 48,
                color: Color(0xFF22A45D),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تسجيل الدخول مطلوب',
              style: robotoBold.copyWith(
                fontSize: 20,
                color: const Color(0xFF121C19),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى تسجيل الدخول أو إنشاء حساب لإتمام دفع طلب الكاشير وربط الفاتورة برقمك للحصول على نقاط الولاء.',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: const Color(0xFF7A8B84),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              buttonText: 'login_or_create_account'.tr,
              onPressed: () {
                Get.toNamed(RouteHelper.getSignInRoute(
                    RouteHelper.getPosCheckoutRoute(widget.token)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(PosCheckoutController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (controller.isExpired
                          ? Colors.amber
                          : const Color(0xFFE53935))
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.isExpired
                      ? Icons.timer_off_outlined
                      : Icons.error_outline_rounded,
                  size: 44,
                  color: controller.isExpired
                      ? Colors.amber.shade800
                      : const Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                controller.isExpired
                    ? 'انتهت صلاحية الجلسة'
                    : 'تعذر تحميل الطلب',
                style: robotoBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF121C19),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage ??
                    'طلب الكاشير غير متاح أو تم إلغاؤه من قبل المتجر.',
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF7A8B84),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF22A45D)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        controller.resolveAndClaim(widget.token);
                      },
                      child: Text(
                        'إعادة المحاولة',
                        style: robotoBold.copyWith(
                          color: const Color(0xFF22A45D),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF121C19),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          Get.offAllNamed(RouteHelper.getInitialRoute()),
                      child: Text(
                        'الرئيسية',
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: 14,
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
    );
  }

  Widget _buildStoreHeader(PosCheckoutOrderModel order) {
    final store = order.store;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImage(
              image: store?.logo ?? '',
              height: 52,
              width: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        store?.name ?? 'المتجر',
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: const Color(0xFF121C19),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (order.orderId != null) {
                          Clipboard.setData(
                              ClipboardData(text: order.orderId!));
                          showCustomSnackBar('order_number_copied'.tr,
                              isError: false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8ECEB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#${order.orderId ?? ""}',
                              style: robotoBold.copyWith(
                                fontSize: 11,
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
                const SizedBox(height: 4),
                Text(
                  store?.address ?? 'طلب مباشر من الكاشير بالفرع',
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF7A8B84),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(PosCheckoutOrderModel order) {
    final int itemsCount = order.items?.length ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تفاصيل الفاتورة',
                style: robotoBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF121C19),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$itemsCount أصناف',
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF7A8B84),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE8ECEB)),
          if (order.items != null && order.items!.isNotEmpty) ...[
            ListView.separated(
              itemCount: order.items!.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) =>
                  const Divider(height: 20, color: Color(0xFFF4F6F5)),
              itemBuilder: (context, index) {
                final item = order.items![index];
                final double lineTotal = item.lineTotal ??
                    ((item.price ?? 0.0) * (item.quantity ?? 1));
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF22A45D).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: robotoBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF22A45D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF121C19),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      PriceConverter.convertPrice(lineTotal),
                      style: robotoBold.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF121C19),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSummary(PosCheckoutOrderModel order) {
    final double subtotal =
        (order.orderAmount ?? 0.0) - (order.totalTaxAmount ?? 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الدفع',
            style: robotoBold.copyWith(
              fontSize: 15,
              color: const Color(0xFF121C19),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'المجموع الفرعي',
            PriceConverter.convertPrice(subtotal > 0 ? subtotal : order.orderAmount),
          ),
          if ((order.storeDiscountAmount ?? 0.0) > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'خصم المتجر',
              '-${PriceConverter.convertPrice(order.storeDiscountAmount)}',
              isDiscount: true,
            ),
          ],
          if ((order.couponDiscountAmount ?? 0.0) > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'خصم الكوبون',
              '-${PriceConverter.convertPrice(order.couponDiscountAmount)}',
              isDiscount: true,
            ),
          ],
          if ((order.totalTaxAmount ?? 0.0) > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'ضريبة القيمة المضافة (15%)',
              PriceConverter.convertPrice(order.totalTaxAmount ?? 0.0),
            ),
          ],
          const Divider(height: 24, color: Color(0xFFE8ECEB)),
          _buildSummaryRow(
            'المبلغ المطلوب سداده',
            PriceConverter.convertPrice(order.orderAmount),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? robotoBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF121C19),
                )
              : robotoRegular.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF7A8B84),
                ),
        ),
        Text(
          value,
          style: isTotal
              ? robotoBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF22A45D),
                )
              : isDiscount
                  ? robotoMedium.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF22A45D),
                    )
                  : robotoMedium.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF121C19),
                    ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(
      PosCheckoutController controller, PosCheckoutOrderModel order) {
    final double walletBalance =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;
    final bool canPayWithWallet =
        walletBalance >= (order.orderAmount ?? 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طريقة الدفع',
            style: robotoBold.copyWith(
              fontSize: 15,
              color: const Color(0xFF121C19),
            ),
          ),
          const SizedBox(height: 12),

          // 1. Digital Payment (Apple Pay, Mada, Cards)
          _buildPaymentCard(
            title: 'electronic_payment_options'.tr,
            subtitle: 'fast_secure_payment'.tr,
            icon: Icons.credit_card_rounded,
            value: 'digital_payment',
            groupValue: controller.selectedPaymentMethod,
            onTap: () => controller.setSelectedPaymentMethod('digital_payment'),
          ),
          const SizedBox(height: 10),

          // 2. Shella Wallet
          _buildPaymentCard(
            title: 'shella_wallet'.tr,
            subtitle:
                '${'available_balance'.tr}: ${PriceConverter.convertPrice(walletBalance)}',
            icon: Icons.account_balance_wallet_rounded,
            value: 'wallet',
            groupValue: controller.selectedPaymentMethod,
            badge: canPayWithWallet
                ? 'sufficient_balance'.tr
                : 'insufficient_balance'.tr,
            badgeColor: canPayWithWallet
                ? const Color(0xFF22A45D)
                : const Color(0xFFE53935),
            enabled: canPayWithWallet,
            onTap: canPayWithWallet
                ? () => controller.setSelectedPaymentMethod('wallet')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    String? badge,
    Color? badgeColor,
    bool enabled = true,
    required VoidCallback? onTap,
  }) {
    final bool isSelected = value == groupValue;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF22A45D).withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF22A45D)
                  : const Color(0xFFE8ECEB),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF22A45D).withValues(alpha: 0.1)
                      : const Color(0xFFF4F6F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF22A45D)
                      : const Color(0xFF7A8B84),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: robotoBold.copyWith(
                              fontSize: 13,
                              color: const Color(0xFF121C19),
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? const Color(0xFF22A45D))
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: robotoMedium.copyWith(
                                fontSize: 9,
                                color:
                                    badgeColor ?? const Color(0xFF22A45D),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF7A8B84),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF22A45D)
                        : const Color(0xFFD0D7D4),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF22A45D),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPayBar(
      PosCheckoutController controller, PosCheckoutOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المبلغ الإجمالي',
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF7A8B84),
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
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                buttonText: 'confirm_and_pay_order'.tr,
                isLoading: controller.isPaying,
                onPressed: () {
                  controller.initiatePayment(widget.token);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
