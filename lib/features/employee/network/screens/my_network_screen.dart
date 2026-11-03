import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/employee/network/controllers/my_network_controller.dart';
import 'package:sixam_mart/features/employee/network/widgets/supervised_marketer_card.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

class MyNetworkScreen extends StatefulWidget {
  const MyNetworkScreen({super.key});

  @override
  State<MyNetworkScreen> createState() => _MyNetworkScreenState();
}

class _MyNetworkScreenState extends State<MyNetworkScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<MyNetworkController>().fetchNetworkData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color pageBg = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color darkText = isDark ? Colors.white : const Color(0xFF111827);
    final Color subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text(
          'my_network'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        centerTitle: true,
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkText, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<MyNetworkController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchNetworkData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // 1. Top KPI Summary Cards (Matching Figma 8949:41979 style)
                  _buildKpiSection(controller, isDark, cardBg, darkText, subText),

                  const SizedBox(height: 14),

                  // 2. Search Field (Matching App Material Style)
                  _buildSearchField(controller, isDark, cardBg, darkText, subText),

                  const SizedBox(height: 14),

                  // 3. Filter Tabs (All / Active / Idle / Near Star)
                  _buildFilterChips(controller, isDark, cardBg, darkText, subText),

                  const SizedBox(height: 14),

                  // 4. Marketers List
                  if (controller.isLoadingList)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF30913F)),
                      ),
                    )
                  else if (controller.marketers.isEmpty)
                    _buildEmptyState(isDark, darkText, subText)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.marketers.length,
                      itemBuilder: (ctx, index) {
                        final marketer = controller.marketers[index];
                        return SupervisedMarketerCard(marketer: marketer);
                      },
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiSection(
    MyNetworkController controller,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    final overview = controller.overview;

    return Column(
      children: [
        Row(
          children: [
            // Active Sub-Marketers KPI Card
            Expanded(
              child: _buildKpiCard(
                title: 'active_marketers'.tr,
                value: overview != null ? '${overview.activeMarketersCount} / ${overview.totalSubMarketers}' : '...',
                badgeText: overview != null ? '${overview.idleMarketersCount} ${'idle'.tr}' : '',
                icon: IconlyBold.user3,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                cardBg: cardBg,
                darkText: darkText,
                subText: subText,
              ),
            ),
            const SizedBox(width: 12),
            // Today's Customers KPI Card
            Expanded(
              child: _buildKpiCard(
                title: 'today_customers'.tr,
                value: overview != null ? '${overview.todayNetworkCustomers}' : '...',
                badgeText: 'registered_via_network'.tr,
                icon: IconlyBold.addUser,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
                cardBg: cardBg,
                darkText: darkText,
                subText: subText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Monthly Supervision Commission Card (Clean Figma Card with Green Soft Accent)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000), // rgba(0,0,0,0.05)
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B3322) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(IconlyBold.wallet, color: Color(0xFF30913F), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'monthly_supervision_earnings'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          overview != null ? overview.monthlySupervisionCommission.toStringAsFixed(2) : '0.00',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF30913F),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const SarCurrencyWidget(size: 14, color: Color(0xFF30913F)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B3322) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '0.50 ${'sar_per_first_order'.tr}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30913F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String badgeText,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color cardBg,
    required Color darkText,
    required Color subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subText,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          if (badgeText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: subText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(
    MyNetworkController controller,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => controller.setSearchQuery(val),
        style: TextStyle(fontSize: 14, color: darkText),
        decoration: InputDecoration(
          hintText: 'search_marketer_hint'.tr,
          hintStyle: TextStyle(color: subText, fontSize: 13),
          prefixIcon: Icon(IconlyLight.search, color: subText, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    MyNetworkController controller,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    final filters = [
      {'key': 'all', 'label': 'all'.tr},
      {'key': 'active', 'label': 'active'.tr},
      {'key': 'idle', 'label': 'idle_alert'.tr},
      {'key': 'near_milestone', 'label': 'near_star'.tr},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = controller.selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.setFilter(f['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF30913F)
                      : (isDark ? const Color(0xFF1E293B) : cardBg),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x3330913F),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
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
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(IconlyLight.user3, size: 36, color: subText),
            ),
            const SizedBox(height: 16),
            Text(
              'no_marketers_in_network'.tr,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkText),
            ),
            const SizedBox(height: 8),
            Text(
              'no_marketers_in_network_hint'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: subText),
            ),
          ],
        ),
      ),
    );
  }
}
