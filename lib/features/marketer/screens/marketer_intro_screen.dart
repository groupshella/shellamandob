import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_apply_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

class MarketerIntroScreen extends StatelessWidget {
  const MarketerIntroScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            MarketerHeader(title: 'voucher_marketer'.tr),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Hero Gradient Card - full width without outer margin
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFDFD3F5),
                            Color(0xFFEBFEEB),
                            Color(0xFFDFD3F5),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'shela_marketing_partner_program'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111B18),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'be_a_voucher_marketer_with_us'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: _primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'marketer_intro_desc'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111B18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Features Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'marketing_benefits_with_us'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Row 1 with SAR Icon
                            _buildFeatureRow(
                              number: '١',
                              numberColor: const Color(0xFF0AB564),
                              badgeBg: const Color(0x170AB564),
                              customContent: Row(
                                children: [
                                  const Text(
                                    '1 ',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SarCurrencyWidget(size: 14, color: Color(0xFF1A1A2E)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'benefit_1_reward_per_user'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildFeatureRow(
                              number: '٢',
                              numberColor: const Color(0xFF1655C0),
                              badgeBg: const Color(0x171655C0),
                              title: 'benefit_2_qr_code'.tr,
                            ),
                            const SizedBox(height: 16),

                            _buildFeatureRow(
                              number: '٣',
                              numberColor: const Color(0xFFF5A623),
                              badgeBg: const Color(0x17F5A623),
                              title: 'benefit_3_track_operations'.tr,
                            ),
                            const SizedBox(height: 16),

                            _buildFeatureRow(
                              number: '٤',
                              numberColor: const Color(0xFF7861A6),
                              badgeBg: const Color(0x69DFD3F5),
                              title: 'benefit_4_receive_profits'.tr,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const MarketerApplyScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'apply_now'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

  Widget _buildFeatureRow({
    required String number,
    required Color numberColor,
    required Color badgeBg,
    String? title,
    Widget? customContent,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: numberColor,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: customContent ??
              Text(
                title ?? '',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
        ),
      ],
    );
  }
}
