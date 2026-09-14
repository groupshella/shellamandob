import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class HomeQidhaPromoBanner extends StatefulWidget {
  const HomeQidhaPromoBanner({super.key});

  @override
  State<HomeQidhaPromoBanner> createState() => _HomeQidhaPromoBannerState();
}

class _HomeQidhaPromoBannerState extends State<HomeQidhaPromoBanner> {
  bool _isExpanded =
      false; // Based on the user image, it has a collapsed and expanded state. Default to collapsed, or maybe expanded? Let's use false so it doesn't clutter unless they open it. Or maybe true? The image shows both. Let's make it expanded initially to grab attention.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (kaidha) {
        final wallet = kaidha.walletKaidhaModel?.wallet;
        final sig = wallet?.signatureStatus;
        final bool qidhaSigned = sig == 1 || sig == true;
        final bool qidhaActive =
            wallet?.status?.toString().toLowerCase() == 'active';
        final bool qidhaSubscribed =
            wallet != null && qidhaSigned && qidhaActive;

        // If the user is logged in but their wallet data is still loading,
        // hide the banner so it doesn't flash for subscribed users.
        if (AuthHelper.isLoggedIn() && kaidha.isLoading_wallet) {
          return const SizedBox.shrink();
        }

        if (qidhaSubscribed) {
          return const SizedBox.shrink(); // Don't show if already subscribed
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFEBFEEB), // Soft pale green matching the design
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _isExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isExpanded = expanded);
              },
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              iconColor: Colors.black,
              collapsedIconColor: Colors.black54,
              leading: Icon(Icons.verified, color: Colors.black87, size: 24),
              title: Text(
                'qidha_promo_title'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'qidha_promo_desc'.tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!AuthHelper.isLoggedIn()) {
                              Get.toNamed(RouteHelper.getSignInRoute('home'));
                              return;
                            }
                            Get.toNamed(
                                RouteHelper.getKiadaWalletSubscription());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'subscribe_now_btn'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
