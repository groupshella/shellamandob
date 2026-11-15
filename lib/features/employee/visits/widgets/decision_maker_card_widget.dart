import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFF3F4F6);
    final textDark = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);
    final inputBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF8F9FA);

    // Figma Node 9710-47944: صفة الشخص المتواجد حالياً في المحل
    // Options: مدير فرع, كاشير, عامل, أخرى
    final roles = [
      {'key': 'branch_manager', 'label': 'role_branch_manager'.tr},
      {'key': 'cashier', 'label': 'role_cashier'.tr},
      {'key': 'worker', 'label': 'role_worker'.tr},
      {'key': 'other', 'label': 'role_other'.tr},
    ];

    // Figma Node 9710-47944: أفضل وقت لتواجد المالك في المحل
    // 4 Radio time slots: 9 صباحاً - 12 ظهراً, 12 ظهراً - 4 مساءً, 4 مساءً - 8 مساءً, 8 مساءً - 11 مساءً
    final timeslots = [
      {'key': 'morning', 'label': 'time_slot_morning'.tr},
      {'key': 'noon', 'label': 'time_slot_noon'.tr},
      {'key': 'afternoon', 'label': 'time_slot_afternoon'.tr},
      {'key': 'evening', 'label': 'time_slot_evening'.tr},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. عنوان القسم الأول: بيانات صاحب القرار (Figma Header)
        Text(
          'decision_maker_data_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),

        // بطاقة صفة الشخص المتواجد حالياً في المحل
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'person_present_role_title'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: roles.map((r) {
                    final isSelected = controller.selectedInterviewedPersonRole == r['key'];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: readOnly
                            ? null
                            : () {
                                controller.setInterviewedPersonRole(
                                  isSelected ? null : (r['key'] as String),
                                );
                              },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF163E20) : const Color(0xFFEBFDF2))
                                : (isDark ? const Color(0xFF252B37) : Colors.white),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? _primaryGreen
                                  : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            r['label'] as String,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? _primaryGreen : textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. عنوان القسم الثاني: بيانات المسؤول (Figma Header)
        Text(
          'responsible_person_data_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),

        // بطاقة اسم المالك ورقم الجوال
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المالك المسؤول
              Text(
                'responsible_owner_name_title'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.decisionMakerNameController,
                readOnly: readOnly,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: textDark),
                decoration: InputDecoration(
                  hintText: 'responsible_owner_name_hint'.tr,
                  hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: textMuted),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
                  ),
                ),
                onChanged: (_) => controller.registerActivity(),
              ),

              const SizedBox(height: 16),

              // رقم جوال المالك للتواصل (+966)
              Text(
                'owner_contact_phone_title'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  controller: controller.decisionMakerPhoneController,
                  keyboardType: TextInputType.phone,
                  readOnly: readOnly,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: textDark),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+966',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 20,
                            width: 1,
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          ),
                        ],
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: '5X XXX XXXX',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: textMuted),
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
                    ),
                  ),
                  onChanged: (_) => controller.registerActivity(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. بطاقة أفضل وقت لتواجد المالك في المحل
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'best_time_owner_present_title'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Grid or 2 Rows of 2 Timeslots matching Figma Node 9710-47944
              Row(
                children: [
                  Expanded(
                    child: _buildTimeSlotCard(
                      slot: timeslots[0],
                      isSelected: controller.selectedDecisionMakerBestTime == timeslots[0]['key'],
                      onTap: () => controller.setDecisionMakerBestTime(
                        controller.selectedDecisionMakerBestTime == timeslots[0]['key']
                            ? null
                            : timeslots[0]['key'],
                      ),
                      cardBg: cardBg,
                      textDark: textDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeSlotCard(
                      slot: timeslots[1],
                      isSelected: controller.selectedDecisionMakerBestTime == timeslots[1]['key'],
                      onTap: () => controller.setDecisionMakerBestTime(
                        controller.selectedDecisionMakerBestTime == timeslots[1]['key']
                            ? null
                            : timeslots[1]['key'],
                      ),
                      cardBg: cardBg,
                      textDark: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeSlotCard(
                      slot: timeslots[2],
                      isSelected: controller.selectedDecisionMakerBestTime == timeslots[2]['key'],
                      onTap: () => controller.setDecisionMakerBestTime(
                        controller.selectedDecisionMakerBestTime == timeslots[2]['key']
                            ? null
                            : timeslots[2]['key'],
                      ),
                      cardBg: cardBg,
                      textDark: textDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeSlotCard(
                      slot: timeslots[3],
                      isSelected: controller.selectedDecisionMakerBestTime == timeslots[3]['key'],
                      onTap: () => controller.setDecisionMakerBestTime(
                        controller.selectedDecisionMakerBestTime == timeslots[3]['key']
                            ? null
                            : timeslots[3]['key'],
                      ),
                      cardBg: cardBg,
                      textDark: textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard({
    required Map<String, dynamic> slot,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color textDark,
  }) {
    return InkWell(
      onTap: readOnly ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF163E20) : const Color(0xFFEBFDF2))
              : (isDark ? const Color(0xFF252B37) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _primaryGreen
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? _primaryGreen
                      : (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1)),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                slot['label'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _primaryGreen : textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
