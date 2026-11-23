import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/employee_shift_controller.dart';
import '../screens/shella_lesson_player_screen.dart';
import '../screens/shella_lessons_screen.dart';

/// Home Screen Collapsible "تقرير الأداء" (Performance Report) Widget matching Figma:
/// - Light blue header bar: "تقرير الأداء" + chevron
/// - Expanded card: "تقييم يومك" + green percentage badge
///   - "نقاط القوة" bullet list
///   - "نقاط للتحسين" bullet list
///   - Inner white card: "درس مقترح ليك" + video icon + lesson title + green "مشاهدة الدرس >" button
class PerformanceReportCardWidget extends StatefulWidget {
  final bool? isDark;

  const PerformanceReportCardWidget({super.key, this.isDark});

  @override
  State<PerformanceReportCardWidget> createState() =>
      _PerformanceReportCardWidgetState();
}

class _PerformanceReportCardWidgetState
    extends State<PerformanceReportCardWidget> {
  static const Color _primaryGreen = Color(0xFF30913F);
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark ??
        (Get.isRegistered<ThemeController>() &&
            Get.find<ThemeController>().darkTheme);

    final headerBg =
        dark ? const Color(0xFF1B263B) : const Color(0xFFEDF3FF);
    final headerTextColor =
        dark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
    final cardBg = dark ? const Color(0xFF1C2028) : const Color(0xFFF8F9FA);
    final innerCardBg = dark ? const Color(0xFF252B37) : Colors.white;
    final darkText = dark ? Colors.white : const Color(0xFF111B18);
    final subText =
        dark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
    final borderColor =
        dark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

    return GetBuilder<EmployeeShiftController>(
      builder: (controller) {
        final report = controller.shiftModel.performanceReport;
        if (report == null) return const SizedBox.shrink();

        final strengths = report.localizedStrengths;
        final improvements = report.localizedImprovements;
        final lesson = report.suggestedLesson;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Collapsible Header Bar ("تقرير الأداء")
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: headerBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'performance_report_title'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: headerTextColor,
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: headerTextColor,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              if (_isExpanded) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title Row: تقييم يومك + Score Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'your_day_evaluation_title'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF132D1B)
                                  : const Color(0xFFEBFEEB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${report.scorePercent}%',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (strengths.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'strengths_section_label'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...strengths.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '• $item',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                height: 1.4,
                                color: subText,
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (improvements.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'improvements_section_label'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...improvements.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '• $item',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                height: 1.4,
                                color: subText,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Suggested Lesson Inner Card ("درس مقترح ليك")
                      if (lesson != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: innerCardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: 0.8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline_rounded,
                                        size: 18,
                                        color: darkText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'suggested_lesson_for_you'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => Get.to(
                                        () => const ShellaLessonsScreen()),
                                    child: Text(
                                      'shella_lessons_title'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lesson.localizedTitle,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: subText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(
                                      () => ShellaLessonPlayerScreen(
                                          lesson: lesson),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryGreen,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'watch_lesson_btn'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Directionality.of(context) ==
                                                TextDirection.rtl
                                            ? Icons.chevron_left_rounded
                                            : Icons.chevron_right_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
