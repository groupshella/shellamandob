import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/features/employee/network/models/network_models.dart';
import 'package:sixam_mart/features/employee/network/controllers/my_network_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

class SupervisedMarketerCard extends StatelessWidget {
  final SupervisedMarketerModel marketer;

  const SupervisedMarketerCard({super.key, required this.marketer});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color darkText = isDark ? Colors.white : const Color(0xFF111827);
    final Color subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Header with Avatar + Name + Store & Status Badge (Top Right/Left)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                  child: Text(
                    marketer.name.isNotEmpty ? marketer.name[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Type + Store
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marketer.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTypeBadge(marketer.marketerType, isDark),
                          if (marketer.storeName != null && marketer.storeName!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                marketer.storeName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Idle Badge if inactive
                if (marketer.isIdle)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B1F2B) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 6, color: Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(
                          'idle_marketer'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Inactive Warning Alert Bar (Clean Figma Alert style)
            if (marketer.isIdle) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A241C) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(IconlyLight.infoSquare, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${'idle_since'.tr} ${marketer.daysSinceLastRegistration} ${'days_ago'.tr}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Milestone 300 Target Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'milestone_star_target'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${marketer.qualifiedCustomersCount} / ${marketer.milestoneTarget}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (marketer.milestoneProgressPct / 100.0).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  marketer.milestoneProgressPct >= 100
                      ? const Color(0xFF10B981)
                      : const Color(0xFF2563EB),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 7-day stats
            Row(
              children: [
                Icon(IconlyLight.graph, size: 14, color: subText),
                const SizedBox(width: 6),
                Text(
                  '${'daily_rate_7d'.tr}: ${marketer.dailyRegistrationRate7d} ${'customers_per_day'.tr}',
                  style: TextStyle(
                    fontSize: 12,
                    color: subText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 3: Action Buttons (Direct Call & Schedule Visit)
            Row(
              children: [
                // Direct Call Button (Grey/Outlined Figma Style)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _callPhone(marketer.phone),
                      icon: Icon(IconlyBold.call, size: 16, color: darkText),
                      label: Text(
                        'direct_call'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Activation Visit Button (App Primary Green #30913F)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _showScheduleModal(context, marketer),
                      icon: const Icon(IconlyBold.calendar, size: 16, color: Colors.white),
                      label: Text(
                        'activation_visit'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF30913F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type, bool isDark) {
    Color bg;
    Color fg;
    String label;

    switch (type) {
      case 'cashier':
        bg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'cashier'.tr;
        break;
      case 'driver':
        bg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = 'driver'.tr;
        break;
      default:
        bg = isDark ? const Color(0xFF3B0764) : const Color(0xFFFAF5FF);
        fg = const Color(0xFF9333EA);
        label = 'freelance'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(' ', '');
    final url = 'tel:$clean';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  void _showScheduleModal(BuildContext context, SupervisedMarketerModel m) {
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          final darkText = isDark ? Colors.white : const Color(0xFF111827);

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${'schedule_visit_for'.tr} ${m.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(IconlyBold.calendar, color: Color(0xFF30913F)),
                    title: Text(
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 60)),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        'change_date'.tr,
                        style: const TextStyle(
                          color: Color(0xFF30913F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'visit_notes_hint'.tr,
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GetBuilder<MyNetworkController>(
                  builder: (networkCtrl) => SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: networkCtrl.isScheduling
                          ? null
                          : () async {
                              final navigator = Navigator.of(ctx);
                              final success = await networkCtrl.scheduleActivationVisit(
                                subMarketerId: m.marketerId,
                                date: selectedDate,
                                notes: noteController.text.trim(),
                              );
                              if (success && ctx.mounted) {
                                navigator.pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF30913F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: networkCtrl.isScheduling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'confirm_schedule_visit'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
