import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../api/api_client.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../../../../core/widgets/skeleton_loading_widgets.dart';
import '../models/zone_store_demand_model.dart';
import 'store_owner_pitch_screen.dart';

/// Zone Stores Demand Screen ("قائمة المتاجر") — Pixel-accurate match to Figma node 9971:8107:
/// - Gradient green banner (#155F2B -> #30913F -> #3EC856, height 157, radius 11)
/// - Overlapping floating white 3-metric KPI bar (radius 15, vertical #E5EBE6 dividers, #30913F numbers)
/// - #F6F5F8 search bar (radius 12)
/// - 4px-radius status filter chips (#30913F active / #F6F6F6 inactive)
/// - Count + Smart Sort row ("X متاجر ظاهرة" | "ترتيب تنازلياً حسب: الأعلى تسجيلاً")
/// - Clean white StoreCards (#E5E9E5 border, radius 16) with centered Black #30913F numbers
///   and top-bordered footer ("آخر تحديث: ..." | "عرض تقديمي ←")
class ZoneStoresDemandScreen extends StatefulWidget {
  const ZoneStoresDemandScreen({super.key});

  @override
  State<ZoneStoresDemandScreen> createState() => _ZoneStoresDemandScreenState();
}

class _ZoneStoresDemandScreenState extends State<ZoneStoresDemandScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = false;
  int? _selectedZoneId;
  String _selectedZoneName = '';
  String _statusFilter = 'all';
  String _sortBy = 'neighborhood';

  List<Map<String, dynamic>> _zones = [];
  List<ZoneStoreDemandModel> _stores = [];
  int _totalStores = 0;
  int _totalNeighborhood = 0;
  int _storesWithCustomers = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoading || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 220) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await _loadData(reset: false, targetPage: _currentPage + 1);
  }

  Future<void> _loadData({bool reset = true, int targetPage = 1}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = false;
      });
    }
    try {
      if (Get.isRegistered<ApiClient>()) {
        final params = <String>[
          'status=$_statusFilter',
          'sort_by=$_sortBy',
          'page=$targetPage',
          'per_page=15',
          if (_selectedZoneId != null) 'zone_id=$_selectedZoneId',
          if (_searchController.text.trim().isNotEmpty)
            'search=${Uri.encodeQueryComponent(_searchController.text.trim())}',
        ];
        final uri =
            '/api/v1/customer/marketer/zone-stores-demand?${params.join('&')}';
        final res = await Get.find<ApiClient>().getData(uri);
        if (res.statusCode == 200 && res.body?['data'] is Map) {
          final data = Map<String, dynamic>.from(res.body['data']);
          _selectedZoneId = data['zone_id'] != null
              ? int.tryParse('${data['zone_id']}')
              : _selectedZoneId;
          _selectedZoneName = data['zone_name']?.toString() ?? '';
          if (data['zones'] is List) {
            _zones = (data['zones'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          if (data['summary'] is Map) {
            final s = data['summary'];
            _totalStores = int.tryParse('${s['total_stores']}') ?? 0;
            _totalNeighborhood =
                int.tryParse('${s['total_neighborhood_customers']}') ?? 0;
            _storesWithCustomers =
                int.tryParse('${s['stores_with_customers']}') ??
                    _storesWithCustomers;
          }
          if (data['pagination'] is Map) {
            final p = data['pagination'];
            _currentPage = int.tryParse('${p['current_page']}') ?? targetPage;
            _hasMore = p['has_more'] == true;
          } else {
            _hasMore = false;
          }
          if (data['stores'] is List) {
            final fetched = (data['stores'] as List)
                .whereType<Map>()
                .map((e) =>
                    ZoneStoreDemandModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            if (reset) {
              _stores = fetched;
            } else {
              _stores.addAll(fetched);
            }
          }
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final searchBg =
            isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final chipInactiveBg =
            isDark ? const Color(0xFF252B37) : const Color(0xFFF6F6F6);
        final chipInactiveText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF68736A);
        final borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E9E5);
        final dividerColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE5EBE6);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/image/figma_arrow_right.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(darkText, BlendMode.srcIn),
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'stores_list_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: _primaryGreen,
              onRefresh: () => _loadData(reset: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Figma 9971:8474 Gradient Banner + Overlapping 9971:8494 Floating KPI Card
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Gradient Green Container (height 157, radius 11)
                            Container(
                              width: double.infinity,
                              height: 157,
                              padding: const EdgeInsets.fromLTRB(17, 22, 17, 0),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(11),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment(-0.75, -1.0),
                                  end: Alignment(0.75, 1.0),
                                  stops: [0.04, 0.64, 0.96],
                                  colors: [
                                    Color(0xFF155F2B),
                                    Color(0xFF30913F),
                                    Color(0xFF3EC856),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'pitch_ready_demand_subtitle'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _selectedZoneName.isNotEmpty
                                              ? _selectedZoneName
                                              : 'select_zone_label'.tr,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                      if (_zones.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          height: 28,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.25),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value: _zones.any((z) =>
                                                      z['id'] ==
                                                      _selectedZoneId)
                                                  ? _selectedZoneId
                                                  : null,
                                              dropdownColor: isDark
                                                  ? cardBg
                                                  : Colors.white,
                                              icon: SvgPicture.asset(
                                                'assets/image/figma_arrow_down.svg',
                                                width: 16,
                                                height: 16,
                                                colorFilter: const ColorFilter.mode(
                                                  Colors.white,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              items: _zones.map((z) {
                                                return DropdownMenuItem<int>(
                                                  value: int.tryParse(
                                                      '${z['id']}'),
                                                  child: Text(
                                                    z['name']?.toString() ?? '',
                                                    style: TextStyle(
                                                      fontFamily: 'Tajawal',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: darkText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              selectedItemBuilder: (_) => _zones
                                                  .map(
                                                    (_) => Center(
                                                      child: Text(
                                                        'select_zone_label'.tr,
                                                        style: const TextStyle(
                                                          fontFamily: 'Tajawal',
                                                          fontSize: 12.5,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (val) {
                                                if (val != null &&
                                                    val != _selectedZoneId) {
                                                  setState(() =>
                                                      _selectedZoneId = val);
                                                  _loadData();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'pitch_hero_headline'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          Colors.white.withValues(alpha: 0.88),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Floating White KPI Bar overlapping bottom edge (top: 123, height: 67, radius: 15)
                            Positioned(
                              left: 16,
                              right: 16,
                              top: 123,
                              child: Container(
                                height: 67,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black38
                                          : const Color(0x141D4024),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildFloatingKpi(
                                        value: '$_totalStores',
                                        label: 'total_stores_kpi'.tr,
                                        subText: subText,
                                      ),
                                    ),
                                    Container(
                                      width: 0.8,
                                      height: 38,
                                      color: dividerColor,
                                    ),
                                    Expanded(
                                      child: _buildFloatingKpi(
                                        value: '$_totalNeighborhood',
                                        label: 'neighborhood_market_kpi'.tr,
                                        subText: subText,
                                      ),
                                    ),
                                    Container(
                                      width: 0.8,
                                      height: 38,
                                      color: dividerColor,
                                    ),
                                    Expanded(
                                      child: _buildFloatingKpi(
                                        value: '$_storesWithCustomers',
                                        label: 'waiting_customers_short'.tr,
                                        subText: subText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Spacer for the overlapping floating KPI card (33px overlap + 18px gap)
                        const SizedBox(height: 50),

                        // 2. Search Bar (Figma 9971:8651 — #F6F5F8, height 52, radius 12)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Container(
                                height: 52,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: searchBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _searchController,
                                    onSubmitted: (_) => _loadData(),
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      color: darkText,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'search_store_hint'.tr,
                                      hintStyle: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFA2A6AF),
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: SvgPicture.asset(
                                          'assets/image/figma_search.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFFA2A6AF),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // 3. Status Filter Chips (Figma 9971:8662 — 4px radius)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip(
                                          'all',
                                          'all_filter'.tr,
                                          chipInactiveBg,
                                          chipInactiveText),
                                      const SizedBox(width: 8),
                                      _buildFilterChip(
                                          'not_contracted',
                                          'not_contracted_badge'.tr,
                                          chipInactiveBg,
                                          chipInactiveText),
                                      const SizedBox(width: 8),
                                      _buildFilterChip(
                                          'contracted',
                                          'contracted_badge'.tr,
                                          chipInactiveBg,
                                          chipInactiveText),
                                      const SizedBox(width: 8),
                                      _buildFilterChip(
                                          'active',
                                          'activated_badge'.tr,
                                          chipInactiveBg,
                                          chipInactiveText),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // 4. Count & Sort Row (Figma 9975:9558)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _sortBy = _sortBy == 'neighborhood'
                                            ? 'waiting'
                                            : 'neighborhood';
                                      });
                                      _loadData();
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          '${'smart_sort_label'.tr}: ',
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            color: subText,
                                          ),
                                        ),
                                        Text(
                                          _sortBy == 'neighborhood'
                                              ? 'sort_by_neighborhood_market'.tr
                                              : 'sort_by_waiting_customers'.tr,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${_stores.length} ${'total_stores_kpi'.tr}',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: darkText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Store Cards List (Figma 9973:8872)
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: SkeletonLoadingWidgets.listCardsSkeleton(
                        isDark: isDark,
                        itemCount: 5,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      ),
                    )
                  else if (_stores.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'no_stores_in_zone'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: subText,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == _stores.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildStoreCard(
                                store: _stores[index],
                                isDark: isDark,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                darkText: darkText,
                                subText: subText,
                              ),
                            );
                          },
                          childCount:
                              _stores.length + (_isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingKpi({
    required String value,
    required String label,
    required Color subText,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _primaryGreen,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: subText,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String key,
    String label,
    Color inactiveBg,
    Color inactiveText,
  ) {
    final selected = _statusFilter == key;
    return GestureDetector(
      onTap: () {
        if (_statusFilter != key) {
          setState(() => _statusFilter = key);
          _loadData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? _primaryGreen : inactiveBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : inactiveText,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard({
    required ZoneStoreDemandModel store,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color darkText,
    required Color subText,
  }) {
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    switch (store.contractStatus) {
      case 'active':
        badgeBg = isDark ? const Color(0xFF132D1B) : const Color(0xFFEBFEEB);
        badgeText = _primaryGreen;
        badgeLabel = 'activated_badge'.tr;
        break;
      case 'contracted':
        badgeBg = isDark ? const Color(0xFF2C203E) : const Color(0xFFDFD3F5);
        badgeText = const Color(0xFF7861A6);
        badgeLabel = 'contracted_badge'.tr;
        break;
      default:
        badgeBg = isDark ? const Color(0xFF3B2E15) : const Color(0xFFFFF5DF);
        badgeText = const Color(0xFFB87516);
        badgeLabel = 'not_contracted_badge'.tr;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Shop Icon (#F0FAF2) + Store Name | Status Pill (radius 999)
          Row(
            children: [
              Container(
                width: 38,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF132D1B)
                      : const Color(0xFFF0FAF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/image/figma_shop.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  store.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 2: Centered Clean Big Green Numbers (Figma 9973:8797 — NO heavy boxes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCleanMetric(
                value: '${store.nearbyCustomers2km}',
                label: 'neighborhood_2km_short'.tr,
                subText: subText,
              ),
              _buildCleanMetric(
                value: '${store.waitingCustomersCount}',
                label: 'waiting_customers_short'.tr,
                subText: subText,
              ),
              _buildCleanMetric(
                value: '${store.storeMarketersCount}',
                label: 'store_marketers_short'.tr,
                subText: subText,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Top-Bordered Footer Action Row (Figma 9973:8756)
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    store.address.isNotEmpty
                        ? store.address
                        : _selectedZoneName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF8B948D),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      Get.to(() => StoreOwnerPitchScreen(store: store)),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'owner_pitch_btn'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF247832),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/image/figma_pitch_arrow.svg',
                          width: 18,
                          height: 18,
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

  Widget _buildCleanMetric({
    required String value,
    required String label,
    required Color subText,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: _primaryGreen,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: subText,
          ),
        ),
      ],
    );
  }
}
