import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employee_shift_controller.dart';
import '../../visits/controllers/store_visits_controller.dart';

class DailyPerformanceSummaryScreen extends StatelessWidget {
  const DailyPerformanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'daily_summary_title'.tr,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF111827)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Trophy & Status
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF30913F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF30913F), size: 48),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'day_ended_successfully'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'thank_you_field_efforts'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 24),

              // Key KPI Grid
              GetBuilder<EmployeeShiftController>(
                builder: (shiftCtrl) {
                  return GetBuilder<StoreVisitsController>(
                    init: StoreVisitsController(),
                    builder: (visitsCtrl) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'completed_work_hours'.tr,
                                  value: shiftCtrl.formattedWorkHours,
                                  subtitle: 'actual_and_calculated'.tr,
                                  icon: Icons.access_time_rounded,
                                  color: const Color(0xFF30913F),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'completed_visits_kpi'.tr,
                                  value: '${visitsCtrl.qualifiedVisitsCount} ${'visits_count_label'.tr}',
                                  subtitle: 'out_of_target_visits'.tr.replaceAll('@target', '${StoreVisitsController.dailyTargetVisits}'),
                                  icon: Icons.storefront_rounded,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'signed_contracts'.tr,
                                  value: '2 ${'contracts_count_label'.tr}',
                                  subtitle: 'immediate_activation'.tr,
                                  icon: Icons.verified_rounded,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'covered_distance'.tr,
                                  value: '18.4 ${'distance_km'.tr}',
                                  subtitle: 'within_geo_fence'.tr,
                                  icon: Icons.directions_car_outlined,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'total_warnings_kpi'.tr,
                                  value: '${shiftCtrl.warnings.length} ${'warning_single'.tr}',
                                  subtitle: shiftCtrl.warnings.isEmpty ? 'excellent_record'.tr : 'avoid_recurrence'.tr,
                                  icon: Icons.warning_amber_rounded,
                                  color: shiftCtrl.warnings.isEmpty ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'target_achievement_rate'.tr,
                                  value: '${(visitsCtrl.dailyProgressPercentage * 100).toInt()}%',
                                  subtitle: 'today_efficiency'.tr,
                                  icon: Icons.analytics_outlined,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Supervisor Note Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rate_review_outlined, color: Color(0xFF30913F), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'daily_closing_note'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'daily_closing_note_desc'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Exit CTA
              ElevatedButton(
                onPressed: () {
                  if (Get.isRegistered<EmployeeShiftController>()) {
                    Get.find<EmployeeShiftController>().endShift();
                  }
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30913F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: Text(
                  'confirm_closing_and_exit'.tr,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
