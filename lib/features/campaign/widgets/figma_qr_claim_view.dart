import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';

class FigmaQrClaimView extends StatelessWidget {
  final DynamicGiftController controller;

  const FigmaQrClaimView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111B18), size: 18),
          onPressed: () => controller.setStep(1), // Back to Cart view (Screen 3)
        ),
        title: const Text(
          'تأكيد الطلب',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111B18),
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Subtitle text: بالرجاء التوجه للكاشير
                    const Text(
                      'بالرجاء التوجه للكاشير',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111B18),
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // QR Code White Box Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        // Encode the SAME short claim code shown as "رمز الاستلام"
                        // so scanning the barcode == typing the code the cashier
                        // verifies (single source of truth).
                        data: controller.qrClaimCode,
                        version: QrVersions.auto,
                        size: 210.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF111B18),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF111B18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Timer Countdown Text: 00 : 29 : 24
                    Text(
                      controller.formattedTimer,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF30913F),
                        letterSpacing: 1.5,
                        fontFamily: 'Tajawal',
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Order Info Gray Card (Figma Screen 4)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'رقم الطلب : ${controller.qrOrderNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111B18),
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'رمز الاستلام : ${controller.qrClaimCode}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111B18),
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Simulation / Handover Trigger Button — DEBUG builds only. In
            // release the cashier redeems the QR server-side and polling
            // advances the screen; the customer must never self-confirm handover.
            if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.simulateHandoverSuccess(), // debug preview only
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF30913F), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF30913F)),
                  label: const Text(
                    'تأكيد الاستلام لدى الكاشير',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF30913F),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
