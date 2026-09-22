import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import '../controllers/employee_navigation_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../widgets/employee_header_widget.dart';
import '../widgets/shift_status_card_widget.dart';
import '../widgets/shift_metrics_grid_widget.dart';
import '../widgets/employee_warnings_banner.dart';
import '../widgets/today_visits_summary_widget.dart';

class EmployeeHomeScreen extends StatelessWidget {
  final VoidCallback? onStartShiftPressed;

  const EmployeeHomeScreen({super.key, this.onStartShiftPressed});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EmployeeShiftController>()) {
      Get.put(EmployeeShiftController(), permanent: true);
    }

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;

        return Container(
          color: bg,
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: const Color(0xFF30913F),
              onRefresh: () async {
                if (Get.isRegistered<EmployeeShiftController>()) {
                  await Get.find<EmployeeShiftController>().loadCurrentShift(notify: true);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. الترويسة والترحيب
                    EmployeeHeaderWidget(
                      isDark: isDark,
                      onNotificationTap: () {
                        // Notification routing if needed
                      },
                    ),

                    // 2. بطاقة حالة الدوام الديناميكية (لم يبدأ / نشط مع عداد حي / استراحة)
                    ShiftStatusCardWidget(
                      isDark: isDark,
                      onStartShift: onStartShiftPressed ?? () {
                        Get.toNamed(RouteHelper.getSelectWorkZoneRoute());
                      },
                    ),

                    // 3. شبكة المقاييس (وقت البدء، وقت العمل، خارج الدوام، الاستئذان المعتمد)
                    ShiftMetricsGridWidget(isDark: isDark),

                    // 4. شريط ونافذة الإنذارات
                    EmployeeWarningsBanner(isDark: isDark),

                    // 5. ملخص زيارات اليوم
                    TodayVisitsSummaryWidget(
                      isDark: isDark,
                      onStartNextVisit: () {
                        Get.find<EmployeeNavigationController>().changeIndex(1);
                      },
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
}
