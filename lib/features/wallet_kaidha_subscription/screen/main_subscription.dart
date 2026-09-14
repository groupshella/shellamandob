// ignore_for_file: prefer_const_literals_to_create_immutables, non_constant_identifier_names, deprecated_member_use, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifecycle_controller/lifecycle_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/LifecycleKaidhaController.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/screen/show_pdf_screen.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/screen/subscription_steps/step1_screen.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/screen/subscription_steps/step2_screen.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/screen/subscription_steps/step3_screen.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/stages_widget.dart';
import '../../../util/app_colors.dart';

class KiadaWalletSubscriptionScreen extends StatefulWidget {
  const KiadaWalletSubscriptionScreen({super.key});

  @override
  State<KiadaWalletSubscriptionScreen> createState() =>
      _KiadaWalletSubscriptionScreenState();
}

class _KiadaWalletSubscriptionScreenState
    extends State<KiadaWalletSubscriptionScreen> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('[QidhaSub][OPEN] screen opened');
    getDate();
  }

  Future<void> getDate() async {
    final KaidhaSubController = Get.find<KaidhaSubscriptionController>();
    final profileController = Get.find<ProfileController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure profile data is loaded
      if (profileController.userInfoModel == null) {
        await profileController.getUserInfo();
      }
      final userInfo = profileController.userInfoModel;
      final profilePhone = userInfo?.phone?.toString().trim();
      final authPhone = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().getUserNumber().trim()
          : '';
      final phone = (profilePhone != null && profilePhone.isNotEmpty)
          ? profilePhone
          : authPhone;

      // Do NOT show validation errors on screen open.
      // Phone validation only runs when user presses a submit/next button.
      if (userInfo == null || userInfo.id == null || phone.isEmpty) {
        debugPrint('[QidhaSub][OPEN] user/phone not ready yet: '
            'userInfo=${userInfo != null} userId=${userInfo?.id} phoneEmpty=${phone.isEmpty}. '
            'Skipping wallet fetch - form will validate on Next press.');
        return;
      }

      // Force refresh wallet data to get latest status
      await KaidhaSubController.get_Wallet_Kaidh(forceRefresh: true);

      // Check if wallet exists and has a valid status
      final wallet = KaidhaSubController.walletKaidhaModel?.wallet;
      if (wallet != null) {
        debugPrint('✅ Wallet found with status: ${wallet.status}');
        KaidhaSubController.clearState_kaidha_SharedPre();

        // Only load PDF when wallet is pending/approved and signed
        final status = wallet.status?.toString().toLowerCase();
        final signatureStatus = wallet.signatureStatus;
        final isSigned = signatureStatus == 1 || signatureStatus == true;
        final isPendingOrApproved = status == 'pending' || status == 'approved';

        // Register once: if the customer already submitted an application, show
        // the pending-review screen on open instead of the registration steps.
        const submittedStatuses = {
          'pending',
          'approved',
          'pending signature',
          'signed',
          'in_review',
          'review',
        };
        if (isSigned && status != null && submittedStatuses.contains(status)) {
          KaidhaSubController.markReviewReady();
        } else if (!isSigned && (status == 'pending' || status == 'pending signature')) {
          debugPrint('🔄 Resuming subscription directly at Step 3 (Nafath verification)');
          KaidhaSubController.setStage(3);
        }

        if (isSigned && isPendingOrApproved) {
          await KaidhaSubController.get_Pdf();
        }
      } else {
        debugPrint('ℹ️ No wallet found, starting new application');
        try {
          await KaidhaSubController.SendState_kaidha(
              'started'); //  ارسال الحاله
        } catch (e) {
          debugPrint('SendState_kaidha failed: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LifecycleScope.create(
      create: () => LifecycleKaidhaController(),
      builder: (context) {
        return GetBuilder<KaidhaSubscriptionController>(
          builder: (KaidhaSubController) {
            // ✅ تمرير لأعلى فقط عند الوصول إلى المرحلة 2
            if (KaidhaSubController.currentStage == 2) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              });
            }

            final wallet = KaidhaSubController.walletKaidhaModel?.wallet;
            final dynamic sigStatus = wallet?.signatureStatus;
            final bool isSigned = sigStatus == 1 || sigStatus == true;
            final String? wStatus = wallet?.status?.toString().toLowerCase();
            const submittedStatuses = {
              'pending',
              'approved',
              'pending signature',
              'signed',
              'in_review',
              'review',
            };
            final bool hasSubmittedStatus =
                wStatus != null && submittedStatuses.contains(wStatus);
            final bool showReviewScreen =
                isSigned && (hasSubmittedStatus || wallet?.signaturePath != null);

            // If customer has a wallet record on server but hasn't signed Nafath yet,
            // resume directly at Step 3 (Nafath verification) instead of Step 1.
            if (!isSigned && wallet != null && KaidhaSubController.currentStage == 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                KaidhaSubController.setStage(3);
              });
            }

            return Scaffold(
              backgroundColor: AppColors.wtColor,
              body: KaidhaSubController.isLoading_Show_Pdf
                  ? const Center(child: CircularProgressIndicator())
                  : showReviewScreen
                      ? const SafeArea(child: ShowPdfScreen())
                      : NestedScrollView(
                          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                            SliverAppBar(
                              backgroundColor: AppColors.wtColor,
                              surfaceTintColor: Colors.transparent,
                              scrolledUnderElevation: 0,
                              elevation: 0,
                              centerTitle: true,
                              pinned: true,
                              floating: false,
                              automaticallyImplyLeading: false,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'محفظة قيدها',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D3633),
                                    ),
                                  ),
                                  if (innerBoxIsScrolled) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5EA),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFC7F3C7),
                                            width: 1),
                                      ),
                                      child: Text(
                                        'الخطوة ${KaidhaSubController.currentStage} من 3',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF30913F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Color(0xFF2D3633), size: 20),
                                onPressed: () {
                                  if (KaidhaSubController.currentStage == 1) {
                                    Get.back();
                                  } else {
                                    KaidhaSubController.nextStage(context,
                                        isNext: false);
                                  }
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SizedBox(height: 4),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        'الاشتراك في قيدها',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111B18),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  StagesWidget(),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                          body: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF6F5F8),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: KaidhaSubController.currentStage == 1
                                ? const Step_1_Screen()
                                : KaidhaSubController.currentStage == 2
                                    ? const Step2Screen()
                                    : KaidhaSubController.currentStage == 3
                                        ? const Step3Screen()
                                        : const SizedBox(),
                          ),
                        ),
            );
          },
        );
      },
    );
  }
}
