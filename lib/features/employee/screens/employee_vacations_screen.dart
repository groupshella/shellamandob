import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'employee_leave_request_screen.dart';
import '../controllers/employee_vacations_controller.dart';

/// Vacations list & history screen — faithfully matches Figma node 8970:2686 in node 8976:27114 "الأجازات"
/// Fully responsive to Dark Mode and Light Mode. Connected to live backend truth.
class EmployeeVacationsScreen extends StatelessWidget {
  const EmployeeVacationsScreen({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    final vacationsCtrl = Get.isRegistered<EmployeeVacationsController>()
        ? Get.find<EmployeeVacationsController>()
        : Get.put(EmployeeVacationsController(apiClient: Get.find()));

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF6F5F8);
        final dividerColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? IconlyLight.arrowRight2
                    : IconlyLight.arrowLeft2,
                color: darkText,
                size: 22,
              ),
            ),
            title: Text(
              'vacations_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => vacationsCtrl.fetchLeaves(),
                tooltip: 'refresh'.tr,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: darkText,
                  size: 22,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: _primaryGreen,
              onRefresh: () => vacationsCtrl.fetchLeaves(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── 1. Top Action Cards Row (Figma 8974:3071) ─────────────────
                    Row(
                      children: [
                        // Card 1: إجازة سنوية -> تقديم طلب
                        Expanded(
                          child: _buildActionCard(
                            cardBg: cardBg,
                            darkText: darkText,
                            borderColor: borderColor,
                            title: 'annual_leave'.tr,
                            onTap: () => Get.to(
                              () => const EmployeeLeaveRequestScreen(
                                leaveType: LeaveType.annual,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Card 2: إجازة مرضية -> تقديم طلب
                        Expanded(
                          child: _buildActionCard(
                            cardBg: cardBg,
                            darkText: darkText,
                            borderColor: borderColor,
                            title: 'sick_leave'.tr,
                            onTap: () => Get.to(
                              () => const EmployeeLeaveRequestScreen(
                                leaveType: LeaveType.sick,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── 2. Previous Leaves Container (Figma 8975:3218) ────────────
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : const Color(0x0D000000),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'previous_leaves'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                ),
                              ),
                              GetBuilder<EmployeeVacationsController>(
                                builder: (ctrl) {
                                  if (ctrl.leavesList.isEmpty) return const SizedBox.shrink();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2B3240) : const Color(0xFFF2F4F7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${ctrl.leavesList.length}',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: subText,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          GetBuilder<EmployeeVacationsController>(
                            builder: (ctrl) {
                              if (ctrl.isLoading) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: _primaryGreen,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (ctrl.leavesList.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 28),
                                    child: Text(
                                      'no_previous_leaves'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: subText,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: ctrl.leavesList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  Color statusColor;
                                  Color statusBgColor;

                                  if (item.status == 'approved') {
                                    statusColor = _primaryGreen;
                                    statusBgColor = isDark
                                        ? const Color(0xFF183B22)
                                        : const Color(0xFFDCFCE7);
                                  } else if (item.status == 'rejected') {
                                    statusColor = const Color(0xFFDC2626);
                                    statusBgColor = isDark
                                        ? const Color(0xFF3B1818)
                                        : const Color(0xFFFEE2E2);
                                  } else {
                                    statusColor = const Color(0xFFF59E0B);
                                    statusBgColor = isDark
                                        ? const Color(0xFF3B2E15)
                                        : const Color(0xFFFEF3C7);
                                  }

                                  return Column(
                                    children: [
                                      if (index > 0) _buildDivider(dividerColor),
                                      _buildHistoryItem(
                                        title: item.typeLabel,
                                        dateAndDuration: item.dateAndDuration,
                                        statusText: item.statusLabel,
                                        statusColor: statusColor,
                                        statusBgColor: statusBgColor,
                                        darkText: darkText,
                                        subText: subText,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Top leave application card (Figma 8974:3076 / 8974:3081)
  Widget _buildActionCard({
    required Color cardBg,
    required Color darkText,
    required Color borderColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'apply_request'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Previous leave history row item (Figma 8975:3189, 8975:3200, 8975:3213)
  Widget _buildHistoryItem({
    required String title,
    required String dateAndDuration,
    required String statusText,
    required Color statusColor,
    required Color statusBgColor,
    required Color darkText,
    required Color subText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateAndDuration,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: subText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color dividerColor) {
    return Divider(
      height: 1,
      thickness: 1,
      color: dividerColor,
    );
  }
}
