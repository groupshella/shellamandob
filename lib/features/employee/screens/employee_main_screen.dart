import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'employee_profile_screen.dart';
import '../controllers/employee_navigation_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import 'employee_home_screen.dart';
import '../attendance/screens/select_work_zone_screen.dart';
import '../visits/screens/daily_visits_screen.dart';
import '../reports/screens/daily_performance_summary_screen.dart';
import '../reports/widgets/previous_day_evaluation_dialog.dart';
import '../alerts/controllers/anti_fraud_alerts_controller.dart';

import 'package:sixam_mart/common/controllers/theme_controller.dart';

class EmployeeMainScreen extends StatefulWidget {
  const EmployeeMainScreen({super.key});

  @override
  State<EmployeeMainScreen> createState() => _EmployeeMainScreenState();
}

class _EmployeeMainScreenState extends State<EmployeeMainScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<EmployeeShiftController>()) {
      Get.put(EmployeeShiftController(), permanent: true);
    }
    if (!Get.isRegistered<EmployeeNavigationController>()) {
      Get.put(EmployeeNavigationController(), permanent: true);
    }
    if (!Get.isRegistered<AntiFraudAlertsController>()) {
      Get.put(AntiFraudAlertsController(), permanent: true);
    }

    // Show morning evaluation dialog once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PreviousDayEvaluationDialog.show(context);
    });
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
          child: GetBuilder<EmployeeNavigationController>(
            builder: (navController) {
              return Scaffold(
                backgroundColor: bg,
                body: IndexedStack(
                  index: navController.currentIndex,
                  children: [
                    // Tab 0: الرئيسية (Employee Home Dashboard)
                    EmployeeHomeScreen(
                      onStartShiftPressed: () {
                        Get.to(() => const SelectWorkZoneScreen());
                      },
                    ),

                    // Tab 1: المواعيد والزيارات اليومية
                    const DailyVisitsScreen(),

                    // Tab 2: التقارير وملخص نهاية اليوم
                    const DailyPerformanceSummaryScreen(),

                    // Tab 3: حسابي (Employee Profile — Figma 8976-27114)
                    const EmployeeProfileScreen(),
                  ],
                ),
                bottomNavigationBar: const EmployeeBottomNavBar(),
              );
            },
          ),
        );
  },
);
  }
}
