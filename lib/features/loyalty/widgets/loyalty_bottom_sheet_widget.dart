import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/loyalty/controllers/loyalty_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class LoyaltyBottomSheetWidget extends StatefulWidget {
  final String amount;
  const LoyaltyBottomSheetWidget({super.key, required this.amount});

  @override
  State<LoyaltyBottomSheetWidget> createState() => _LoyaltyBottomSheetWidgetState();
}

class _LoyaltyBottomSheetWidgetState extends State<LoyaltyBottomSheetWidget> {
  final TextEditingController _pointController = TextEditingController();
  double _convertedAmount = 0.0;

  late final int exchangePointRate;
  late final int minimumExchangePoint;

  @override
  void initState() {
    super.initState();
    final config = Get.find<SplashController>().configModel;
    exchangePointRate = config?.loyaltyPointExchangeRate ?? 250;
    minimumExchangePoint = config?.minimumPointToTransfer ?? 0;

    _pointController.text = widget.amount;
    _updateConvertedAmount(widget.amount);

    _pointController.addListener(() {
      _updateConvertedAmount(_pointController.text);
    });
  }

  void _updateConvertedAmount(String pointStr) {
    final double? points = double.tryParse(pointStr.trim());
    if (points != null && points > 0 && exchangePointRate > 0) {
      final double calculated = points / exchangePointRate;
      if (calculated != _convertedAmount) {
        setState(() {
          _convertedAmount = calculated;
        });
      }
    } else {
      if (_convertedAmount != 0.0) {
        setState(() {
          _convertedAmount = 0.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _pointController.dispose();
    super.dispose();
  }

  void _onConvert(LoyaltyController controller) {
    if (_pointController.text.trim().isEmpty) {
      showCustomSnackBar('input_field_is_empty'.tr);
      return;
    }

    final int? points = int.tryParse(_pointController.text.trim());
    if (points == null || points <= 0) {
      showCustomSnackBar('input_field_is_empty'.tr);
      return;
    }

    final int userPoints =
        Get.find<ProfileController>().userInfoModel?.loyaltyPoint ?? 0;

    if (points < minimumExchangePoint) {
      showCustomSnackBar(
          '${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
      return;
    }

    if (userPoints < points) {
      showCustomSnackBar('you_do_not_have_enough_point_to_exchange'.tr);
      return;
    }

    controller.pointToWallet(points);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color fieldBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F5F8);
    final Color onSurface = isDark ? Colors.white : const Color(0xFF111B18);
    final Color subColor =
        isDark ? const Color(0xFF94A3B8) : theme.disabledColor;
    final Color? fieldBorder = isDark ? const Color(0xFF334155) : null;
    final Color primary = theme.primaryColor;

    return Stack(
      children: [
        Container(
          width: ResponsiveHelper.isDesktop(context) ? 400 : 550,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Green star badge with soft outer ring ──
              Container(
                width: 66,
                height: 66,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.15),
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // ── Rate: "250 نقاط = 1.00 ﷼" ──
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '$exchangePointRate ${'points'.tr} = ',
                  style: tajawalBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge, color: onSurface),
                ),
                PriceConverter.convertPrice2(
                  1,
                  textStyle: tajawalBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge, color: onSurface),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Points to convert ⇄ Converted SAR Amount ──
              Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // النقاط للتحويل (input)
                  Expanded(
                    child: _FieldBox(
                      label: 'النقاط للتحويل',
                      fieldBg: fieldBg,
                      border: fieldBorder,
                      labelColor: subColor,
                      child: TextField(
                        controller: _pointController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: tajawalBold.copyWith(
                            fontSize: 18, color: onSurface),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: '0',
                          hintStyle: tajawalBold.copyWith(
                              fontSize: 18,
                              color: onSurface.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                  ),

                  // Swap icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.swap_horiz, color: primary, size: 24),
                  ),

                  // المبلغ المحول (calculated display)
                  Expanded(
                    child: _FieldBox(
                      label: 'المبلغ المحول',
                      fieldBg: fieldBg,
                      border: fieldBorder,
                      labelColor: subColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Images.sar,
                              width: 16, height: 16, color: onSurface),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _convertedAmount.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                              style: tajawalBold.copyWith(
                                  fontSize: 18, color: onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text(
                'amount_can_be_convert_into_wallet_money'.tr,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: subColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              GetBuilder<LoyaltyController>(builder: (controller) {
                return CustomButton(
                  width: double.infinity,
                  isBold: false,
                  buttonText: 'تحويل نقاط الآن',
                  radius: 14,
                  isLoading: controller.isLoading,
                  onPressed: () => _onConvert(controller),
                );
              }),
            ]),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.clear, size: 20, color: onSurface),
          ),
        ),
      ],
    );
  }
}

/// Labelled rounded field box used for the "converted amount" / "your points"
/// pair in the loyalty conversion dialog.
class _FieldBox extends StatelessWidget {
  final String label;
  final Color fieldBg;
  final Color? border;
  final Color labelColor;
  final Widget child;
  const _FieldBox({
    required this.label,
    required this.fieldBg,
    required this.border,
    required this.labelColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: 12, color: labelColor),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: border == null ? null : Border.all(color: border!),
          ),
          child: child,
        ),
      ],
    );
  }
}
