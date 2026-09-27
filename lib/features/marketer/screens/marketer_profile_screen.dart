import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              'profile_and_settings'.tr,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Marketer Info Card
              GetBuilder<MarketerController>(
                builder: (c) {
                  return GetBuilder<ProfileController>(
                    builder: (profileController) {
                      final user = profileController.userInfoModel;
                      final name = user != null
                          ? '${user.fName ?? ''} ${user.lName ?? ''}'.trim()
                          : 'voucher_marketer'.tr;
                      final phone = user?.phone ?? '';

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C2028) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(IconlyLight.profile, color: _primaryGreen, size: 28),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            name.isNotEmpty ? name : 'voucher_marketer'.tr,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : _darkText,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFF0FDF4),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'verified_approved'.tr,
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (phone.isNotEmpty)
                                        Text(
                                          phone,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 13,
                                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Divider(height: 1, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                            const SizedBox(height: 12),
                            // Referral Code Box
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(IconlyLight.discount, size: 18, color: _primaryGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${'marketer_code_label'.tr}: ${c.code}',
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : _darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: c.code));
                                      showCustomSnackBar('code_copied'.tr, isError: false);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1C2028) : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                                      ),
                                      child: Text(
                                        'copy'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryGreen,
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
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Marketer Actions Section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2028) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: IconlyLight.chat,
                      title: 'marketer_support_desk'.tr,
                      subtitle: 'marketer_support_subtitle'.tr,
                      isDark: isDark,
                      onTap: () => _openWhatsAppSupport(),
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    _buildSettingsTile(
                      icon: IconlyLight.document,
                      title: 'commission_terms_policy'.tr,
                      subtitle: 'commission_terms_subtitle'.tr,
                      isDark: isDark,
                      onTap: () => _showTermsDialog(context, isDark),
                    ),
                    Divider(height: 1, indent: 54, color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6)),
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'app_language'.tr,
                      subtitle: _getLanguageName(locCtrl.locale.languageCode),
                      isDark: isDark,
                      onTap: () => Get.to(() => const LanguageSelectScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Logout Button
              OutlinedButton.icon(
                onPressed: () => _showLogoutConfirmDialog(context, isDark),
                icon: const Icon(IconlyLight.logout, color: Color(0xFFDC2626), size: 20),
                label: Text(
                  'sign_out'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: isDark ? const Color(0xFF2A1515) : Colors.white,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : _darkText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 11,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
      trailing: Icon(isLtr ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
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
