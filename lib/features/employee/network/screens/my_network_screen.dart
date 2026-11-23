import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/employee/network/controllers/my_network_controller.dart';
import 'package:sixam_mart/features/employee/network/models/network_models.dart';
import 'package:sixam_mart/features/employee/network/screens/marketers_list_screen.dart';
import 'package:sixam_mart/features/employee/network/screens/sub_marketer_profile_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';

class MyNetworkScreen extends StatefulWidget {
  const MyNetworkScreen({super.key});

  @override
  State<MyNetworkScreen> createState() => _MyNetworkScreenState();
}

class _MyNetworkScreenState extends State<MyNetworkScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<MyNetworkController>().fetchNetworkData();
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
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        centerTitle: true,
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<MyNetworkController>(
        builder: (controller) {
          final overview = controller.overview;

          return RefreshIndicator(
            color: const Color(0xFF30913F),
            onRefresh: () => controller.fetchNetworkData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Cumulative Supervision Commission Hero Card
                  _buildSupervisionCommissionCard(overview, isDark, darkText),

                  const SizedBox(height: 12),

                  // 2. 2x2 Performance Grid
                  _build2x2Grid(overview, isDark, cardBg, darkText, subText),

                  const SizedBox(height: 14),

                  // 3. "بحاجة لمتابعة" Section + Bottom Action Button inside unified card
                  _buildNeedsFollowUpSection(
                    controller,
                    overview,
                    isDark,
                    cardBg,
                    darkText,
                    subText,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupervisionCommissionCard(
    NetworkOverviewModel? overview,
    bool isDark,
    Color darkText,
  ) {
    final double amount = overview?.monthlySupervisionCommission ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF2E1F47),
                  const Color(0xFF1E293B),
                  const Color(0xFF143326),
                ]
              : [
                  const Color(0xFFE9D5FF),
                  const Color(0xFFEDE9FE),
                  const Color(0xFFDCFCE7),
                ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'cumulative_supervision_commission'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SarCurrencyWidget(
                    size: 22,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    amount.toStringAsFixed(2),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF30913F),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build2x2Grid(
    NetworkOverviewModel? overview,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    final double directEarnings = overview?.directEarnings ?? 0.0;
    final int directCustomers = overview?.directCustomersCount ?? 0;
    final double teamEarnings = overview?.teamEarnings ?? 0.0;
    final int teamCustomers = overview?.teamCustomersCount ?? 0;
    final int activeCount = overview?.activeMarketersCount ?? 0;
    final int idleCount = overview?.idleMarketersCount ?? 0;
    final int todayCustomers = overview?.todayNetworkCustomers ?? 0;

    return Column(
      children: [
        // Row 1: Right = أرباحي المباشرة | Left = أرباح فريقي المباشر
        Row(
          children: [
            // أرباحي المباشرة (Right in RTL)
            Expanded(
              child: _buildEarningsCard(
                icon: IconlyLight.user2,
                iconColor: const Color(0xFF30913F),
                iconBg: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
                title: 'direct_earnings'.tr,
                rateText: '.50',
                subtitle: 'direct_earnings_sub'.tr,
                amount: directEarnings,
                valueColor: const Color(0xFF30913F),
                badgeText: '$directCustomers ${'client'.tr}',
                badgeBg: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
                badgeTextColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                isDark: isDark,
                cardBg: cardBg,
                darkText: darkText,
                subText: subText,
              ),
            ),
            const SizedBox(width: 10),
            // أرباح فريقي المباشر (Left in RTL)
            Expanded(
              child: _buildEarningsCard(
                icon: IconlyLight.user3,
                iconColor: const Color(0xFF6D28D9),
                iconBg: isDark ? const Color(0xFF2E1F47) : const Color(0xFFEDE9FE),
                title: 'direct_team_earnings'.tr,
                rateText: '.25',
                subtitle: 'direct_team_earnings_sub'.tr,
                amount: teamEarnings,
                valueColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF5B21B6),
                badgeText: '$teamCustomers ${'client'.tr}',
                badgeBg: isDark ? const Color(0xFF2E1F47) : const Color(0xFFEDE9FE),
                badgeTextColor: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B21B6),
                isDark: isDark,
                cardBg: cardBg,
                darkText: darkText,
                subText: subText,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 2: Right = المسوقين النشطين (Green tint) | Left = عملاء اليوم (Lavender tint)
        Row(
          children: [
            // المسوقين النشطين (Right in RTL)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132A20) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E4631) : const Color(0xFFDCFCE7),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'active_marketers_count'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activeCount',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF30913F),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$idleCount ${'idle_count'.tr}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // عملاء اليوم (Left in RTL)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF241B38) : const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3B2A5E) : const Color(0xFFEDE9FE),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'today_customers_count'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$todayCustomers',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF5B21B6),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'registered_via_your_network'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String rateText,
    required String subtitle,
    required double amount,
    required Color valueColor,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required bool isDark,
    required Color cardBg,
    required Color darkText,
    required Color subText,
  }) {
    final String formattedAmount = amount.truncateToDouble() == amount
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rateText,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(width: 2),
                SarCurrencyWidget(size: 9, color: darkText),
                const SizedBox(width: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: subText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SarCurrencyWidget(size: 16, color: valueColor),
                const SizedBox(width: 4),
                Text(
                  formattedAmount,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsFollowUpSection(
    MyNetworkController controller,
    NetworkOverviewModel? overview,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    final List<IdleMarketerSummaryModel> list = overview?.idleMarketers ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header: Right = بحاجة لمتابعة + subtitle | Left = عرض الكل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'needs_follow_up'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'not_registered_in_3_days'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: subText,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  Get.to(() => const MarketersListScreen(initialFilter: 'idle'));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'view_all'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subText,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (controller.isLoadingOverview && overview == null)
            Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SkeletonLoadingWidgets.shimmerBox(
                    height: 50,
                    width: double.infinity,
                    borderRadius: 10,
                    isDark: isDark,
                  ),
                ),
              ),
            )
          else if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'no_marketers_in_network'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: subText,
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                list.length > 3 ? 3 : list.length,
                (index) {
                  final item = list[index];
                  final isLast = index == (list.length > 3 ? 2 : list.length - 1);
                  return Column(
                    children: [
                      _buildIdleListItem(
                        item: item,
                        isDark: isDark,
                        darkText: darkText,
                        subText: subText,
                      ),
                      if (!isLast)
                        Divider(
                          height: 12,
                          thickness: 0.7,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                        ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 14),

          // Bottom Main Button "عرض كل المسوّقين"
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => const MarketersListScreen(initialFilter: 'all'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30913F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'view_all_marketers'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleListItem({
    required IdleMarketerSummaryModel item,
    required bool isDark,
    required Color darkText,
    required Color subText,
  }) {
    final String joinedText = _formatJoinedDate(item.joinedAt);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Get.to(
          () => SubMarketerProfileScreen(
            marketerId: item.marketerId,
            fallbackName: item.name,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Right in RTL: Avatar / First Letter Box
            _buildMarketerAvatar(item.name, item.avatar, isDark),
            const SizedBox(width: 10),

            // Middle: Name + Profession badge (Top) & Joined + Clients (Bottom/Side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.profession,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${'joined_on'.tr} $joinedText · ${'clients_count'.tr} ${item.customersCount}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: subText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),
            // Left in RTL: Trailing chevron arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: subText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketerAvatar(String name, String? avatarUrl, bool isDark) {
    final String trimmed = name.trim();
    final String initial = trimmed.isNotEmpty ? trimmed.characters.first : '-';

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty && avatarUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          avatarUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialBox(initial, isDark),
        ),
      );
    }

    return _buildInitialBox(initial, isDark);
  }

  Widget _buildInitialBox(String initial, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        ),
      ),
    );
  }

  String _formatJoinedDate(String? dt) {
    if (dt == null || dt.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dt);
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return '${parsed.day} ${months[parsed.month - 1]}';
    } catch (_) {
      return dt;
    }
  }
}
