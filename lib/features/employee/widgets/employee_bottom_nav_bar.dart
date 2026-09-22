import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_navigation_controller.dart';

class EmployeeBottomNavBar extends StatelessWidget {
  const EmployeeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final navBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);
        final activeColor = isDark ? Colors.white : const Color(0xFF111B18);
        const inactiveColor = Color(0xFF9CA3AF);

        return GetBuilder<EmployeeNavigationController>(
          builder: (controller) {
            return Container(
              decoration: BoxDecoration(
                color: navBg,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom
                    : 10,
                top: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              // الرئيسية (Home) - Far right in RTL
              _buildNavItem(
                index: 0,
                icon: IconlyLight.home,
                activeIcon: IconlyBold.home,
                isSelected: controller.currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => controller.changeIndex(0),
              ),

              // الإحصائيات والتقارير (Chart)
              _buildNavItem(
                index: 2,
                icon: IconlyLight.chart,
                activeIcon: IconlyBold.chart,
                isSelected: controller.currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => controller.changeIndex(2),
              ),

              // المواعيد والزيارات (Calendar)
              _buildNavItem(
                index: 1,
                icon: IconlyLight.calendar,
                activeIcon: IconlyBold.calendar,
                isSelected: controller.currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => controller.changeIndex(1),
              ),

              // حسابي / المسوق (Profile) - Far left in RTL
              _buildNavItem(
                index: 3,
                icon: IconlyLight.profile,
                activeIcon: IconlyBold.profile,
                isSelected: controller.currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => controller.changeIndex(3),
              ),
            ],
          ),
        );
      },
    );
  },
);
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 24,
            color: isSelected ? activeColor : inactiveColor,
          ),
        ],
      ),
    );
  }
}
