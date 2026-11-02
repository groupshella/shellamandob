import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/helper/otp_error_helper.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_success_dialog.dart';

/// Headline text color from the design system — hsba(162, 37%, 11%).
const Color _kHeadlineColor = Color(0xFF121C19);

/// Error/red color for invalid OTP state.
const Color _kErrorColor = Color(0xFFE53935);

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final int cooldownSeconds;
  final int expiresInSeconds;
  final Map<String, dynamic>? pendingMarketerData;
  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.cooldownSeconds = 120,
    this.expiresInSeconds = 600,
    this.pendingMarketerData,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _otp = '';
  String? _errorText;
  bool get _hasError => _errorText != null;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown(widget.cooldownSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final int m = _secondsLeft ~/ 60;
    final int s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Verification only runs when the user taps the button — no auto-submit on
  /// the 6th digit. Errors are shown inline (red boxes + message), not a dialog.
  Future<void> _verify(AuthController authController) async {
    if (_otp.length < 6) {
      return;
    }
    final result =
        await authController.verifyOtp(phone: widget.phone, otp: _otp);
    if (!mounted) {
      return;
    }
    if (result.success) {
      if (widget.pendingMarketerData != null) {
        final data = widget.pendingMarketerData!;
        // Auto-register if new user
        if (!result.isExisted) {
          final String firstName = data['firstName']?.toString() ?? '';
          final String lastName = data['lastName']?.toString() ?? '';
          final String fullName = '$firstName $lastName'.trim();
          final String? supCode = data['supervisorCode']?.toString();

          final regResponse = await authController.registerV2(
            name: fullName.isNotEmpty ? fullName : 'Marketer Applicant',
            phone: widget.phone,
            registrationToken: result.registrationToken ?? authController.registrationToken,
            refCode: (supCode != null && supCode.isNotEmpty) ? supCode : null,
          );
          if (!regResponse.isSuccess) {
            setState(() {
              _errorText = mapOtpAuthError(regResponse.message, regResponse.message);
            });
            return;
          }
        }

        // Apply as marketer now that user is authenticated
        final marketerController = Get.find<MarketerController>();
        final String? docPath = data['idPhotoPath']?.toString();
        final XFile? docFile = (docPath != null && docPath.isNotEmpty) ? XFile(docPath) : null;

        final ok = await marketerController.apply(
          firstName: data['firstName']?.toString() ?? '',
          lastName: data['lastName']?.toString() ?? '',
          phone: widget.phone,
          profession: data['profession']?.toString() ?? '',
          documentType: data['documentType']?.toString() ?? 'هوية وطنية',
          documentFile: docFile,
          supervisorCode: data['supervisorCode']?.toString(),
          marketerType: data['marketerType']?.toString() ?? 'freelance',
        );

        if (ok && mounted) {
          bool navigated = false;
          void navigateToMarketerScreen() {
            if (!navigated) {
              navigated = true;
              Get.offAll(() => const MarketerScreen());
            }
          }

          if (mounted) {
            await MarketerSuccessDialog.show(context, onClose: navigateToMarketerScreen);
          }
          navigateToMarketerScreen();
          return;
        } else if (mounted) {
          return;
        }
      }

      if (result.isExisted) {
        if (mounted) {
          Get.find<LocationController>()
              .navigateToLocationScreen(context, 'sign-in', offNamed: true);
        }
      } else {
        Get.toNamed(RouteHelper.getCreateAccountRoute());
      }
    } else {
      setState(() {
        _errorText = mapOtpAuthError(result.errorCode, result.message);
      });
    }
  }

  Future<void> _resend(AuthController authController) async {
    if (_secondsLeft > 0) {
      return;
    }
    final result = await authController.sendOtp(phone: widget.phone);
    if (!mounted) {
      return;
    }
    if (result.success) {
      setState(() => _errorText = null);
      _startCooldown(result.retryAfterSeconds ?? result.cooldownSeconds);
    } else {
      setState(() {
        _errorText = mapOtpAuthError(result.errorCode, result.message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        // Back icon pinned to the physical left (LTR icon) regardless of RTL.
        actions: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_ios_new,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: isDesktop ? 450 : context.width,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top content (scrolls if the keyboard reduces space).
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Text('enter_activation_code'.tr,
                            style: tajawalBold.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: _kHeadlineColor,
                            )),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Builder(builder: (context) {
                          final TextStyle subtitleStyle =
                              tajawalRegular.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 1.6,
                                  color: const Color(0xFF545454));
                          // Phone flows at the end of the sentence and renders
                          // left-to-right (so +966… is not reversed by RTL).
                          return Text.rich(
                            TextSpan(style: subtitleStyle, children: [
                              TextSpan(
                                  text:
                                      '${'activation_code_sent_hint'.tr} '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(widget.phone,
                                      style: subtitleStyle),
                                ),
                              ),
                            ]),
                            textAlign: TextAlign.start,
                          );
                        }),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraLarge),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: PinCodeTextField(
                            length: 6,
                            appContext: context,
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            autoFocus: true,
                            // We own _otpController and dispose it ourselves —
                            // stop PinCodeTextField from disposing it too
                            // (otherwise it's disposed twice).
                            autoDisposeControllers: false,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textStyle: tajawalBold.copyWith(
                                fontSize: 20,
                                color: _hasError
                                    ? _kErrorColor
                                    : _kHeadlineColor),
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              fieldHeight: 50,
                              fieldWidth: 44,
                              borderWidth: 1,
                              fieldOuterPadding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                              selectedColor: _hasError
                                  ? _kErrorColor
                                  : Theme.of(context).primaryColor,
                              selectedFillColor: Theme.of(context).cardColor,
                              inactiveFillColor: Theme.of(context).cardColor,
                              inactiveColor: _hasError
                                  ? _kErrorColor
                                  : Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.5),
                              activeColor: _hasError
                                  ? _kErrorColor
                                  : Theme.of(context).primaryColor,
                              activeFillColor: Theme.of(context).cardColor,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 250),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            // Clear any previous error as the user edits — but
                            // never auto-verify; verification is button-driven.
                            onChanged: (value) => setState(() {
                              _otp = value;
                              if (_errorText != null) {
                                _errorText = null;
                              }
                            }),
                            beforeTextPaste: (text) => true,
                          ),
                        ),
                        if (_hasError) ...[
                          const SizedBox(
                              height: Dimensions.paddingSizeSmall),
                          Text(
                            _errorText!,
                            style: tajawalRegular.copyWith(
                                fontSize: 14,
                                height: 1.6,
                                color: _kErrorColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Bottom-pinned actions.
                GetBuilder<AuthController>(builder: (authController) {
                  return GetBuilder<MarketerController>(builder: (marketerController) {
                    final bool isBusy = authController.isLoading || marketerController.isSubmitting;
                    return CustomButton(
                      buttonText: 'continue_action'.tr,
                      isBold: true,
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      textHeight: 1.6,
                      textColor: Colors.white,
                      isLoading: isBusy,
                      onPressed: (_otp.length < 6 || isBusy)
                          ? null
                          : () => _verify(authController),
                    );
                  });
                }),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Center(
                  child: GetBuilder<AuthController>(builder: (authController) {
                    if (_secondsLeft > 0) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('resend_code_again'.tr,
                              style: tajawalRegular.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF545454))),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(_formattedTime,
                              style: tajawalMedium.copyWith(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor)),
                        ],
                      );
                    }
                    return TextButton(
                      onPressed: () => _resend(authController),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${'didnt_receive_code'.tr} ',
                            style: tajawalRegular.copyWith(
                                fontSize: 14,
                                color: const Color(0xFF545454))),
                        TextSpan(
                            text: 'resend_action'.tr,
                            style: tajawalMedium.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor)),
                      ])),
                    );
                  }),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
