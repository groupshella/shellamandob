import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../../api/api_client.dart';
import '../../../common/controllers/theme_controller.dart';
import '../../../util/app_constants.dart';
import '../models/training_lesson_model.dart';

/// Lesson Player Screen ("درس شلة") matching Figma node 9942:96110:
/// - Inline YouTube IFrame video player (height 201, radius 4) inside WebViewWidget
/// - Real playback progress tracking synced to backend
/// - Lesson title + clock SVG & duration
/// - Section "دروس أخرى يمكنك الاطلاع عليها" + other lessons list
class ShellaLessonPlayerScreen extends StatefulWidget {
  final TrainingLessonModel lesson;
  final List<TrainingLessonModel> otherLessons;

  const ShellaLessonPlayerScreen({
    super.key,
    required this.lesson,
    this.otherLessons = const [],
  });

  @override
  State<ShellaLessonPlayerScreen> createState() =>
      _ShellaLessonPlayerScreenState();
}

class _ShellaLessonPlayerScreenState extends State<ShellaLessonPlayerScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  static const String _arrowRightSvg =
      'assets/image/figma_lessons_arrow_right.svg';
  static const String _arrowLeftSvg =
      'assets/image/figma_lessons_arrow_left.svg';
  static const String _clockSvg = 'assets/image/figma_lessons_clock.svg';
  static const String _volumeSvg = 'assets/image/figma_player_volume.svg';
  static const String _settingsSvg = 'assets/image/figma_player_settings.svg';
  static const String _notesSvg = 'assets/image/figma_player_notes.svg';
  static const String _fullscreenSvg =
      'assets/image/figma_player_fullscreen.svg';

  late TrainingLessonModel _currentLesson;
  List<TrainingLessonModel> _otherLessons = [];
  bool _isPlayerActive = false;
  bool _isMuted = false;
  int _watchedSeconds = 0;
  Timer? _progressTimer;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.lesson;
    _watchedSeconds = widget.lesson.watchedSeconds;
    _otherLessons = widget.otherLessons
        .where((l) => l.id != widget.lesson.id)
        .toList();
    if (_otherLessons.isEmpty) {
      _loadOtherLessons();
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOtherLessons() async {
    if (!Get.isRegistered<ApiClient>()) return;
    try {
      final res =
          await Get.find<ApiClient>().getData(AppConstants.marketerLessonsUri);
      if (res.statusCode == 200 && res.body?['data']?['lessons'] is List) {
        final all = (res.body['data']['lessons'] as List)
            .whereType<Map>()
            .map((e) =>
                TrainingLessonModel.fromJson(Map<String, dynamic>.from(e)))
            .where((l) => l.id != _currentLesson.id)
            .toList();
        if (mounted) {
          setState(() => _otherLessons = all);
        }
      }
    } catch (_) {}
  }

  int get _totalSeconds {
    return (_currentLesson.durationMinutes > 0
            ? _currentLesson.durationMinutes
            : 10) *
        60;
  }

  double get _progressRatio => _totalSeconds > 0
      ? (_watchedSeconds / _totalSeconds).clamp(0.0, 1.0)
      : 0.0;

  String _formatClock(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String? _extractYoutubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([A-Za-z0-9_-]{11})',
    ).firstMatch(url);
    return match?.group(1);
  }

  String? _resolveThumbnail(TrainingLessonModel lesson) {
    if (lesson.thumbnailUrl != null && lesson.thumbnailUrl!.isNotEmpty) {
      return lesson.thumbnailUrl;
    }
    final ytId = _extractYoutubeId(lesson.videoUrl);
    if (ytId != null) {
      return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    }
    return null;
  }

  void _initInlineYoutubePlayer(String videoId) {
    final startSec = _watchedSeconds > 0 ? _watchedSeconds : 0;
    final embedUri = Uri.parse(
      'https://www.youtube-nocookie.com/embed/$videoId'
      '?autoplay=1&playsinline=1&rel=0&modestbranding=1&fs=1&start=$startSec',
    );

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.contains('youtube.com/embed') ||
                url.contains('youtube-nocookie.com/embed') ||
                url.contains('googlevideo.com') ||
                url.contains('ytimg.com')) {
              return NavigationDecision.navigate;
            }
            if (url.startsWith('https://www.youtube.com/watch') ||
                url.startsWith('https://m.youtube.com/watch') ||
                url.startsWith('https://youtu.be/')) {
              _openExternalVideo();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller.loadRequest(
      embedUri,
      headers: const {
        'Referer': 'https://shellafood.com/',
      },
    );

    setState(() {
      _webViewController = controller;
      _isPlayerActive = true;
    });

    if (_watchedSeconds == 0) {
      _watchedSeconds = 5;
    }
    _syncProgressToServer();
    _startProgressTicker();
  }

  void _startProgressTicker() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_watchedSeconds < _totalSeconds) {
          _watchedSeconds++;
        } else {
          _progressTimer?.cancel();
          _syncProgressToServer();
        }
      });
      if (_watchedSeconds % 15 == 0) {
        _syncProgressToServer();
      }
    });
  }

  void _startPlayback() {
    final ytId = _extractYoutubeId(_currentLesson.videoUrl);
    if (ytId != null) {
      _initInlineYoutubePlayer(ytId);
      return;
    }
    _openExternalVideo();
  }

  Future<void> _openExternalVideo() async {
    final urlStr = _currentLesson.videoUrl;
    if (urlStr == null || urlStr.isEmpty) return;
    final uri = Uri.tryParse(urlStr);
    if (uri != null) {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _syncProgressToServer() async {
    if (!Get.isRegistered<ApiClient>() || _currentLesson.id <= 0) return;
    final pct = (_progressRatio * 100).round().clamp(1, 100);
    try {
      await Get.find<ApiClient>().postData(
        '${AppConstants.marketerLessonsUri}/${_currentLesson.id}/progress',
        {
          'watched_seconds': _watchedSeconds,
          'progress_percent': pct,
          'is_completed': pct >= 90,
        },
      );
    } catch (_) {}
  }

  void _switchLesson(TrainingLessonModel nextLesson) {
    _progressTimer?.cancel();
    if (_watchedSeconds > 0) {
      _syncProgressToServer();
    }
    setState(() {
      final previous = _currentLesson.copyWith(
        watchedSeconds: _watchedSeconds,
        progressPercent: (_progressRatio * 100).round(),
      );
      _otherLessons = [
        previous,
        ..._otherLessons
            .where((l) => l.id != nextLesson.id && l.id != previous.id),
      ];
      _currentLesson = nextLesson;
      _watchedSeconds = nextLesson.watchedSeconds;
      _isPlayerActive = false;
      _webViewController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final resolvedThumb = _resolveThumbnail(_currentLesson);

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final bodyText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);

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
              onPressed: () {
                if (_watchedSeconds > 0) {
                  _syncProgressToServer();
                }
                Get.back(result: true);
              },
            ),
            title: Text(
              'shella_lesson_single_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Video Player Box (Figma 9942:96387 — height 201, radius 4)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 201,
                      child: _isPlayerActive && _webViewController != null
                          ? WebViewWidget(controller: _webViewController!)
                          : GestureDetector(
                              onTap: _startPlayback,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (resolvedThumb != null &&
                                      resolvedThumb.isNotEmpty)
                                    Image.network(
                                      resolvedThumb,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildPlaceholderBanner(),
                                    )
                                  else
                                    _buildPlaceholderBanner(),

                                  // Bottom dark gradient overlay
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: 76,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0x00000000),
                                            Color(0xC70D0037),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Play button overlay
                                  Center(
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: _primaryGreen
                                            .withValues(alpha: 0.92),
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x40000000),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                    ),
                                  ),

                                  // Bottom Controls Row (Figma 9942:96395..96405)
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 14,
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${_formatClock(_watchedSeconds)} / ${_formatClock(_totalSeconds)}',
                                                style: const TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => setState(
                                                    () => _isMuted = !_isMuted),
                                                child: Opacity(
                                                  opacity:
                                                      _isMuted ? 0.45 : 1.0,
                                                  child: SvgPicture.asset(
                                                    _volumeSvg,
                                                    width: 22,
                                                    height: 22,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: _startPlayback,
                                                child: SvgPicture.asset(
                                                  _settingsSvg,
                                                  width: 22,
                                                  height: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: _startPlayback,
                                                child: SvgPicture.asset(
                                                  _notesSvg,
                                                  width: 22,
                                                  height: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: _openExternalVideo,
                                                child: SvgPicture.asset(
                                                  _fullscreenSvg,
                                                  width: 22,
                                                  height: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Bottom Progress Bar (Figma 9942:96390 + 9942:96391)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 8,
                                      color: const Color(0xFFDCDBDE),
                                      child: FractionallySizedBox(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        widthFactor: _progressRatio > 0
                                            ? _progressRatio
                                            : 0.2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: _primaryGreen,
                                            borderRadius:
                                                BorderRadiusDirectional
                                                    .horizontal(
                                              end: Radius.circular(48),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Lesson Title & Duration (Figma 9942:96431)
                  Text(
                    _currentLesson.localizedTitle,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
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
                        '${_currentLesson.durationMinutes} ${'minute_unit'.tr}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: bodyText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  if (_otherLessons.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'other_lessons_you_can_view'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._otherLessons.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _buildOtherLessonCard(
                          item: item,
                          isDark: isDark,
                          isRtl: isRtl,
                          cardBg: cardBg,
                          darkText: darkText,
                          bodyText: bodyText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherLessonCard({
    required TrainingLessonModel item,
    required bool isDark,
    required bool isRtl,
    required Color cardBg,
    required Color darkText,
    required Color bodyText,
  }) {
    final thumbUrl = _resolveThumbnail(item);

    return InkWell(
      onTap: () => _switchLesson(item),
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
                        errorBuilder: (_, __, ___) => _buildPlaceholderBanner(),
                      )
                    : _buildPlaceholderBanner(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.localizedTitle,
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
                        '${item.durationMinutes} ${'minute_unit'.tr}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: bodyText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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

  Widget _buildPlaceholderBanner() {
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
        size: 36,
      ),
    );
  }
}
