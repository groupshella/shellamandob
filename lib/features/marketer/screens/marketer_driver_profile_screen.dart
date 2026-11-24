import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:sixam_mart/util/app_constants.dart';

class MarketerDriverProfileScreen extends StatefulWidget {
  final int driverId;
  final String? driverName;

  const MarketerDriverProfileScreen({
    super.key,
    required this.driverId,
    this.driverName,
  });

  @override
  State<MarketerDriverProfileScreen> createState() => _MarketerDriverProfileScreenState();
}

class _MarketerDriverProfileScreenState extends State<MarketerDriverProfileScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  bool _isLoading = true;
  Map<String, dynamic>? _driverData;
  List<Map<String, dynamic>> _registrations = [];

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }

  Future<void> _fetchDriverDetails() async {
    setState(() => _isLoading = true);
    try {
      final res = await Get.find<ApiClient>().getData(
        '${AppConstants.marketerDriverLeadsUri}/${widget.driverId}',
        handleError: false,
      );
      if (res.statusCode == 200 && res.body is Map && res.body['data'] is Map) {
        final d = Map<String, dynamic>.from(res.body['data'] as Map);
        if (mounted) {
          setState(() {
            _driverData = d['driver'] != null ? Map<String, dynamic>.from(d['driver'] as Map) : null;
            _registrations = (d['registrations'] as List? ?? [])
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

    final name = (_driverData?['name'] ?? widget.driverName ?? 'driver_label'.tr).toString();
    final phone = (_driverData?['phone'] ?? '').toString();
    final joinedAt = (_driverData?['joined_at_text'] ?? '').toString();
    final vehicleType = (_driverData?['vehicle_type_label'] ?? 'vehicle_sedan'.tr).toString();
    final customersCount = (_driverData?['customers_count'] as num?)?.toInt() ?? 0;
    final returnAmount = (_driverData?['return_amount'] as num?)?.toDouble() ?? 0.0;

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
          'driver_profile_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
      body: _isLoading
          ? SkeletonLoadingWidgets.vacationsSkeleton(isDark: isDark)
          : RefreshIndicator(
              color: _primaryGreen,
              onRefresh: _fetchDriverDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Driver Profile Hero Card (Figma 10055:43744)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF261B3D) : const Color(0xFFEFE6FF),
                              border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(IconlyBold.user2, color: Color(0xFF8B5CF6), size: 32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              color: textSub,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  vehicleType,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryGreen,
                                  ),
                                ),
                              ),
                              if (joinedAt.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${'joined_date_label'.tr}: $joinedAt',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: textSub,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Dual Stats Cards (Registered Customers & Return Amount)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'registered_customers_count'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: textSub,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$customersCount ${'customer'.tr}',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'total_driver_return'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: textSub,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    SarCurrencyWidget(size: 14, color: textDark),
                                    const SizedBox(width: 4),
                                    Text(
                                      returnAmount.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Registrations Log Title (Figma 10055:43744)
                    Text(
                      'registrations_log_title'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_registrations.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(IconlyLight.user2, size: 40, color: textSub.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text(
                              'no_driver_registrations_yet'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: textSub,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _registrations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _registrations[index];
                          final customerName = (item['customer_name'] ?? 'customer'.tr).toString();
                          final date = (item['date'] ?? '').toString();
                          final reward = (item['commission'] as num?)?.toDouble() ?? 0.50;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(IconlyLight.user2, size: 18, color: _primaryGreen),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customerName,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: textDark,
                                        ),
                                      ),
                                      if (date.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          date,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            color: textSub,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '+${reward.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const SarCurrencyWidget(size: 11, color: _primaryGreen),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
