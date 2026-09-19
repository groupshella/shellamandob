import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/screens/language_select_screen.dart';
import 'package:sixam_mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart/features/update/controllers/update_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/images.dart';

class EmployeeSettingsScreen extends StatelessWidget {
  const EmployeeSettingsScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _cardBg = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? IconlyLight.arrowRight2
                : IconlyLight.arrowLeft2,
            color: _darkText,
            size: 22,
          ),
        ),
        title: Text(
          'settings'.tr,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _darkText,
          ),
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (profileCtrl) {
          final userInfo = profileCtrl.userInfoModel;
          final fullName = userInfo != null
              ? '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim()
              : 'certified_marketer'.tr;
          final phone = userInfo?.phone ?? '';
          final imageUrl = userInfo?.imageFullUrl ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. User Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      ClipOval(
                        child: imageUrl.isNotEmpty
                            ? CustomImage(
                                image: imageUrl,
                                height: 56,
                                width: 56,
                                placeholder: Images.guestIcon,
                              )
                            : Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  IconlyBold.profile,
                                  size: 28,
                                  color: _primaryGreen,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Name & Phone
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isNotEmpty ? fullName : 'shella_agent'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phone.isNotEmpty ? phone : '',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: _subText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBFEEB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'certified_marketer'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      IconButton(
                        onPressed: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
                        icon: const Icon(IconlyLight.edit, color: _primaryGreen, size: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Account & Security Section
                _buildSectionHeader('account_and_security'.tr),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.profile,
                  title: 'profile'.tr,
                  subtitle: 'edit_profile_desc'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.lock,
                  title: 'change_password'.tr,
                  subtitle: 'change_password_desc'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change')),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.notification,
                  title: 'notifications'.tr,
                  subtitle: 'app_notifications_desc'.tr,
                  onTap: () => Get.bottomSheet(const NotificationStatusChangeBottomSheet()),
                ),
                const SizedBox(height: 20),

                // 3. Preferences Section
                _buildSectionHeader('preferences_and_language'.tr),
                const SizedBox(height: 8),
                GetBuilder<LocalizationController>(
                  builder: (localizationController) {
                    final langCode = localizationController.locale.languageCode;
                    final currentLang = langCode == 'ar'
                        ? 'العربية'
                        : (langCode == 'bn'
                            ? 'বাংলা'
                            : (langCode == 'es' ? 'Español' : 'English'));
                    return _buildSettingsTile(
                      context: context,
                      icon: Icons.language_rounded,
                      title: 'app_language'.tr,
                      subtitle: currentLang,
                      trailing: Text(
                        currentLang,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _primaryGreen,
                        ),
                      ),
                      onTap: () => Get.to(() => const LanguageSelectScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 4. Support & Legal Section
                _buildSectionHeader('help_and_info'.tr),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.headset_mic_outlined,
                  title: 'support'.tr,
                  subtitle: 'tech_support_desc'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.chat,
                  title: 'live_chat'.tr,
                  subtitle: 'live_chat_desc'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getConversationRoute()),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.document,
                  title: 'terms_conditions'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.shieldDone,
                  title: 'privacy_policy'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: IconlyLight.infoSquare,
                  title: 'about_us'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('about-us')),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.system_update_outlined,
                  title: 'check_for_updates'.tr,
                  subtitle: 'check_for_updates_desc'.tr,
                  onTap: () {
                    if (Get.isRegistered<UpdateController>()) {
                      Get.find<UpdateController>().manualCheckForUpdates();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // 5. Logout Button
                InkWell(
                  onTap: () => _handleLogout(context, profileCtrl),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEECEB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(IconlyLight.logout, color: Color(0xFFE53935), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'logout'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Version Footer
                Center(
                  child: Text(
                    '${'app_version_label'.tr} ${AppConstants.appVersion}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _subText,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primaryGreen, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: _subText,
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? IconlyLight.arrowLeft2
                  : IconlyLight.arrowRight2,
              size: 16,
              color: const Color(0xFF9CA3AF),
            ),
      ),
    );
  }

  void _handleLogout(BuildContext context, ProfileController profileController) {
    Get.dialog(
      ConfirmationDialog(
        icon: Images.support,
        description: 'are_you_sure_to_logout'.tr,
        isLogOut: true,
        onYesPressed: () async {
          profileController.clearUserInfo();
          await Get.find<AuthController>().socialLogout();
          await Get.find<AuthController>().clearSharedData();
          await Get.offAllNamed(RouteHelper.getWelcomeRoute());
        },
      ),
    );
  }
}
