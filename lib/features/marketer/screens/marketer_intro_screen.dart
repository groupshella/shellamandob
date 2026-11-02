import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_apply_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

/// Marketer Independent Mode Screen (Figma node 8433:84426 / 9055:83191 / 9632:34984)
/// Frame: "مندوب تسويق قسائم شرائية" / "كن شريك شله لأول مرة"
/// Design specifications:
/// - Background: Colors.white (#FFFFFF) in Light Mode, Slate (#0F172A) in Dark Mode.
/// - Header: 18px Tajawal Bold, Back Button + Title.
/// - Hero Gradient Card: linear-gradient(137deg, #DFD3F5 0%, #EBFEEB 48%, #DFD3F5 99%), borderRadius: 8px.
///   Sub-title: 12px FontWeight.w500 (#111B18).
///   Title: 22px FontWeight.w800 (#30913F).
///   Description: 15px FontWeight.w500 (#111B18).
/// - Features Card: Container with borderRadius 20px, boxShadow: 0px 2px 12px rgba(0,0,0,0.06).
///   Title: 15px FontWeight.w700 (#1A1A2E).
///   4 Feature Rows with distinct colored numeral badges (10px borderRadius):
///     1. Green #0AB564 / rgba(10, 181, 100, 0.09) -> '1' + SAR symbol + 'عن كل عميل مكتمل التسجيل'
///     2. Blue #1655C0 / rgba(22, 85, 192, 0.09) -> 'رمز QR خاص بك'
///     3. Amber #F5A623 / rgba(245, 166, 35, 0.09) -> 'تتبع عمليات التسجيل والأرباح'
///     4. Purple #7861A6 / rgba(223, 211, 245, 0.41) -> 'استلام أرباحك ومتابعتها من حسابك'
/// - Primary Action CTA: Width 343px, Height 48px, #30913F, borderRadius 12px, Text: "تقدّم الآن" (16px Tajawal Bold).
class MarketerIntroScreen extends StatelessWidget {
  const MarketerIntroScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Get.locale?.languageCode == 'ar';

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final heroTextColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF111B18);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardTextColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            MarketerHeader(title: 'voucher_marketer'.tr),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Hero Gradient Card (Figma Frame 2085665904)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [
                                  Color(0xFF1E1B4B),
                                  Color(0xFF064E3B),
                                  Color(0xFF1E1B4B),
                                ]
                              : const [
                                  Color(0xFFDFD3F5),
                                  Color(0xFFEBFEEB),
                                  Color(0xFFDFD3F5),
                                ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'shela_marketing_partner_program'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: heroTextColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'be_a_voucher_marketer_with_us'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'marketer_intro_desc'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: heroTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Features Card (Figma Container with borderRadius 20px)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'marketing_benefits_with_us'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: cardTextColor,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Row 1: Green #0AB564 -> 1 SAR per customer
                            _buildFeatureRow(
                              number: isAr ? '١' : '1',
                              numberColor: const Color(0xFF0AB564),
                              badgeBg: isDark ? const Color(0xFF064E3B) : const Color(0x170AB564),
                              customContent: Row(
                                children: [
                                  Text(
                                    'benefit_1_reward_per_user'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cardTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '1',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: cardTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  SarCurrencyWidget(
                                    size: 13,
                                    color: cardTextColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Row 2: Blue #1655C0 -> QR Code
                            _buildFeatureRow(
                              number: isAr ? '٢' : '2',
                              numberColor: const Color(0xFF1655C0),
                              badgeBg: isDark ? const Color(0xFF1E3A8A) : const Color(0x171655C0),
                              title: 'benefit_2_qr_code'.tr,
                              cardTextColor: cardTextColor,
                            ),
                            const SizedBox(height: 18),

                            // Row 3: Amber #F5A623 -> Track registrations
                            _buildFeatureRow(
                              number: isAr ? '٣' : '3',
                              numberColor: const Color(0xFFF5A623),
                              badgeBg: isDark ? const Color(0xFF78350F) : const Color(0x17F5A623),
                              title: 'benefit_3_track_operations'.tr,
                              cardTextColor: cardTextColor,
                            ),
                            const SizedBox(height: 18),

                            // Row 4: Purple #7861A6 -> Receive profits
                            _buildFeatureRow(
                              number: isAr ? '٤' : '4',
                              numberColor: const Color(0xFF7861A6),
                              badgeBg: isDark ? const Color(0xFF4C1D95) : const Color(0x69DFD3F5),
                              title: 'benefit_4_receive_profits'.tr,
                              cardTextColor: cardTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action CTA Button (Figma Frame 2085664427)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                height: 48,
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
    Color? cardTextColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: numberColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: customContent ??
              Text(
                title ?? '',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cardTextColor ?? const Color(0xFF1A1A2E),
                ),
              ),
        ),
      ],
    );
  }
}
