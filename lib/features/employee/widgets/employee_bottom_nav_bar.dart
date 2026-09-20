import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import '../controllers/employee_navigation_controller.dart';

class EmployeeBottomNavBar extends StatelessWidget {
  const EmployeeBottomNavBar({super.key});

  static const Color _activeColor = Color(0xFF111B18);
  static const Color _inactiveColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeNavigationController>(
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF0F0F2), width: 1)),
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
                onTap: () => controller.changeIndex(0),
              ),

              // الإحصائيات والتقارير (Chart)
              _buildNavItem(
                index: 2,
                icon: IconlyLight.chart,
                activeIcon: IconlyBold.chart,
                isSelected: controller.currentIndex == 2,
                onTap: () => controller.changeIndex(2),
              ),

              // المواعيد والزيارات (Calendar)
              _buildNavItem(
                index: 1,
                icon: IconlyLight.calendar,
                activeIcon: IconlyBold.calendar,
                isSelected: controller.currentIndex == 1,
                onTap: () => controller.changeIndex(1),
              ),

              // حسابي / المسوق (Profile) - Far left in RTL
              _buildNavItem(
                index: 3,
                icon: IconlyLight.profile,
                activeIcon: IconlyBold.profile,
                isSelected: controller.currentIndex == 3,
                onTap: () => controller.changeIndex(3),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
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
            color: isSelected ? _activeColor : _inactiveColor,
          ),
        ],
      ),
    );
  }
}
