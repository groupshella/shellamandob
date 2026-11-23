import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../common/controllers/theme_controller.dart';
import '../../../../core/widgets/skeleton_loading_widgets.dart';
import '../../../../helper/route_helper.dart';
import '../../controllers/employee_navigation_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';

/// Submit Visit Summary Screen matching Figma (9905:30349 & 9944:99720):
/// 1. ملخص الوقت
/// 2. بيانات المحل
/// 3. بيانات المسؤول
/// 4. جهات اتصال المتجر والتدريب
/// 5. نتيجة الزيارة
/// 6. تحليل ذكي للزيارة (حالة طبيعية بنفسجية 9944:99720 أو حالة تناقض حمراء 9905:30349)
/// Actions: [إرسال البيانات للمشرف] & [تعديل البيانات]
class SubmitVisitSummaryScreen extends StatefulWidget {
  final StoreVisitModel visit;
  final bool isReadOnly;
  final bool cameDirectlyFromSummary;

  const SubmitVisitSummaryScreen({
    super.key,
    required this.visit,
    this.isReadOnly = false,
    this.cameDirectlyFromSummary = false,
  });

  @override
  State<SubmitVisitSummaryScreen> createState() =>
      _SubmitVisitSummaryScreenState();
}

class _SubmitVisitSummaryScreenState extends State<SubmitVisitSummaryScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _aiPurple = Color(0xFF7861A6);

  bool _isAnalyzing = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!Get.isRegistered<StoreVisitsController>()) {
      if (mounted) setState(() => _isAnalyzing = false);
      return;
    }
    final ctrl = Get.find<StoreVisitsController>();
    try {
      if (widget.isReadOnly && widget.visit.storeId != null) {
        try {
          await ctrl.loadStoreContacts(widget.visit.storeId!);
          if (mounted) setState(() {});
        } catch (_) {}
      }
      final res = await ctrl.analyzeVisitSummary(widget.visit);
      if (mounted) {
        setState(() {
          _aiAnalysis = res;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  String _formatTime(DateTime dt) {
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('hh:mm a', lang).format(dt);
  }

  String _localizeInterest(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    switch (raw) {
      case 'very_interested':
        return 'very_interested'.tr;
      case 'interested':
        return 'interested'.tr;
      case 'requested_grace_period':
        return 'requested_grace_period'.tr;
      case 'needs_follow_up':
        return 'needs_follow_up'.tr;
      case 'not_interested':
        return 'not_interested'.tr;
      default:
        return raw;
    }
  }

  ({Color bg, Color border, Color text}) _salesStagePillStyle(
      StorePipelineStep step, bool isDark) {
    switch (step) {
      case StorePipelineStep.presented:
        return (
          bg: isDark ? const Color(0xFF14273D) : const Color(0xFFEBFCFE),
          border: isDark ? const Color(0xFF60A5FA) : const Color(0xFF23497E),
          text: isDark ? const Color(0xFF93C5FD) : const Color(0xFF23497E),
        );
      case StorePipelineStep.rejected:
      case StorePipelineStep.notQualified:
        return (
          bg: isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2),
          border: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          text: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
        );
      case StorePipelineStep.negotiating:
      case StorePipelineStep.gracePeriod:
        return (
          bg: isDark ? const Color(0xFF2A1E3D) : const Color(0xFFF4EFFB),
          border: isDark ? const Color(0xFFC4B5FD) : _aiPurple,
          text: isDark ? const Color(0xFFC4B5FD) : _aiPurple,
        );
      default:
        return (
          bg: isDark ? const Color(0xFF132D1B) : const Color(0xFFEBFEEB),
          border: _primaryGreen,
          text: _primaryGreen,
        );
    }
  }

  Future<void> _submitToSupervisor() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      if (Get.isRegistered<StoreVisitsController>()) {
        final ctrl = Get.find<StoreVisitsController>();
        await ctrl.submitAndFinishVisit(targetVisit: widget.visit);
        await ctrl.loadVisits();
      }

      Get.snackbar(
        'visit_summary_sent_success'.tr,
        widget.visit.storeName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFECFDF5),
        colorText: _primaryGreen,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );

      if (Get.isRegistered<EmployeeNavigationController>()) {
        Get.find<EmployeeNavigationController>().changeIndex(2);
      }
      Get.offAllNamed(RouteHelper.getEmployeeMainRoute());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final ctrl = Get.isRegistered<StoreVisitsController>()
        ? Get.find<StoreVisitsController>()
        : null;

    final fallbackDuration =
        widget.visit.durationMinutes > 0 ? widget.visit.durationMinutes : 30;
    final endTime = widget.visit.completedAt ??
        (widget.isReadOnly && widget.visit.startedAt != null
            ? widget.visit.startedAt!.add(Duration(minutes: fallbackDuration))
            : DateTime.now());
    final startTime = widget.visit.startedAt ??
        endTime.subtract(Duration(minutes: fallbackDuration));
    final totalMinutes = (widget.isReadOnly && widget.visit.durationMinutes > 0)
        ? widget.visit.durationMinutes
        : endTime.difference(startTime).inMinutes.clamp(1, 600);
    final extraMinutes = widget.visit.extendedMinutes > 0
        ? widget.visit.extendedMinutes
        : (totalMinutes > 30 ? (totalMinutes - 30) : 0);
    final baseMinutes =
        (totalMinutes - extraMinutes).clamp(1, totalMinutes);

    final contacts = ctrl?.storeContacts ?? [];
    final primaryContact = contacts.isNotEmpty ? contacts.first : null;

    final hasContradiction = _aiAnalysis?['has_contradiction'] == true;
    final interestScore =
        (_aiAnalysis?['interest_score'] as num?)?.toInt() ?? 0;
    final interestLabel = isAr
        ? (_aiAnalysis?['interest_label_ar']?.toString() ?? '-')
        : (_aiAnalysis?['interest_label_en']?.toString() ?? '-');
    final closingProb =
        (_aiAnalysis?['closing_probability'] as num?)?.toInt() ?? 0;
    final closingLabel = isAr
        ? (_aiAnalysis?['closing_label_ar']?.toString() ?? '-')
        : (_aiAnalysis?['closing_label_en']?.toString() ?? '-');
    final suggestedApproach = isAr
        ? (_aiAnalysis?['suggested_approach_ar']?.toString() ?? '')
        : (_aiAnalysis?['suggested_approach_en']?.toString() ?? '');

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final tileBg =
            isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final darkText = isDark ? Colors.white : const Color(0xFF19201B);
        final headlineText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6C756E);
        final borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE4E9E5);
        final stagePill =
            _salesStagePillStyle(widget.visit.pipelineStep, isDark);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Transform.flip(
                flipX: !isRtl,
                child: SvgPicture.asset(
                  'assets/image/figma_arrow_right.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    headlineText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            title: Text(
              widget.isReadOnly
                  ? 'view_report'.tr
                  : 'submit_visit_summary_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: headlineText,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. ملخص الوقت (Figma 9905:30611)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'time_summary_section'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeBox(
                                label: 'visit_start_time_label'.tr,
                                value: _formatTime(startTime),
                                bg: tileBg,
                                valueColor: darkText,
                                labelColor: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTimeBox(
                                label: 'visit_end_time_label'.tr,
                                value: _formatTime(endTime),
                                bg: tileBg,
                                valueColor: darkText,
                                labelColor: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeBox(
                                label: 'base_visit_duration_label'.tr,
                                value: '$baseMinutes ${'minute_unit'.tr}',
                                bg: tileBg,
                                valueColor: darkText,
                                labelColor: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTimeBox(
                                label: 'extra_overtime_label'.tr,
                                value: '$extraMinutes ${'minute_unit'.tr}',
                                bg: isDark
                                    ? const Color(0xFF2C203E)
                                    : const Color(0xFFF4EFFB),
                                valueColor: isDark
                                    ? const Color(0xFFC4B5FD)
                                    : _aiPurple,
                                labelColor: isDark
                                    ? const Color(0xFFC4B5FD)
                                    : _aiPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total_actual_duration_label'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: darkText,
                              ),
                            ),
                            Text(
                              '$totalMinutes ${'minute_unit'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. بيانات المحل (Figma 9905:30667)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'store_data'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: headlineText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildKeyValueRow(
                            'openings_count'.tr,
                            widget.visit.openingsCount.toString(),
                            darkText,
                            subText,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _buildKeyValueRow(
                            'cr_number'.tr,
                            widget.visit.crNumber.isNotEmpty
                                ? widget.visit.crNumber
                                : '-',
                            darkText,
                            subText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. بيانات المسؤول (Figma 9905:30682)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'manager_data_section'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: headlineText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildKeyValueRow(
                            'manager_name_label'.tr,
                            widget.visit.managerName.isNotEmpty
                                ? widget.visit.managerName
                                : '-',
                            darkText,
                            subText,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _buildKeyValueRow(
                            'phone_number_label'.tr,
                            widget.visit.phone.isNotEmpty
                                ? widget.visit.phone
                                : '-',
                            darkText,
                            subText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. جهات اتصال المتجر والتدريب (Figma 9905:30696)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'store_contacts_training_section'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: headlineText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _buildBadgeRow(
                            label: 'store_role_label'.tr,
                            value: primaryContact?.role ??
                                widget.visit.interviewedPersonRole ??
                                'store_owner_role'.tr,
                            subText: subText,
                            bg: isDark
                                ? const Color(0xFF132D1B)
                                : const Color(0xFFEBFEEB),
                            border: isDark
                                ? _primaryGreen
                                : const Color(0xFF1A611E),
                            textColor: isDark
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFF1A611E),
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildKeyValueRow(
                            'full_name_label'.tr,
                            primaryContact?.name ??
                                (widget.visit.decisionMakerName?.isNotEmpty ==
                                        true
                                    ? widget.visit.decisionMakerName!
                                    : widget.visit.managerName),
                            darkText,
                            subText,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildKeyValueRow(
                            'whatsapp_training_phone_label'.tr,
                            primaryContact?.phone ??
                                (widget.visit.decisionMakerPhone?.isNotEmpty ==
                                        true
                                    ? widget.visit.decisionMakerPhone!
                                    : widget.visit.phone),
                            darkText,
                            subText,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _buildKeyValueRow(
                            'preferred_training_lang_label'.tr,
                            primaryContact?.preferredLanguage ??
                                'arabic_lang_label'.tr,
                            darkText,
                            subText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. نتيجة الزيارة (Figma 9905:30860)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'visit_result_section'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: headlineText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _buildBadgeRow(
                            label: 'interest_status_label'.tr,
                            value: _localizeInterest(widget.visit.interestStatus),
                            subText: subText,
                            bg: isDark
                                ? const Color(0xFF132D1B)
                                : const Color(0xFFEBFEEB),
                            border: _primaryGreen,
                            textColor: _primaryGreen,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _buildBadgeRow(
                            label: 'sales_stage_label'.tr,
                            value: widget.visit.pipelineStep.localizedLabel,
                            subText: subText,
                            bg: stagePill.bg,
                            border: stagePill.border,
                            textColor: stagePill.text,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildKeyValueRow(
                            'not_met_reason_label'.tr,
                            (widget.visit.closingReason ?? '').isNotEmpty
                                ? widget.visit.closingReason!
                                : '-',
                            darkText,
                            subText,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ready_promos_label'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: subText,
                                ),
                              ),
                              if ((widget.visit.selectedPromo ?? '').isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF132D1B)
                                        : const Color(0xFFEBFEEB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.visit.selectedPromo!,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '-',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: darkText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: _buildKeyValueRow(
                            'required_commitments_label'.tr,
                            (widget.visit.nextFollowUpCommitments ?? '')
                                    .isNotEmpty
                                ? widget.visit.nextFollowUpCommitments!
                                : '-',
                            darkText,
                            subText,
                          ),
                        ),
                        Divider(height: 1, thickness: 0.8, color: borderColor),
                        const SizedBox(height: 8),
                        Text(
                          'obstacles_and_issues_label'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: subText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (widget.visit.obstaclesNotes ?? '').isNotEmpty
                              ? widget.visit.obstaclesNotes!
                              : '-',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. تحليل ذكي للزيارة (Figma 9944:99840 Purple / 9894:28197 Red)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: hasContradiction
                            ? (isDark
                                ? [
                                    const Color(0xFF35191C),
                                    const Color(0xFF1C2028)
                                  ]
                                : [const Color(0xFFFFE2E2), Colors.white])
                            : (isDark
                                ? [
                                    const Color(0xFF241C35),
                                    const Color(0xFF1C2028)
                                  ]
                                : [const Color(0xFFF6F1FD), Colors.white]),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? (hasContradiction
                                ? const Color(0xFF7F1D1D)
                                : const Color(0xFF4C3B6E))
                            : const Color(0xFFD9CAEF),
                        width: 0.8,
                      ),
                    ),
                    child: _isAnalyzing
                        ? SkeletonLoadingWidgets.inlineCardSkeleton(isDark: isDark, height: 96)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: hasContradiction
                                          ? (isDark
                                              ? const Color(0xFF4A1D21)
                                              : const Color(0xFFF9E3E3))
                                          : (isDark
                                              ? const Color(0xFF35284E)
                                              : const Color(0xFFEAE3F9)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/image/figma_summary_star.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        hasContradiction
                                            ? const Color(0xFFAB1414)
                                            : _aiPurple,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'ai_visit_analysis_title'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: hasContradiction
                                          ? (isDark
                                              ? const Color(0xFFF87171)
                                              : const Color(0xFFAB1414))
                                          : (isDark
                                              ? const Color(0xFFC4B5FD)
                                              : const Color(0xFF59427F)),
                                    ),
                                  ),
                                ],
                              ),
                              if (!hasContradiction) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'merchant_interest_index_label'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 9,
                                            color: headlineText,
                                          ),
                                        ),
                                        Text(
                                          interestLabel,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? const Color(0xFFC4B5FD)
                                                : _aiPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '$interestScore%',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFFC4B5FD)
                                            : _aiPurple,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF332B47)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: FractionallySizedBox(
                                    alignment: AlignmentDirectional.centerStart,
                                    widthFactor:
                                        (interestScore / 100.0).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFAD94DC),
                                            _aiPurple
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Divider(
                                height: 1,
                                thickness: 0.8,
                                color: isDark
                                    ? const Color(0xFF3B3054)
                                    : const Color(0xFFE5DCEF),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'closing_probability_label'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: headlineText,
                                    ),
                                  ),
                                  Text(
                                    '$closingLabel · $closingProb%',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: headlineText,
                                    ),
                                  ),
                                ],
                              ),
                              if (suggestedApproach.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: hasContradiction
                                          ? const Color(0xFFA66162)
                                          : _aiPurple,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'suggested_approach_label'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: hasContradiction
                                              ? const Color(0xFFDC2626)
                                              : (isDark
                                                  ? const Color(0xFFC4B5FD)
                                                  : _aiPurple),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        suggestedApproach,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                          color: headlineText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),

                  if (!widget.isReadOnly) ...[
                    const SizedBox(height: 16),

                    // Bottom Actions: إرسال البيانات للمشرف + تعديل البيانات (Figma 9913:55053)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || hasContradiction)
                            ? null
                            : _submitToSupervisor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          disabledBackgroundColor: isDark
                              ? const Color(0xFF2B3240)
                              : const Color(0xFFE2E4E6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'send_data_to_supervisor_btn'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: hasContradiction
                                      ? (isDark
                                          ? Colors.white54
                                          : const Color(0xFF555555))
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          if (!widget.cameDirectlyFromSummary) {
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF252B37)
                              : const Color(0xFFF6F6F6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'edit_data_btn'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF343434),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeBox({
    required String label,
    required String value,
    required Color bg,
    required Color valueColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A1C3420),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildKeyValueRow(
      String label, String value, Color darkText, Color subText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subText,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeRow({
    required String label,
    required String value,
    required Color subText,
    required Color bg,
    required Color border,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subText,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
