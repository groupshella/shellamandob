import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'contract_signing_screen.dart';
import 'follow_up_task_screen.dart';

class VisitSummaryScreen extends StatefulWidget {
  final StoreVisitModel visit;
  final bool isReadOnly;

  const VisitSummaryScreen({
    super.key,
    required this.visit,
    this.isReadOnly = false,
  });

  @override
  State<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _InterestOptionItem {
  final String key;
  final String label;
  const _InterestOptionItem({required this.key, required this.label});
}

class _VisitSummaryScreenState extends State<VisitSummaryScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  late bool _isEditable;

  List<_InterestOptionItem> get _interestOptions => [
    _InterestOptionItem(key: 'requested_grace_period', label: 'requested_grace_period'.tr),
    _InterestOptionItem(key: 'interested', label: 'interested'.tr),
    _InterestOptionItem(key: 'very_interested', label: 'very_interested'.tr),
    _InterestOptionItem(key: 'needs_follow_up', label: 'needs_follow_up'.tr),
    _InterestOptionItem(key: 'not_interested', label: 'not_interested'.tr),
  ];

  @override
  void initState() {
    super.initState();
    _isEditable = !widget.isReadOnly || widget.visit.visitStatus == StoreVisitStatus.followUp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        final controller = Get.find<StoreVisitsController>();
        controller.storeNameController.text = widget.visit.storeName;
        controller.managerNameController.text = widget.visit.managerName;
        controller.phoneController.text = widget.visit.phone;
        controller.openingsController.text = widget.visit.openingsCount.toString();
        controller.crNumberController.text = widget.visit.crNumber;
        controller.commitmentsController.text = widget.visit.nextFollowUpCommitments ?? '';
        controller.obstaclesController.text = widget.visit.obstaclesNotes ?? '';
        controller.confidentialNotesController.text = widget.visit.confidentialNotes ?? '';
        controller.setPipelineStep(widget.visit.pipelineStep);
        if (widget.visit.interestStatus != null && widget.visit.interestStatus!.isNotEmpty) {
          controller.setInterestStatus(widget.visit.interestStatus!);
        }
        if (widget.visit.closingReason != null) {
          controller.reasonNotMetController.text = widget.visit.closingReason!;
          controller.reasonRejectedController.text = widget.visit.closingReason!;
          controller.reasonDisqualifiedController.text = widget.visit.closingReason!;
        }
      }
    });
  }

  void _syncInputsToController(StoreVisitsController controller) {
    controller.registerActivity();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final screenBg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final inputFill = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final selectedBg = isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB);
        final unselectedBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final unselectedBorder = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF3F4F6);

        return GetBuilder<StoreVisitsController>(
          init: Get.isRegistered<StoreVisitsController>()
              ? Get.find<StoreVisitsController>()
              : Get.put(StoreVisitsController(), permanent: true),
          autoRemove: false,
          builder: (controller) {
            final currentVisit = widget.isReadOnly ? widget.visit : (controller.activeVisit ?? widget.visit);
            final isContract = controller.selectedPipelineStep == StorePipelineStep.contractSigned;

            return Scaffold(
              backgroundColor: screenBg,
              appBar: AppBar(
                backgroundColor: cardBg,
                elevation: 0.5,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  'visit_summary'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                actions: [
                  if (currentVisit.visitStatus == StoreVisitStatus.followUp)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1F56) : const Color(0xFFDFD3F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF7861A6) : const Color(0xFFC7B3E8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7861A6)),
                          const SizedBox(width: 4),
                          Text(
                            'needs_follow_up'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7861A6),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (currentVisit.visitStatus == StoreVisitStatus.completed)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFB8F2BD)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: _primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            'completed_visit_badge'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!_isEditable)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditable = true;
                        });
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16, color: _primaryGreen),
                      label: Text(
                        'edit'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. بيانات المحل (Figma Container 8915:35142)
                    _buildSectionHeader('store_data'.tr, darkText),
                    const SizedBox(height: 8),
                    _buildCardContainer(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      children: [
                        _buildInputField(
                          label: 'openings_count'.tr,
                          controller: controller.openingsController,
                          hintText: 'openings_example'.tr,
                          keyboardType: TextInputType.number,
                          readOnly: !_isEditable,
                          initialValue: currentVisit.openingsCount.toString(),
                          onChanged: (_) => _syncInputsToController(controller),
                          darkText: darkText,
                          inputFill: inputFill,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'cr_number'.tr,
                          controller: controller.crNumberController,
                          hintText: '1010XXXXXX',
                          readOnly: !_isEditable,
                          initialValue: currentVisit.crNumber,
                          onChanged: (_) => _syncInputsToController(controller),
                          darkText: darkText,
                          inputFill: inputFill,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 2. بيانات المسؤول (Figma Container 8940:108585)
                    _buildSectionHeader('manager_data'.tr, darkText),
                    const SizedBox(height: 8),
                    _buildCardContainer(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      children: [
                        _buildInputField(
                          label: 'manager_name'.tr,
                          controller: controller.managerNameController,
                          hintText: 'enter_name'.tr,
                          readOnly: !_isEditable,
                          initialValue: currentVisit.managerName,
                          onChanged: (_) => _syncInputsToController(controller),
                          darkText: darkText,
                          inputFill: inputFill,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'phone_number'.tr,
                          controller: controller.phoneController,
                          hintText: '05XXXXXXXX',
                          keyboardType: TextInputType.phone,
                          readOnly: !_isEditable,
                          initialValue: currentVisit.phone,
                          onChanged: (_) => _syncInputsToController(controller),
                          darkText: darkText,
                          inputFill: inputFill,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3. حالة الاهتمام (Figma Node 8937:108427, 8942:1746, 8945:23023)
                    _buildSectionHeader('interest_status'.tr, darkText),
                    const SizedBox(height: 8),
                    _buildCardContainer(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interestOptions.map((option) {
                            final isSelected = controller.selectedInterestStatus == option.key ||
                                controller.selectedInterestStatus == option.label;
                            return InkWell(
                              onTap: !_isEditable ? null : () => controller.setInterestStatus(option.label),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedBg : unselectedBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? _primaryGreen : unselectedBorder,
                                    width: isSelected ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? _primaryGreen : darkText,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 4. مرحلة البيع (Figma Node 8937:108427, 8942:1746, 8945:23023)
                    _buildSectionHeader('sales_pipeline_step'.tr, darkText),
                    const SizedBox(height: 4),
                    Text(
                      'select_current_stage'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        color: subText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildCardContainer(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      children: [
                        _buildSalesStageGrid(
                          controller,
                          !_isEditable,
                          currentVisit.pipelineStep,
                          selectedBg: selectedBg,
                          unselectedBg: unselectedBg,
                          unselectedBorder: unselectedBorder,
                          darkText: darkText,
                        ),

                        // Conditional reason when 'لم تتم المقابلة' is selected (Figma Node 8942:1746 & 8945:23023)
                        if (controller.selectedPipelineStep == StorePipelineStep.notMet) ...[
                          const SizedBox(height: 14),
                          _buildInputField(
                            label: 'reason_not_met'.tr,
                            controller: controller.reasonNotMetController,
                            hintText: 'enter_reason'.tr,
                            readOnly: !_isEditable,
                            initialValue: currentVisit.closingReason,
                            onChanged: (_) => _syncInputsToController(controller),
                            darkText: darkText,
                            inputFill: inputFill,
                            isDark: isDark,
                          ),
                        ],

                        // Conditional reason when 'رفض' is selected
                        if (controller.selectedPipelineStep == StorePipelineStep.rejected) ...[
                          const SizedBox(height: 14),
                          _buildInputField(
                            label: 'reason_rejection'.tr,
                            controller: controller.reasonRejectedController,
                            hintText: 'enter_reason'.tr,
                            readOnly: !_isEditable,
                            initialValue: currentVisit.closingReason,
                            onChanged: (_) => _syncInputsToController(controller),
                            darkText: darkText,
                            inputFill: inputFill,
                            isDark: isDark,
                          ),
                        ],

                        // Conditional reason when 'غير مؤهل' is selected
                        if (controller.selectedPipelineStep == StorePipelineStep.notQualified) ...[
                          const SizedBox(height: 14),
                          _buildInputField(
                            label: 'reason_disqualification'.tr,
                            controller: controller.reasonDisqualifiedController,
                            hintText: 'enter_reason'.tr,
                            readOnly: !_isEditable,
                            initialValue: currentVisit.closingReason,
                            onChanged: (_) => _syncInputsToController(controller),
                            darkText: darkText,
                            inputFill: inputFill,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 5. الالتزامات والمعوقات (Figma Container 8937:108427)
                    _buildCardContainer(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      children: [
                        _buildInputField(
                          label: 'required_commitments'.tr,
                          controller: controller.commitmentsController,
                          hintText: 'commitments_example'.tr,
                          readOnly: !_isEditable,
                          initialValue: currentVisit.nextFollowUpCommitments,
                          onChanged: (_) => _syncInputsToController(controller),
                          darkText: darkText,
                          inputFill: inputFill,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          label: 'obstacles_and_issues'.tr,
                          controller: controller.obstaclesController,
                          hintText: 'obstacles_example'.tr,
                          readOnly: !_isEditable,
                          initialValue: currentVisit.obstaclesNotes,
                          onChanged: (_) => _syncInputsToController(controller),
                          darkText: darkText,
                          inputFill: inputFill,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Display Confidential Report if exists
                    if (currentVisit.confidentialNotes != null && currentVisit.confidentialNotes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader('confidential_report'.tr, darkText),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252B37) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF854D0E) : const Color(0xFFFEF08A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(IconlyLight.shieldDone, color: Color(0xFFCA8A04), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentVisit.confidentialNotes!,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF854D0E),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              bottomNavigationBar: _buildBottomBar(
                context,
                controller,
                currentVisit,
                isContract,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                darkText: darkText,
                subText: subText,
                inputFill: inputFill,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color darkText) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
    );
  }

  Widget _buildCardContainer({
    required List<Widget> children,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? initialValue,
    required ValueChanged<String> onChanged,
    required Color darkText,
    required Color inputFill,
    required bool isDark,
  }) {
    if (readOnly && controller.text.isEmpty && initialValue != null) {
      controller.text = initialValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: readOnly ? (isDark ? const Color(0xFF1E232D) : const Color(0xFFF9FAFB)) : inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: _primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Figma 3-row grid for 8 Sales Stages
  Widget _buildSalesStageGrid(
    StoreVisitsController controller,
    bool readOnly,
    StorePipelineStep initialStep, {
    required Color selectedBg,
    required Color unselectedBg,
    required Color unselectedBorder,
    required Color darkText,
  }) {
    final activeStep = readOnly ? initialStep : controller.selectedPipelineStep;

    final row1 = [
      StorePipelineStep.notMet,
      StorePipelineStep.presented,
      StorePipelineStep.interested,
    ];

    final row2 = [
      StorePipelineStep.gracePeriod,
      StorePipelineStep.negotiating,
      StorePipelineStep.contractSigned,
    ];

    final row3 = [
      StorePipelineStep.rejected,
      StorePipelineStep.notQualified,
    ];

    Widget buildStageButton(StorePipelineStep step) {
      final isSelected = activeStep == step;
      return Expanded(
        child: InkWell(
          onTap: readOnly ? null : () => controller.setPipelineStep(step),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : unselectedBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? _primaryGreen : unselectedBorder,
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Text(
              step.localizedLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _primaryGreen : darkText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Row 1: لم تتم المقابلة | تم تقديم شلة | مهتم
        Row(
          children: row1.map(buildStageButton).toList(),
        ),
        const SizedBox(height: 8),

        // Row 2: طلب مهلة | تفاوض | تم توقيع العقد
        Row(
          children: row2.map(buildStageButton).toList(),
        ),
        const SizedBox(height: 8),

        // Row 3: رفض | غير مؤهل
        Row(
          children: [
            buildStageButton(row3[0]),
            buildStageButton(row3[1]),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  // Figma Frame 7 & Frame 2085664369: Bottom Actions
  Widget _buildBottomBar(
    BuildContext context,
    StoreVisitsController controller,
    StoreVisitModel currentVisit,
    bool isContract, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color darkText,
    required Color subText,
    required Color inputFill,
  }) {
    if (!_isEditable) {
      final hasSignedContract = currentVisit.contractSignaturePath != null ||
          currentVisit.pipelineStep == StorePipelineStep.contractSigned;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSignedContract) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => ContractSigningScreen(visit: currentVisit)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'contract_details'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditable = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'edit_and_save_data'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'done_back_to_visits'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Frame 7: تقرير سري Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showConfidentialReportBottomSheet(
                  context,
                  controller,
                  currentVisit,
                  isDark: isDark,
                  cardBg: cardBg,
                  darkText: darkText,
                  inputFill: inputFill,
                ),
                icon: Icon(IconlyLight.shieldDone, size: 20, color: darkText),
                label: Text(
                  'confidential_report'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF252B37) : const Color(0xFFF6F6F6),
                  elevation: 0,
                  side: BorderSide(color: borderColor, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Frame 2085664369: متابعة لنتيجة الزيارة / الانتقال لتوقيع العقد
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Save all current form fields to the active visit model
                  final updatedVisit = currentVisit.copyWith(
                    openingsCount: int.tryParse(controller.openingsController.text) ?? currentVisit.openingsCount,
                    crNumber: controller.crNumberController.text,
                    managerName: controller.managerNameController.text,
                    phone: controller.phoneController.text,
                    pipelineStep: controller.selectedPipelineStep,
                    interestStatus: controller.selectedInterestStatus,
                    nextFollowUpCommitments: controller.commitmentsController.text,
                    obstaclesNotes: controller.obstaclesController.text,
                    closingReason: controller.selectedPipelineStep == StorePipelineStep.notMet
                        ? controller.reasonNotMetController.text
                        : (controller.selectedPipelineStep == StorePipelineStep.rejected
                            ? controller.reasonRejectedController.text
                            : controller.reasonDisqualifiedController.text),
                  );

                  if (isContract) {
                    Get.to(() => ContractSigningScreen(visit: updatedVisit));
                  } else {
                    Get.to(() => FollowUpTaskScreen(visit: updatedVisit));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isContract ? 'contract_signed'.tr : 'continue_text'.tr,
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
  }

  // Figma Frame 8937:108513: تقرير سري BottomSheet
  void _showConfidentialReportBottomSheet(
    BuildContext context,
    StoreVisitsController controller,
    StoreVisitModel visit, {
    required bool isDark,
    required Color cardBg,
    required Color darkText,
    required Color inputFill,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool hasContent = controller.confidentialNotesController.text.trim().isNotEmpty ||
                controller.confidentialTitleController.text.trim().isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title: تقرير سري
                    Text(
                      'confidential_report'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle: Store Name
                    Text(
                      visit.storeName.isNotEmpty ? visit.storeName : '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Label: عنوان التقرير
                    Text(
                      'report_title'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller.confidentialTitleController,
                        onChanged: (_) => setModalState(() {}),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: darkText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'report_title_example'.tr,
                          hintStyle: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF707784),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Label: الملاحظات السرية
                    Text(
                      'confidential_notes'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller.confidentialNotesController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) => setModalState(() {}),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: darkText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'write_notes_here'.tr,
                          hintStyle: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF707784),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Button: حفظ الملاحظات
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.snackbar(
                            'notes_saved_success'.tr,
                            'notes_saved_success'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB),
                            colorText: _primaryGreen,
                            margin: const EdgeInsets.all(16),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasContent ? _primaryGreen : (isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6)),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'save_notes'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: hasContent ? Colors.white : const Color(0xFF555555),
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
