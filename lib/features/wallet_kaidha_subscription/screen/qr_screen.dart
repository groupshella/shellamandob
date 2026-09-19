// ignore_for_file: use_key_in_widget_constructors, camel_case_types, library_private_types_in_public_api, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/pos/services/pos_checkout_deep_link_service.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/dialog.dart/success_celebration_dialog.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class Qr_Screen extends StatefulWidget {
  @override
  _Qr_ScreenState createState() => _Qr_ScreenState();
}

class _Qr_ScreenState extends State<Qr_Screen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? otpCode;
  bool _isNavigating = false;
  bool _isFlashOn = false;

  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(fn);
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final double scanBoxSize = MediaQuery.of(context).size.width * 0.72;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Camera View
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: const Color(0xFF22A45D),
              borderRadius: 20,
              borderLength: 32,
              borderWidth: 6,
              cutOutSize: scanBoxSize,
              overlayColor: Colors.black.withValues(alpha: 0.65),
            ),
          ),

          // 2. Animated Laser Scanner Bar
          Center(
            child: SizedBox(
              width: scanBoxSize - 20,
              height: scanBoxSize - 20,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(0.0, (_animation.value * 2) - 1),
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF22A45D).withValues(alpha: 0.0),
                            const Color(0xFF22A45D),
                            const Color(0xFF55E795),
                            const Color(0xFF22A45D),
                            const Color(0xFF22A45D).withValues(alpha: 0.0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22A45D).withValues(alpha: 0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Top Floating Glass Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    _buildGlassCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Get.back(),
                    ),

                    // Title Badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFF22A45D),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'مسح رمز QR',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Flashlight Toggle
                    _buildGlassCircleButton(
                      icon: _isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      iconColor: _isFlashOn ? Colors.amber : Colors.white,
                      onTap: () async {
                        await controller?.toggleFlash();
                        final status = await controller?.getFlashStatus();
                        _safeSetState(() {
                          _isFlashOn = status ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Floating Info & Action Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121C19).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22A45D).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.center_focus_strong_rounded,
                              color: Color(0xFF22A45D),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'وجّه الكاميرا نحو رمز QR للمتابعة',
                            textAlign: TextAlign.center,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'يدعم كاشير المتاجر POS وروابط الدفع واشتراكات قيدها',
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          if (otpCode != null) ...[
                            const SizedBox(height: 16),
                            CustomButton(
                              buttonText: 'continue_order'.tr,
                              onPressed: () {
                                _handleCode(otpCode!);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code?.trim();

      if (code != null && code.isNotEmpty && !_isNavigating) {
        _isNavigating = true;
        controller.pauseCamera();

        _handleCode(code);
      }
    });
  }

  void _handleCode(String code) {
    // 1. Check if it is a POS Checkout QR Link or Token
    String? posToken;
    try {
      final Uri? uri = Uri.tryParse(code);
      if (uri != null) {
        posToken = PosCheckoutDeepLinkService.extractTokenFromUri(uri);
      }
    } catch (_) {}

    if (posToken == null &&
        (code.startsWith('pos_') ||
            (code.length >= 32 &&
                RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(code)))) {
      posToken = code.startsWith('pos_token:')
          ? code.substring('pos_token:'.length)
          : code;
    }

    if (posToken != null && posToken.isNotEmpty) {
      Get.offNamed(RouteHelper.getPosCheckoutRoute(posToken));
      return;
    }

    // 2. Check if it is a First-Order Gift / Partner Campaign QR or Link
    int? storeId;
    bool isGiftOrPartner = false;

    try {
      final Uri? uri = Uri.tryParse(code);
      if (uri != null) {
        if (uri.path.contains('gift') ||
            uri.path.contains('first-order') ||
            uri.path.contains('campaign') ||
            uri.path.contains('invite/customer') ||
            uri.path.contains('partners') ||
            uri.path.contains('/p/')) {
          isGiftOrPartner = true;
          if (uri.queryParameters.containsKey('store_id')) {
            storeId = int.tryParse(uri.queryParameters['store_id']!);
          } else if (uri.queryParameters.containsKey('store')) {
            storeId = int.tryParse(uri.queryParameters['store']!);
          } else if (uri.queryParameters.containsKey('ref')) {
            final ref = uri.queryParameters['ref']!;
            final match = RegExp(r'S(\d+)', caseSensitive: false).firstMatch(ref);
            if (match != null) {
              storeId = int.tryParse(match.group(1)!);
            }
          }
          if (storeId == null && uri.pathSegments.isNotEmpty) {
            final lastSeg = uri.pathSegments.last;
            final match = RegExp(r'^\d+$').firstMatch(lastSeg);
            if (match != null) {
              storeId = int.tryParse(lastSeg);
            }
          }
        }
      }
    } catch (_) {}

    if (!isGiftOrPartner &&
        (code.startsWith('gift_') ||
            code.startsWith('partner_') ||
            code.contains('first-order-gift') ||
            code.contains('invite/customer'))) {
      isGiftOrPartner = true;
      if (code.contains('store_id=')) {
        final match = RegExp(r'store_id=(\d+)').firstMatch(code);
        if (match != null) {
          storeId = int.tryParse(match.group(1)!);
        }
      } else if (code.contains('ref=')) {
        final match = RegExp(r'S(\d+)', caseSensitive: false).firstMatch(code);
        if (match != null) {
          storeId = int.tryParse(match.group(1)!);
        }
      }
    }

    if (isGiftOrPartner) {
      Get.offNamed(RouteHelper.getFirstOrderGiftRoute(storeId: storeId));
      return;
    }

    // 3. Fallback to Qidha Wallet flow
    _safeSetState(() {
      otpCode = code;
    });

    Get.offNamed(RouteHelper.getKiadaWalletSubscription());

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: SuccessCelebrationWidget(),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    controller?.dispose();
    super.dispose();
  }
}

