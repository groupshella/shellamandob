import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';

class DecisionMakerCardWidget extends StatelessWidget {
  final StoreVisitsController controller;
  final StoreVisitModel visit;
  final bool isDark;
  final bool readOnly;

  const DecisionMakerCardWidget({
    super.key,
    required this.controller,
    required this.visit,
    required this.isDark,
    this.readOnly = false,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'cannot_call_title'.tr,
        'invalid_phone_number'.tr,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickScheduleDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = controller.selectedFollowUpDate ?? now.add(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: _primaryGreen,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E232D),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _primaryGreen,
                    onPrimary: Colors.white,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;
    final initialTime = controller.selectedFollowUpDate != null
        ? TimeOfDay.fromDateTime(controller.selectedFollowUpDate!)
        : const TimeOfDay(hour: 17, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: _primaryGreen,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E232D),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _primaryGreen,
                    onPrimary: Colors.white,
                  ),
                ),
          child: child!,
        );
      },
    );

    final finalTime = pickedTime ?? const TimeOfDay(hour: 17, minute: 0);
    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      finalTime.hour,
      finalTime.minute,
    );

    controller.setFollowUpDate(combinedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final textDark = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final inputBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);

    final roles = [
      {'key': 'worker', 'label': 'role_worker'.tr, 'icon': Icons.badge_outlined},
      {'key': 'cashier', 'label': 'role_cashier'.tr, 'icon': Icons.point_of_sale_outlined},
      {'key': 'branch_manager', 'label': 'role_branch_manager'.tr, 'icon': Icons.manage_accounts_outlined},
      {'key': 'other', 'label': 'role_other'.tr, 'icon': Icons.person_outline},
    ];

    final timeslots = [
      {'key': 'morning', 'label': 'time_morning'.tr, 'icon': Icons.wb_sunny_outlined},
      {'key': 'noon', 'label': 'time_noon'.tr, 'icon': Icons.light_mode_outlined},
      {'key': 'afternoon', 'label': 'time_afternoon'.tr, 'icon': Icons.wb_twilight_outlined},
      {'key': 'evening', 'label': 'time_evening'.tr, 'icon': Icons.nightlight_outlined},
    ];

    final scheduledDate = controller.selectedFollowUpDate;
    final locale = Get.locale?.languageCode ?? 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.contact_phone_outlined, color: _primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'decision_maker_card_title'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    Text(
                      'decision_maker_card_subtitle'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. صفة الشخص المقابل
          Text(
            'interviewed_person_role_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles.map((r) {
              final isSelected = controller.selectedInterviewedPersonRole == r['key'];
              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  r['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : textMuted,
                ),
                label: Text(
                  r['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : textDark,
                  ),
                ),
                selected: isSelected,
                selectedColor: _primaryGreen,
                backgroundColor: inputBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? _primaryGreen : borderColor,
                  ),
                ),
                onSelected: readOnly
                    ? null
                    : (selected) {
                        controller.setInterviewedPersonRole(selected ? (r['key'] as String) : null);
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 2. اسم صاحب القرار / المالك
          Text(
            'decision_maker_name_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.decisionMakerNameController,
            readOnly: readOnly,
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: textDark),
            decoration: InputDecoration(
              hintText: 'decision_maker_name_hint'.tr,
              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: textMuted),
              filled: true,
              fillColor: inputBg,
              prefixIcon: const Icon(Icons.person_outline, size: 20, color: _primaryGreen),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
              ),
            ),
            onChanged: (_) => controller.registerActivity(),
          ),

          const SizedBox(height: 14),

          // 3. رقم جوال صاحب القرار مع زر الاتصال
          Text(
            'decision_maker_phone_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.decisionMakerPhoneController,
            keyboardType: TextInputType.phone,
            readOnly: readOnly,
            textDirection: TextDirection.ltr,
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: textDark),
            decoration: InputDecoration(
              hintText: '05xxxxxxxx',
              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: textMuted),
              filled: true,
              fillColor: inputBg,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: _primaryGreen),
              suffixIcon: IconButton(
                icon: const Icon(Icons.phone_forwarded, color: _primaryGreen),
                tooltip: 'call_owner_now'.tr,
                onPressed: () {
                  final phone = controller.decisionMakerPhoneController.text.trim();
                  if (phone.isNotEmpty) {
                    _makePhoneCall(phone);
                  } else {
                    Get.snackbar(
                      'enter_phone_first'.tr,
                      '',
                      backgroundColor: const Color(0xFFF59E0B),
                      colorText: Colors.white,
                    );
                  }
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
              ),
            ),
            onChanged: (_) => controller.registerActivity(),
          ),

          const SizedBox(height: 16),

          // 4. أفضل وقت لتواجد المالك
          Text(
            'best_time_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeslots.map((t) {
              final isSelected = controller.selectedDecisionMakerBestTime == t['key'];
              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  t['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : textMuted,
                ),
                label: Text(
                  t['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : textDark,
                  ),
                ),
                selected: isSelected,
                selectedColor: _primaryGreen,
                backgroundColor: inputBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? _primaryGreen : borderColor,
                  ),
                ),
                onSelected: readOnly
                    ? null
                    : (selected) {
                        controller.setDecisionMakerBestTime(selected ? (t['key'] as String) : null);
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 5. جدولة موعد الزيارة القادمة لمقابلة المالك
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 16),

          if (scheduledDate != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, color: _primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'scheduled_visit_date_time'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE d MMMM yyyy - hh:mm a', locale).format(scheduledDate),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!readOnly)
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined, size: 20, color: _primaryGreen),
                      tooltip: 'change_schedule'.tr,
                      onPressed: () => _pickScheduleDateTime(context),
                    ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: readOnly ? null : () => _pickScheduleDateTime(context),
                icon: const Icon(Icons.calendar_month_outlined, size: 18, color: _primaryGreen),
                label: Text(
                  'schedule_next_visit_btn'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryGreen, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: _primaryGreen.withValues(alpha: 0.04),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
