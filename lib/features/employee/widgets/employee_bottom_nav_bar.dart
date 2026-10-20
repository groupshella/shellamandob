import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/util/images.dart';
import '../controllers/employee_navigation_controller.dart';

/// Data class representing a navigation tab item in [EmployeeBottomNavBar].
class FloatingNavItem {
  final String? activeAsset;
  final String? inactiveAsset;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final String labelKey;
  final String fallbackLabel;

  const FloatingNavItem({
    this.activeAsset,
    this.inactiveAsset,
    this.activeIcon,
    this.inactiveIcon,
    required this.labelKey,
    required this.fallbackLabel,
  });
}

/// Floating glass navigation bar for Employee App — identical to Captain App style & details.
///
/// Spec (Figma component set "Same navbar" 9249:73006):
/// - Bar: 56px tall, full stadium radius, white 10% glass + blur (sigma 20),
///   shadow 0 0 10 rgba(0,0,0,0.05), 16px horizontal inner padding.
/// - Items: 50x40 slots, spaced between. The active slot gets a
///   #E5E5E5 pill (radius 200) with the bold icon variant; inactive slots
///   show the linear icon variant.
/// - The active pill slides between slots for a smooth transition.
class EmployeeBottomNavBar extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int>? onTap;
  final List<FloatingNavItem>? items;

  const EmployeeBottomNavBar({
    super.key,
    this.selectedIndex,
    this.onTap,
    this.items,
  });

  static const double _barHeight = 56;
  static const double _innerPadding = 16;
  static const double _slotWidth = 50;
  static const double _slotHeight = 40;

  /// Default 4 navigation items for Shella Employee App
  /// (RTL visual order: home, visits, reports, profile).
  static const List<FloatingNavItem> defaultNavItems = [
    // 0: الرئيسية (Home)
    FloatingNavItem(
      activeAsset: Images.navHomeActive,
      inactiveAsset: Images.navHomeInactive,
      activeIcon: IconlyBold.home,
      inactiveIcon: IconlyLight.home,
      labelKey: 'home',
      fallbackLabel: 'الرئيسية',
    ),
    // 1: المواعيد والزيارات (Daily Visits)
    FloatingNavItem(
      activeIcon: IconlyBold.calendar,
      inactiveIcon: IconlyLight.calendar,
      labelKey: 'today_visits',
      fallbackLabel: 'الزيارات',
    ),
    // 2: التقارير والأداء (Performance Reports)
    FloatingNavItem(
      activeAsset: Images.navReceiptActive,
      inactiveAsset: Images.navReceiptInactive,
      activeIcon: IconlyBold.chart,
      inactiveIcon: IconlyLight.chart,
      labelKey: 'reports',
      fallbackLabel: 'التقارير',
    ),
    // 3: حسابي (Employee Profile)
    FloatingNavItem(
      activeAsset: Images.navProfileActive,
      inactiveAsset: Images.navProfileInactive,
      activeIcon: IconlyBold.profile,
      inactiveIcon: IconlyLight.profile,
      labelKey: 'profile',
      fallbackLabel: 'حسابي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Hide navbar while keyboard is visible
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }

    final navItems = items ?? defaultNavItems;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;

        // Glass surface (Identical to Captain App Figma specs)
        final Color barColor = isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.10);
        final Color borderColor = isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.45);
        final List<BoxShadow> barShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 10,
          ),
        ];

        // Active pill (Figma: #E5E5E5)
        final Color pillColor = isDark
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFFE5E5E5);
        final Color activeIconColor =
            isDark ? Colors.white : const Color(0xFF111B18);
        final Color inactiveIconColor = isDark
            ? Colors.white.withValues(alpha: 0.55)
            : const Color(0xFF111B18).withValues(alpha: 0.55);

        return GetBuilder<EmployeeNavigationController>(
          builder: (navCtrl) {
            final int currentIndex = selectedIndex ?? navCtrl.currentIndex;
            final ValueChanged<int> onSelect = onTap ?? (idx) => navCtrl.changeIndex(idx);

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomPadding > 0 ? bottomPadding + 4 : 16,
              ),
              child: Container(
                height: _barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_barHeight),
                  boxShadow: barShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_barHeight),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(_barHeight),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: _innerPadding),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final int count = navItems.length;
                          final double gap = count > 1
                              ? (constraints.maxWidth - (_slotWidth * count)) / (count - 1)
                              : 0;
                          final int safeIndex = currentIndex.clamp(0, count - 1);

                          return Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              // Sliding active pill
                              AnimatedPositionedDirectional(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                start: safeIndex * (_slotWidth + gap),
                                top: (constraints.maxHeight - _slotHeight) / 2,
                                width: _slotWidth,
                                height: _slotHeight,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: pillColor,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                ),
                              ),

                              // Icons row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(count, (index) {
                                  final item = navItems[index];
                                  final bool isSelected = index == safeIndex;
                                  return _FloatingNavItemWidget(
                                    item: item,
                                    isSelected: isSelected,
                                    activeColor: activeIconColor,
                                    inactiveColor: inactiveIconColor,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      onSelect(index);
                                    },
                                  );
                                }),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FloatingNavItemWidget extends StatelessWidget {
  final FloatingNavItem item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _FloatingNavItemWidget({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  String _getLabel() {
    final trValue = item.labelKey.tr;
    if (trValue.isNotEmpty && trValue != item.labelKey) {
      return trValue;
    }
    return item.fallbackLabel;
  }

  @override
  Widget build(BuildContext context) {
    final label = _getLabel();

    Widget iconWidget;
    if (item.activeAsset != null && item.inactiveAsset != null) {
      iconWidget = Image.asset(
        isSelected ? item.activeAsset! : item.inactiveAsset!,
        key: ValueKey<String>('${isSelected ? item.activeAsset : item.inactiveAsset}_$isSelected'),
        width: 24,
        height: 24,
        color: isSelected ? activeColor : inactiveColor,
      );
    } else if (item.activeIcon != null && item.inactiveIcon != null) {
      iconWidget = Icon(
        isSelected ? item.activeIcon : item.inactiveIcon,
        key: ValueKey<String>('${isSelected ? item.activeIcon : item.inactiveIcon}_$isSelected'),
        size: 24,
        color: isSelected ? activeColor : inactiveColor,
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: EmployeeBottomNavBar._slotWidth,
            height: EmployeeBottomNavBar._slotHeight,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: iconWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
