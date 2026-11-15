import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/employee/network/controllers/my_network_controller.dart';
import 'package:sixam_mart/features/employee/network/widgets/supervised_marketer_card.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';

class MarketersListScreen extends StatefulWidget {
  final String initialFilter;

  const MarketersListScreen({super.key, this.initialFilter = 'all'});

  @override
  State<MarketersListScreen> createState() => _MarketersListScreenState();
}

class _MarketersListScreenState extends State<MarketersListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MyNetworkController>();
    if (widget.initialFilter != 'all') {
      controller.setFilter(widget.initialFilter);
    } else {
      if (controller.selectedFilter != 'all') {
        controller.setFilter('all');
      } else {
        controller.fetchMarketers();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color pageBg = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final Color headerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color darkText = isDark ? Colors.white : const Color(0xFF111827);
    final Color subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text(
          'marketers'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        centerTitle: true,
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkText,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<MyNetworkController>(
        builder: (controller) {
          return RefreshIndicator(
            color: const Color(0xFF30913F),
            onRefresh: () => controller.fetchMarketers(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Top white header area containing Search, Filter chips, and Count row
                SliverToBoxAdapter(
                  child: Container(
                    color: headerBg,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Compact Search Bar
                        _buildSearchField(controller, isDark, darkText, subText),

                        const SizedBox(height: 12),

                        // 2. Status Filter Chips
                        _buildFilterChips(controller, isDark, darkText, subText),

                        const SizedBox(height: 12),

                        // 3. Marketers count (Right in RTL) and Priority label (Left in RTL)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.marketers.length} ${'marketer_unit'.tr}',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                            if (controller.selectedFilter == 'all' || controller.selectedFilter == 'idle')
                              Text(
                                'priority_needs_followup'.tr,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: controller.selectedFilter == 'all'
                                      ? const Color(0xFFD97706)
                                      : subText,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 4. Marketers List
                if (controller.isLoadingList)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) => SkeletonLoadingWidgets.supervisedMarketerCardSkeleton(isDark: isDark),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (controller.marketers.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildEmptyState(isDark, darkText, subText),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final marketer = controller.marketers[index];
                          return SupervisedMarketerCard(marketer: marketer);
                        },
                        childCount: controller.marketers.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(
    MyNetworkController controller,
    bool isDark,
    Color darkText,
    Color subText,
  ) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => controller.setSearchQuery(val),
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 13,
          color: darkText,
        ),
        decoration: InputDecoration(
          hintText: 'search_name_profession_phone'.tr,
          hintStyle: TextStyle(
            fontFamily: 'Tajawal',
            color: subText,
            fontSize: 12,
          ),
          prefixIcon: Icon(IconlyLight.search, color: darkText, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    MyNetworkController controller,
    bool isDark,
    Color darkText,
    Color subText,
  ) {
    final filters = [
      {'key': 'all', 'label': 'all_filter'.tr},
      {'key': 'active', 'label': 'active_filter'.tr},
      {'key': 'idle', 'label': 'idle_filter'.tr},
      {'key': 'near_milestone', 'label': 'near_star_filter'.tr},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = controller.selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => controller.setFilter(f['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF30913F)
                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : subText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color darkText, Color subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(IconlyLight.user3, size: 36, color: subText),
            ),
            const SizedBox(height: 16),
            Text(
              'no_marketers_in_network'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'no_marketers_in_network_hint'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: subText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
