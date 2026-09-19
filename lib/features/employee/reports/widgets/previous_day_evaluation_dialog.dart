import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviousDayEvaluationDialog extends StatelessWidget {
  const PreviousDayEvaluationDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PreviousDayEvaluationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'morning_greeting'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'previous_day_report_title'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Performance Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    title: 'completed_work_hours'.tr,
                    value: '07:45 ${'hour_unit'.tr}',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricBox(
                    title: 'deducted_hours'.tr,
                    value: '00:15 ${'hour_unit'.tr}',
                    icon: Icons.timer_off_outlined,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    title: 'successful_visits'.tr,
                    value: '14',
                    icon: Icons.store_mall_directory_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricBox(
                    title: 'recorded_warnings'.tr,
                    value: '1 ${'warning_single'.tr}',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Supervisor Directives Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_ind_outlined, color: Color(0xFF15803D), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'supervisor_directives'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'evaluation_supervisor_comment'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Color(0xFF14532D),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      'direct_supervisor_name'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Dismiss CTA
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30913F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'dismiss_and_start_tour'.tr,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
