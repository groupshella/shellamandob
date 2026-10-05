import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/supervisor_recommendations_controller.dart';
import '../models/supervisor_recommendation_model.dart';

class SupervisorRecommendationsScreen extends StatelessWidget {
  const SupervisorRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SupervisorRecommendationsController>()) {
      Get.put(SupervisorRecommendationsController());
    }

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final titleColor = isDark ? Colors.white : const Color(0xFF111B18);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: titleColor,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'supervisor_recommendations'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: GetBuilder<SupervisorRecommendationsController>(
              builder: (controller) {
                if (controller.isLoading && controller.recommendations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF30913F)),
                  );
                }

                if (controller.recommendations.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF30913F),
                    onRefresh: () => controller.loadRecommendations(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tips_and_updates_outlined,
                              size: 64,
                              color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_recommendations_yet'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final grouped = controller.groupedRecommendations;

                return RefreshIndicator(
                  color: const Color(0xFF30913F),
                  onRefresh: () => controller.loadRecommendations(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, groupIndex) {
                      final groupTitle = grouped.keys.elementAt(groupIndex);
                      final items = grouped[groupTitle] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date Header Label
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              groupTitle,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF707784),
                              ),
                            ),
                          ),

                          // Recommendations in this date group
                          ...items.map((item) => _buildRecommendationCard(
                                context,
                                item,
                                controller,
                                isDark,
                              )),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    SupervisorRecommendationModel item,
    SupervisorRecommendationsController controller,
    bool isDark,
  ) {
    final bool isExpanded = item.isExpanded;
    const primaryGreen = Color(0xFF30913F);
    final headerBg = isExpanded
        ? (isDark ? const Color(0xFF16321D) : const Color(0xFFEBFEEB))
        : (isDark ? const Color(0xFF1E232D) : const Color(0xFFF6F5F8));
    final titleColor = isDark ? Colors.white : const Color(0xFF111B18);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
    final timeColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded ? primaryGreen : headerBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.toggleExpand(item.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(16),
                    bottom: Radius.circular(isExpanded ? 0 : 16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Right side in RTL: Avatar
                    _buildAvatar(item.supervisorAvatar),
                    const SizedBox(width: 12),

                    // Middle details: Supervisor Name, Role, and Recommendation Category Tag
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.supervisorName,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.supervisorRole,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: subColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Left side in RTL: Time & Expand/Collapse Icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.timeText,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: timeColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: isExpanded ? primaryGreen : timeColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body Content (when expanded)
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    item.content,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    const double size = 42;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFA),
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/image/supervisor_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
