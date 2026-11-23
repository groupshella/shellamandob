import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/features/employee/network/models/network_models.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/network/screens/sub_marketer_profile_screen.dart';

class SupervisedMarketerCard extends StatelessWidget {
  final SupervisedMarketerModel marketer;

  const SupervisedMarketerCard({super.key, required this.marketer});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color darkText = isDark ? Colors.white : const Color(0xFF111827);
    final Color subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    final int recent7dRegistrations =
        marketer.dailyRegistrationRate7d > 0 ? (marketer.dailyRegistrationRate7d * 7).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => SubMarketerProfileScreen(
              marketerId: marketer.marketerId,
              fallbackName: marketer.name,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Right in RTL = Avatar + Name + Profession Badge | Left in RTL = Status Pill Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right in RTL: Avatar + Name + Profession
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildMarketerAvatar(marketer.name, marketer.avatar, isDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              marketer.name,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            _buildProfessionBadge(
                              marketer.storeName,
                              marketer.marketerType,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Left in RTL: Status Badge (نشط / بحاجة لمتابعة)
                _buildStatusTag(marketer.isIdle, isDark),
              ],
            ),

            const SizedBox(height: 12),

            // Row 2: Two Statistics Boxes (Right in RTL = آخر تسجيل | Left in RTL = آخر 7 أيام)
            Row(
              children: [
                // 1. Right in RTL: Last registration date/time
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatLastActivity(marketer.lastActivityAt),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'last_registration'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            color: subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Left in RTL: Last 7 days registrations count
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$recent7dRegistrations',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'last_7_days'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            color: subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 3: Milestone 300 Target Progress
            // Right in RTL = الهدف نحو حافز النجمة (300 عميل) | Left in RTL = 300/X
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'milestone_star_target'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${marketer.milestoneTarget}/${marketer.qualifiedCustomersCount}',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (marketer.milestoneProgressPct / 100.0).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
              ),
            ),

            const SizedBox(height: 12),

            // Row 4: Action Buttons (Right in RTL = اتصال [Solid Green] | Left in RTL = زيارة تنشيط [Soft Neutral])
            Row(
              children: [
                // Right in RTL: اتصال (Solid Primary Green Button)
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => _callPhone(marketer.phone),
                      icon: const Icon(IconlyLight.call, size: 16, color: Colors.white),
                      label: Text(
                        'call'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF30913F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Left in RTL: زيارة تنشيط (Soft Neutral Gray Button) -> opens SubMarketerProfileScreen
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => SubMarketerProfileScreen(
                            marketerId: marketer.marketerId,
                            fallbackName: marketer.name,
                          ),
                        );
                      },
                      icon: Icon(
                        IconlyLight.calendar,
                        size: 16,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      label: Text(
                        'activation_visit_btn'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMarketerAvatar(String name, String? avatarUrl, bool isDark) {
    final String trimmed = name.trim();
    final String initial = trimmed.isNotEmpty ? trimmed.characters.first : '-';

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty && avatarUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          avatarUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialBox(initial, isDark),
        ),
      );
    }

    return _buildInitialBox(initial, isDark);
  }

  Widget _buildInitialBox(String initial, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        ),
      ),
    );
  }

  Widget _buildProfessionBadge(String? storeName, String marketerType, bool isDark) {
    final String rawLabel = (storeName != null && storeName.trim().isNotEmpty)
        ? storeName.trim()
        : (marketerType == 'cashier'
            ? 'cashier'.tr
            : (marketerType == 'driver' ? 'driver'.tr : 'freelance'.tr));

    final bool isDriver = marketerType == 'driver' || rawLabel.contains('سائق');

    final Color bg = isDriver
        ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF9C3))
        : (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF));
    final Color fg = isDriver
        ? (isDark ? const Color(0xFFFDE047) : const Color(0xFFCA8A04))
        : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rawLabel,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildStatusTag(bool isIdle, bool isDark) {
    if (isIdle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFD97706),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'needs_follow_up'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF30913F),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'active_filter'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatLastActivity(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final period = dt.hour >= 12 ? 'م' : 'ص';
        return 'اليوم، $hour:${dt.minute.toString().padLeft(2, '0')} $period';
      }
      return '${dt.day} ${_monthNameAr(dt.month)}، ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _monthNameAr(int m) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    if (m >= 1 && m <= 12) return months[m - 1];
    return '';
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(' ', '');
    final url = 'tel:$clean';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
