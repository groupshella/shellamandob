import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'contract_signing_screen.dart';
import 'follow_up_task_screen.dart';

class StoreVisitDetailScreen extends StatefulWidget {
  final StoreVisitModel visit;

  const StoreVisitDetailScreen({super.key, required this.visit});

  @override
  State<StoreVisitDetailScreen> createState() => _StoreVisitDetailScreenState();
}

class _StoreVisitDetailScreenState extends State<StoreVisitDetailScreen> {
  List<String> get _closingReasonsList => [
    'closing_reason_signed'.tr,
    'closing_reason_interested'.tr,
    'closing_reason_negotiating'.tr,
    'closing_reason_manager_absent'.tr,
    'closing_reason_competitor_exclusive'.tr,
    'closing_reason_closed_or_unqualified'.tr,
    'closing_reason_other_management'.tr,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().startVisit(widget.visit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreVisitsController>(
      builder: (controller) {
        final visit = controller.activeVisit ?? widget.visit;

        // Auto outcome logic
        final bool isQualifiedOutcome = (controller.selectedPipelineStep != StorePipelineStep.notMet &&
                controller.selectedPipelineStep != StorePipelineStep.rejected &&
                controller.selectedPipelineStep != StorePipelineStep.notQualified) &&
            (controller.frontImagePath != null || controller.insideImagePath != null);

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Text(
              visit.storeName,
              style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 17),
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            elevation: 0.5,
            actions: [
              // 30-min visit countdown pill
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.remainingVisitSeconds < 300
                      ? const Color(0xFFFEE2E2)
                      : controller.remainingVisitSeconds < 600
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.remainingVisitSeconds < 300
                        ? const Color(0xFFEF4444)
                        : controller.remainingVisitSeconds < 600
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF0284C7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: controller.remainingVisitSeconds < 300
                          ? const Color(0xFFDC2626)
                          : controller.remainingVisitSeconds < 600
                              ? const Color(0xFFD97706)
                              : const Color(0xFF0369A1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.formattedRemainingTime,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: controller.remainingVisitSeconds < 300
                            ? const Color(0xFFDC2626)
                            : controller.remainingVisitSeconds < 600
                                ? const Color(0xFFD97706)
                                : const Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Inactivity Alert Warning Banner (if inactive >= 10 min)
                  if (controller.inactivitySeconds >= StoreVisitsController.inactivityThresholdSeconds)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF87171)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'inactivity_alert_title'.tr,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'inactivity_alert_body'.tr,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFFB91C1C)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 2. Daily Target Progress Indicator (الهدف اليومي: 16 زيارة)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF30913F).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.track_changes_rounded, color: Color(0xFF30913F), size: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'daily_achievement_indicator'.tr,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                ),
                              ],
                            ),
                            Text(
                              'successful_visits_of_target'.trParams({
                                'current': controller.qualifiedVisitsCount.toString(),
                                'target': StoreVisitsController.dailyTargetVisits.toString(),
                              }),
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF30913F)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: controller.dailyProgressPercentage,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'daily_target_hint'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Outcome Logic Live Badge (تصنيف الزيارة تلقائياً)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isQualifiedOutcome ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isQualifiedOutcome ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isQualifiedOutcome ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          color: isQualifiedOutcome ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isQualifiedOutcome
                                ? 'visit_qualified_banner'.tr
                                : 'visit_unqualified_banner'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isQualifiedOutcome ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Anti-Spoofing Live Photos (واجهة المحل + داخل المحل)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined, color: Color(0xFF30913F), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'mandatory_photo_doc'.tr,
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'gallery_upload_prohibited'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Card 1: Store Front
                            Expanded(
                              child: _buildPhotoCaptureCard(
                                title: 'store_front_photo'.tr,
                                subtitle: 'store_front_subtitle'.tr,
                                imagePath: controller.frontImagePath,
                                onTap: () => controller.captureStorePhoto(isFrontImage: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Card 2: Store Inside
                            Expanded(
                              child: _buildPhotoCaptureCard(
                                title: 'store_inside_photo'.tr,
                                subtitle: 'store_inside_subtitle'.tr,
                                imagePath: controller.insideImagePath,
                                onTap: () => controller.captureStorePhoto(isFrontImage: false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Store Micro-Form Details (حقول المحل والسجل والفتحات)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'facility_and_manager_info'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          label: 'store_name_label'.tr,
                          controller: controller.storeNameController,
                          icon: Icons.storefront_outlined,
                          onChanged: (_) => controller.registerActivity(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'manager_name_label'.tr,
                                controller: controller.managerNameController,
                                icon: Icons.person_outline,
                                onChanged: (_) => controller.registerActivity(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                label: 'phone_number_label'.tr,
                                controller: controller.phoneController,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                onChanged: (_) => controller.registerActivity(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'openings_count_label'.tr,
                                controller: controller.openingsController,
                                icon: Icons.meeting_room_outlined,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => controller.registerActivity(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                label: 'cr_number_label'.tr,
                                controller: controller.crNumberController,
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => controller.registerActivity(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. Sales Pipeline / Funnel Steps (Interactive Chips)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sales_pipeline_steps'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'select_pipeline_step_desc'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: StorePipelineStep.values.map((step) {
                            final isSelected = controller.selectedPipelineStep == step;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    step.icon,
                                    size: 16,
                                    color: isSelected ? Colors.white : step.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    step.localizedLabel,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: step.color,
                              backgroundColor: const Color(0xFFF3F4F6),
                              elevation: isSelected ? 2 : 0,
                              pressElevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? step.color : const Color(0xFFE5E7EB),
                                ),
                              ),
                              onSelected: (_) {
                                controller.setPipelineStep(step);
                                if (step == StorePipelineStep.contractSigned) {
                                  Get.to(() => ContractSigningScreen(visit: visit));
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 7. Next Follow-up & Commitments & Obstacles
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'follow_up_and_obstacles'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'next_appointment_commitments'.tr,
                          controller: controller.commitmentsController,
                          icon: Icons.event_available_outlined,
                          hint: 'next_appointment_hint'.tr,
                          onChanged: (_) => controller.registerActivity(),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'obstacles_encountered'.tr,
                          controller: controller.obstaclesController,
                          icon: Icons.report_problem_outlined,
                          hint: 'obstacles_hint'.tr,
                          onChanged: (_) => controller.registerActivity(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 8. Closing Reasons Dropdown + "أخرى" text box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'visit_closing_options'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: controller.selectedClosingReason,
                          hint: Text(
                            'choose_closing_action'.tr,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF9CA3AF)),
                          ),
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          items: _closingReasonsList.map((reason) {
                            return DropdownMenuItem(
                              value: reason,
                              child: Text(
                                reason,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.setClosingReason(val);
                          },
                        ),
                        // When "أخرى" / other is chosen, show high management input box
                        if (controller.selectedClosingReason == 'closing_reason_other_management'.tr ||
                            (controller.selectedClosingReason?.contains('أخرى') ?? false)) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF4FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE879F9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFA21CAF), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'auto_escalate_management'.tr,
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFA21CAF)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: controller.otherReasonController,
                                  maxLines: 3,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'senior_management_notes_hint'.tr,
                                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF9CA3AF)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFF0ABFC)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 9. Confidential Supervisor Report (التقرير السري الخاص لداشبورد المشرف)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: controller.toggleConfidentialReport,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.security_rounded, color: Color(0xFFD97706), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'confidential_report_title'.tr,
                                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                      ),
                                      Text(
                                        'confidential_report_desc'.tr,
                                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF6B7280)),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  controller.isConfidentialReportExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.isConfidentialReportExpanded)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            child: TextField(
                              controller: controller.confidentialNotesController,
                              maxLines: 3,
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'confidential_notes_hint'.tr,
                                hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF9CA3AF)),
                                filled: true,
                                fillColor: const Color(0xFFFFFBEB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFFDE68A)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 10. Finish & Submit Button: [إنهاء الزيارة وإرسال التقرير]
                  ElevatedButton.icon(
                    onPressed: () => _handleFinishVisit(context, controller, visit),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: Text(
                      'finish_visit_and_submit'.tr,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF30913F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // If deal not closed, option to schedule follow up task directly
                  if (controller.selectedPipelineStep != StorePipelineStep.contractSigned)
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.to(() => FollowUpTaskScreen(visit: visit));
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(
                        'schedule_next_follow_up_btn'.tr,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoCaptureCard({
    required String title,
    required String subtitle,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hasImage ? const Color(0xFFECFDF5) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
            width: hasImage ? 1.5 : 1.0,
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                          const SizedBox(width: 4),
                          Text('documented_badge'.tr, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_enhance_rounded, color: Color(0xFF4B5563), size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF30913F)),
            ),
          ),
        ),
      ],
    );
  }

  void _handleFinishVisit(BuildContext context, StoreVisitsController controller, StoreVisitModel visit) {
    if (controller.frontImagePath == null && controller.insideImagePath == null) {
      Get.snackbar(
        'photo_doc_required_snack_title'.tr,
        'photo_doc_required_snack_body'.tr,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final success = controller.submitAndFinishVisit();
    if (success) {
      Get.back();
      Get.snackbar(
        'report_sent_success_title'.tr,
        'report_sent_success_body'.tr,
        backgroundColor: const Color(0xFF30913F),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
