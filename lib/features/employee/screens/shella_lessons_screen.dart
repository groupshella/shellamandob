import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../api/api_client.dart';
import '../../../common/controllers/theme_controller.dart';
import '../../../core/widgets/skeleton_loading_widgets.dart';
import '../../../util/app_constants.dart';
import '../models/training_lesson_model.dart';
import 'shella_lesson_player_screen.dart';

/// Shella Lessons Screen ("دروس شلة") matching Figma:
/// - List with progress: node 9944:96510
/// - Empty state: node 9945:99953
class ShellaLessonsScreen extends StatefulWidget {
  const ShellaLessonsScreen({super.key});

  @override
  State<ShellaLessonsScreen> createState() => _ShellaLessonsScreenState();
}

class _ShellaLessonsScreenState extends State<ShellaLessonsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  static const String _arrowRightSvg =
      'assets/image/figma_lessons_arrow_right.svg';
  static const String _arrowLeftSvg =
      'assets/image/figma_lessons_arrow_left.svg';
  static const String _searchSvg = 'assets/image/figma_lessons_search.svg';
  static const String _clockSvg = 'assets/image/figma_lessons_clock.svg';
  static const String _emptySvg = 'assets/image/figma_lessons_empty.svg';

  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = دروس شلة (all), 1 = تمت مشاهدتها (watched)
  bool _isLoading = true;
  List<TrainingLessonModel> _allLessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res =
            await Get.find<ApiClient>().getData(AppConstants.marketerLessonsUri);
        if (res.statusCode == 200 && res.body?['data']?['lessons'] is List) {
          _allLessons = (res.body['data']['lessons'] as List)
              .whereType<Map>()
              .map((e) =>
                  TrainingLessonModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String? _resolveThumbnail(TrainingLessonModel lesson) {
    if (lesson.thumbnailUrl != null && lesson.thumbnailUrl!.isNotEmpty) {
      return lesson.thumbnailUrl;
    }
    final url = lesson.videoUrl;
    if (url != null && url.isNotEmpty) {
      final m = RegExp(
        r'(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([A-Za-z0-9_-]{11})',
      ).firstMatch(url);
      if (m != null) {
        return 'https://img.youtube.com/vi/${m.group(1)}/hqdefault.jpg';
      }
    }
    return null;
  }

  List<TrainingLessonModel> get _filteredLessons {
    final query = _searchController.text.trim().toLowerCase();
    return _allLessons.where((lesson) {
      if (_selectedTab == 1 &&
          lesson.progressPercent <= 0 &&
          !lesson.isCompleted) {
        return false;
      }
      if (query.isNotEmpty) {
        return lesson.titleAr.toLowerCase().contains(query) ||
            lesson.titleEn.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final bodyText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final searchBg =
            isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final segBg =
            isDark ? const Color(0xFF252B37) : const Color(0xFFEEEEEE);

        final lessons = _filteredLessons;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform:
                    isRtl ? Matrix4.identity() : Matrix4.rotationY(math.pi),
                child: SvgPicture.asset(
                  _arrowRightSvg,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(darkText, BlendMode.srcIn),
                ),
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'shella_lessons_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search + Segmented Control (Figma 9944:99487)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      // Search Bar (56px, #F6F5F8, radius 12)
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: searchBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'search_lesson_hint'.tr,
                            hintStyle: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFA2A6AF),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                _searchSvg,
                                width: 20,
                                height: 20,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Two-tab Segmented Pill (دروس شلة | تمت مشاهدتها)
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: segBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTabButton(
                                label: 'shella_lessons_title'.tr,
                                isSelected: _selectedTab == 0,
                                cardBg: cardBg,
                                darkText: darkText,
                                onTap: () => setState(() => _selectedTab = 0),
                              ),
                            ),
                            Expanded(
                              child: _buildTabButton(
                                label: 'watched_lessons_tab'.tr,
                                isSelected: _selectedTab == 1,
                                cardBg: cardBg,
                                darkText: darkText,
                                onTap: () => setState(() => _selectedTab = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Body
                Expanded(
                  child: _isLoading
                      ? SkeletonLoadingWidgets.lessonsListSkeleton(isDark: isDark)
                      : lessons.isEmpty
                          ? _buildEmptyState(darkText)
                          : RefreshIndicator(
                              color: _primaryGreen,
                              onRefresh: _loadLessons,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 12, 16, 24),
                                itemCount: lessons.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 11),
                                itemBuilder: (context, index) {
                                  final lesson = lessons[index];
                                  return _buildLessonCard(
                                    context: context,
                                    lesson: lesson,
                                    showProgressBar: _selectedTab == 1 ||
                                        lesson.progressPercent > 0,
                                    isDark: isDark,
                                    isRtl: isRtl,
                                    cardBg: cardBg,
                                    darkText: darkText,
                                    bodyText: bodyText,
                                  );
                                },
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

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required Color cardBg,
    required Color darkText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard({
    required BuildContext context,
    required TrainingLessonModel lesson,
    required bool showProgressBar,
    required bool isDark,
    required bool isRtl,
    required Color cardBg,
    required Color darkText,
    required Color bodyText,
  }) {
    final progress = (lesson.progressPercent / 100.0).clamp(0.0, 1.0);
    final thumbUrl = _resolveThumbnail(lesson);

    return InkWell(
      onTap: () async {
        final refreshed = await Get.to(
          () => ShellaLessonPlayerScreen(
            lesson: lesson,
            otherLessons: _allLessons,
          ),
        );
        if (refreshed == true) {
          _loadLessons();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 7),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Start (Right in RTL): Thumbnail 112x89, radius 4
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 112,
                height: 89,
                color: isDark
                    ? const Color(0xFF252B37)
                    : const Color(0xFFF3F4F6),
                child: thumbUrl != null && thumbUrl.isNotEmpty
                    ? Image.network(
                        thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderThumb(),
                      )
                    : _buildPlaceholderThumb(),
              ),
            ),
            const SizedBox(width: 8),

            // Middle: Title + optional green progress bar + clock & duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.localizedTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      color: darkText,
                    ),
                  ),
                  if (showProgressBar) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress > 0 ? progress : 0.15,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? const Color(0xFF2B3240)
                            : const Color(0xFFE5E7EB),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_primaryGreen),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset(
                        _clockSvg,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          bodyText.withValues(alpha: 0.8),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${lesson.durationMinutes} ${'minute_unit'.tr}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: bodyText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // End (Left in RTL): Arrow Left SVG (24x24)
            Transform(
              alignment: Alignment.center,
              transform:
                  isRtl ? Matrix4.identity() : Matrix4.rotationY(math.pi),
              child: SvgPicture.asset(
                _arrowLeftSvg,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(darkText, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderThumb() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFF78350F)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.play_circle_fill_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildEmptyState(Color darkText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              _emptySvg,
              width: 234,
              height: 240,
            ),
            const SizedBox(height: 24),
            Text(
              'no_lessons_available_now'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
