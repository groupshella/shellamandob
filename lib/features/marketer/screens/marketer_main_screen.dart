import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_clients_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_dashboard_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_profile_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_wallet_screen.dart';

class MarketerMainScreen extends StatefulWidget {
  final int initialIndex;
  const MarketerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<MarketerMainScreen> createState() => _MarketerMainScreenState();
}

class _MarketerMainScreenState extends State<MarketerMainScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  late int _currentIndex;

  final List<Widget> _tabs = const [
    MarketerDashboardScreen(isRoot: true),
    MarketerClientsScreen(isRoot: true),
    MarketerWalletScreen(isRoot: true),
    MarketerProfileScreen(isRoot: true),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (locCtrl) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  activeIcon: IconlyBold.home,
                  inactiveIcon: IconlyLight.home,
                  label: 'nav_home'.tr,
                ),
                _buildNavItem(
                  index: 1,
                  activeIcon: IconlyBold.user3,
                  inactiveIcon: IconlyLight.user2,
                  label: 'nav_clients'.tr,
                ),
                _buildNavItem(
                  index: 2,
                  activeIcon: IconlyBold.wallet,
                  inactiveIcon: IconlyLight.wallet,
                  label: 'nav_wallet'.tr,
                ),
                _buildNavItem(
                  index: 3,
                  activeIcon: IconlyBold.profile,
                  inactiveIcon: IconlyLight.profile,
                  label: 'nav_profile'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? _primaryGreen : const Color(0xFF9CA3AF),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? _primaryGreen : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
