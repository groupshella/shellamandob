import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet/controllers/wallet_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import '../../../common/widgets/custom_text_field.dart';

class ConvertMoneyBottomsheet extends StatefulWidget {
  const ConvertMoneyBottomsheet({super.key});

  @override
  State<ConvertMoneyBottomsheet> createState() => _ConvertMoneyBottomsheetState();
}

class _ConvertMoneyBottomsheetState extends State<ConvertMoneyBottomsheet> {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController myOtp = TextEditingController();
  TextEditingController otpUser = TextEditingController();
  TextEditingController money = TextEditingController();
  bool isRequested = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: context.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView(
        children: [
          Center(
            child: Container(
              height: 1,
              width: context.width * .5,
              decoration: const BoxDecoration(color: Colors.black),
            ),
          ),
          if (!isRequested)
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text('wallet_transfer_phone_hint'.tr),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: phoneNumber,
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRequested = true;
                          });
                          Get.find<WalletController>().requestExchange(phoneNumber.text);
                        },
                        child: Text('request_code'.tr))),
              ],
            ),
          if (isRequested)
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text('code_via_notifications'.tr),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: money,
                  showTitle: true,
                  titleText: 'enter_amount_to_transfer'.tr,
                  prefixIcon: Icons.monetization_on,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: myOtp,
                  showTitle: true,
                  titleText: 'your_code'.tr,
                  prefixIcon: Icons.qr_code,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: otpUser,
                  showTitle: true,
                  titleText: 'recipient_code'.tr,
                  prefixIcon: Icons.qr_code,
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          // Validate the amount before calling the server:
                          // numeric, > 0, and not more than the wallet balance.
                          final double? amount =
                              double.tryParse(money.text.trim());
                          final double balance = Get.isRegistered<ProfileController>()
                              ? (Get.find<ProfileController>()
                                      .userInfoModel
                                      ?.walletBalance ??
                                  0)
                              : 0;
                          if (amount == null || amount <= 0) {
                            showCustomSnackBar('please_enter_valid_amount'.tr,
                                isError: true);
                            return;
                          }
                          if (amount > balance) {
                            showCustomSnackBar(
                                'المبلغ أكبر من رصيد محفظتك', isError: true);
                            return;
                          }
                          await Get.find<WalletController>().Exchange(phoneNumber.text, myOtp.text, otpUser.text, money.text);
                          Get.back();
                        },
                        child: Text('transfer_amount'.tr))),
              ],
            )
        ],
      ),
    );
  }
}
