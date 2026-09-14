// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';

class PaymentSection extends StatefulWidget {
  final Widget? partialPayView;
  final Widget? Kaidha_Wallat_PayView;

  final int? storeId;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;

  const PaymentSection({
    super.key,
    required this.partialPayView,
    required this.Kaidha_Wallat_PayView,
    this.storeId,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.isOfflinePaymentActive,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  CheckoutController checkoutController = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
        id: 'payment', // ✅ استخدام ID لتحديث جزئي
        builder: (checkoutController) {
          return Column(
            children: [
              //

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                    widget.storeId != null
                        ? 'payment_method'.tr
                        : 'choose_payment_method'.tr,
                    textAlign: TextAlign.right,
                    style: tajawalBold.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      letterSpacing: 0,
                    )),
                // widget.storeId == null && !ResponsiveHelper.isDesktop(context)
                //     ? InkWell(
                //         onTap: () {
                //            Get.bottomSheet(
                //            const PaymentMethodBottomSheet(),
                //            backgroundColor: Colors.transparent,
                //               isScrollControlled: true,
                //          );
                //         },
                //         child: Image.asset(Images.paymentSelect, height: 26, width: 26),
                //       )
                //     : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              //

              SizedBox(height: Dimensions.fontSizeSmall),

              // PaymentButtons(
              //   checkoutController: checkoutController,
              //   partialPayView: widget.partialPayView,
              // ),

              GetBuilder<KaidhaSubscriptionController>(
                  builder: (KaidhaSub_Controller) {
                return GetBuilder<ProfileController>(
                    builder: (profileController) {
                  debugPrint(
                      '🔍 [PaymentSection] widget.storeId=${widget.storeId}, checkout.storeId=${checkoutController.store?.id}, checkout.shellaWallet=${checkoutController.store?.shellaWallet}');
                  if (Get.isRegistered<StoreController>()) {
                    debugPrint(
                        '🔍 [PaymentSection] StoreController.storeId=${Get.find<StoreController>().store?.id}, StoreController.shellaWallet=${Get.find<StoreController>().store?.shellaWallet}');
                  }
                  return Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPaymentOption(
                            context: context,
                            label: 'my_wallet'.tr,
                            icon: Icons.account_balance_wallet_outlined,
                            imageAsset: Images.myWalletIcon,
                            index: 2,
                            onTap: () {
                              // Guard null FIRST — the old order unwrapped
                              // userInfoModel! before the == null check, so a
                              // not-yet-loaded profile crashed on tapping wallet.
                              final info = profileController.userInfoModel;
                              if (info == null ||
                                  info.walletBalance == null ||
                                  info.walletBalance == 0.0) {
                                _showEmptyWalletBottomSheet();
                                return;
                              }

                              setState(() {
                                checkoutController.selectedButton = 2;
                                checkoutController.select_payment_Methods =
                                    null;
                              });

                              if (checkoutController.isKaidhaPay == true) {
                                //"قيدها"
                                checkoutController.change_Kaidha_Pay();
                              }

                              if (widget.partialPayView != null) {
                                if (kDebugMode) {
                                  debugPrint(
                                    '[PaymentMethod][BOTTOM_OPEN] partialWallet sheet',
                                  );
                                }
                                Get.bottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF1E293B)
                                          : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.vertical(
                                        top: const Radius.circular(
                                            Dimensions.radiusLarge),
                                        bottom: Radius.circular(
                                            ResponsiveHelper.isDesktop(context)
                                                ? Dimensions.radiusLarge
                                                : 0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeLarge,
                                      vertical: Dimensions.paddingSizeLarge,
                                    ),
                                    child: widget.partialPayView,
                                  ),
                                );
                              }
                            },
                          ),
                          if (checkoutController.store?.shellaWallet == true ||
                              (Get.isRegistered<StoreController>() &&
                                  Get.find<StoreController>().store?.shellaWallet == true))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: _buildPaymentOption(
                                context: context,
                                label: 'kiadha_wallet'.tr,
                                icon: Icons.credit_card_outlined,
                                imageAsset: Images.quidhaWalletIcon,
                                index: 0,
                                onTap: () {
                                  debugPrint('[QIDHA_CHECKOUT][SELECTED]');
                                  final userInfo =
                                      profileController.userInfoModel;
                                  // Source of truth for the wallet state is the
                                  // KaidhaSubscriptionController (same source as
                                  // the displayed balance); fall back to the
                                  // profile flags only when it's unavailable. This
                                  // fixes the "subscription required" prompt
                                  // showing even though a funded, active wallet
                                  // already exists.
                                  final walletModel =
                                      KaidhaSub_Controller.walletKaidhaModel;
                                  final wallet = walletModel?.wallet;
                                  final bool hasWallet =
                                      walletModel?.hasWallet == true ||
                                          wallet != null ||
                                          userInfo?.hasQidhaWallet == true;
                                  // Type-robust checks: the API may return these
                                  // as int (1), string ("1") or bool, so compare
                                  // on the stringified value. A non-empty
                                  // signature path also implies a signed contract.
                                  final String sigStatus =
                                      wallet?.signatureStatus?.toString() ?? '';
                                  final String walletStatus = wallet?.status
                                          ?.toString()
                                          .toLowerCase() ??
                                      '';
                                  final bool hasSignaturePath =
                                      (wallet?.signaturePath?.toString() ?? '')
                                          .isNotEmpty;
                                  final bool isSigned = sigStatus == '1' ||
                                      sigStatus == 'true' ||
                                      hasSignaturePath ||
                                      userInfo?.qidhaWalletSigned == true;
                                  final bool isActive =
                                      walletStatus == 'active' ||
                                          walletStatus == '1' ||
                                          walletStatus == 'true' ||
                                          userInfo?.qidhaWalletActive == true;
                                  final double profileBalance =
                                      userInfo?.qidhaWalletBalance ?? 0.0;
                                  double walletBalance = double.tryParse(
                                          '${wallet?.availableBalance ?? profileBalance}') ??
                                      profileBalance;

                                  final int? currentStoreId = widget.storeId ??
                                      (Get.isRegistered<StoreController>()
                                          ? Get.find<StoreController>().store?.id
                                          : null);
                                  if (currentStoreId != null && currentStoreId != 1) {
                                    final storeCtrl = Get.isRegistered<StoreController>()
                                        ? Get.find<StoreController>()
                                        : null;
                                    final double? storeBal = storeCtrl?.store?.id == currentStoreId
                                        ? (storeCtrl?.store?.qidhaAvailableBalance ?? storeCtrl?.store?.qidhaCreditLimit)
                                        : KaidhaSub_Controller.getStoreContractBalance(currentStoreId);
                                    if (storeBal != null) {
                                      walletBalance = storeBal;
                                    }
                                  }
                                  debugPrint(
                                      '[QIDHA_CHECKOUT][STATUS] storeId=$currentStoreId hasWallet=$hasWallet signed=$isSigned active=$isActive balance=$walletBalance '
                                      'rawSigStatus=${wallet?.signatureStatus} rawStatus=${wallet?.status} rawSigPath=${wallet?.signaturePath}');

                                  if (!hasWallet || !isSigned || !isActive) {
                                    debugPrint(
                                        '[QIDHA_CHECKOUT][REDIRECT] customer not subscribed/active. Redirecting to subscription flow.');
                                    Get.toNamed(RouteHelper
                                            .getKiadaWalletSubscription())
                                        ?.then((_) async {
                                      // Refresh status on return
                                      await KaidhaSub_Controller
                                          .get_Wallet_Kaidh(forceRefresh: true);
                                      await profileController.getUserInfo(
                                          forceRefresh: true);

                                      // Re-read status
                                      final updatedWallet = KaidhaSub_Controller
                                          .walletKaidhaModel?.wallet;
                                      final updatedUserInfo =
                                          profileController.userInfoModel;
                                      final bool updatedHasWallet =
                                          KaidhaSub_Controller.walletKaidhaModel
                                                      ?.hasWallet ==
                                                  true ||
                                              updatedWallet != null ||
                                              updatedUserInfo?.hasQidhaWallet ==
                                                  true;
                                      final String updatedSigStatus =
                                          updatedWallet?.signatureStatus
                                                  ?.toString() ??
                                              '';
                                      final String updatedWalletStatus =
                                          updatedWallet?.status
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              '';
                                      final bool updatedHasSignaturePath =
                                          (updatedWallet?.signaturePath
                                                      ?.toString() ??
                                                  '')
                                              .isNotEmpty;
                                      final bool updatedIsSigned =
                                          updatedSigStatus == '1' ||
                                              updatedSigStatus == 'true' ||
                                              updatedHasSignaturePath ||
                                              updatedUserInfo
                                                      ?.qidhaWalletSigned ==
                                                  true;
                                      final bool updatedIsActive =
                                          updatedWalletStatus == 'active' ||
                                              updatedWalletStatus == '1' ||
                                              updatedWalletStatus == 'true' ||
                                              updatedUserInfo
                                                      ?.qidhaWalletActive ==
                                                  true;

                                      if (updatedHasWallet &&
                                          updatedIsSigned &&
                                          updatedIsActive) {
                                        // Auto-select and set state
                                        setState(() {
                                          checkoutController.selectedButton = 0;
                                          checkoutController
                                              .select_payment_Methods = null;
                                        });
                                        checkoutController.setPaymentMethod(0);
                                        if (checkoutController.isKaidhaPay ==
                                            false) {
                                          checkoutController
                                              .change_Kaidha_Pay();
                                        }
                                        if (checkoutController.isPartialPay ==
                                            true) {
                                          checkoutController
                                              .changePartialPayment();
                                        }
                                        if (checkoutController.isMy_Pay ==
                                            true) {
                                          checkoutController.change_My_Pay();
                                        }
                                      }
                                    });
                                    return;
                                  }

                                  if (walletBalance < widget.total) {
                                    debugPrint(
                                        '[QIDHA_CHECKOUT][BLOCKED] reason=insufficient_balance');
                                    showCustomSnackBar(
                                        'insufficient_qidha_balance'.tr);
                                    return;
                                  }
                                  if (KaidhaSub_Controller.walletKaidhaModel ==
                                          null ||
                                      KaidhaSub_Controller
                                              .walletKaidhaModel!.wallet ==
                                          null) {
                                    debugPrint(
                                        '[QIDHA_CHECKOUT][ERROR] reason=api_unavailable');
                                    showCustomSnackBar(
                                        'محفظة قيدها غير متاحة - يرجى المحاولة لاحقًا');
                                    return;
                                  }

                                  setState(() {
                                    checkoutController.selectedButton = 0;
                                    checkoutController.select_payment_Methods =
                                        null;
                                  });

                                  checkoutController.setPaymentMethod(0);

                                  // Ensure Qidha wallet is enabled
                                  if (checkoutController.isKaidhaPay == false) {
                                    checkoutController.change_Kaidha_Pay();
                                  }

                                  if (checkoutController.isPartialPay == true) {
                                    //"محفظتي"
                                    checkoutController.changePartialPayment();
                                  }
                                  if (checkoutController.isMy_Pay == true) {
                                    //عادي
                                    checkoutController.change_My_Pay();
                                  }

                                  if (widget.Kaidha_Wallat_PayView != null) {
                                    Get.bottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF1E293B)
                                              : Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.vertical(
                                            top: const Radius.circular(
                                                Dimensions.radiusLarge),
                                            bottom: Radius.circular(
                                                ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? Dimensions.radiusLarge
                                                    : 0),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeLarge,
                                          vertical: Dimensions.paddingSizeLarge,
                                        ),
                                        child: widget.Kaidha_Wallat_PayView,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          if (checkoutController.store?.shellaWallet == true)
                            const SizedBox(width: 4),

                          _buildPaymentOption(
                            context: context,
                            label: 'my_bill_wallet'.tr,
                            icon: Icons.receipt_long_outlined,
                            imageAsset: Images.receiptAddIcon,
                            index: 1,
                            onTap: () {
                              setState(() {
                                checkoutController.selectedButton = 1;
                              });

                              checkoutController.setPaymentMethod(2);

                              if (checkoutController.isKaidhaPay == true) {
                                //"قيدها"
                                checkoutController.change_Kaidha_Pay();
                              }

                              if (checkoutController.isMy_Pay == true) {
                                //عادي
                                checkoutController.change_My_Pay();
                              }

                              Get.bottomSheet(
                                const PaymentMethodBottomSheet(),
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                              ).then((_) {
                                setState(() {});
                              });
                            },
                          ),

                          //
                        ],
                      ),
                    ),
                  );
                });
              }),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Inline warning shown when the user taps pay without picking a
              // payment method. Cleared automatically once a method is selected.
              if (checkoutController.payMethodError)
                Builder(builder: (context) {
                  final bool isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3A3320)
                          : const Color(0xFFFCF0D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'please_select_payment_method'.tr,
                            textAlign: TextAlign.right,
                            style: tajawalBold.copyWith(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark
                                  ? const Color(0xFFF5E6C8)
                                  : const Color(0xFF121C19),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFFF5E6C8)
                                : const Color(0xFF1C1C1C),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.priority_high,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF3A3320)
                                  : Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        });
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required int index,
    required VoidCallback onTap,
    String? imageAsset,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = index == 0
        ? checkoutController.paymentMethodIndex == 0
        : index == 1
            ? checkoutController.paymentMethodIndex == 2
            : checkoutController.paymentMethodIndex == 1;

    // Active container background per design.
    const Color activeBg = Color(0xFFF0FDF4); // Very light green
    final Color inactiveBg = isDark ? Colors.transparent : Colors.white;

    final Color borderColor = isSelected
        ? Theme.of(context).primaryColor
        : (isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0)); // subtle grey
    final Color backgroundColor = isSelected ? activeBg : inactiveBg;

    // Icon is always black/dark (or white in dark mode)
    final Color restIcon =
        (isDark && !isSelected) ? Colors.white : const Color(0xFF1E293B);
    final Color iconColor = restIcon;

    // Label is always black/dark (or white in dark mode)
    final Color labelColor =
        (isDark && !isSelected) ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 130,
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon inside a soft tinted circle.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800] : const Color(0xFFF8FAFC),
              ),
              child: Center(
                child: imageAsset != null
                    ? Image.asset(imageAsset,
                        width: 22, height: 22, color: iconColor)
                    : Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: tajawalBold.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0,
                  color: labelColor),
            ),
            const SizedBox(height: 6),
            _buildWalletBalance(context, index),
          ],
        ),
      ),
    );
  }

  /// Balance line under a payment card. Wallet/Qidha show the amount with the
  /// SAR currency symbol; digital payment shows the "secure pay" label.
  Widget _buildWalletBalance(BuildContext context, int index) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = index == 0
        ? checkoutController.paymentMethodIndex == 0
        : index == 1
            ? checkoutController.paymentMethodIndex == 2
            : checkoutController.paymentMethodIndex == 1;

    final Color textColor =
        isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B);
    final TextStyle style = tajawalMedium.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0,
      color: (isDark && !isSelected) ? Colors.white70 : textColor,
    );

    if (index == 1) {
      // Digital Payment
      return Text('secure_payment'.tr,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }

    double balance = 0.0;
    if (index == 0) {
      // Qidha Wallet
      final kaidhaController = Get.find<KaidhaSubscriptionController>();
      final storeCtrl = Get.isRegistered<StoreController>() ? Get.find<StoreController>() : null;
      final currentStore = checkoutController.store ?? storeCtrl?.store;
      final int? currentStoreId = widget.storeId ?? currentStore?.id;

      if (currentStoreId != null && currentStoreId != 1) {
        final double? storeBal = (currentStore?.id == currentStoreId
                ? (currentStore?.qidhaAvailableBalance ?? currentStore?.qidhaCreditLimit)
                : null) ??
            kaidhaController.getStoreContractBalance(currentStoreId);
        if (storeBal != null) {
          balance = storeBal;
        } else {
          balance = double.tryParse(
                  '${kaidhaController.walletKaidhaModel?.wallet?.availableBalance ?? 0}') ??
              0.0;
        }
      } else {
        balance = double.tryParse(
                '${kaidhaController.walletKaidhaModel?.wallet?.availableBalance ?? 0}') ??
            0.0;
      }
    } else {
      // Regular Wallet
      final profileController = Get.find<ProfileController>();
      balance = profileController.userInfoModel?.walletBalance ?? 0.0;
    }

    final Color symbolColor =
        isSelected ? const Color(0xFF1E293B) : Theme.of(context).primaryColor;
    return PriceConverter.convertPrice2(balance,
        textStyle: style, symbolColor: symbolColor);
  }

  /// Bottom sheet shown when the user's wallet has no balance — offers to top
  /// up instead of the old plain snackbar.
  Future<void> _showEmptyWalletBottomSheet() async {
    await Get.bottomSheet<void>(
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeLarge,
            Dimensions.paddingSizeExtraLarge,
            Dimensions.paddingSizeLarge,
            Dimensions.paddingSizeLarge),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'wallet_empty'.tr,
                textAlign: TextAlign.center,
                style: tajawalBold.copyWith(
                  fontSize: 22,
                  height: 33 / 22,
                  letterSpacing: 0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF121C19),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'add_balance_to_complete_payment'.tr,
                textAlign: TextAlign.center,
                style: tajawalMedium.copyWith(
                  fontSize: 18,
                  height: 1.6,
                  letterSpacing: 0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFB9C0CC)
                      : const Color(0xFF545454),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back<void>();
                    Get.toNamed(RouteHelper.getWalletRoute());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  child: Text(
                    'add_balance'.tr,
                    style: tajawalBold.copyWith(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
