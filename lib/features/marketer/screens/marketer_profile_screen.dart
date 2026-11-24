import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/screens/language_select_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketerProfileScreen extends StatelessWidget {
  final bool isRoot;
  const MarketerProfileScreen({super.key, this.isRoot = false});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'ar':
        return 'العربية';
      case 'bn':
        return 'বাংলা';
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;

        return GetBuilder<LocalizationController>(
      builder: (locCtrl) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121418) : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: !isRoot,
            leading: isRoot
                ? null
                : IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      locCtrl.isLtr ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
                      color: isDark ? Colors.white : _darkText,
                    ),
                  ),
            title: Text(
              'my_account_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : _darkText,
              ),
            ),
          ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Marketer User Card (Figma 10055:45426)
              GetBuilder<ProfileController>(
                builder: (profileController) {
                  final user = profileController.userInfoModel;
                  final name = user != null
                      ? '${user.fName ?? ''} ${user.lName ?? ''}'.trim()
                      : '';
                  final phone = user?.phone ?? '';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2028) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB),
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryGreen.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/image/figma_freelance_marketer/pf_setting.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(_primaryGreen, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isNotEmpty ? '${'welcome_greeting'.tr} $name' : 'voucher_marketer'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : _darkText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                phone.isNotEmpty ? phone : 'account_settings_label'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          locCtrl.isLtr ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2,
                          size: 18,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 2. Shella Lessons & Supervisor Recommendations Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2028) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_video_square.svg',
                      title: 'shella_lessons_title'.tr,
                      isDark: isDark,
                      onTap: () => _openLessonsDialog(context, isDark),
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_document_like.svg',
                      title: 'supervisor_recommendations_title'.tr,
                      isDark: isDark,
                      onTap: () => _openRecommendationsDialog(context, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Location, Language & Dark Mode Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2028) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_location.svg',
                      title: 'geo_location_title'.tr,
                      trailingText: 'riyadh_central_zone'.tr,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_language_square.svg',
                      title: 'app_language'.tr,
                      trailingText: _getLanguageName(locCtrl.locale.languageCode),
                      isDark: isDark,
                      onTap: () => Get.to(() => const LanguageSelectScreen()),
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    // Dark Mode Reactive Switch Tile
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/image/figma_freelance_marketer/pf_devices.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(_primaryGreen, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'dark_mode_setting'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : _darkText,
                              ),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeThumbColor: _primaryGreen,
                            onChanged: (val) {
                              themeCtrl.toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Support, Privacy & Terms Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2028) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_headset_help.svg',
                      title: 'marketer_support_desk'.tr,
                      isDark: isDark,
                      onTap: () => _openWhatsAppSupport(),
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_security_safe.svg',
                      title: 'privacy_policy_title'.tr,
                      isDark: isDark,
                      onTap: () => _showTermsDialog(context, isDark),
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    _buildFigmaSettingsTile(
                      svgAsset: 'assets/image/figma_freelance_marketer/pf_folder.svg',
                      title: 'commission_terms_policy'.tr,
                      isDark: isDark,
                      onTap: () => _showTermsDialog(context, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Logout Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2028) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B1D1D) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/image/figma_freelance_marketer/pf_logout.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFFDC2626), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  title: Text(
                    'sign_out'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  trailing: Icon(
                    locCtrl.isLtr ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2,
                    size: 16,
                    color: const Color(0xFFDC2626),
                  ),
                  onTap: () => _showLogoutConfirmDialog(context, isDark),
                ),
              ),
              SizedBox(height: isRoot ? 90 : 20),
            ],
          ),
        ),
      ),
    );
          },
        );
      },
    );
  }

  Widget _buildFigmaSettingsTile({
    required String svgAsset,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SvgPicture.asset(
            svgAsset,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(_primaryGreen, BlendMode.srcIn),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : _darkText,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(
            isLtr ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2,
            size: 16,
            color: const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }

  void _openLessonsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C2028) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'shella_lessons_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'shella_lessons_info'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                height: 1.5,
                color: isDark ? const Color(0xFFE5E7EB) : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr, style: const TextStyle(fontFamily: 'Tajawal', color: _primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _openRecommendationsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C2028) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'supervisor_recommendations_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'supervisor_recommendations_info'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                height: 1.5,
                color: isDark ? const Color(0xFFE5E7EB) : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr, style: const TextStyle(fontFamily: 'Tajawal', color: _primaryGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsAppSupport() async {
    const phone = '+966500000000'; // Default support number
    final message = 'whatsapp_marketer_support_message'.tr;
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('cannot_open_whatsapp'.tr);
    }
  }

  void _showTermsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C2028) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'commission_terms_policy'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '${'term_1'.tr}\n${'term_2'.tr}\n${'term_3'.tr}\n${'term_4'.tr}\n${'term_5'.tr}',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              height: 1.6,
              color: isDark ? const Color(0xFFE5E7EB) : Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr, style: const TextStyle(fontFamily: 'Tajawal', color: _primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C2028) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'confirm_sign_out'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'sign_out_prompt'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            color: isDark ? const Color(0xFF9CA3AF) : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr, style: TextStyle(fontFamily: 'Tajawal', color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<AuthController>().clearSharedData();
              Get.offAllNamed(RouteHelper.getWelcomeRoute());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'sign_out'.tr,
              style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
