// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/personal_information.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/before_Pdf.dart';

class Step_1_Screen extends StatefulWidget {
  const Step_1_Screen({super.key});

  @override
  State<Step_1_Screen> createState() => _Step_1_ScreenState();
}

class _Step_1_ScreenState extends State<Step_1_Screen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (KaidhaSubController) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              if (!KaidhaSubController.isLoading) ...[
                const SizedBox(height: 6),
                const PersonalInformation(),
                const SizedBox(height: 24),

                // Primary Button: "التالي"
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF30913F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      debugPrint('[QidhaSub][NEXT] pressed');
                      final bool isValid =
                          KaidhaSubController.validate_Fields_Screen_1(context);
                      if (isValid) {
                        KaidhaSubController.SendState_kaidha('in_progress');
                      }
                    },
                    child: Text(
                      'next'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Tajawal',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Button: "استعراض العقد قبل التوقيع"
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6F6F6),
                      foregroundColor: const Color(0xFF111B18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    onPressed: () {
                      final now = DateTime.now();
                      final time =
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                      const days = [
                        'الاثنين',
                        'الثلاثاء',
                        'الأربعاء',
                        'الخميس',
                        'الجمعة',
                        'السبت',
                        'الأحد'
                      ];
                      Get.to(
                        () => Befor_Pdf_Screen(
                          time: time,
                          day: days[now.weekday - 1],
                          name: KaidhaSubController.fullNameController.text.isNotEmpty
                              ? KaidhaSubController.fullNameController.text
                              : '${KaidhaSubController.firstname.text} ${KaidhaSubController.fathername.text} ${KaidhaSubController.grandfathername.text} ${KaidhaSubController.last_name.text}',
                          identityNumber: KaidhaSubController
                              .identity_card_number.text
                              .toString(),
                          nationality: KaidhaSubController.nationality
                              .toString(),
                          neighborhood: KaidhaSubController
                              .neighborhood.text
                              .toString(),
                          house_type: KaidhaSubController.house_type
                              .toString(),
                        ),
                      );
                    },
                    child: Text(
                      'review_contract_before_signing'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                        color: Color(0xFF111B18),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
