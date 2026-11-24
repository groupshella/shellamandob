import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../models/store_visit_model.dart';
import '../models/dynamic_not_closing_reason.dart';
import '../controllers/store_visits_controller.dart';
import 'submit_visit_summary_screen.dart';

class FollowUpTaskScreen extends StatefulWidget {
  final StoreVisitModel visit;

  const FollowUpTaskScreen({super.key, required this.visit});

  @override
  State<FollowUpTaskScreen> createState() => _FollowUpTaskScreenState();
}

class _FollowUpTaskScreenState extends State<FollowUpTaskScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  // Step 1 = Reason, Step 2 = Schedule
  int _currentStep = 1;

  // Selected Reason Code
  String _selectedReasonCode = 'needs_time';
  final TextEditingController _customReasonController = TextEditingController();
  final TextEditingController _exclusiveAppController = TextEditingController();
  DateTime? _exclusiveContractEndsAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().loadNotClosingReasons();
      }
    });
  }

  // Schedule Fields
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 10);
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _customReasonController.dispose();
    _exclusiveAppController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final screenBg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
        final appBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);

        return Scaffold(
          backgroundColor: screenBg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: darkText,
                size: 20,
              ),
              onPressed: () {
                if (_currentStep == 2) {
                  setState(() => _currentStep = 1);
                } else {
                  Get.back();
                }
              },
            ),
            title: Text(
              'next_follow_up'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: _currentStep == 1 ? _buildReasonStep(isDark) : _buildScheduleStep(isDark),
          ),
          bottomNavigationBar: _buildBottomBar(isDark),
        );
      },
    );
  }

  // Figma Frame 8945:40836 & 8945:41002: سبب عدم إتمام التعاقد
  Widget _buildReasonStep(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);
    final itemBg = isDark ? const Color(0xFF252B37) : Colors.white;
    final itemSelectedBg = isDark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9);
    final darkText = isDark ? Colors.white : const Color(0xFF1F2937);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final inputFill = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'reason_for_not_closing'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'select_reason_desc'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: subText,
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic Reasons List
              GetBuilder<StoreVisitsController>(
                builder: (visitsCtrl) {
                  final reasons = visitsCtrl.dynamicNotClosingReasons;
                  final isEn = (Get.locale?.languageCode ?? 'ar') == 'en';
                  DynamicNotClosingReason? selectedItem;
                  for (final r in reasons) {
                    if (r.code == _selectedReasonCode) {
                      selectedItem = r;
                      break;
                    }
                  }
                  final helperHeadline = selectedItem?.localizedHeadline(isEn);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...reasons.map((reason) {
                        final isSelected = _selectedReasonCode == reason.code;
                        final isLast = reason.code == reasons.last.code;

                        return Container(
                          margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedReasonCode = reason.code),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: 49,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: AlignmentDirectional.centerStart,
                              decoration: BoxDecoration(
                                color: isSelected ? itemSelectedBg : itemBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? _primaryGreen : borderColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                reason.localizedTitle(isEn),
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? _primaryGreen : darkText,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (helperHeadline != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D2111) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF5C4018) : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 18,
                                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'reason_helper_headline_title'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      helperHeadline,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFFEF3C7) : const Color(0xFF78350F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Custom Reason Input when 'other' is selected
        if (_selectedReasonCode == 'other') ...[
          const SizedBox(height: 16),
          Text(
            'write_custom_reason'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 79,
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _customReasonController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: darkText,
              ),
              decoration: InputDecoration(
                hintText: 'write_custom_reason'.tr,
                hintStyle: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: subText,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],

        // [R09] Exclusive contract with competitor app
        if (_selectedReasonCode == 'exclusive_other_app') ...[
          const SizedBox(height: 16),
          Text(
            'exclusive_competitor_app_label'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _exclusiveAppController,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: darkText),
              decoration: InputDecoration(
                hintText: 'exclusive_competitor_app_hint'.tr,
                hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: subText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'exclusive_contract_ends_at_label'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _exclusiveContractEndsAt ?? now.add(const Duration(days: 60)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                final oneMonthBefore = DateTime(picked.year, picked.month - 1, picked.day);
                setState(() {
                  _exclusiveContractEndsAt = picked;
                  _selectedDate = oneMonthBefore.isAfter(now)
                      ? oneMonthBefore
                      : now.add(const Duration(days: 1));
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _exclusiveContractEndsAt != null
                        ? '${_exclusiveContractEndsAt!.year}-${_exclusiveContractEndsAt!.month.toString().padLeft(2, '0')}-${_exclusiveContractEndsAt!.day.toString().padLeft(2, '0')}'
                        : 'exclusive_contract_ends_at_hint'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      color: _exclusiveContractEndsAt != null ? darkText : subText,
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 16, color: _primaryGreen),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF143326) : const Color(0xFFE9F5EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available_outlined, size: 16, color: _primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'exclusive_auto_followup_note'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF1E5E2A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // [R09] OTP / Nafath fear tip (R23)
        if (_selectedReasonCode == 'otp_nafath_fear') ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'otp_nafath_visual_tip_title'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFDBEAFE) : const Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'otp_nafath_visual_tip_body'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // [R09] No credit sales distinction note
        if (_selectedReasonCode == 'no_credit_sales') ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2111) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF5C4018) : const Color(0xFFFDE6B8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'no_credit_sales_note'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  // Figma Frame 8945:41739: جدولة الموعد القادم
  Widget _buildScheduleStep(bool isDark) {
    final outerBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);
    final cardBg = isDark ? const Color(0xFF252B37) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final inputFill = isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);

    final formattedDate = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final hourOfPeriod = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    final minuteStr = _selectedTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$hourOfPeriod : $minuteStr $period';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: outerBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'schedule_next_appointment'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'schedule_follow_up_desc'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: subText,
                  ),
                ),
                const SizedBox(height: 16),

                // Row with Time & Date side-by-side
                Row(
                  children: [
                    // Column 1: Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'follow_up_time'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _showFigmaTimePicker(isDark),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 43,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: inputFill,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: darkText,
                                    ),
                                  ),
                                  Icon(IconlyLight.timeCircle, color: darkText, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Column 2: Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'follow_up_date'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _showFigmaDatePicker(isDark),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 43,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: inputFill,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: darkText,
                                    ),
                                  ),
                                  Icon(IconlyLight.calendar, color: darkText, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Field 3: Follow-up notes
                Text(
                  'follow_up_notes_optional'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 89,
                  decoration: BoxDecoration(
                    color: inputFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'follow_up_notes_hint'.tr,
                      hintStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        color: subText,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Time Picker Modal
  void _showFigmaTimePicker(bool isDark) {
    int hour = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    int minute = _selectedTime.minute;
    bool isAm = _selectedTime.period == DayPeriod.am;

    final dialogBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setPickerState) {
            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'follow_up_time'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hours & Minutes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_up, size: 24, color: darkText),
                              onPressed: () {
                                setPickerState(() {
                                  hour = hour == 12 ? 1 : hour + 1;
                                });
                              },
                            ),
                            Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_down, size: 24, color: darkText),
                              onPressed: () {
                                setPickerState(() {
                                  hour = hour == 1 ? 12 : hour - 1;
                                });
                              },
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ),

                        // Minutes
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_up, size: 24, color: darkText),
                              onPressed: () {
                                setPickerState(() {
                                  minute = (minute + 5) % 60;
                                });
                              },
                            ),
                            Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_down, size: 24, color: darkText),
                              onPressed: () {
                                setPickerState(() {
                                  minute = (minute - 5 + 60) % 60;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // AM / PM Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => setPickerState(() => isAm = true),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 60,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAm
                                  ? (isDark ? const Color(0xFF163E20) : const Color(0xFFD1FDD2))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isAm ? _primaryGreen : const Color(0xFFC6C8CE),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'AM',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isAm ? _primaryGreen : (isDark ? Colors.white70 : const Color(0xFF888888)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setPickerState(() => isAm = false),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 60,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isAm
                                  ? (isDark ? const Color(0xFF163E20) : const Color(0xFFD1FDD2))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: !isAm ? _primaryGreen : const Color(0xFFC6C8CE),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'PM',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: !isAm ? _primaryGreen : (isDark ? Colors.white70 : const Color(0xFF888888)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          final h24 = isAm
                              ? (hour == 12 ? 0 : hour)
                              : (hour == 12 ? 12 : hour + 12);
                          setState(() {
                            _selectedTime = TimeOfDay(hour: h24, minute: minute);
                          });
                          Navigator.pop(dialogCtx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          'continue_text'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
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
      },
    );
  }

  // Date Picker Dialog
  void _showFigmaDatePicker(bool isDark) {
    DateTime displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    DateTime tempSelectedDate = _selectedDate;
    final dialogBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setCalendarState) {
            final lang = Get.locale?.languageCode ?? 'ar';
            final monthName = DateFormat('MMMM yyyy', lang).format(displayedMonth);
            final daysInMonth = DateUtils.getDaysInMonth(displayedMonth.year, displayedMonth.month);
            final firstDayOffset = DateTime(displayedMonth.year, displayedMonth.month, 1).weekday % 7;

            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_right, size: 22, color: darkText),
                          onPressed: () {
                            setCalendarState(() {
                              displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
                            });
                          },
                        ),
                        Text(
                          monthName,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_left, size: 22, color: darkText),
                          onPressed: () {
                            setCalendarState(() {
                              displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Calendar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daysInMonth + firstDayOffset,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemBuilder: (gridCtx, index) {
                        if (index < firstDayOffset) {
                          return const SizedBox.shrink();
                        }
                        final dayNum = index - firstDayOffset + 1;
                        final isSelected = tempSelectedDate.year == displayedMonth.year &&
                            tempSelectedDate.month == displayedMonth.month &&
                            tempSelectedDate.day == dayNum;

                        return InkWell(
                          onTap: () {
                            setCalendarState(() {
                              tempSelectedDate = DateTime(displayedMonth.year, displayedMonth.month, dayNum);
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _primaryGreen
                                  : (isDark ? const Color(0xFF252B37) : const Color(0x10000000)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : darkText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = tempSelectedDate;
                          });
                          Navigator.pop(dialogCtx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          'continue_text'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
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
      },
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final bool canProceedStep1 = _selectedReasonCode != 'other' ||
        _customReasonController.text.trim().isNotEmpty;
    final bool isButtonActive = _currentStep == 1 ? canProceedStep1 : true;
    final bottomBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bottomBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isButtonActive
                ? () {
                    if (_currentStep == 1) {
                      setState(() => _currentStep = 2);
                    } else {
                      _submitFollowUp();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonActive ? _primaryGreen : (isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6)),
              disabledBackgroundColor: isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _currentStep == 1 ? 'proceed_to_schedule'.tr : 'schedule_follow_up_btn'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isButtonActive ? Colors.white : subText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitFollowUp() async {
    final finalReason = _selectedReasonCode == 'other' && _customReasonController.text.trim().isNotEmpty
        ? _customReasonController.text.trim()
        : _selectedReasonCode;

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (Get.isRegistered<StoreVisitsController>()) {
      final controller = Get.find<StoreVisitsController>();
      controller.setClosingReason(finalReason);
      controller.exclusiveCompetitorAppController.text = _exclusiveAppController.text.trim();
      controller.setExclusiveContractEndsAt(_exclusiveContractEndsAt);
      controller.setFollowUpDate(combinedDateTime);
      controller.setFollowUpTime(_selectedTime);
      if (_notesController.text.trim().isNotEmpty) {
        controller.obstaclesController.text = _notesController.text.trim();
      }
    }

    final reviewVisit = widget.visit.copyWith(
      closingReason: finalReason,
      nextFollowUpDate: combinedDateTime,
      obstaclesNotes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : widget.visit.obstaclesNotes,
    );

    Get.to(() => SubmitVisitSummaryScreen(visit: reviewVisit));
  }
}
