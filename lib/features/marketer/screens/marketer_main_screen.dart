import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/widgets/employee_bottom_nav_bar.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_clients_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_dashboard_screen.dart';
import 'package:sixam_mart/features/employee/screens/employee_profile_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_wallet_screen.dart';

class MarketerMainScreen extends StatefulWidget {
  final int initialIndex;
  const MarketerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<MarketerMainScreen> createState() => _MarketerMainScreenState();
}

class _MarketerMainScreenState extends State<MarketerMainScreen> {
  late int _currentIndex;

  final List<Widget> _tabs = const [
    MarketerDashboardScreen(isRoot: true),
    MarketerClientsScreen(isRoot: true),
    MarketerWalletScreen(isRoot: true),
    EmployeeProfileScreen(isRoot: true),
  ];

  static const List<FloatingNavItem> _marketerNavItems = [
    // 0: الرئيسية (Home / QR Code & Stats)
    FloatingNavItem(
      activeIcon: IconlyBold.home,
      inactiveIcon: IconlyLight.home,
      labelKey: 'home',
      fallbackLabel: 'الرئيسية',
    ),
    // 1: العملاء (Clients & Sign-ups)
    FloatingNavItem(
      activeIcon: IconlyBold.user3,
      inactiveIcon: IconlyLight.user2,
      labelKey: 'nav_clients',
      fallbackLabel: 'العملاء',
    ),
    // 2: المحفظة (Wallet & Earnings)
    FloatingNavItem(
      activeIcon: IconlyBold.wallet,
      inactiveIcon: IconlyLight.wallet,
      labelKey: 'nav_wallet',
      fallbackLabel: 'المحفظة',
    ),
    // 3: حسابي (Profile & Settings)
    FloatingNavItem(
      activeIcon: IconlyBold.profile,
      inactiveIcon: IconlyLight.profile,
      labelKey: 'profile',
      fallbackLabel: 'حسابي',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;

        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: isDark ? const Color(0xFF1C2028) : Colors.white,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: Scaffold(
            backgroundColor: bg,
            body: Stack(
              fit: StackFit.expand,
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: _tabs,
                ),
                if (!GetPlatform.isDesktop)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: EmployeeBottomNavBar(
                      selectedIndex: _currentIndex,
                      onTap: (index) => setState(() => _currentIndex = index),
                      items: _marketerNavItems,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
