import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_apply_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_intro_screen.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

enum MarketerRoleOption { specialist, freelance }

class MarketerRoleSelectionScreen extends StatefulWidget {
  const MarketerRoleSelectionScreen({super.key});

  @override
  State<MarketerRoleSelectionScreen> createState() =>
      _MarketerRoleSelectionScreenState();
}

class _MarketerRoleSelectionScreenState
    extends State<MarketerRoleSelectionScreen> {
  MarketerRoleOption _selectedRole = MarketerRoleOption.specialist;

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subtitleGrey = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final Color bgColor = isDark ? const Color(0xFF121418) : Colors.white;
    final Color cardBg =
        isDark ? const Color(0xFF1A261D) : const Color(0xFFF2FFF2);
    final Color cardBorder = isDark
        ? const Color(0xFF2C4A33)
        : const Color(0x3330913F);
    final Color tabInactiveBg =
        isDark ? const Color(0xFF1E232B) : const Color(0xFFF6F5F8);
    final Color textColor = isDark ? Colors.white : _darkText;
    final Color subtextColor = isDark ? Colors.white70 : _subtitleGrey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: textColor,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450 : context.width,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // 1. Header Title: "انضم لفريق شلّة"
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: tajawalBold.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: '${'join_shella_team'.tr.replaceAll('شلّة', '').replaceAll('شلة', '').trim()} ',
                        ),
                        const TextSpan(
                          text: 'شلّة',
                          style: TextStyle(color: _primaryGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Subtitle: "اختار طريقة العمل اللي تناسبك وابدأ رحلتك معانا"
                  Text(
                    'join_team_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: tajawalMedium.copyWith(
                      fontSize: 15,
                      color: subtextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Tab Selector + Card
                  _buildRoleSelectorCard(
                    isDark: isDark,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    tabInactiveBg: tabInactiveBg,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectorCard({
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color tabInactiveBg,
    required Color textColor,
  }) {
    final bool isSpecialist =
        _selectedRole == MarketerRoleOption.specialist;

    return Column(
      children: [
        // Tabs Header Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Tab 1: أخصائي تسويق
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = MarketerRoleOption.specialist;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: isSpecialist ? 52 : 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSpecialist ? cardBg : tabInactiveBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    border: isSpecialist
                        ? Border(
                            top: BorderSide(color: cardBorder, width: 1.2),
                            left: BorderSide(color: cardBorder, width: 1.2),
                            right: BorderSide(color: cardBorder, width: 1.2),
                          )
                        : null,
                    boxShadow: isSpecialist
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'marketing_specialist'.tr,
                    style: isSpecialist
                        ? tajawalBold.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          )
                        : tajawalMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : const Color(0xFF777777),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Tab 2: مسوق حر
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = MarketerRoleOption.freelance;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: !isSpecialist ? 52 : 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isSpecialist ? cardBg : tabInactiveBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    border: !isSpecialist
                        ? Border(
                            top: BorderSide(color: cardBorder, width: 1.2),
                            left: BorderSide(color: cardBorder, width: 1.2),
                            right: BorderSide(color: cardBorder, width: 1.2),
                          )
                        : null,
                    boxShadow: !isSpecialist
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'freelance_marketer'.tr,
                    style: !isSpecialist
                        ? tajawalBold.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          )
                        : tajawalMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : const Color(0xFF777777),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Main Card Body
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            border: Border.all(color: cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: isSpecialist
                ? _buildSpecialistContent(textColor, isDark)
                : _buildFreelanceContent(textColor, isDark),
          ),
        ),
      ],
    );
  }

  // --- Specialist (أخصائي تسويق ميداني) Tab View ---
  Widget _buildSpecialistContent(Color textColor, bool isDark) {
    return Column(
      key: const ValueKey('specialist_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Title
        Text(
          'field_marketing_specialist'.tr,
          style: tajawalBold.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),

        // Tagline
        Text(
          'field_marketer_tagline'.tr,
          style: tajawalMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _primaryGreen,
          ),
        ),
        const SizedBox(height: 14),

        // Divider
        Divider(
          color: _primaryGreen.withValues(alpha: isDark ? 0.3 : 0.15),
          thickness: 1,
        ),
        const SizedBox(height: 14),

        // Tasks Header
        Text(
          'your_daily_tasks'.tr,
          style: tajawalBold.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 14),

        // 4 Task Bullets
        _buildTaskItem('field_task_1'.tr, textColor, isDark),
        _buildTaskItem('field_task_2'.tr, textColor, isDark),
        _buildTaskItem('field_task_3'.tr, textColor, isDark),
        _buildTaskItem('field_task_4'.tr, textColor, isDark),

        const SizedBox(height: 22),

        // CTA Button
        _buildActionButton(
          label: 'join_as_specialist_cta'.tr,
          onTap: () {
            Get.to(() => const MarketerApplyScreen(
                  marketerType: 'growth_specialist',
                ));
          },
        ),
      ],
    );
  }

  // --- Freelance (مسوق حر) Tab View ---
  Widget _buildFreelanceContent(Color textColor, bool isDark) {
    return Column(
      key: const ValueKey('freelance_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Title
        Text(
          'freelance_marketer'.tr,
          style: tajawalBold.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),

        // Tagline
        Text(
          'freelance_marketer_tagline'.tr,
          style: tajawalMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _primaryGreen,
          ),
        ),
        const SizedBox(height: 14),

        // Divider
        Divider(
          color: _primaryGreen.withValues(alpha: isDark ? 0.3 : 0.15),
          thickness: 1,
        ),
        const SizedBox(height: 14),

        // Tasks Header
        Text(
          'your_tasks'.tr,
          style: tajawalBold.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 14),

        // 4 Task Bullets
        _buildTaskItem('freelance_task_1'.tr, textColor, isDark),
        _buildTaskItem('freelance_task_2'.tr, textColor, isDark),
        _buildTaskItem('freelance_task_3'.tr, textColor, isDark),
        _buildTaskItem('freelance_task_4'.tr, textColor, isDark),

        const SizedBox(height: 22),

        // CTA Button
        _buildActionButton(
          label: 'join_as_freelance_cta'.tr,
          onTap: () {
            Get.to(() => const MarketerIntroScreen());
          },
        ),
      ],
    );
  }

  // Single bullet row with circular check icon
  Widget _buildTaskItem(String text, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFD0F4D5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 13,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tajawalMedium.copyWith(
                fontSize: 13.5,
                color: textColor.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom action button with chevron arrow
  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: tajawalBold.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
