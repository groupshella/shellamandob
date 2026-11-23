import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'merchant_objections_screen.dart';
import 'store_visit_map_screen.dart';
import 'visit_photo_documentation_screen.dart';

class ActiveStoreVisitScreen extends StatelessWidget {
  final StoreVisitModel visit;

  const ActiveStoreVisitScreen({
    super.key,
    required this.visit,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

  static String _tr(String key, String fallback) {
    final res = key.tr;
    if (res == key || res.isEmpty) {
      return fallback;
    }
    return res;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('hh:mm a', lang).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final headerBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final screenBg =
            isDark ? const Color(0xFF121418) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final cardTitleColor = isDark ? Colors.white : const Color(0xFF1F2937);
        final subTextColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final purpleCardBg =
            isDark ? const Color(0xFF261D3B) : const Color(0xFFECE5F9);
        final purpleTextColor = isDark ? Colors.white : const Color(0xFF1F2937);
        final purpleSubText =
            isDark ? const Color(0xFFB8B0C8) : const Color(0xFF514863);
        final purpleIconColor =
            isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111B18);
        final borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return GetBuilder<StoreVisitsController>(
          builder: (controller) {
            final currentVisit = controller.activeVisit ?? visit;
            final startedTimeText =
                _formatTime(currentVisit.startedAt ?? DateTime.now());
            final hasAlerts = controller.alertHistory.isNotEmpty;
            final lastAlert = hasAlerts ? controller.alertHistory.last : null;
            final int alertLevel =
                (lastAlert != null && lastAlert['level'] != null)
                    ? (lastAlert['level'] as int)
                    : 0;
            final showInlineAlert =
                hasAlerts && !controller.isActiveAlertDismissed;

            return Scaffold(
              backgroundColor: screenBg,
              appBar: AppBar(
                backgroundColor: headerBg,
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
                        textColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '${'visit_store_title'.tr} ${currentVisit.storeName}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Purple Store Summary Card (Figma 8918:36047)
                      _buildStoreCard(
                        currentVisit,
                        startedTimeText,
                        purpleCardBg,
                        purpleTextColor,
                        purpleSubText,
                        purpleIconColor,
                      ),

                      const SizedBox(height: 16),

                      // 2. White Timer Card + Inline Alert + Finish CTA (Figma 8918:36071)
                      _buildTimerCard(
                        controller: controller,
                        currentVisit: currentVisit,
                        cardBg: cardBg,
                        textColor: cardTitleColor,
                        subTextColor: subTextColor,
                        isDark: isDark,
                        showInlineAlert: showInlineAlert,
                        alertLevel: alertLevel,
                        lastAlert: lastAlert,
                      ),

                      const SizedBox(height: 16),

                      // 4. أهم اعتراضات التجار (Figma 9946:100211)
                      _buildNavigationCard(
                        title: 'merchant_objections_title'.tr,
                        cardBg: cardBg,
                        titleColor: cardTitleColor,
                        iconColor: subTextColor,
                        isRtl: isRtl,
                        isDark: isDark,
                        onTap: () =>
                            Get.to(() => const MerchantObjectionsScreen()),
                      ),

                      // 5. سجل التنبيهات (Figma 8918:36109)
                      if (hasAlerts) ...[
                        const SizedBox(height: 16),
                        _buildAlertsLogCard(
                          controller: controller,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: cardTitleColor,
                          subTextColor: subTextColor,
                          isDark: isDark,
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 1. Store Header Purple Card (Figma 8918:36047)
  Widget _buildStoreCard(
    StoreVisitModel visit,
    String startedTimeText,
    Color purpleCardBg,
    Color purpleTextColor,
    Color purpleSubText,
    Color purpleIconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: purpleCardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.storeName,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: purpleTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/image/figma_visit_location.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            purpleIconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            visit.address.isNotEmpty
                                ? visit.address
                                : 'not_specified_address'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: purpleIconColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Get.to(() => StoreVisitMapScreen(visit: visit)),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'store_map_label'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Column 1: Visit started
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'visit_started_label'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: purpleSubText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/image/figma_visit_clock.svg',
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          purpleIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        startedTimeText,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: purpleIconColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Column 2: Distance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'distance_label'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: purpleSubText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/image/figma_visit_location.svg',
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          purpleIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${visit.distanceKm} ${_tr('km_unit', 'كم')}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: purpleIconColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Timer Card with Circular Progress, Remaining Pill, Optional Alert, and CTA Button
  Widget _buildTimerCard({
    required StoreVisitsController controller,
    required StoreVisitModel currentVisit,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
    required bool showInlineAlert,
    required int alertLevel,
    required Map<String, dynamic>? lastAlert,
  }) {
    final bool isCriticalTime = controller.remainingVisitSeconds <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Card Title
          Text(
            'visit_timer_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),

          const SizedBox(height: 8),

          // Circular Progress with Elapsed Time inside (140x140)
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 9,
                    color: isDark
                        ? const Color(0xFF252B37)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: controller.progressPercent,
                    strokeWidth: 9,
                    color: isCriticalTime
                        ? const Color(0xFFEF4444)
                        : _primaryGreen,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.formattedVisitTime,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'elapsed_label'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Compact Centered Green Pill Badge (Figma 8918:36087)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            decoration: BoxDecoration(
              color: isCriticalTime
                  ? (isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2))
                  : (isDark
                      ? const Color(0xFF15281E)
                      : const Color(0xFFE8F5E9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.isAutoExtended) ...[
                      const Icon(Icons.verified_outlined,
                          size: 13, color: _primaryGreen),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      controller.isAutoExtended
                          ? 'max_visit_extended_badge'.tr
                          : 'max_visit_duration_hint'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: controller.isAutoExtended
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: controller.isAutoExtended
                            ? _primaryGreen
                            : subTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isCriticalTime
                      ? _tr('max_visit_time_exceeded',
                          'تم تجاوز الحد الأقصى للزيارة')
                      : '${_tr('remaining_visit_time', 'متبقي')} ${controller.remainingMinutes} ${_tr('minute_unit', 'دقيقة')}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isCriticalTime
                        ? const Color(0xFFDC2626)
                        : _primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // Inline Inactivity Alert inside Timer Card (Figma 8918:36090)
          if (showInlineAlert) ...[
            const SizedBox(height: 12),
            _buildInactivityAlertCard(
              level: alertLevel,
              alert: lastAlert,
              isDark: isDark,
              onDismiss: () => controller.dismissActiveAlert(),
            ),
          ],

          const SizedBox(height: 16),

          // Green CTA Button inside Timer Card (Figma 8918:36108)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => VisitPhotoDocumentationScreen(
                      visit: currentVisit,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'doc_and_finish_visit'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // White Navigation Card (قائمة المتاجر / أهم اعتراضات التجار)
  Widget _buildNavigationCard({
    required String title,
    required Color cardBg,
    required Color titleColor,
    required Color iconColor,
    required bool isRtl,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            Transform.flip(
              flipX: !isRtl,
              child: SvgPicture.asset(
                'assets/image/figma_visit_arrow_left.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for alert level palette matching Figma frames 8911:34886 -> 8918:36040
  ({
    Color bg,
    Color border,
    Color text,
    String title,
    String subtitle,
    String desc,
  }) _alertStyle(int level, bool isDark) {
    switch (level) {
      case 4:
        return (
          bg: isDark ? const Color(0xFF3B1818) : const Color(0xFFF3EAEA),
          border: isDark
              ? const Color(0xFF991B1B)
              : const Color(0x4F991B1B),
          text: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
          title: _tr('critical_alert', 'تنبيه حرج'),
          subtitle: _tr(
            'active_alert4_figma_subtitle',
            'تم احتساب هذا الوقت خارج الدوام.',
          ),
          desc: _tr(
            'active_alert4_figma_desc',
            'تم تسجيل مستوى الخمول الرابع وفق سياسة التشغيل. يمكنك رفع طلب للمشرف إذا كان هناك سبب يستدعي المراجعة.',
          ),
        );
      case 3:
        return (
          bg: isDark ? const Color(0xFF351A1A) : const Color(0xFFFEE2E2),
          border: isDark
              ? const Color(0xFFDC2626)
              : const Color(0x4FDC2626),
          text: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          title: _tr('third_alert', 'تنبيه ثالث'),
          subtitle: _tr(
            'active_alert3_figma_subtitle',
            'تم تسجيل عدم نشاط مستمر أثناء الجولة.',
          ),
          desc: _tr(
            'active_alert3_figma_desc',
            'قد يؤثر تكرار هذه الحالة على احتساب وقت العمل.',
          ),
        );
      case 2:
        return (
          bg: isDark ? const Color(0xFF332112) : const Color(0xFFFFF7ED),
          border: isDark
              ? const Color(0xFFEA580C)
              : const Color(0x4FEA580C),
          text: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
          title: _tr('second_alert', 'تنبيه ثاني'),
          subtitle: _tr(
            'active_alert2_figma_subtitle',
            'لم يتم رصد تقدم كافٍ نحو المتجر.',
          ),
          desc: _tr(
            'active_alert2_figma_desc',
            'يرجى التوجه إلى موقع الزيارة أو تحديث حالة الزيارة.',
          ),
        );
      case 1:
      default:
        return (
          bg: isDark ? const Color(0xFF332812) : const Color(0xFFFEF3C7),
          border: isDark
              ? const Color(0xFFF59E0B)
              : const Color(0x4FF59E0B),
          text: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          title: _tr('first_alert', 'تنبيه أول'),
          subtitle: _tr(
            'active_alert1_figma_subtitle',
            'يبدو أنك لم تتحرك نحو المتجر المستهدف.',
          ),
          desc: _tr(
            'active_alert1_figma_desc',
            'تحقق من موقعك واستعد لبدء الزيارة.',
          ),
        );
    }
  }

  // 3. Inline Inactivity Alert Box (Figma 8918:36091)
  Widget _buildInactivityAlertCard({
    required int level,
    required Map<String, dynamic>? alert,
    required bool isDark,
    required VoidCallback onDismiss,
  }) {
    final s = _alertStyle(level, isDark);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.border, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/image/figma_visit_warning.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(s.text, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert?['title']?.toString() ?? s.title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.subtitle,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: s.text,
                  ),
                ),
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.85,
                  child: Text(
                    s.desc,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: s.text,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Opacity(
                opacity: 0.7,
                child: SvgPicture.asset(
                  'assets/image/figma_visit_close.svg',
                  width: 8,
                  height: 8,
                  colorFilter: ColorFilter.mode(s.text, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Expandable Alerts Log ("سجل التنبيهات" — Figma 8918:36109)
  Widget _buildAlertsLogCard({
    required StoreVisitsController controller,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    final count = controller.alertHistory.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.toggleAlertsLog(),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Text(
                  'alerts_log_title'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B1818)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  controller.isAlertsLogExpanded
                      ? 'assets/image/figma_visit_arrow_up.svg'
                      : 'assets/image/figma_visit_arrow_down.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(subTextColor, BlendMode.srcIn),
                ),
              ],
            ),
          ),
          if (controller.isAlertsLogExpanded) ...[
            const SizedBox(height: 12),
            Column(
              children: List.generate(controller.alertHistory.length, (index) {
                final item = controller.alertHistory[index];
                final level = (item['level'] as num?)?.toInt() ?? 1;
                final s = _alertStyle(level, isDark);

                return Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0 : 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: s.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/image/figma_visit_warning.svg',
                          width: 20,
                          height: 20,
                          colorFilter:
                              ColorFilter.mode(s.text, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['title']?.toString() ?? s.title,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: s.text,
                            ),
                          ),
                        ),
                        Text(
                          item['time']?.toString() ?? '',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
