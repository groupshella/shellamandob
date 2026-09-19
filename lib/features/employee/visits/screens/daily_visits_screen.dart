import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'store_visit_detail_screen.dart';

class DailyVisitsScreen extends StatelessWidget {
  const DailyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoreVisitsController>()) {
      Get.put(StoreVisitsController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'daily_visits_agenda'.tr,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Refresh action
            },
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF30913F)),
          ),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<StoreVisitsController>(
          builder: (controller) {
            final visits = controller.filteredVisits;

            return CustomScrollView(
              slivers: [
                // 1. Daily Target Header Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF30913F), Color(0xFF1F632B)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF30913F).withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.track_changes_rounded, color: Colors.white, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'daily_target_indicator'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${'target_visits_label'.tr}: ${StoreVisitsController.dailyTargetVisits}',
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'qualified_completed_visits'.tr}: ${controller.qualifiedVisitsCount}',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(controller.dailyProgressPercentage * 100).toInt()}%',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: controller.dailyProgressPercentage,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Filter Tabs
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: '${'all_visits'.tr} (${controller.allVisits.length})',
                          index: 0,
                          controller: controller,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: '${'status_scheduled'.tr} (${controller.allVisits.where((v) => v.visitStatus == StoreVisitStatus.scheduled).length})',
                          index: 1,
                          controller: controller,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: '${'status_completed'.tr} (${controller.completedVisitsCount})',
                          index: 2,
                          controller: controller,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: '${'status_follow_up'.tr} (${controller.followUpVisitsCount})',
                          index: 3,
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // 3. Visits List
                if (visits.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'no_visits_found'.tr,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final visit = visits[index];
                          return _buildVisitCard(context, visit);
                        },
                        childCount: visits.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int index,
    required StoreVisitsController controller,
  }) {
    final isSelected = controller.selectedFilterIndex == index;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF4B5563),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF30913F),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF30913F) : const Color(0xFFE5E7EB),
        ),
      ),
      onSelected: (_) => controller.setFilterIndex(index),
    );
  }

  Widget _buildVisitCard(BuildContext context, StoreVisitModel visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: visit.visitStatus == StoreVisitStatus.inProgress
              ? const Color(0xFFF59E0B)
              : const Color(0xFFE5E7EB),
          width: visit.visitStatus == StoreVisitStatus.inProgress ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Name & Status Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF30913F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_rounded, color: Color(0xFF30913F), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.storeName,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${visit.category} • ${visit.address}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: visit.visitStatus.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit.visitStatus.localizedTitle,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: visit.visitStatus.color,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20, color: Color(0xFFF3F4F6)),

          // Info row: Contact Person, Distance, Pipeline step
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  visit.managerName,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF4B5563)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.near_me_outlined, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(
                '${visit.distanceKm} ${'distance_km'.tr}',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF4B5563)),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.schedule, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(
                visit.localizedTimeSlot,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Pipeline status chip & Action CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: visit.pipelineStep.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(visit.pipelineStep.icon, size: 14, color: visit.pipelineStep.color),
                    const SizedBox(width: 4),
                    Text(
                      visit.pipelineStep.localizedLabel,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: visit.pipelineStep.color,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => StoreVisitDetailScreen(visit: visit));
                },
                icon: Icon(
                  visit.visitStatus == StoreVisitStatus.completed ? Icons.edit_note_rounded : Icons.play_arrow_rounded,
                  size: 16,
                ),
                label: Text(
                  visit.visitStatus == StoreVisitStatus.completed ? 'view_report'.tr : 'visit_now'.tr,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30913F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
