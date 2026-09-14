import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/qidha_store_card_widget.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/qidha_stores_filter_bottom_sheet.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

const String _fontTajawal = 'Tajawal';
const Color _primary = Color(0xFF30913F);

class QidhaDiscoverStoresScreen extends StatefulWidget {
  final bool? isContractedOnly; // true: المتعاقد معها فقط, false: المتاحة للتعاقد, null: الكل

  const QidhaDiscoverStoresScreen({
    super.key,
    this.isContractedOnly,
  });

  @override
  State<QidhaDiscoverStoresScreen> createState() =>
      _QidhaDiscoverStoresScreenState();
}

class _QidhaDiscoverStoresScreenState extends State<QidhaDiscoverStoresScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _selectedTabIndex = 0; // 0: المطاعم, 1: المتاجر
  String _searchQuery = '';

  String? _filterSortBy;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStores();
      _loadRequestedStores();
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreStores();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadStores({String? type, String? search}) {
    if (Get.isRegistered<KaidhaSubscriptionController>()) {
      Get.find<KaidhaSubscriptionController>().getQidhaStores(
        isContractedOnly: widget.isContractedOnly,
        type: type ?? (_selectedTabIndex == 0 ? 'restaurants' : 'stores'),
        search: search ?? (_searchQuery.trim().isNotEmpty ? _searchQuery.trim() : null),
        reload: true,
      );
    }
  }

  void _loadMoreStores() {
    if (Get.isRegistered<KaidhaSubscriptionController>()) {
      Get.find<KaidhaSubscriptionController>().loadMoreQidhaStores(
        isContractedOnly: widget.isContractedOnly,
        type: _selectedTabIndex == 0 ? 'restaurants' : 'stores',
        search: _searchQuery.trim().isNotEmpty ? _searchQuery.trim() : null,
      );
    }
  }

  void _loadRequestedStores() {
    if (Get.isRegistered<KaidhaSubscriptionController>()) {
      Get.find<KaidhaSubscriptionController>().loadRequestedStoreIds();
    }
  }

  List<Store> _filterStores(List<Store>? rawList, {required int tabIndex}) {
    if (rawList == null) return [];

    var list = rawList.where((store) {
      // Category filter from filter bottom sheet
      if (_filterCategory != null && _filterCategory!.isNotEmpty) {
        final catQuery = _filterCategory!.toLowerCase();
        final name = (store.name ?? '').toLowerCase();
        final categoryName = (store.categoryDetails?.isNotEmpty == true &&
                store.categoryDetails!.first.name != null)
            ? store.categoryDetails!.first.name!.toLowerCase()
            : '';
        if (!name.contains(catQuery) && !categoryName.contains(catQuery)) {
          // Keep if no direct match
        }
      }

      // Free delivery filter
      if (_filterSortBy == 'free_delivery' && store.freeDelivery != true) {
        return false;
      }

      return true;
    }).toList();

    // Sort by rating
    if (_filterSortBy == 'rating') {
      list.sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));
    }

    return list;
  }

  void _openFilterSheet() {
    QidhaStoresFilterBottomSheet.show(
      context,
      isRestaurantTab: _selectedTabIndex == 0,
      initialSortBy: _filterSortBy,
      initialCategory: _filterCategory,
      onApply: (result) {
        setState(() {
          _filterSortBy = result.sortBy;
          _filterCategory = result.selectedCategory;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBgColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF111B18);

    final String screenTitle = widget.isContractedOnly == true
        ? 'المتاجر المتعاقد معها'
        : (widget.isContractedOnly == false
            ? 'المتاجر المتاحة للتعاقد'
            : 'المطاعم والمتاجر بقيدها');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        appBar: AppBar(
          backgroundColor: cardBgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            screenTitle,
            style: tajawalBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: textColor,
            ),
          ),
          leading: IconButton(
            icon: Image.asset(
              Images.arrow_back_ios_new,
              width: 18,
              height: 18,
              color: textColor,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                Images.candle_2,
                width: 22,
                height: 22,
                color: (_filterSortBy != null || _filterCategory != null)
                    ? primaryColor
                    : textColor,
              ),
              onPressed: _openFilterSheet,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            // ── Segmented Tab Control (المطاعم | المتاجر) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5F8),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(
                  children: [
                    // Tab 1: المطاعم (Right in RTL)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedTabIndex != 0) {
                            setState(() {
                              _selectedTabIndex = 0;
                            });
                            _loadStores(type: 'restaurants');
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: _selectedTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'المطاعم',
                            style: tajawalBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: _selectedTabIndex == 0
                                  ? Colors.white
                                  : const Color(0xFF082E0A),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tab 2: المتاجر (Left in RTL)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedTabIndex != 1) {
                            setState(() {
                              _selectedTabIndex = 1;
                            });
                            _loadStores(type: 'stores');
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: _selectedTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'المتاجر',
                            style: tajawalBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: _selectedTabIndex == 1
                                  ? Colors.white
                                  : const Color(0xFF082E0A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Input Field ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall,
              ),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5F8),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? primaryColor.withValues(alpha: 0.5)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: _searchQuery.isNotEmpty
                          ? primaryColor
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: tajawalMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: _selectedTabIndex == 0
                              ? 'ابحث عن مطعم أو وجبة...'
                              : 'ابحث عن متجر أو منتج...',
                          hintStyle: tajawalRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall + 1,
                            color: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 350), () {
                            _loadStores(
                              search: value.trim().isNotEmpty ? value.trim() : null,
                            );
                          });
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadStores(search: null);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // ── Stores / Restaurants List View ──────────────────────────────
            Expanded(
              child: GetBuilder<KaidhaSubscriptionController>(
                builder: (kaidhaController) {
                  if (kaidhaController.isLoadingQidhaStores) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }

                  final allStores = kaidhaController.qidhaStoresList ?? [];
                  final filteredStores = _filterStores(allStores,
                      tabIndex: _selectedTabIndex);

                  return RefreshIndicator(
                    onRefresh: () async {
                      await kaidhaController.getQidhaStores(
                        isContractedOnly: widget.isContractedOnly,
                        type: _selectedTabIndex == 0 ? 'restaurants' : 'stores',
                        search: _searchQuery.trim().isNotEmpty
                            ? _searchQuery.trim()
                            : null,
                        reload: true,
                      );
                      await kaidhaController.loadRequestedStoreIds();
                    },
                    color: _primary,
                    child: _buildStoreListView(
                      stores: filteredStores,
                      isRestaurantTab: _selectedTabIndex == 0,
                      requestedStoreIds: kaidhaController.requestedStoreIds,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreListView({
    required List<Store> stores,
    required bool isRestaurantTab,
    required Set<int> requestedStoreIds,
  }) {
    if (stores.isEmpty) {
      if (_searchQuery.trim().isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    color: Color(0xFF94A3B8),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'لا توجد نتائج بحث مطابقة لـ "$_searchQuery"',
                  style: const TextStyle(
                    fontFamily: _fontTajawal,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111B18),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'جرّب البحث بكلمات أخرى أو تحقق من كتابة الاسم',
                  style: TextStyle(
                    fontFamily: _fontTajawal,
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: _primary,
                  ),
                  label: const Text(
                    'مسح البحث',
                    style: TextStyle(
                      fontFamily: _fontTajawal,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isRestaurantTab
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRestaurantTab
                      ? Icons.restaurant_rounded
                      : Icons.storefront_rounded,
                  color: isRestaurantTab
                      ? const Color(0xFFEA580C)
                      : _primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isRestaurantTab
                    ? 'لا توجد مطاعم مطابقة حالياً'
                    : 'لا توجد متاجر مطابقة حالياً',
                style: const TextStyle(
                  fontFamily: _fontTajawal,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111B18),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isRestaurantTab
                    ? 'يمكنك تصفح قسم المتاجر المتاحة'
                    : 'يمكنك تصفح قسم المطاعم المتاحة',
                style: const TextStyle(
                  fontFamily: _fontTajawal,
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedTabIndex = isRestaurantTab ? 1 : 0;
                  });
                },
                icon: Icon(
                  isRestaurantTab ? Icons.storefront_rounded : Icons.restaurant_rounded,
                  size: 18,
                  color: _primary,
                ),
                label: Text(
                  isRestaurantTab ? 'الانتقال إلى المتاجر' : 'الانتقال إلى المطاعم',
                  style: const TextStyle(
                    fontFamily: _fontTajawal,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool isLoadingMore =
        Get.isRegistered<KaidhaSubscriptionController>() &&
            Get.find<KaidhaSubscriptionController>().isLoadingMoreQidhaStores;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      itemCount: stores.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= stores.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _primary,
                ),
              ),
            ),
          );
        }

        final store = stores[index];
        final bool isContracted = widget.isContractedOnly == true;
        final bool isRequested =
            store.id != null && requestedStoreIds.contains(store.id);

        return QidhaStoreCardWidget(
          store: store,
          isContracted: isContracted,
          isRequested: isRequested,
          onRequestSent: () {
            if (mounted) setState(() {});
          },
        );
      },
    );
  }
}
