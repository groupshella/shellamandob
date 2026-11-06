import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import '../controllers/store_visits_controller.dart';
import 'active_store_visit_screen.dart';

/// Step 2: every store in the chosen neighborhood. Already-visited (claimed
/// by another rep) stores stay visible but disabled with a label, instead of
/// silently disappearing -- so it's clear why that option isn't tappable.
class NeighborhoodStoresScreen extends StatefulWidget {
  final String neighborhood;

  const NeighborhoodStoresScreen({super.key, required this.neighborhood});

  @override
  State<NeighborhoodStoresScreen> createState() => _NeighborhoodStoresScreenState();
}

class _NeighborhoodStoresScreenState extends State<NeighborhoodStoresScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<StoreVisitsController>().loadLeadsForNeighborhood(widget.neighborhood);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121418) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final disabledBg = isDark ? const Color(0xFF17191D) : const Color(0xFFF7F7F8);
    final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB);
    final headingText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            MarketerHeader(title: widget.neighborhood),
            Expanded(
              child: GetBuilder<StoreVisitsController>(
                builder: (controller) {
                  if (controller.isLoadingNeighborhoodLeads) {
                    return const Center(child: CircularProgressIndicator(color: _primaryGreen));
                  }
                  final leads = controller.neighborhoodLeads;
                  if (leads.isEmpty) {
                    return Center(
                      child: Text(
                        'no_stores_in_area'.tr,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: subText),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: leads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final lead = leads[index];
                      final isClaimed = lead['is_claimed'] == true;
                      final distance = (lead['distance_km'] as num?)?.toStringAsFixed(1);

                      return Opacity(
                        opacity: isClaimed ? 0.55 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isClaimed ? disabledBg : cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lead['name']?.toString() ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: headingText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        lead['address']?.toString() ?? '',
                                        if (distance != null) '$distance ${'km'.tr}',
                                      ].join(' · '),
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subText),
                                    ),
                                    if (isClaimed) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF3B2E15) : const Color(0x17F59E0B),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'visited_by_another_rep'.tr,
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: isClaimed
                                    ? null
                                    : () async {
                                        final controller = Get.find<StoreVisitsController>();
                                        final started = await controller.startVisitFromLead(lead);
                                        if (started && controller.activeVisit != null) {
                                          Get.to(() => ActiveStoreVisitScreen(visit: controller.activeVisit!));
                                        } else {
                                          // Someone may have just claimed it -- refresh the list.
                                          controller.loadLeadsForNeighborhood(widget.neighborhood);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGreen,
                                  disabledBackgroundColor: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  'start_visit'.tr,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
