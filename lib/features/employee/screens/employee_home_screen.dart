import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import '../controllers/employee_navigation_controller.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. الترويسة والترحيب
              EmployeeHeaderWidget(
                onNotificationTap: () {
                  // Notification routing if needed
                },
              ),

              // 2. بطاقة حالة الدوام الديناميكية (لم يبدأ / نشط مع عداد حي / استراحة)
              ShiftStatusCardWidget(
                onStartShift: onStartShiftPressed ?? () {
                  Get.toNamed(RouteHelper.getSelectWorkZoneRoute());
                },
              ),

              // 3. شبكة المقاييس (وقت البدء، وقت العمل، خارج الدوام، الاستئذان المعتمد)
              const ShiftMetricsGridWidget(),

              // 4. شريط ونافذة الإنذارات
              const EmployeeWarningsBanner(),

              // 5. ملخص زيارات اليوم
              TodayVisitsSummaryWidget(
                onStartNextVisit: () {
                  Get.find<EmployeeNavigationController>().changeIndex(1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
