import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_navigation_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../models/employee_shift_model.dart';
import '../visits/controllers/store_visits_controller.dart';
import '../visits/models/store_visit_model.dart';

class UpcomingVisitCardWidget extends StatelessWidget {
  final bool? isDark;

  const UpcomingVisitCardWidget({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final dark = isDark ??
        (Get.isRegistered<ThemeController>() && Get.find<ThemeController>().darkTheme);
    final cardBg = dark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = dark ? const Color(0xFF2B3240) : const Color(0xFFD1D5DB);
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText = dark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
    final btnBg = dark ? const Color(0xFF252B37) : const Color(0xFFF5F6F7);

    return GetBuilder<EmployeeShiftController>(
      builder: (shiftCtrl) {
        if (shiftCtrl.status != ShiftStatus.active) {
          return const SizedBox.shrink();
        }

        return GetBuilder<StoreVisitsController>(
          builder: (visitsCtrl) {
            final StoreVisitModel? upcomingVisit = visitsCtrl.activeVisit ??
                visitsCtrl.allVisits.firstWhereOrNull(
                  (v) =>
                      v.visitStatus == StoreVisitStatus.scheduled ||
                      v.visitStatus == StoreVisitStatus.inProgress ||
                      v.visitStatus == StoreVisitStatus.followUp,
                );

            if (upcomingVisit == null) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Right side in RTL: Upcoming visit details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF1E3A5F) : const Color(0xFFEBF5FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'upcoming_visit_badge'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            upcomingVisit.storeName,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                IconlyLight.location,
                                size: 15,
                                color: subText,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  upcomingVisit.address,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 13,
                                    color: subText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                IconlyLight.timeCircle,
                                size: 14,
                                color: subText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                upcomingVisit.timeSlot,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  color: subText,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Icon(
                                IconlyLight.location,
                                size: 14,
                                color: subText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${upcomingVisit.distanceKm.toStringAsFixed(1)} ${'km'.tr}',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  color: subText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Left side in RTL: Vertical "بدأ الزيارة" button
                    Material(
                      color: btnBg,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (Get.isRegistered<EmployeeNavigationController>()) {
                            Get.find<EmployeeNavigationController>().changeIndex(2);
                          }
                        },
                        child: SizedBox(
                          width: 46,
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'start_visit_vertical'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: darkText,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: darkText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

