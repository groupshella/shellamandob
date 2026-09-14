import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/screen/qidha_discover_stores_screen.dart';
import 'package:sixam_mart/util/styles.dart';

class QidhaWalletActivatedDialog extends StatelessWidget {
  const QidhaWalletActivatedDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const QidhaWalletActivatedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF30913F);
    const Color ink = Color(0xFF111B18);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top close button
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),

                // Illustration / Wallet Icon Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC7F3C7), width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: green,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'تم تفعيل محفظة قيدها بنجاح',
                  textAlign: TextAlign.center,
                  style: tajawalBold.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'استكشف المتاجر والمطاعم التي تدعم الدفع بقيدها',
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'Tajawal',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button: "استكشف الاَن"
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.to(() => const QidhaDiscoverStoresScreen());
                    },
                    child: Text(
                      'استكشف الاَن',
                      style: robotoBold.copyWith(
                        fontSize: 15,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
