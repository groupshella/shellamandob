import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/widgets/employee_bottom_nav_bar.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/freelance_network_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_dashboard_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_profile_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_wallet_screen.dart';

/// Freelance Marketer shell (Figma 10055:44561) with the 4-tab floating glass nav:
/// الرئيسية | شبكتي | المحفظة | حسابي
class MarketerMainScreen extends StatefulWidget {
  final int initialIndex;
  const MarketerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<MarketerMainScreen> createState() => _MarketerMainScreenState();
}

class _MarketerMainScreenState extends State<MarketerMainScreen> {
  static const String _assetDir = 'assets/image/figma_freelance_marketer';

  static const List<FloatingNavItem> _navItems = [
    FloatingNavItem(
      activeAsset: '$_assetDir/nav_home_bold.svg',
      inactiveAsset: '$_assetDir/nav_home_linear.svg',
      labelKey: 'home',
      fallbackLabel: 'home',
    ),
    FloatingNavItem(
      activeAsset: '$_assetDir/nav_people_bold.svg',
      inactiveAsset: '$_assetDir/nav_people_outline.svg',
      labelKey: 'my_network',
      fallbackLabel: 'my_network',
    ),
    FloatingNavItem(
      activeAsset: '$_assetDir/nav_wallet_bold.svg',
      inactiveAsset: '$_assetDir/nav_wallet_linear.svg',
      labelKey: 'fm_wallet_title',
      fallbackLabel: 'fm_wallet_title',
    ),
    FloatingNavItem(
      activeAsset: '$_assetDir/nav_profile_bold.svg',
      inactiveAsset: '$_assetDir/nav_profile_linear.svg',
      labelKey: 'my_account',
      fallbackLabel: 'my_account',
    ),
  ];

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _navItems.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<MarketerController>()) {
        Get.find<MarketerController>().loadDashboard(notify: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;

        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: isDark ? const Color(0xFF121418) : Colors.white,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: Scaffold(
            extendBody: true,
            backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                MarketerDashboardScreen(isRoot: true),
                FreelanceNetworkScreen(),
                MarketerWalletScreen(isRoot: true),
                MarketerProfileScreen(isRoot: true),
              ],
            ),
            bottomNavigationBar: EmployeeBottomNavBar(
              selectedIndex: _currentIndex,
              items: _navItems,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        );
      },
    );
  }
}
