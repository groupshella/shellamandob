import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import '../controllers/store_visits_controller.dart';
import 'neighborhood_stores_screen.dart';

/// Step 1 of starting a visit: pick which area to work, then (on the next
/// screen) pick a specific store in it. Replaces the old single
/// auto-suggested-nearest-store flow with an explicit, browsable choice.
class NeighborhoodPickerScreen extends StatefulWidget {
  const NeighborhoodPickerScreen({super.key});

  @override
  State<NeighborhoodPickerScreen> createState() => _NeighborhoodPickerScreenState();
}

class _NeighborhoodPickerScreenState extends State<NeighborhoodPickerScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<StoreVisitsController>().loadNeighborhoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121418) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB);
    final headingText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            MarketerHeader(title: 'choose_area_to_visit'.tr),
            Expanded(
              child: GetBuilder<StoreVisitsController>(
                builder: (controller) {
                  if (controller.isLoadingNeighborhoods) {
                    return const Center(child: CircularProgressIndicator(color: _primaryGreen));
                  }
                  final neighborhoods = controller.neighborhoods;
                  if (neighborhoods.isEmpty) {
                    return Center(
                      child: Text(
                        'no_areas_available'.tr,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: subText),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: neighborhoods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = neighborhoods[index];
                      final available = (n['available'] as num?)?.toInt() ?? 0;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Get.to(() => NeighborhoodStoresScreen(
                              neighborhood: n['name']?.toString() ?? '',
                            )),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBg,
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
                                      n['name']?.toString() ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: headingText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$available ${'stores_available'.tr}',
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: subText),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_left_rounded, color: _primaryGreen),
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
