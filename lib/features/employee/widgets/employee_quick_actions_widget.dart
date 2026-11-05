import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import '../controllers/employee_navigation_controller.dart';
import '../controllers/monthly_earnings_controller.dart';
import '../screens/growth_specialist_earnings_screen.dart';

class EmployeeQuickActionsWidget extends StatelessWidget {
  final bool? isDark;

  const EmployeeQuickActionsWidget({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final dark = isDark ??
        (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final cardBorder = dark ? const Color(0xFF2B3240) : const Color(0xFFF0F0F2);

    // Color definitions from Figma design (1:1)
    final yellowBg = dark ? const Color(0xFF3B2E15) : const Color(0xFFFEF6E0);
    const yellowIcon = Color(0xFFD97706);

    final purpleBg = dark ? const Color(0xFF2C1E3F) : const Color(0xFFEFEAFC);
    const purpleIcon = Color(0xFF7E22CE);

    final pinkBg = dark ? const Color(0xFF3B1828) : const Color(0xFFFCE8EF);
    const pinkIcon = Color(0xFFDB2777);

    final greenBg = dark ? const Color(0xFF163E20) : const Color(0xFFE6F6EC);
    const greenIcon = Color(0xFF16A34A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 1. أرباحي (Yellow/Amber Wallet) - Far Right in RTL
          Expanded(
            child: _buildActionCard(
              label: 'my_earnings'.tr,
              icon: IconlyLight.wallet,
              bgColor: yellowBg,
              iconColor: yellowIcon,
              textColor: darkText,
              cardBg: cardBg,
              cardBorder: cardBorder,
              onTap: () {
                if (Get.isRegistered<EmployeeNavigationController>()) {
                  Get.find<EmployeeNavigationController>().changeIndex(3);
                } else {
                  if (!Get.isRegistered<MonthlyEarningsController>()) {
                    Get.put(MonthlyEarningsController(apiClient: Get.find()));
                  }
                  Get.to(() => const GrowthSpecialistEarningsScreen());
                }
              },
            ),
          ),
          const SizedBox(width: 8),

          // 2. شبكتي (Purple Network/People)
          Expanded(
            child: _buildActionCard(
              label: 'my_network'.tr,
              icon: IconlyLight.user3,
              bgColor: purpleBg,
              iconColor: purpleIcon,
              textColor: darkText,
              cardBg: cardBg,
              cardBorder: cardBorder,
              onTap: () {
                Get.toNamed(RouteHelper.getMyNetworkRoute());
              },
            ),
          ),
          const SizedBox(width: 8),

          // 3. تفعيل المتجر (Pink Document)
          Expanded(
            child: _buildActionCard(
              label: 'store_activation'.tr,
              icon: IconlyLight.document,
              bgColor: pinkBg,
              iconColor: pinkIcon,
              textColor: darkText,
              cardBg: cardBg,
              cardBorder: cardBorder,
              onTap: () {
                Get.toNamed(RouteHelper.getStoresInActivationListRoute());
              },
            ),
          ),
          const SizedBox(width: 8),

          // 4. الدعم (Green Phone Call) - Far Left in RTL
          Expanded(
            child: _buildActionCard(
              label: 'support_short'.tr,
              icon: IconlyLight.call,
              bgColor: greenBg,
              iconColor: greenIcon,
              textColor: darkText,
              cardBg: cardBg,
              cardBorder: cardBorder,
              onTap: () {
                Get.toNamed(RouteHelper.getSupportRoute());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
    required Color cardBg,
    required Color cardBorder,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
