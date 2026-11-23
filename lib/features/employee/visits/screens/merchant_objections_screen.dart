import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// شاشة «أهم اعتراضات التجار» مطابقة لتصميم Figma (9946:100222 & 9946:100487).
class MerchantObjectionsScreen extends StatefulWidget {
  const MerchantObjectionsScreen({super.key});

  @override
  State<MerchantObjectionsScreen> createState() =>
      _MerchantObjectionsScreenState();
}

class _MerchantObjectionsScreenState extends State<MerchantObjectionsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _objections = [];
  final Set<int> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchObjections();
  }

  Future<void> _fetchObjections() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getData(
        AppConstants.marketerMerchantObjectionsUri,
        handleError: false,
      );

      if (response.statusCode == 200 && response.body is Map) {
        final data = response.body['data'];
        final rawList =
            (data is Map ? data['objections'] : null) as List? ?? [];
        final parsed = rawList
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (mounted) {
          setState(() {
            _objections = parsed;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _toggleItem(int id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final screenBg = isDark ? const Color(0xFF121418) : Colors.white;
        final headlineColor = isDark ? Colors.white : const Color(0xFF111B18);
        final subTextColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final dividerColor =
            isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final answerBg =
            isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);

        return Scaffold(
          backgroundColor: screenBg,
          appBar: AppBar(
            backgroundColor: screenBg,
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
                    headlineColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            title: Text(
              'merchant_objections_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: headlineColor,
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: _primaryGreen,
              onRefresh: _fetchObjections,
              child: _isLoading
                  ? SkeletonLoadingWidgets.listCardsSkeleton(isDark: isDark, itemCount: 5)
                  : _hasError
                      ? _buildStateMessage(
                          headlineColor: headlineColor,
                          subTextColor: subTextColor,
                          message: 'failed_to_load_data'.tr,
                          showRetry: true,
                        )
                      : _objections.isEmpty
                          ? _buildStateMessage(
                              headlineColor: headlineColor,
                              subTextColor: subTextColor,
                              message: 'no_objections_available'.tr,
                              showRetry: false,
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                              children: [
                                Text(
                                  'merchant_objections_title'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: headlineColor,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ..._objections.map((item) {
                                  final id = (item['id'] as num?)?.toInt() ?? 0;
                                  final isEn =
                                      (Get.locale?.languageCode ?? 'ar') == 'en';
                                  final title = isEn
                                      ? (item['title_en']?.toString().isNotEmpty == true
                                          ? item['title_en'].toString()
                                          : (item['title'] ?? '').toString())
                                      : (item['title_ar']?.toString().isNotEmpty == true
                                          ? item['title_ar'].toString()
                                          : (item['title'] ?? '').toString());
                                  final responseText = isEn
                                      ? (item['response_en']?.toString().isNotEmpty == true
                                          ? item['response_en'].toString()
                                          : (item['response'] ?? '').toString())
                                      : (item['response_ar']?.toString().isNotEmpty == true
                                          ? item['response_ar'].toString()
                                          : (item['response'] ?? '').toString());
                                  final isExpanded = _expandedIds.contains(id);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      InkWell(
                                        onTap: () => _toggleItem(id),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: dividerColor,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontFamily: 'Tajawal',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: headlineColor,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              SvgPicture.asset(
                                                isExpanded
                                                    ? 'assets/image/figma_visit_arrow_up.svg'
                                                    : 'assets/image/figma_visit_arrow_down.svg',
                                                width: 20,
                                                height: 20,
                                                colorFilter: ColorFilter.mode(
                                                  headlineColor,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      AnimatedCrossFade(
                                        firstChild: const SizedBox.shrink(),
                                        secondChild: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                          color: answerBg,
                                          child: Text(
                                            responseText,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: headlineColor,
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration:
                                            const Duration(milliseconds: 200),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateMessage({
    required Color headlineColor,
    required Color subTextColor,
    required String message,
    required bool showRetry,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
                if (showRetry) ...[
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _fetchObjections,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'retry_btn'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
