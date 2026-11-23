import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import 'package:sixam_mart/features/employee/visits/controllers/store_visits_controller.dart';
import 'package:sixam_mart/features/employee/visits/domain/models/contract_activation_model.dart';
import 'package:sixam_mart/features/employee/visits/screens/contract_activation_screen.dart';

class StoresInActivationListScreen extends StatefulWidget {
  const StoresInActivationListScreen({super.key});

  @override
  State<StoresInActivationListScreen> createState() => _StoresInActivationListScreenState();
}

class _StoresInActivationListScreenState extends State<StoresInActivationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().loadInActivationContracts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color pageBg = isDark ? const Color(0xFF111827) : Colors.white;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color darkText = isDark ? Colors.white : const Color(0xFF111827);
    final Color subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text(
          'store_activation_followup_title'.tr,
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
            color: darkText,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<StoreVisitsController>(
        builder: (controller) {
          final contracts = controller.inActivationContracts;

          return RefreshIndicator(
            color: const Color(0xFF30913F),
            onRefresh: () => controller.loadInActivationContracts(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // Top Summary Header (Clean Figma layout without card box)
                        _buildSummaryHeader(contracts.length, isDark, darkText, subText),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Stores List
                if (controller.isInActivationListLoading && contracts.isEmpty)
                  SliverToBoxAdapter(
                    child: SkeletonLoadingWidgets.listCardsSkeleton(
                      isDark: isDark,
                      itemCount: 4,
                      cardHeight: 110,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  )
                else if (contracts.isEmpty)
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
                          final item = contracts[index];
                          // First card or urgent deadline card uses the expanded Figma 9777-11530 layout
                          final bool isUrgentFeatured = index == 0 || item.remainingDays <= 5 || item.timerColor == 'orange' || item.timerColor == 'red';
                          if (isUrgentFeatured && index == 0) {
                            return _buildFeaturedUrgentStoreCard(
                              context,
                              item,
                              isDark,
                              cardBg,
                              darkText,
                              subText,
                            );
                          }
                          return _buildStandardStoreCard(
                            context,
                            item,
                            isDark,
                            cardBg,
                            darkText,
                            subText,
                          );
                        },
                        childCount: contracts.length,
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

  /// Figma 9777-11530 Summary Header:
  /// Right in RTL: متابعة تفعيل العقود الموقعة + مهلة 30 يوماً...
  /// Left in RTL: Green rounded-square count badge (e.g. "3")
  Widget _buildSummaryHeader(
    int count,
    bool isDark,
    Color darkText,
    Color subText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Right in RTL: Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'active_contract_followups'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '30_days_activation_rule_desc'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Left in RTL: Rounded square green badge with count
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
            ),
          ),
        ),
      ],
    );
  }

  /// Featured / First Urgent Store Card matching Figma 9777-11530 top card
  Widget _buildFeaturedUrgentStoreCard(
    BuildContext context,
    ContractActivationModel item,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    final bool requiresPhoto = (item.standPhotoPath == null || item.standPhotoPath!.isEmpty) &&
        item.completedItems >= 2 &&
        item.completedItems < item.totalItems;
    final String warningText = requiresPhoto
        ? 'deadline_near_photo_warning'.tr
        : 'deadline_near_followup_warning'.tr;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => ContractActivationScreen(
                  storeId: item.storeId,
                  storeName: item.storeName,
                  contractNumber: item.contractNumber,
                ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top White Header Section
              Padding(
                padding: const EdgeInsets.all(14),
                child: _buildCardHeaderRow(item, isDark, darkText, subText),
              ),

              // 2. Middle Light-Green Progress & Remaining Time Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                color: isDark ? const Color(0xFF132A20) : const Color(0xFFECFDF5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Right in RTL: White rounded box with Calendar Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            IconlyLight.calendar,
                            color: Color(0xFF30913F),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Middle & Left: Remaining Time row + Completion Rate row
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'remaining_time_for_activation'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${item.remainingDays}',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF30913F),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'days_unit'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF30913F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'completion_rate_label'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                                    ),
                                  ),
                                  Text(
                                    '${item.progressPercentage}%',
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF30913F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item.progressPercentage / 100.0).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bottom Amber Warning Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: isDark ? const Color(0xFF2A241C) : const Color(0xFFFEF3C7).withValues(alpha: 0.65),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warningText,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Standard Store Card matching Figma 9777-11530 lower cards
  Widget _buildStandardStoreCard(
    BuildContext context,
    ContractActivationModel item,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => ContractActivationScreen(
                  storeId: item.storeId,
                  storeName: item.storeName,
                  contractNumber: item.contractNumber,
                ));
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1: Store Icon + Name + Contract Number (Right) & Status Badge (Left)
                _buildCardHeaderRow(item, isDark, darkText, subText),

                const SizedBox(height: 14),

                // Row 2: Right in RTL = Calendar icon + متبقي X أيام | Left in RTL = X%
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconlyLight.calendar,
                          size: 16,
                          color: subText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${'remaining_label'.tr} ',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subText,
                          ),
                        ),
                        Text(
                          '${item.remainingDays} ${'days_unit'.tr}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${item.progressPercentage}%',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF30913F),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 3: Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (item.progressPercentage / 100.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30913F)),
                  ),
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 10),

                // Row 4: Right in RTL = عرض تفاصيل التفعيل | Left in RTL = ←
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'view_activation_details'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30913F),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFF30913F),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeaderRow(
    ContractActivationModel item,
    bool isDark,
    Color darkText,
    Color subText,
  ) {
    final bool isRecentlyStarted = item.completedItems == 0 || item.elapsedDays <= 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Right in RTL: Store Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF143326) : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: Color(0xFF30913F),
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        // Middle: Store Name & Contract Number
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.storeName,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${'contract_number_label'.tr}  ${item.contractNumber}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Left in RTL: Status Pill Badge (قيد التفعيل / بدأ حديثاً)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isRecentlyStarted
                ? (isDark ? const Color(0xFF2E1F47) : const Color(0xFFEDE9FE))
                : (isDark ? const Color(0xFF143326) : const Color(0xFFDCFCE7)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isRecentlyStarted ? 'recently_started_badge'.tr : 'in_activation_badge'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isRecentlyStarted
                  ? (isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B21B6))
                  : (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Color darkText, Color subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
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
              child: Icon(IconlyLight.document, size: 36, color: subText),
            ),
            const SizedBox(height: 16),
            Text(
              'no_in_activation_stores'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'no_in_activation_stores_hint'.tr,
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
