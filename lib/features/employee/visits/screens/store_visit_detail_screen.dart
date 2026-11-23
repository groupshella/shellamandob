import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../../../../core/widgets/skeleton_loading_widgets.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'active_store_visit_screen.dart';
import 'store_visit_map_screen.dart';

/// Pre-visit Store Details Screen matching Figma (Image 4):
/// - First-time state ("أول مرة"): Header card (Store name, badge, Start Visit & Open Location) + Visit Details card.
/// - Follow-up state ("متابعة"): Same header & Visit Details + Expandable Supervisor Recommendations card +
///   Store Data card + Manager Data card + Previous Visit Result card.
class StoreVisitDetailScreen extends StatefulWidget {
  final StoreVisitModel visit;
  final bool isReadOnly;

  const StoreVisitDetailScreen({
    super.key,
    required this.visit,
    this.isReadOnly = false,
  });

  @override
  State<StoreVisitDetailScreen> createState() => _StoreVisitDetailScreenState();
}

class _StoreVisitDetailScreenState extends State<StoreVisitDetailScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  bool _isLoading = true;
  bool _isFollowUp = false;
  bool _isRecommendationExpanded = true;
  List<Map<String, dynamic>> _recommendations = [];
  Map<String, dynamic>? _previousResult;

  @override
  void initState() {
    super.initState();
    _isFollowUp = widget.visit.isFollowUpVisit;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    if (!Get.isRegistered<StoreVisitsController>()) {
      setState(() => _isLoading = false);
      return;
    }
    final controller = Get.find<StoreVisitsController>();
    final data = await controller.fetchVisitDetails(widget.visit.id);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        _isFollowUp = (data['visit_type']?.toString() == 'follow_up') ||
            widget.visit.isFollowUpVisit;
        if (data['recommendations'] is List) {
          _recommendations = (data['recommendations'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (data['previous_result'] is Map) {
          _previousResult = Map<String, dynamic>.from(data['previous_result']);
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _localizePipelineStep(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    for (final step in StorePipelineStep.values) {
      if (step.name.toLowerCase() == raw.toLowerCase() ||
          raw.toLowerCase().replaceAll('_', '') == step.name.toLowerCase()) {
        return step.localizedLabel;
      }
    }
    return raw;
  }

  String _nonEmptyOrDash(String? primary, String? fallback) {
    final p = primary?.trim() ?? '';
    if (p.isNotEmpty) return p;
    final f = fallback?.trim() ?? '';
    if (f.isNotEmpty) return f;
    return '-';
  }

  String _localizeInterestStatus(String? raw) {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        final visit = widget.visit;
        final openings = _previousResult?['openings_count']?.toString() ??
            visit.openingsCount.toString();
        final crNumber = (_previousResult?['cr_number']?.toString() ?? '').isNotEmpty
            ? _previousResult!['cr_number'].toString()
            : (visit.crNumber.isNotEmpty ? visit.crNumber : '-');
        final managerName = (_previousResult?['manager_name']?.toString() ?? '').isNotEmpty
            ? _previousResult!['manager_name'].toString()
            : (visit.managerName.isNotEmpty ? visit.managerName : '-');
        final phone = (_previousResult?['phone']?.toString() ?? '').isNotEmpty
            ? _previousResult!['phone'].toString()
            : (visit.phone.isNotEmpty ? visit.phone : '-');

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? IconlyLight.arrowRight2
                    : IconlyLight.arrowLeft2,
                color: darkText,
                size: 22,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'store_details_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Store Action Card (Name + Badge + Start Visit & Open Location)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                visit.storeName,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isFollowUp
                                    ? (isDark
                                        ? const Color(0xFF3B1F56)
                                        : const Color(0xFFEDE9FE))
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFEFF6FF)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isFollowUp
                                    ? 'follow_up_label'.tr
                                    : 'first_time_badge'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _isFollowUp
                                      ? (isDark
                                          ? const Color(0xFFC084FC)
                                          : const Color(0xFF7861A6))
                                      : (isDark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF3B82F6)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!Get.isRegistered<StoreVisitsController>()) {
                                      return;
                                    }
                                    final ctrl = Get.find<StoreVisitsController>();
                                    if (!ctrl.canStartVisit(showWarning: true)) {
                                      return;
                                    }
                                    ctrl.startVisit(visit);
                                    Get.off(() => ActiveStoreVisitScreen(visit: visit));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryGreen,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'start_visit_action'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.to(() => StoreVisitMapScreen(visit: visit));
                                  },
                                  icon: const Icon(
                                    IconlyLight.location,
                                    size: 18,
                                    color: _primaryGreen,
                                  ),
                                  label: Text(
                                    'open_location_btn'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? const Color(0xFF132D1B)
                                        : const Color(0xFFEBFEEB),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Visit Details Card (Address, Time, Duration)
                  _buildCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'visit_details_section'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(IconlyLight.location, size: 16, color: subText),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                visit.address.isNotEmpty
                                    ? visit.address
                                    : 'not_specified_address'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                  color: subText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(IconlyLight.timeCircle, size: 16, color: subText),
                            const SizedBox(width: 8),
                            Text(
                              visit.localizedTimeSlot.isNotEmpty
                                  ? visit.localizedTimeSlot
                                  : '09:00 AM',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: subText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${'visit_duration_label'.tr} 30 ${'minute_unit'.tr}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Follow-up extra sections (Matching Figma Right Screen)
                  if (_isFollowUp) ...[
                    const SizedBox(height: 14),

                    // 3. Supervisor Recommendations Expandable Card
                    if (_isLoading)
                      SkeletonLoadingWidgets.inlineCardSkeleton(isDark: isDark)
                    else if (_recommendations.isNotEmpty)
                      _buildSupervisorRecommendationCard(
                        rec: _recommendations.first,
                        isDark: isDark,
                        darkText: darkText,
                        subText: subText,
                      ),

                    const SizedBox(height: 14),

                    // 4. Store Data Card (بيانات المحل)
                    _buildCard(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'store_data'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildKeyValueRow('openings_count'.tr, openings, darkText, subText),
                          const Divider(height: 18),
                          _buildKeyValueRow('cr_number'.tr, crNumber, darkText, subText),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 5. Manager Data Card (بيانات المسؤول)
                    _buildCard(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'manager_data_section'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildKeyValueRow('manager_name_label'.tr, managerName, darkText, subText),
                          const Divider(height: 18),
                          _buildKeyValueRow('phone_number_label'.tr, phone, darkText, subText),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 6. Previous Visit Result Card (نتيجة الزيارة السابقة)
                    _buildCard(
                      cardBg: cardBg,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'previous_visit_result_section'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBadgeRow(
                            'interest_status_label'.tr,
                            _localizeInterestStatus(
                              _previousResult?['interest_status']?.toString() ??
                                  visit.interestStatus,
                            ),
                            isDark,
                            subText,
                          ),
                          const Divider(height: 18),
                          _buildBadgeRow(
                            'sales_stage_label'.tr,
                            _localizePipelineStep(
                              _previousResult?['pipeline_step']?.toString() ??
                                  visit.pipelineStep.name,
                            ),
                            isDark,
                            subText,
                          ),
                          const Divider(height: 18),
                          _buildKeyValueRow(
                            'not_met_reason_label'.tr,
                            _nonEmptyOrDash(
                              _previousResult?['closing_reason']?.toString(),
                              visit.closingReason,
                            ),
                            darkText,
                            subText,
                          ),
                          const Divider(height: 18),
                          _buildKeyValueRow(
                            'ready_promos_label'.tr,
                            _nonEmptyOrDash(
                              _previousResult?['selected_promo']?.toString(),
                              visit.selectedPromo,
                            ),
                            darkText,
                            subText,
                          ),
                          const Divider(height: 18),
                          _buildKeyValueRow(
                            'required_commitments_label'.tr,
                            _nonEmptyOrDash(
                              _previousResult?['next_follow_up_commitments']
                                  ?.toString(),
                              visit.nextFollowUpCommitments,
                            ),
                            darkText,
                            subText,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupervisorRecommendationCard({
    required Map<String, dynamic> rec,
    required bool isDark,
    required Color darkText,
    required Color subText,
  }) {
    final supervisorName = rec['supervisor_name']?.toString() ?? 'مشرف الفريق';
    final supervisorRole = rec['supervisor_role']?.toString() ?? 'مشرف المبيعات';
    final title = rec['title']?.toString() ?? 'supervisor_performance_tips'.tr;
    final content = rec['content']?.toString() ?? '';
    final timeText = rec['time_text']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132D1B) : const Color(0xFFEBFEEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isRecommendationExpanded = !_isRecommendationExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2028) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: _primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supervisorName,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        Text(
                          supervisorRole,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            color: subText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        _isRecommendationExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: darkText,
                      ),
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            color: subText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isRecommendationExpanded && content.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Color cardBg,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
            fontSize: 13,
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeRow(
      String label, String value, bool isDark, Color subText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            color: subText,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132D1B) : const Color(0xFFEBFEEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _primaryGreen.withValues(alpha: 0.4)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}
