import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../domain/models/store_preview_model.dart';

enum _PreviewItemFilter { all, noImage, noPrice }

/// [R08] Read-only customer-view preview of a store with automated readiness diagnostics.
/// Redesigned to match Figma 10031:37520 (empty) & 10031:50586 (populated).
/// Intentionally has NO cart and NO order placement controls.
class StoreCustomerPreviewScreen extends StatefulWidget {
  final int storeId;
  final String storeName;

  const StoreCustomerPreviewScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<StoreCustomerPreviewScreen> createState() =>
      _StoreCustomerPreviewScreenState();
}

class _StoreCustomerPreviewScreenState
    extends State<StoreCustomerPreviewScreen> {
  static const Color _brandGreen = Color(0xFF30913F);
  static const String _assetsDir = 'assets/image/figma_activation_preview';

  _PreviewItemFilter _selectedFilter = _PreviewItemFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().loadStorePreview(widget.storeId);
      }
    });
  }

  bool _isUsableImageUrl(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('160x160/img2.jpg') || trimmed.endsWith('/def.png')) {
      return false;
    }
    return true;
  }

  String _formatTimeTo12h(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(':');
    if (parts.length < 2) return trimmed;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return trimmed;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    final String mm = minute.toString().padLeft(2, '0');
    return '$h12:$mm $period';
  }

  String _formatWorkingHours(
    StorePreviewReadiness readiness,
    List<StorePreviewSchedule> schedules,
  ) {
    if (!readiness.workingHoursConfigured || schedules.isEmpty) {
      return 'preview_hours_unspecified'.tr;
    }
    final first = schedules.first;
    final openFormatted = _formatTimeTo12h(first.openingTime);
    final closeFormatted = _formatTimeTo12h(first.closingTime);
    if (openFormatted.isEmpty || closeFormatted.isEmpty) {
      return 'preview_hours_configured'.tr;
    }
    return 'preview_hours_range'.trParams({
      'from': openFormatted,
      'to': closeFormatted,
    });
  }

  List<StorePreviewItem> _filteredItems(List<StorePreviewItem> items) {
    switch (_selectedFilter) {
      case _PreviewItemFilter.all:
        return items;
      case _PreviewItemFilter.noImage:
        return items
            .where((i) => !i.hasImage || !_isUsableImageUrl(i.imageFullUrl))
            .toList();
      case _PreviewItemFilter.noPrice:
        return items.where((i) => !i.hasPrice).toList();
    }
  }

  String _filterSummaryLabel(int count) {
    switch (_selectedFilter) {
      case _PreviewItemFilter.all:
        return 'preview_total_items_count'.trParams({'count': '$count'});
      case _PreviewItemFilter.noImage:
        return 'preview_missing_images_count'.trParams({'count': '$count'});
      case _PreviewItemFilter.noPrice:
        return 'preview_missing_prices_count'.trParams({'count': '$count'});
    }
  }

  String _formatPrice(double price) {
    if (price == price.truncateToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final bool isDark = themeController.darkTheme;
        final bool isRtl = Directionality.of(context) == TextDirection.rtl;
        final Color screenBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color softSurface =
            isDark ? const Color(0xFF1E293B) : const Color(0xFFF6F5F8);
        final Color textDark = isDark ? Colors.white : const Color(0xFF111B18);
        final Color textSub =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF555555);
        final Color borderColor =
            isDark ? const Color(0xFF334155) : const Color(0xFFE4E9E5);

        return Scaffold(
          backgroundColor: screenBg,
          body: GetBuilder<StoreVisitsController>(
            builder: (controller) {
              if (controller.isStorePreviewLoading) {
                return Column(
                  children: [
                    _buildTopHeroHeader(
                      store: null,
                      isDark: isDark,
                      isRtl: isRtl,
                      textDark: textDark,
                      softSurface: softSurface,
                    ),
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: _brandGreen),
                      ),
                    ),
                  ],
                );
              }

              final preview = controller.currentStorePreview;
              if (preview == null) {
                return Column(
                  children: [
                    _buildTopHeroHeader(
                      store: null,
                      isDark: isDark,
                      isRtl: isRtl,
                      textDark: textDark,
                      softSurface: softSurface,
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                '$_assetsDir/preview_empty_cart.svg',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.storePreviewError ??
                                    'preview_load_failed'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textSub,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () => controller
                                      .loadStorePreview(widget.storeId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _brandGreen,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'retry'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final filtered = _filteredItems(preview.items);

              return RefreshIndicator(
                color: _brandGreen,
                onRefresh: () => controller.loadStorePreview(widget.storeId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Botanical Green Banner + Overlapping Store Logo & Name/Specialty
                      _buildTopHeroHeader(
                        store: preview.store,
                        isDark: isDark,
                        isRtl: isRtl,
                        textDark: textDark,
                        softSurface: softSurface,
                      ),
                      const SizedBox(height: 14),

                      // 2. Read-Only Preview Banner (Figma 10031:50468)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildReadOnlyBanner(
                          isDark: isDark,
                          softSurface: softSurface,
                          textDark: textDark,
                          borderColor: borderColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Automated Readiness Check 2x2 Grid Card (Figma 10031:50469 / 10031:50622)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildReadinessSectionCard(
                          readiness: preview.readiness,
                          schedules: preview.schedules,
                          isDark: isDark,
                          cardBg: cardBg,
                          softSurface: softSurface,
                          textDark: textDark,
                          borderColor: borderColor,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4. Section Title: قائمة الأصناف (Figma 10031:50537)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'preview_items_section_title'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5. Filter Chips + Items List / Empty Cart Card (Figma 10031:50519 / 10031:50640)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        child: _buildItemsSectionCard(
                          filteredItems: filtered,
                          isDark: isDark,
                          cardBg: cardBg,
                          softSurface: softSurface,
                          textDark: textDark,
                          textSub: textSub,
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =========================================================================
  // 1. Hero Botanical Banner + Overlapping Store Logo & Identity
  // =========================================================================
  Widget _buildTopHeroHeader({
    required StorePreviewInfo? store,
    required bool isDark,
    required bool isRtl,
    required Color textDark,
    required Color softSurface,
  }) {
    final double topInset = MediaQuery.of(context).padding.top;
    final double bannerHeight = 135 + topInset * 0.5;
    final bool hasCover = store != null && _isUsableImageUrl(store.coverPhotoFullUrl);
    final bool hasLogo = store != null && _isUsableImageUrl(store.logoFullUrl);
    final String displayName = (store != null && store.name.trim().isNotEmpty)
        ? store.name.trim()
        : (widget.storeName.trim().isNotEmpty
            ? widget.storeName.trim()
            : 'store_name_label'.tr);
    final String displaySpecialty =
        (store?.specialty != null && store!.specialty!.trim().isNotEmpty)
            ? store.specialty!.trim()
            : ((store?.address != null && store!.address!.trim().isNotEmpty)
                ? store.address!.trim()
                : 'preview_store_specialty_fallback'.tr);

    return SizedBox(
      height: bannerHeight + 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top Cover / Figma Botanical Green Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: hasCover
                  ? Image.network(
                      store.coverPhotoFullUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildBannerFallback(),
                    )
                  : _buildBannerFallback(),
            ),
          ),

          // Floating Circular Back Button (Start edge in RTL = Right, LTR = Left)
          PositionedDirectional(
            top: topInset + 10,
            start: 16,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(35),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xCC1E293B)
                      : const Color(0xCCF6F5F8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      isRtl ? Matrix4.identity() : Matrix4.rotationY(math.pi),
                  child: SvgPicture.asset(
                    '$_assetsDir/preview_arrow_right.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : const Color(0xFF111B18),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlapping Store Logo + Store Name & Specialty
          PositionedDirectional(
            top: bannerHeight - 28,
            start: 16,
            end: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Logo Container (72 x 80, 4px white/card border, #3EC856 fallback bg)
                Container(
                  width: 72,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3EC856),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF6F5F8),
                      width: 4,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasLogo
                      ? Image.network(
                          store.logoFullUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildLogoFallback(),
                        )
                      : _buildLogoFallback(),
                ),
                const SizedBox(width: 10),
                // Store Name + Specialty aligned to bottom half (below banner)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displaySpecialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerFallback() {
    return Image.asset(
      '$_assetsDir/preview_banner_bg.png',
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildLogoFallback() {
    return Container(
      color: const Color(0xFF0A7D3B),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(14),
      child: SvgPicture.asset(
        'assets/image/figma_activation_shop.svg',
        width: 30,
        height: 30,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }

  // =========================================================================
  // 2. Read-Only Preview Banner (Figma 10031:50468)
  // =========================================================================
  Widget _buildReadOnlyBanner({
    required bool isDark,
    required Color softSurface,
    required Color textDark,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: softSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? borderColor : const Color(0xFFF6F5F8),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SvgPicture.asset(
              '$_assetsDir/preview_eye.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : const Color(0xFF111B18),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'preview_mode_banner'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.55,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. Automated Store Readiness Check 2x2 Grid Card (Figma 10031:50469)
  // =========================================================================
  Widget _buildReadinessSectionCard({
    required StorePreviewReadiness readiness,
    required List<StorePreviewSchedule> schedules,
    required bool isDark,
    required Color cardBg,
    required Color softSurface,
    required Color textDark,
    required Color borderColor,
  }) {
    final String hoursText = _formatWorkingHours(readiness, schedules);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A1C3420),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'preview_readiness_title'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          // Row 1: إجمالي الأصناف (Start/Right in RTL, Green tinted) | أصناف بلا صورة (End/Left)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildReadinessTile(
                    label: 'preview_total_items'.tr,
                    value: '${readiness.totalItems}',
                    highlighted: true,
                    isDark: isDark,
                    softSurface: softSurface,
                    textDark: textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReadinessTile(
                    label: 'preview_missing_images'.tr,
                    value: '${readiness.itemsWithoutImage}',
                    highlighted: false,
                    isDark: isDark,
                    softSurface: softSurface,
                    textDark: textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          // Row 2: أصناف بلا سعر (Start/Right in RTL) | أوقات العمل (End/Left)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildReadinessTile(
                    label: 'preview_missing_prices'.tr,
                    value: '${readiness.itemsWithoutPrice}',
                    highlighted: false,
                    isDark: isDark,
                    softSurface: softSurface,
                    textDark: textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReadinessTile(
                    label: 'preview_working_hours'.tr,
                    value: hoursText,
                    highlighted: false,
                    isDark: isDark,
                    softSurface: softSurface,
                    textDark: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessTile({
    required String label,
    required String value,
    required bool highlighted,
    required bool isDark,
    required Color softSurface,
    required Color textDark,
  }) {
    final Color bgColor = highlighted
        ? (isDark ? const Color(0xFF143326) : const Color(0xFFEBFEEB))
        : (isDark ? const Color(0xFF0F172A) : softSurface);
    final Color tileBorder = highlighted
        ? (isDark
            ? const Color(0xFF22693A)
            : const Color(0x4D30913F))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFCFCED1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tileBorder, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. Items List Card with 3 Filter Chips + Empty / Populated States
  // =========================================================================
  Widget _buildItemsSectionCard({
    required List<StorePreviewItem> filteredItems,
    required bool isDark,
    required Color cardBg,
    required Color softSurface,
    required Color textDark,
    required Color textSub,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A1C3420),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3 Filter Chips (Start to End in RTL: إجمالي الأصناف | أصناف بلا صورة | أصناف بلا سعر)
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  filter: _PreviewItemFilter.all,
                  label: 'preview_total_items'.tr,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  filter: _PreviewItemFilter.noImage,
                  label: 'preview_missing_images'.tr,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  filter: _PreviewItemFilter.noPrice,
                  label: 'preview_missing_prices'.tr,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (filteredItems.isEmpty)
            // Empty State (Figma 10031:37520)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    '$_assetsDir/preview_empty_cart.svg',
                    width: 143,
                    height: 155,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'preview_no_items_yet'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Populated Count Label (Figma 10031:50801)
            Text(
              _filterSummaryLabel(filteredItems.length),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Product Cards List (Figma 10031:50763 / 50736 / 50750)
            ...filteredItems.map(
              (item) => _buildProductCard(
                item: item,
                isDark: isDark,
                cardBg: cardBg,
                softSurface: softSurface,
                textDark: textDark,
                textSub: textSub,
                borderColor: borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required _PreviewItemFilter filter,
    required String label,
    required bool isDark,
  }) {
    final bool isSelected = _selectedFilter == filter;
    final Color bg = isSelected
        ? _brandGreen
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F6F6));
    final Color textColor = isSelected
        ? Colors.white
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF707784));

    return InkWell(
      onTap: () {
        if (_selectedFilter != filter) {
          setState(() => _selectedFilter = filter);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required StorePreviewItem item,
    required bool isDark,
    required Color cardBg,
    required Color softSurface,
    required Color textDark,
    required Color textSub,
    required Color borderColor,
  }) {
    final bool showItemImg =
        item.hasImage && _isUsableImageUrl(item.imageFullUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : cardBg,
        borderRadius: BorderRadius.circular(8),
        border: isDark ? Border.all(color: borderColor, width: 0.7) : null,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Start (Right in RTL): Product Thumbnail or Missing Image Icon
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : softSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: showItemImg
                ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.network(
                      item.imageFullUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          _buildMissingImagePlaceholder(isDark),
                    ),
                  )
                : _buildMissingImagePlaceholder(isDark),
          ),
          const SizedBox(width: 10),

          // Center: Product Title + Stock Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: textDark,
                  ),
                ),
                if (item.stock != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'preview_stock_count'.trParams({'count': '${item.stock}'}),
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSub,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // End (Left in RTL): Price + SAR Symbol (or "—" + SAR Symbol when missing price)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.hasPrice ? _formatPrice(item.price) : '—',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                '$_assetsDir/preview_sar_symbol.svg',
                width: 15,
                height: 15,
                colorFilter: ColorFilter.mode(textDark, BlendMode.srcIn),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissingImagePlaceholder(bool isDark) {
    return SvgPicture.asset(
      '$_assetsDir/preview_missing_image.svg',
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF555555),
        BlendMode.srcIn,
      ),
    );
  }
}
