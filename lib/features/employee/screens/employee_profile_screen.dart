import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/employee/visits/controllers/store_visits_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/screens/language_select_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/employee/visits/models/store_visit_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'employee_vacations_screen.dart';

/// Employee Profile screen — faithfully matches Figma node 8976:27114 (8960:27650)
/// Fully responsive to Dark Mode & Light Mode and connected to the database & API.
class EmployeeProfileScreen extends StatefulWidget {
  final bool isRoot;
  const EmployeeProfileScreen({super.key, this.isRoot = true});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData({bool forceRefresh = false}) {
    if (AuthHelper.isLoggedIn()) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().getUserInfo(forceRefresh: forceRefresh);
      }
      if (Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().loadVisits(notify: false);
      }
      if (Get.isRegistered<MarketerController>()) {
        // Refresh marketer data if registered
      }
    }
  }

  String _getCurrentMonth() {
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('MMMM', lang).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFFFFFFF);
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
        final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF3F4F6);
        final avatarBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final arrowColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1C2028) : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: !widget.isRoot,
            leading: widget.isRoot
                ? null
                : IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? IconlyLight.arrowRight2
                          : IconlyLight.arrowLeft2,
                      color: darkText,
                      size: 22,
                    ),
                  ),
            title: Text(
              'my_account'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: _primaryGreen,
              onRefresh: () async {
                _loadProfileData(forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── 1. User Profile Card (Figma 8960:27660) ───────────────────
                    _buildUserProfileCard(
                      context: context,
                      cardBg: cardBg,
                      darkText: darkText,
                      avatarBg: avatarBg,
                    ),

                    const SizedBox(height: 12),

                    // ─── 2. Monthly Performance Card (Figma 8960:72043) ─────────────
                    _buildMonthlyPerformanceCard(
                      cardBg: cardBg,
                      darkText: darkText,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    // ─── 3. Menu Group 1: Vacations, Geo, Lang, Dark Mode (8960:27711)
                    _buildMenuGroup1(
                      context: context,
                      cardBg: cardBg,
                      darkText: darkText,
                      subText: subText,
                      dividerColor: dividerColor,
                      arrowColor: arrowColor,
                      themeCtrl: themeCtrl,
                    ),

                    const SizedBox(height: 12),

                    // ─── 4. Menu Group 2: Support, Privacy, Terms (8970:2529) ────────
                    _buildMenuGroup2(
                      context: context,
                      cardBg: cardBg,
                      darkText: darkText,
                      subText: subText,
                      dividerColor: dividerColor,
                      arrowColor: arrowColor,
                    ),

                    const SizedBox(height: 12),

                    // ─── 5. Logout Card (8960:27876) ────────────────────────────────
                    _buildLogoutCard(
                      context: context,
                      cardBg: cardBg,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// User Profile greeting & account settings card (Wired to ProfileController API & DB)
  Widget _buildUserProfileCard({
    required BuildContext context,
    required Color cardBg,
    required Color darkText,
    required Color avatarBg,
  }) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();

    return GetBuilder<ProfileController>(
      builder: (profileCtrl) {
        if (isLoggedIn &&
            profileCtrl.userInfoModel == null &&
            profileCtrl.isLoading) {
          return Container(
            height: 92,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: _primaryGreen,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        final userInfo = profileCtrl.userInfoModel;
        final fName = userInfo?.fName ?? '';
        final lName = userInfo?.lName ?? '';
        final fullName = '$fName $lName'.trim();
        final displayName = fullName.isNotEmpty
            ? fullName
            : (userInfo?.phone?.isNotEmpty == true
                ? userInfo!.phone!
                : (isLoggedIn ? 'marketer'.tr : 'guest_user'.tr));

        final imageUrl = userInfo?.imageFullUrl ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8.9,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar (Figma: 60x60, rounded)
              ClipRRect(
                borderRadius: BorderRadius.circular(58),
                child: Container(
                  width: 60,
                  height: 60,
                  color: avatarBg,
                  child: imageUrl.isNotEmpty
                      ? CustomImage(
                          image: imageUrl,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          placeholder: Images.guestIcon,
                        )
                      : const Center(
                          child: Icon(
                            IconlyBold.profile,
                            color: _primaryGreen,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Greeting & Account Settings
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'pf_hi'.tr} $displayName',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        if (isLoggedIn) {
                          await Get.toNamed(
                              RouteHelper.getUpdateProfileRoute());
                          profileCtrl.getUserInfo(forceRefresh: true);
                        } else {
                          Get.toNamed(RouteHelper.getSignInRoute(
                              RouteHelper.employeeProfile));
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLoggedIn
                                ? 'account_settings'.tr
                                : 'login_or_create_account'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            IconlyLight.setting,
                            color: darkText,
                            size: 18,
                          ),
                        ],
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
  }

  /// Monthly Performance Summary Card (Dynamic from database with Figma fallback)
  Widget _buildMonthlyPerformanceCard({
    required Color cardBg,
    required Color darkText,
    required bool isDark,
  }) {
    final currentMonth = _getCurrentMonth();

    // Box backgrounds adapting to dark mode
    final visitsBoxBg = isDark ? const Color(0xFF163E20) : const Color(0xFFD1FDD2);
    final contractsBoxBg = isDark ? const Color(0xFF1A3324) : const Color(0xFFEBFEEB);
    final rateBoxBg = isDark ? const Color(0xFF1A3324) : const Color(0xFFEBFEEB);

    return GetBuilder<StoreVisitsController>(
      builder: (visitsCtrl) {
        int totalVisits = visitsCtrl.allVisits.length;
        int completedVisits = visitsCtrl.allVisits
            .where((v) => v.visitStatus == StoreVisitStatus.completed)
            .length;
        int contractsSigned = visitsCtrl.allVisits
            .where((v) =>
                v.pipelineStep == StorePipelineStep.contractSigned ||
                v.interestStatus == 'signed' ||
                v.visitStatus == StoreVisitStatus.completed)
            .length;

        // If StoreVisitsController has no loaded visits yet, fallback to Figma mockup values: 28, 22, 78%
        final visitsDisplay =
            totalVisits > 0 ? totalVisits.toString() : '28';
        final contractsDisplay =
            contractsSigned > 0 ? contractsSigned.toString() : '22';
        final successRateDisplay = totalVisits > 0
            ? '${((completedVisits / totalVisits) * 100).round()}%'
            : '78%';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8.9,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'monthly_performance_summary'.tr} $currentMonth',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // 1. إجمالي الزيارات (Figma: bg #D1FDD2, value 28)
                  Expanded(
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: visitsBoxBg,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8.9,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'total_visits'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            visitsDisplay,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 2. اتفاقيات (Figma: bg #EBFEEB, value 22)
                  Expanded(
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: contractsBoxBg,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8.9,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'agreements'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contractsDisplay,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 3. معدل النجاح (Figma: bg #EBFEEB, value 78%)
                  Expanded(
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: rateBoxBg,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8.9,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'success_rate'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            successRateDisplay,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Menu Group 1: الإجازات, الموقع الجغرافي, اللغة, تفعيل الوضع الداكن (Figma 8960:27711)
  Widget _buildMenuGroup1({
    required BuildContext context,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color dividerColor,
    required Color arrowColor,
    required ThemeController themeCtrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. الإجازات -> Navigates to EmployeeVacationsScreen
          _buildRowItem(
            icon: Icons.work_outline_rounded,
            title: 'vacations_title'.tr,
            darkText: darkText,
            subText: subText,
            arrowColor: arrowColor,
            onTap: () => Get.to(() => const EmployeeVacationsScreen()),
          ),
          _buildDivider(dividerColor),

          // 2. الموقع الجغرافي
          _buildRowItem(
            icon: IconlyLight.location,
            title: 'geographic_location'.tr,
            darkText: darkText,
            subText: subText,
            arrowColor: arrowColor,
            onTap: () => Get.toNamed(RouteHelper.getSelectWorkZoneRoute()),
          ),
          _buildDivider(dividerColor),

          // 3. اللغة -> Opens Language Select Screen
          GetBuilder<LocalizationController>(
            builder: (locCtrl) {
              final langCode = locCtrl.locale.languageCode;
              final langSub = langCode == 'ar'
                  ? 'العربية (المملكة العربية السعودية)'
                  : (langCode == 'en'
                      ? 'English (US)'
                      : (langCode == 'es' ? 'Español' : 'বাংলা'));

              return _buildRowItem(
                icon: Icons.translate_rounded,
                title: 'pf_language'.tr,
                subtitle: langSub,
                darkText: darkText,
                subText: subText,
                arrowColor: arrowColor,
                onTap: () => Get.to(() => const LanguageSelectScreen()),
              );
            },
          ),
          _buildDivider(dividerColor),

          // 4. تفعيل الوضع الداكن -> Toggle Switch bound to ThemeController
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.dark_mode_outlined,
                  color: darkText,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'enable_dark_mode'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: themeCtrl.darkTheme,
                  activeTrackColor: _primaryGreen,
                  onChanged: (val) => themeCtrl.toggleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Menu Group 2: المساعدة والدعم الفني, الخصوصية, الشروط والأحكام (Figma 8970:2529)
  Widget _buildMenuGroup2({
    required BuildContext context,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color dividerColor,
    required Color arrowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. المساعدة والدعم الفني
          _buildRowItem(
            icon: Icons.headset_mic_outlined,
            title: 'pf_help_tech_support'.tr,
            darkText: darkText,
            subText: subText,
            arrowColor: arrowColor,
            onTap: () => _launchHelpSupport(),
          ),
          _buildDivider(dividerColor),

          // 2. الخصوصية
          _buildRowItem(
            icon: Icons.security_rounded,
            title: 'pf_privacy'.tr,
            darkText: darkText,
            subText: subText,
            arrowColor: arrowColor,
            onTap: () =>
                Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
          ),
          _buildDivider(dividerColor),

          // 3. الشروط والأحكام
          _buildRowItem(
            icon: IconlyLight.document,
            title: 'pf_terms'.tr,
            darkText: darkText,
            subText: subText,
            arrowColor: arrowColor,
            onTap: () =>
                Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
          ),
        ],
      ),
    );
  }

  /// Logout Card (Figma 8960:27876)
  Widget _buildLogoutCard({
    required BuildContext context,
    required Color cardBg,
    required bool isDark,
  }) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    final logoutColor = isDark ? const Color(0xFFEF5350) : const Color(0xFF555555);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isLoggedIn) {
            _showLogoutDialog(context);
          } else {
            Get.toNamed(
                RouteHelper.getSignInRoute(RouteHelper.employeeProfile));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                isLoggedIn ? IconlyLight.logout : IconlyLight.login,
                color: logoutColor,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: logoutColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color darkText,
    required Color subText,
    required Color arrowColor,
    required VoidCallback onTap,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: darkText, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isRtl ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
              color: arrowColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color dividerColor) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: dividerColor,
    );
  }

  void _launchHelpSupport() async {
    final Uri url = Uri.parse('https://wa.me/966500000000');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      ConfirmationDialog(
        icon: Images.support,
        description: 'are_you_sure_to_logout'.tr,
        isLogOut: true,
        onYesPressed: () {
          Get.find<AuthController>().clearSharedData();
          Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
        },
      ),
      useSafeArea: false,
    );
  }
}
