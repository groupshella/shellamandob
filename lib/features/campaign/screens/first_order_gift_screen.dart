import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';
import 'package:sixam_mart/features/campaign/widgets/figma_store_view.dart';
import 'package:sixam_mart/features/campaign/widgets/figma_gift_cart_view.dart';
import 'package:sixam_mart/features/campaign/widgets/figma_qr_claim_view.dart';
import 'package:sixam_mart/features/campaign/widgets/figma_gift_success_view.dart';

class FirstOrderGiftScreen extends StatefulWidget {
  final int? storeId;
  const FirstOrderGiftScreen({super.key, this.storeId});

  @override
  State<FirstOrderGiftScreen> createState() => _FirstOrderGiftScreenState();
}

class _FirstOrderGiftScreenState extends State<FirstOrderGiftScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<DynamicGiftController>();
    controller.resetForNewFetch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFirstOrderGift(storeId: widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicGiftController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF30913F)),
            ),
          );
        }

        switch (controller.currentStep) {
          case 0:
            // Screen 1 & Screen 2: Store & Free Products View
            return FigmaStoreView(controller: controller, storeId: widget.storeId);
          case 1:
            // Screen 3: Cart Page
            return FigmaGiftCartView(controller: controller);
          case 2:
            // Screen 4: QR Claim Screen
            return FigmaQrClaimView(controller: controller);
          case 3:
            // Screen 5: Delivered / Handover Success Screen
            return FigmaGiftSuccessView(controller: controller);
          default:
            return FigmaStoreView(controller: controller, storeId: widget.storeId);
        }
      },
    );
  }
}
