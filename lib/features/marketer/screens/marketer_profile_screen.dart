import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketerProfileScreen extends StatelessWidget {
  final bool isRoot;
  const MarketerProfileScreen({super.key, this.isRoot = false});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (locCtrl) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: !isRoot,
            leading: isRoot
                ? null
                : IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      locCtrl.isLtr ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
                      color: _darkText,
                    ),
                  ),
            title: Text(
              'profile_and_settings'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _darkText,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
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
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEBFEEB),
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
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: _darkText,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0FDF4),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'verified_approved'.tr,
                                              style: const TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF16A34A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (phone.isNotEmpty)
                                        Text(
                                          phone,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            const SizedBox(height: 12),
                            // Referral Code Box
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
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
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _darkText,
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: IconlyLight.chat,
                      title: 'marketer_support_desk'.tr,
                      subtitle: 'marketer_support_subtitle'.tr,
                      onTap: () => _openWhatsAppSupport(),
                    ),
                    const Divider(height: 1, indent: 54, color: Color(0xFFF3F4F6)),
                    _buildSettingsTile(
                      icon: IconlyLight.document,
                      title: 'commission_terms_policy'.tr,
                      subtitle: 'commission_terms_subtitle'.tr,
                      onTap: () => _showTermsDialog(context),
                    ),
                    const Divider(height: 1, indent: 54, color: Color(0xFFF3F4F6)),
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'app_language'.tr,
                      subtitle: locCtrl.locale.languageCode == 'ar' ? 'العربية' : 'English',
                      onTap: () => _toggleLanguage(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Logout Button
              OutlinedButton.icon(
                onPressed: () => _showLogoutConfirmDialog(context),
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
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
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
  }) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _darkText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 11,
          color: Color(0xFF6B7280),
        ),
      ),
      trailing: Icon(isLtr ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2, size: 16, color: const Color(0xFF9CA3AF)),
    );
  }

  Future<void> _openWhatsAppSupport() async {
    const phone = '+966500000000'; // Default support number
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent('مرحباً، أحتاج مساعدة بخصوص حسابي كمسوق في تطبيق شلة')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('cannot_open_whatsapp'.tr);
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'commission_terms_policy'.tr,
          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Text(
            '${'term_1'.tr}\n${'term_2'.tr}\n${'term_3'.tr}\n${'term_4'.tr}\n${'term_5'.tr}',
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6),
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

  void _toggleLanguage(BuildContext context) {
    final locCtrl = Get.find<LocalizationController>();
    if (locCtrl.locale.languageCode == 'ar') {
      locCtrl.setLanguage(context, const Locale('en', 'US'));
    } else {
      locCtrl.setLanguage(context, const Locale('ar', 'SA'));
    }
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'confirm_sign_out'.tr,
          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'sign_out_prompt'.tr,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF6B7280))),
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
