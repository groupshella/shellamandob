import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'visit_photo_documentation_screen.dart';

class ActiveStoreVisitScreen extends StatelessWidget {
  final StoreVisitModel visit;

  const ActiveStoreVisitScreen({
    super.key,
    required this.visit,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

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
        final screenBg = isDark ? const Color(0xFF121418) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF111B18);
        final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final purpleCardBg = isDark ? const Color(0xFF261D3B) : const Color(0xFFECE5F9);
        final purpleTextColor = isDark ? Colors.white : const Color(0xFF1F2937);
        final purpleSubText = isDark ? const Color(0xFFB8B0C8) : const Color(0xFF514863);
        final purpleIconColor = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111B18);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return GetBuilder<StoreVisitsController>(
          builder: (controller) {
            final currentVisit = controller.activeVisit ?? visit;
            final startedTimeText = _formatTime(currentVisit.startedAt ?? DateTime.now());
            final hasAlerts = controller.alertHistory.isNotEmpty;
            final lastAlert = hasAlerts ? controller.alertHistory.last : null;
            final int alertLevel = (lastAlert != null && lastAlert['level'] != null)
                ? (lastAlert['level'] as int)
                : 0;

            return Scaffold(
              backgroundColor: screenBg,
              appBar: AppBar(
                backgroundColor: cardBg,
                elevation: isDark ? 0 : 0.5,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_ios
                        : Icons.arrow_back_ios_new,
                    color: textColor,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  '${'visit_store_title'.tr} ${currentVisit.storeName}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Purple Store Summary Card (Figma Container 8911:33193)
                            _buildStoreCard(
                              currentVisit,
                              startedTimeText,
                              purpleCardBg,
                              purpleTextColor,
                              purpleSubText,
                              purpleIconColor,
                            ),

                            const SizedBox(height: 16),

                            // 2. White Timer Card (Figma Container 8911:33216)
                            _buildTimerCard(
                              controller,
                              cardBg,
                              borderColor,
                              textColor,
                              subTextColor,
                              isDark,
                            ),

                            // 3. Inactivity Alerts Section (Figma 8911:34886 to 8918:36040)
                            if (hasAlerts) ...[
                              const SizedBox(height: 16),
                              _buildInactivityAlertCard(alertLevel, lastAlert, isDark),
                              const SizedBox(height: 12),
                              _buildAlertsLogCard(
                                controller,
                                cardBg,
                                borderColor,
                                textColor,
                                subTextColor,
                              ),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // 4. Bottom Action Button: توثيق و إنهاء الزيارة (Figma Frame 8911:34855)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: isDark ? Border(top: BorderSide(color: borderColor)) : null,
                        boxShadow: isDark
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 10,
                                  offset: Offset(0, -4),
                                ),
                              ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
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
                              borderRadius: BorderRadius.circular(10),
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

  // 1. Store Header Purple Card
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
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Name
          Text(
            visit.storeName,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: purpleTextColor,
            ),
          ),
          const SizedBox(height: 4),

          // Address with Location Pin
          Row(
            children: [
              Icon(
                IconlyLight.location,
                size: 15,
                color: purpleIconColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  visit.address,
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

          const SizedBox(height: 14),

          // Distance and Start Time Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Column 1: Distance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'distance_label'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: purpleSubText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconlyLight.discovery, size: 14, color: purpleIconColor),
                      const SizedBox(width: 4),
                      Text(
                        '${visit.distanceKm} ${'km_unit'.tr}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: purpleIconColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Column 2: Start Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'visit_started_label'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: purpleSubText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconlyLight.timeCircle, size: 14, color: purpleIconColor),
                      const SizedBox(width: 4),
                      Text(
                        startedTimeText,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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

  // 2. Timer Card with Circular Progress and Remaining Badge
  Widget _buildTimerCard(
    StoreVisitsController controller,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    final bool isCriticalTime = controller.remainingVisitSeconds <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),

          const SizedBox(height: 20),

          // Circular Progress with Elapsed Time inside
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 9,
                    color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: controller.progressPercent,
                    strokeWidth: 9,
                    color: isCriticalTime ? const Color(0xFFEF4444) : _primaryGreen,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Inner Content: 06:02 and مضى
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.formattedVisitTime,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'elapsed_label'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Green Pill Badge: الحد الأقصى للزيارة 30 دقيقة • متبقي 23 دقيقة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isCriticalTime
                  ? (isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2))
                  : (isDark ? const Color(0xFF15281E) : const Color(0xFFE8F5E9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'max_visit_duration_hint'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCriticalTime
                      ? 'max_visit_time_exceeded'.tr
                      : '${'remaining_visit_time'.tr} ${controller.remainingMinutes} ${'minute_unit'.tr}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isCriticalTime ? const Color(0xFFDC2626) : _primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Inactivity Alert Box matching Figma frames 8911:34886 to 8918:36040
  Widget _buildInactivityAlertCard(int level, Map<String, dynamic>? alert, bool isDark) {
    Color bgColor;
    Color alertBorderColor;
    Color titleColor;
    Color alertBodyColor;
    String defaultTitle;
    String defaultSubtitle;
    String defaultDesc;

    switch (level) {
      case 4:
        bgColor = isDark ? const Color(0xFF3B1818) : const Color(0xFFF3EAEA);
        alertBorderColor = const Color(0xFF991B1B);
        titleColor = isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B);
        alertBodyColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D);
        defaultTitle = 'critical_alert'.tr;
        defaultSubtitle = 'تم احتساب هذا الوقت خارج الدوام.';
        defaultDesc = 'تم تسجيل مستوى الخمول الرابع وفق سياسة التشغيل. يمكنك رفع طلب للمشرف إذا كان هناك سبب يستدعي المراجعة.';
        break;
      case 3:
        bgColor = isDark ? const Color(0xFF351A1A) : const Color(0xFFFEF2F2);
        alertBorderColor = const Color(0xFFEF4444);
        titleColor = const Color(0xFFEF4444);
        alertBodyColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
        defaultTitle = 'third_alert'.tr;
        defaultSubtitle = 'تم تسجيل عدم نشاط مستمر أثناء الجولة.';
        defaultDesc = 'قد يؤثر تكرار هذه الحالة على احتساب وقت العمل.';
        break;
      case 2:
        bgColor = isDark ? const Color(0xFF332612) : const Color(0xFFFFFBEB);
        alertBorderColor = const Color(0xFFF59E0B);
        titleColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        alertBodyColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
        defaultTitle = 'second_alert'.tr;
        defaultSubtitle = 'لم يتم رصد تقدم كافٍ نحو المتجر.';
        defaultDesc = 'يرجى التوجه إلى موقع الزيارة أو تحديث حالة الزيارة.';
        break;
      case 1:
      default:
        bgColor = isDark ? const Color(0xFF152238) : const Color(0xFFEFF6FF);
        alertBorderColor = const Color(0xFF3B82F6);
        titleColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
        alertBodyColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
        defaultTitle = 'first_alert'.tr;
        defaultSubtitle = 'يبدو أنك لم تتحرك نحو المتجر المستهدف.';
        defaultDesc = 'تحقق من موقعك واستعد لبدء الزيارة.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alertBorderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(
                alert?['title'] ?? defaultTitle,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            defaultSubtitle,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            defaultDesc,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: alertBodyColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Expandable Alerts Log ("سجل التنبيهات")
  Widget _buildAlertsLogCard(
    StoreVisitsController controller,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final count = controller.alertHistory.length;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.toggleAlertsLog(),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'alerts_log_title'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Red Pill Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    controller.isAlertsLogExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: subTextColor,
                  ),
                ],
              ),
            ),
          ),

          if (controller.isAlertsLogExpanded) ...[
            Divider(height: 1, color: borderColor),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.alertHistory.length,
              separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16, color: borderColor),
              itemBuilder: (context, index) {
                final item = controller.alertHistory[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'] ?? 'warning_single'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        item['time'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
