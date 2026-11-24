import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/employee/network/controllers/my_network_controller.dart';
import 'package:sixam_mart/features/employee/network/models/network_models.dart';
import 'package:sixam_mart/features/employee/network/screens/marketers_list_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_drivers_list_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_driver_profile_screen.dart';
import 'package:sixam_mart/features/employee/network/screens/add_driver_lead_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class FreelanceNetworkScreen extends StatefulWidget {
  final bool isRoot;
  const FreelanceNetworkScreen({super.key, this.isRoot = false});

  @override
  State<FreelanceNetworkScreen> createState() => _FreelanceNetworkScreenState();
}

class _FreelanceNetworkScreenState extends State<FreelanceNetworkScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<MyNetworkController>()) {
      Get.find<MyNetworkController>().fetchNetworkData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().darkTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pageBg = isDark ? const Color(0xFF121418) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final textDark = isDark ? Colors.white : _darkText;
    final textSub = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.isRoot,
        leading: widget.isRoot
            ? null
            : IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  isRtl ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2,
                  color: textDark,
                ),
              ),
        title: Text(
          'my_network'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<MyNetworkController>(
          builder: (c) {
            if (c.isLoadingOverview && c.overview == null) {
              return SkeletonLoadingWidgets.vacationsSkeleton(isDark: isDark);
            }
            final overview = c.overview;

            return RefreshIndicator(
              color: _primaryGreen,
              onRefresh: c.fetchNetworkData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top 3 Decorative Stat Cards (Figma 10055:45556)
                    _buildTopThreeCards(overview, isDark, cardBg, textDark, textSub),
                    const SizedBox(height: 14),

                    // 2. Ring Progress Cards (Active Marketers & Today Customers)
                    _buildRingCards(overview, isDark, cardBg, textDark, textSub),
                    const SizedBox(height: 14),

                    // 3. Marketers Needing Follow-up Section
                    _buildNeedsFollowUpSection(c, overview, isDark, cardBg, textDark, textSub, borderColor),
                    const SizedBox(height: 14),

                    // 4. Added Drivers Section (Figma 10055:45556)
                    _buildAddedDriversSection(overview, isDark, cardBg, textDark, textSub, borderColor),
                    SizedBox(height: widget.isRoot ? 90 : 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------- 1. Top 3 Decorative Stat Cards
  Widget _buildTopThreeCards(
    NetworkOverviewModel? overview,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
  ) {
    final growthCount = overview?.growthSpecialistsCount ?? 0;
    final marketerCount = overview?.freelanceMarketersCount ?? (overview?.totalSubMarketers ?? 0);
    final driverCount = overview?.driversCount ?? (overview?.addedDrivers.length ?? 0);

    return Row(
      children: [
        // Card 1: أخصائي تسويق (Right in RTL)
        Expanded(
          child: Container(
            height: 92,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16362C) : const Color(0xFFD1FDEF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/image/figma_freelance_marketer/registration_user.svg',
                      width: 22,
                      height: 22,
                    ),
                    Text(
                      '$growthCount',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                Text(
                  'growth_specialist_badge'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 2: مسوق (Middle in RTL)
        Expanded(
          child: Container(
            height: 92,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162D1D) : const Color(0xFFEBFEEB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/image/figma_freelance_marketer/nav_people_bold.svg',
                      width: 22,
                      height: 22,
                    ),
                    Text(
                      '$marketerCount',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _primaryGreen,
                      ),
                    ),
                  ],
                ),
                Text(
                  'voucher_marketer'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 3: السائقين (Left in RTL) -> Navigates to drivers list
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const MarketerDriversListScreen()),
            child: Container(
              height: 92,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF261B3D) : const Color(0xFFEFE6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/image/figma_freelance_marketer/truck_driver.svg',
                        width: 22,
                        height: 22,
                      ),
                      Text(
                        '$driverCount',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'drivers_label'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF6B21A8),
                        ),
                      ),
                      const Icon(IconlyLight.arrowLeft2, size: 12, color: Color(0xFF8B5CF6)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------- 2. Ring Progress Cards
  Widget _buildRingCards(
    NetworkOverviewModel? overview,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
  ) {
    final active = overview?.activeMarketersCount ?? 0;
    final total = overview?.totalSubMarketers ?? 0;
    final activePct = total > 0 ? (active / total).clamp(0.0, 1.0) : 0.0;
    final todayCust = overview?.todayNetworkCustomers ?? 0;

    return Row(
      children: [
        // Ring 1: المسوقون النشطون
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: activePct > 0 ? activePct : 0.05,
                        strokeWidth: 4,
                        backgroundColor: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
                      ),
                      Center(
                        child: Text(
                          '${(activePct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'active_marketers_stat'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$active / $total',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Ring 2: عملاء اليوم
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: (todayCust / 50).clamp(0.05, 1.0),
                        strokeWidth: 4,
                        backgroundColor: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      ),
                      Center(
                        child: Text(
                          '$todayCust',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'today_customers'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'customer'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------- 3. Marketers Needing Follow-up Section
  Widget _buildNeedsFollowUpSection(
    MyNetworkController controller,
    NetworkOverviewModel? overview,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
    Color borderColor,
  ) {
    final idleMarketers = overview?.idleMarketers ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'marketers_needing_followup'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              if (idleMarketers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B1D1D) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${idleMarketers.length}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (idleMarketers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'all_marketers_active_good'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: textSub,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: idleMarketers.length > 3 ? 3 : idleMarketers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = idleMarketers[index];
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          m.name.isNotEmpty ? m.name[0] : 'M',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${'last_referrals'.tr}: ${m.customersCount}',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              color: textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (m.phone != null && m.phone!.isNotEmpty)
                      IconButton(
                        onPressed: () async {
                          final uri = Uri.parse('https://wa.me/${m.phone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(IconlyLight.chat, size: 20, color: _primaryGreen),
                      ),
                  ],
                );
              },
            ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Get.to(() => const MarketersListScreen()),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'view_all_marketers'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------- 4. Added Drivers Section (Figma 10055:45556)
  Widget _buildAddedDriversSection(
    NetworkOverviewModel? overview,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
    Color borderColor,
  ) {
    final drivers = overview?.addedDrivers ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'drivers_added_by_you'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const MarketerDriversListScreen()),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text(
                  'view_all'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'no_drivers_added_yet'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        color: textSub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => Get.to(() => const AddDriverLeadScreen()),
                      icon: const Icon(IconlyLight.plus, size: 16, color: _primaryGreen),
                      label: Text(
                        'add_driver_btn'.tr,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: _primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: drivers.length > 3 ? 3 : drivers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final d = drivers[index];
                return GestureDetector(
                  onTap: () => Get.to(() => MarketerDriverProfileScreen(driverId: d.id, driverName: d.name)),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF261B3D) : const Color(0xFFEFE6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(IconlyBold.user2, color: Color(0xFF8B5CF6), size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${d.customersCount} ${'customer'.tr} • ${d.joinedAtText ?? ''}',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11,
                                  color: textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              d.returnAmount.toStringAsFixed(2),
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(width: 2),
                            SarCurrencyWidget(size: 10, color: textDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
