import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class QidhaFilterResult {
  final String? sortBy; // 'rating', 'free_delivery', 'fast_delivery'
  final String? selectedCategory;

  const QidhaFilterResult({
    this.sortBy,
    this.selectedCategory,
  });
}

class QidhaStoresFilterBottomSheet extends StatefulWidget {
  final bool isRestaurantTab;
  final String? initialSortBy;
  final String? initialCategory;
  final ValueChanged<QidhaFilterResult> onApply;

  const QidhaStoresFilterBottomSheet({
    super.key,
    required this.isRestaurantTab,
    this.initialSortBy,
    this.initialCategory,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isRestaurantTab,
    String? initialSortBy,
    String? initialCategory,
    required ValueChanged<QidhaFilterResult> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QidhaStoresFilterBottomSheet(
        isRestaurantTab: isRestaurantTab,
        initialSortBy: initialSortBy,
        initialCategory: initialCategory,
        onApply: onApply,
      ),
    );
  }

  @override
  State<QidhaStoresFilterBottomSheet> createState() =>
      _QidhaStoresFilterBottomSheetState();
}

class _QidhaStoresFilterBottomSheetState
    extends State<QidhaStoresFilterBottomSheet> {
  String? _sortBy;
  String? _selectedCategory;

  final List<String> _restaurantCategories = [
    'وجبة سريعة',
    'سندوتشات',
    'مأكولات عربية',
    'حلويات',
    'أمريكي',
    'مشروبات',
    'شاورما',
  ];

  final List<String> _storeCategories = [
    'سوبرماركت',
    'الكترونيات',
    'منظفات',
    'صيدلية',
    'مستلزمات منزلية',
    'عطور وتجميل',
    'أدوات مكتبية',
  ];

  @override
  void initState() {
    super.initState();
    _sortBy = widget.initialSortBy;
    _selectedCategory = widget.initialCategory ??
        (widget.isRestaurantTab
            ? _restaurantCategories.first
            : _storeCategories.first);
  }

  void _toggleSort(String sortKey) {
    setState(() {
      if (_sortBy == sortKey) {
        _sortBy = null;
      } else {
        _sortBy = sortKey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardBgColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF111B18);

    final categories = widget.isRestaurantTab
        ? _restaurantCategories
        : _storeCategories;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          top: Dimensions.paddingSizeDefault,
          bottom: MediaQuery.of(context).padding.bottom + Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header (Close Button on Left, Title Centered) ───────────────
            Stack(
              alignment: Alignment.center,
              children: [
                // Title
                Text(
                  'فلتر',
                  style: tajawalBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: textColor,
                  ),
                ),

                // Close X button (Left side in RTL)
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F5F8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Scrollable Body ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: الترتيب حسب
                    Text(
                      'الترتيب حسب',
                      textAlign: TextAlign.right,
                      style: tajawalBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sort Options Chips (Row)
                    Row(
                      children: [
                        // Chip 1: أعلى تقييم (Right in RTL)
                        Expanded(
                          child: _buildSortChip(
                            key: 'rating',
                            label: 'highest_rating'.tr,
                            assetImage: Images.star_v2,
                            primaryColor: primaryColor,
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Chip 2: توصيل مجاني (Center)
                        Expanded(
                          child: _buildSortChip(
                            key: 'free_delivery',
                            label: 'free_delivery'.tr,
                            assetImage: Images.truck_delivery_v2,
                            primaryColor: primaryColor,
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Chip 3: توصيل سريع (Left in RTL)
                        Expanded(
                          child: _buildSortChip(
                            key: 'fast_delivery',
                            label: 'fast_delivery'.tr,
                            assetImage: Images.truck_delivery_v2,
                            primaryColor: primaryColor,
                            textColor: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section 2: فئة المطاعم / فئة المتاجر
                    Text(
                      widget.isRestaurantTab ? 'فئة المطاعم' : 'فئة المتاجر',
                      textAlign: TextAlign.right,
                      style: tajawalBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categories Radio List
                    ...categories.map((cat) {
                      final bool isSelected = _selectedCategory == cat;
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = isSelected ? null : cat;
                              });
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  // Category Label (Right in RTL)
                                  Text(
                                    cat,
                                    textAlign: TextAlign.right,
                                    style: isSelected
                                        ? tajawalBold.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: textColor,
                                          )
                                        : tajawalMedium.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: textColor,
                                          ),
                                  ),

                                  const Spacer(),

                                  // Radio Icon on Left (Figma)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? textColor
                                            : const Color(0xFFD1D5DB),
                                        width: isSelected ? 6.5 : 3.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF6F5F8),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Bottom Done (تم) Button ─────────────────────────────────────
            ElevatedButton(
              onPressed: () {
                widget.onApply(QidhaFilterResult(
                  sortBy: _sortBy,
                  selectedCategory: _selectedCategory,
                ));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              child: Text(
                'تم',
                style: tajawalBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required String key,
    required String label,
    required String assetImage,
    required Color primaryColor,
    required Color textColor,
  }) {
    final bool isSelected = _sortBy == key;

    return GestureDetector(
      onTap: () => _toggleSort(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : const Color(0xFFF6F5F8),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: isSelected
              ? Border.all(color: primaryColor, width: 1.2)
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: isSelected
                  ? tajawalBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall - 1,
                      color: primaryColor,
                    )
                  : tajawalMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall - 1,
                      color: textColor,
                    ),
            ),
            const SizedBox(width: 4),
            Image.asset(
              assetImage,
              width: 14,
              height: 14,
              color: isSelected ? primaryColor : textColor,
            ),
          ],
        ),
      ),
    );
  }
}
