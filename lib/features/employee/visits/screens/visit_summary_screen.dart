import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'contract_signing_screen.dart';

class VisitSummaryScreen extends StatelessWidget {
  final StoreVisitModel visit;

  const VisitSummaryScreen({
    super.key,
    required this.visit,
  });

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _lightGreenBg = Color(0xFFEBFEEB);
  static const Color _lightGreenBorder = Color(0xFFB8F2BD);
  static const Color _screenBg = Color(0xFFF8F9FA);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _subText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreVisitsController>(
      builder: (controller) {
        final currentVisit = controller.activeVisit ?? visit;

        return Scaffold(
          backgroundColor: _screenBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: _darkText, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'visit_summary'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Store Data Section
                _buildCardSection(
                  title: 'store_data_section'.tr,
                  children: [
                    _buildTextField(
                      label: 'openings_count'.tr,
                      controller: controller.openingsController,
                      keyboardType: TextInputType.number,
                      hintText: '1',
                      onChanged: (_) => controller.registerActivity(),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      label: 'cr_number_label'.tr,
                      controller: controller.crNumberController,
                      hintText: 'commercial_register_hint'.tr,
                      onChanged: (_) => controller.registerActivity(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Manager Data Section
                _buildCardSection(
                  title: 'manager_data_section'.tr,
                  children: [
                    _buildTextField(
                      label: 'manager_name'.tr,
                      controller: controller.managerNameController,
                      hintText: 'contact_person_hint'.tr,
                      onChanged: (_) => controller.registerActivity(),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      label: 'phone_number_label'.tr,
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      hintText: 'enter_phone'.tr,
                      onChanged: (_) => controller.registerActivity(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Interest Status Section
                _buildCardSection(
                  title: 'interest_status'.tr,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInterestChip(
                          label: 'very_interested'.tr,
                          keyName: 'very_interested',
                          controller: controller,
                        ),
                        _buildInterestChip(
                          label: 'interested'.tr,
                          keyName: 'interested',
                          controller: controller,
                        ),
                        _buildInterestChip(
                          label: 'grace_period'.tr,
                          keyName: 'grace_period',
                          controller: controller,
                        ),
                        _buildInterestChip(
                          label: 'needs_follow_up'.tr,
                          keyName: 'needs_follow_up',
                          controller: controller,
                        ),
                        _buildInterestChip(
                          label: 'not_interested'.tr,
                          keyName: 'not_interested',
                          controller: controller,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. Sales Stage Section
                _buildCardSection(
                  title: 'sales_stage'.tr,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPipelineChip(
                          label: 'not_met'.tr,
                          step: StorePipelineStep.notMet,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'introduced'.tr,
                          step: StorePipelineStep.presented,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'interested'.tr,
                          step: StorePipelineStep.interested,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'grace_period'.tr,
                          step: StorePipelineStep.gracePeriod,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'negotiating'.tr,
                          step: StorePipelineStep.negotiating,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'contract_signed'.tr,
                          step: StorePipelineStep.contractSigned,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'not_qualified'.tr,
                          step: StorePipelineStep.notQualified,
                          controller: controller,
                        ),
                        _buildPipelineChip(
                          label: 'rejected'.tr,
                          step: StorePipelineStep.rejected,
                          controller: controller,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 5. Dynamic Conditional Content Based on Selected Sales Stage
                if (controller.selectedPipelineStep == StorePipelineStep.notMet) ...[
                  _buildCardSection(
                    title: 'reason_not_met'.tr,
                    children: [
                      _buildTextField(
                        label: 'reason_not_met'.tr,
                        controller: controller.reasonNotMetController,
                        hintText: 'enter_reason_hint'.tr,
                        maxLines: 3,
                        onChanged: (_) => controller.registerActivity(),
                      ),
                    ],
                  ),
                ] else if (controller.selectedPipelineStep == StorePipelineStep.rejected) ...[
                  _buildCardSection(
                    title: 'reason_rejected'.tr,
                    children: [
                      _buildTextField(
                        label: 'reason_rejected'.tr,
                        controller: controller.reasonRejectedController,
                        hintText: 'enter_reason_hint'.tr,
                        maxLines: 3,
                        onChanged: (_) => controller.registerActivity(),
                      ),
                    ],
                  ),
                ] else if (controller.selectedPipelineStep == StorePipelineStep.notQualified) ...[
                  _buildCardSection(
                    title: 'reason_disqualified'.tr,
                    children: [
                      _buildTextField(
                        label: 'reason_disqualified'.tr,
                        controller: controller.reasonDisqualifiedController,
                        hintText: 'enter_reason_hint'.tr,
                        maxLines: 3,
                        onChanged: (_) => controller.registerActivity(),
                      ),
                    ],
                  ),
                ] else ...[
                  // Green Wallet Alert Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lightGreenBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _lightGreenBorder, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: _primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'wallet_balance_first_alert'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Next Follow Up Date Picker (if applicable)
                  if (controller.selectedPipelineStep == StorePipelineStep.gracePeriod ||
                      controller.selectedPipelineStep == StorePipelineStep.negotiating ||
                      controller.selectedPipelineStep == StorePipelineStep.interested) ...[
                    _buildCardSection(
                      title: 'next_follow_up_date'.tr,
                      children: [
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.selectedFollowUpDate ?? now.add(const Duration(days: 2)),
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              controller.setFollowUpDate(picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _cardBorder, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.selectedFollowUpDate != null
                                      ? DateFormat('yyyy-MM-dd').format(controller.selectedFollowUpDate!)
                                      : 'select_date'.tr.isNotEmpty && 'select_date'.tr != 'select_date'
                                          ? 'select_date'.tr
                                          : 'اختر التاريخ',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    color: controller.selectedFollowUpDate != null ? _darkText : _subText,
                                  ),
                                ),
                                const Icon(IconlyLight.calendar, color: Color(0xFF6B7280), size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Required Commitments Card
                  _buildCardSection(
                    title: 'required_commitments'.tr,
                    children: [
                      _buildTextField(
                        label: 'required_commitments'.tr,
                        controller: controller.commitmentsController,
                        hintText: 'commitments_hint'.tr,
                        maxLines: 3,
                        onChanged: (_) => controller.registerActivity(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Obstacles & Issues Card
                  _buildCardSection(
                    title: 'obstacles_and_issues'.tr,
                    children: [
                      _buildTextField(
                        label: 'obstacles_and_issues'.tr,
                        controller: controller.obstaclesController,
                        hintText: 'obstacles_hint'.tr,
                        maxLines: 3,
                        onChanged: (_) => controller.registerActivity(),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Confidential Report Button
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showConfidentialReportBottomSheet(context, controller, currentVisit),
                      icon: const Icon(IconlyLight.shieldDone, size: 18, color: Color(0xFF374151)),
                      label: Text(
                        'confidential_report'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Complete and Document Visit Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final isContract = controller.selectedPipelineStep == StorePipelineStep.contractSigned;
                          controller.submitAndFinishVisit();

                          if (isContract) {
                            Get.off(() => ContractSigningScreen(visit: currentVisit));
                          } else {
                            Get.back(); // close summary
                            Get.back(); // close photo doc
                            Get.snackbar(
                              'visit_completed_successfully'.tr,
                              '${'store_name'.tr}: ${currentVisit.storeName}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFECFDF5),
                              colorText: _primaryGreen,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 3),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'finish_and_document_visit'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            color: _darkText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip({
    required String label,
    required String keyName,
    required StoreVisitsController controller,
  }) {
    final bool isSelected = controller.selectedInterestStatus == keyName;

    return InkWell(
      onTap: () => controller.setInterestStatus(keyName),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _lightGreenBg : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primaryGreen : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? _primaryGreen : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineChip({
    required String label,
    required StorePipelineStep step,
    required StoreVisitsController controller,
  }) {
    final bool isSelected = controller.selectedPipelineStep == step;

    return InkWell(
      onTap: () => controller.setPipelineStep(step),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _lightGreenBg : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primaryGreen : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? _primaryGreen : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  void _showConfidentialReportBottomSheet(
    BuildContext context,
    StoreVisitsController controller,
    StoreVisitModel visit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(IconlyLight.shieldDone, color: _primaryGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'confidential_report'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _darkText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                Text(
                  'confidential_notes_disclaimer'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: _subText,
                  ),
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),

                // Report Title Field
                _buildTextField(
                  label: 'report_title'.tr,
                  controller: controller.confidentialTitleController,
                  hintText: 'report_title_hint'.tr,
                  onChanged: (_) => controller.registerActivity(),
                ),

                const SizedBox(height: 14),

                // Store Name (Read only)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'concerned_store'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: Text(
                        visit.storeName,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _darkText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Confidential Notes Field
                _buildTextField(
                  label: 'confidential_notes'.tr,
                  controller: controller.confidentialNotesController,
                  hintText: 'confidential_notes_hint'.tr,
                  maxLines: 4,
                  onChanged: (_) => controller.registerActivity(),
                ),

                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.registerActivity();
                      Navigator.of(ctx).pop();
                      Get.snackbar(
                        'confidential_report'.tr,
                        'save_confidential_report'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFECFDF5),
                        colorText: _primaryGreen,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'save_confidential_report'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
  }
}
