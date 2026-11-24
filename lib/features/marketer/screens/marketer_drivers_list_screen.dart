import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/employee/network/screens/add_driver_lead_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_driver_profile_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:sixam_mart/util/app_constants.dart';

class MarketerDriversListScreen extends StatefulWidget {
  const MarketerDriversListScreen({super.key});

  @override
  State<MarketerDriversListScreen> createState() => _MarketerDriversListScreenState();
}

class _MarketerDriversListScreenState extends State<MarketerDriversListScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  bool _isLoading = true;
  List<Map<String, dynamic>> _drivers = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDrivers([String? search]) async {
    setState(() => _isLoading = true);
    try {
      String uri = AppConstants.marketerDriverLeadsUri;
      if (search != null && search.trim().isNotEmpty) {
        uri += '?search=${Uri.encodeComponent(search.trim())}';
      }
      final res = await Get.find<ApiClient>().getData(uri, handleError: false);
      if (res.statusCode == 200 && res.body is Map && res.body['data'] is Map) {
        final d = Map<String, dynamic>.from(res.body['data'] as Map);
        if (mounted) {
          setState(() {
            _drivers = (d['drivers'] as List? ?? [])
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        leading: IconButton(
          icon: Icon(
            isRtl ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2,
            color: textDark,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'drivers_list_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const AddDriverLeadScreen())?.then((_) => _fetchDrivers()),
            icon: const Icon(IconlyLight.plus, color: _primaryGreen),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar (Figma 10055:44144)
            Container(
              color: cardBg,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _fetchDrivers(val);
                  },
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: textDark,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: SvgPicture.asset(
                      'assets/image/figma_freelance_marketer/search_outline.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(textSub, BlendMode.srcIn),
                    ),
                    hintText: 'search_drivers_hint'.tr,
                    hintStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      color: textSub,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? SkeletonLoadingWidgets.vacationsSkeleton(isDark: isDark)
                  : RefreshIndicator(
                      color: _primaryGreen,
                      onRefresh: () => _fetchDrivers(_searchQuery),
                      child: _drivers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconlyLight.user2, size: 54, color: textSub.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'no_drivers_found'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textSub,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => Get.to(() => const AddDriverLeadScreen())?.then((_) => _fetchDrivers()),
                                    icon: const Icon(IconlyLight.plus, size: 18),
                                    label: Text('add_driver_btn'.tr),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _drivers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final d = _drivers[index];
                                final id = (d['id'] as num?)?.toInt() ?? 0;
                                final name = (d['name'] ?? 'driver_label'.tr).toString();
                                final phone = (d['phone'] ?? '').toString();
                                final joined = (d['joined_at_text'] ?? '').toString();
                                final customersCount = (d['customers_count'] as num?)?.toInt() ?? 0;
                                final returnAmount = (d['return_amount'] as num?)?.toDouble() ?? 0.0;

                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => MarketerDriverProfileScreen(driverId: id, driverName: name),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: borderColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF261B3D) : const Color(0xFFEFE6FF),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                                          ),
                                          child: const Center(
                                            child: Icon(IconlyBold.user2, color: Color(0xFF8B5CF6), size: 24),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                phone,
                                                style: TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 12,
                                                  color: textSub,
                                                ),
                                              ),
                                              if (joined.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${'joined_date_label'.tr}: $joined',
                                                  style: TextStyle(
                                                    fontFamily: 'Tajawal',
                                                    fontSize: 10,
                                                    color: textSub,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '$customersCount ${'customers_count_short'.tr}',
                                                style: const TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: _primaryGreen,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${'your_return_label'.tr}: ${returnAmount.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontFamily: 'Tajawal',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: textDark,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                SarCurrencyWidget(size: 10, color: textDark),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          isRtl ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
                                          size: 16,
                                          color: textSub,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
