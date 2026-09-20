import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
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
  static const Color _purpleCardBg = Color(0xFFECE5F9);
  static const Color _darkText = Color(0xFF1F2937);
  static const Color _subText = Color(0xFF514863);
  static const Color _screenBg = Color(0xFFF6F5F8);

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('hh:mm a', lang).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: _screenBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111B18), size: 20),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'زيارة متجر ${currentVisit.storeName}',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111B18),
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
                        _buildStoreCard(currentVisit, startedTimeText),

                        const SizedBox(height: 16),

                        // 2. White Timer Card (Figma Container 8911:33216)
                        _buildTimerCard(controller),

                        // 3. Inactivity Alerts Section (Figma 8911:34886 to 8918:36040)
                        if (hasAlerts) ...[
                          const SizedBox(height: 16),
                          _buildInactivityAlertCard(alertLevel, lastAlert),
                          const SizedBox(height: 12),
                          _buildAlertsLogCard(controller),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 4. Bottom Action Button: توثيق و إنهاء الزيارة (Figma Frame 8911:34855)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
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
                        // Navigate to VisitPhotoDocumentationScreen for storefront & inside camera capture
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
                        'doc_and_finish_visit'.tr.isNotEmpty && 'doc_and_finish_visit'.tr != 'doc_and_finish_visit'
                            ? 'doc_and_finish_visit'.tr
                            : 'توثيق و إنهاء الزيارة',
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
  }

  // 1. Store Header Purple Card
  Widget _buildStoreCard(StoreVisitModel visit, String startedTimeText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _purpleCardBg,
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
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 4),

          // Address with Location Pin
          Row(
            children: [
              const Icon(
                IconlyLight.location,
                size: 15,
                color: Color(0xFF111B18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  visit.address,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111B18),
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
                    'distance_label'.tr.isNotEmpty && 'distance_label'.tr != 'distance_label'
                        ? 'distance_label'.tr
                        : 'المسافة',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: _subText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(IconlyLight.discovery, size: 14, color: Color(0xFF111B18)),
                      const SizedBox(width: 4),
                      Text(
                        '${visit.distanceKm} كم',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111B18),
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
                    'visit_started_label'.tr.isNotEmpty && 'visit_started_label'.tr != 'visit_started_label'
                        ? 'visit_started_label'.tr
                        : 'بدأت الزيارة',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: _subText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(IconlyLight.timeCircle, size: 14, color: Color(0xFF111B18)),
                      const SizedBox(width: 4),
                      Text(
                        startedTimeText,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111B18),
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
  Widget _buildTimerCard(StoreVisitsController controller) {
    final bool isCriticalTime = controller.remainingVisitSeconds <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Card Title
          Text(
            'visit_timer_title'.tr.isNotEmpty && 'visit_timer_title'.tr != 'visit_timer_title'
                ? 'visit_timer_title'.tr
                : 'مؤقت الزيارة',
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
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
                    color: const Color(0xFFF3F4F6),
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
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'elapsed_label'.tr.isNotEmpty && 'elapsed_label'.tr != 'elapsed_label'
                          ? 'elapsed_label'.tr
                          : 'مضى',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        color: Color(0xFF6B7280),
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
              color: isCriticalTime ? const Color(0xFFFEE2E2) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'max_visit_duration_hint'.tr.isNotEmpty && 'max_visit_duration_hint'.tr != 'max_visit_duration_hint'
                      ? 'max_visit_duration_hint'.tr
                      : 'الحد الأقصى للزيارة 30 دقيقة',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCriticalTime
                      ? 'تم تجاوز الحد الأقصى للزيارة'
                      : 'متبقي ${controller.remainingMinutes} دقيقة',
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
  Widget _buildInactivityAlertCard(int level, Map<String, dynamic>? alert) {
    Color bgColor;
    Color borderColor;
    Color titleColor;
    Color bodyColor;
    String defaultTitle;
    String defaultSubtitle;
    String defaultDesc;

    switch (level) {
      case 4:
        bgColor = const Color(0xFFF3EAEA);
        borderColor = const Color(0xFF991B1B);
        titleColor = const Color(0xFF991B1B);
        bodyColor = const Color(0xFF7F1D1D);
        defaultTitle = 'تنبيه حرج';
        defaultSubtitle = 'تم احتساب هذا الوقت خارج الدوام.';
        defaultDesc = 'تم تسجيل مستوى الخمول الرابع وفق سياسة التشغيل. يمكنك رفع طلب للمشرف إذا كان هناك سبب يستدعي المراجعة.';
        break;
      case 3:
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFEF4444);
        titleColor = const Color(0xFFEF4444);
        bodyColor = const Color(0xFF991B1B);
        defaultTitle = 'تنبيه ثالث';
        defaultSubtitle = 'تم تسجيل عدم نشاط مستمر أثناء الجولة.';
        defaultDesc = 'قد يؤثر تكرار هذه الحالة على احتساب وقت العمل.';
        break;
      case 2:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFF59E0B);
        titleColor = const Color(0xFFD97706);
        bodyColor = const Color(0xFF92400E);
        defaultTitle = 'تنبيه ثاني';
        defaultSubtitle = 'لم يتم رصد تقدم كافٍ نحو المتجر.';
        defaultDesc = 'يرجى التوجه إلى موقع الزيارة أو تحديث حالة الزيارة.';
        break;
      case 1:
      default:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF3B82F6);
        titleColor = const Color(0xFF2563EB);
        bodyColor = const Color(0xFF1E40AF);
        defaultTitle = 'تنبيه أول';
        defaultSubtitle = 'يبدو أنك لم تتحرك نحو المتجر المستهدف.';
        defaultDesc = 'تحقق من موقعك واستعد لبدء الزيارة.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
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
              color: bodyColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Expandable Alerts Log ("سجل التنبيهات")
  Widget _buildAlertsLogCard(StoreVisitsController controller) {
    final count = controller.alertHistory.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
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
                    'alerts_log_title'.tr.isNotEmpty && 'alerts_log_title'.tr != 'alerts_log_title'
                        ? 'alerts_log_title'.tr
                        : 'سجل التنبيهات',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _darkText,
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
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          if (controller.isAlertsLogExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.alertHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final item = controller.alertHistory[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'] ?? 'تنبيه',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _darkText,
                        ),
                      ),
                      Text(
                        item['time'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
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
