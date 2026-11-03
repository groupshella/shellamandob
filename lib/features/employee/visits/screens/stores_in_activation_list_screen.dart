import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
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
    final Color pageBg = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color darkText = isDark ? Colors.white : const Color(0xFF111827);
    final Color subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text(
          'stores_in_activation_title'.tr,
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
      body: GetBuilder<StoreVisitsController>(
        builder: (controller) {
          final contracts = controller.inActivationContracts;

          return RefreshIndicator(
            color: const Color(0xFF30913F),
            onRefresh: () => controller.loadInActivationContracts(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Top Header Card (Summary)
                  _buildSummaryHeader(contracts.length, isDark, cardBg, darkText, subText),

                  const SizedBox(height: 16),

                  // Stores List
                  if (contracts.isEmpty)
                    _buildEmptyState(isDark, darkText, subText)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contracts.length,
                      itemBuilder: (ctx, index) {
                        final item = contracts[index];
                        return _buildStoreCard(context, item, isDark, cardBg, darkText, subText);
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

  Widget _buildSummaryHeader(
    int count,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    return Container(
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B3322) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(IconlyBold.document, color: Color(0xFF30913F), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'active_contract_followups'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '30_days_activation_rule_desc'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: subText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count ${'stores_label'.tr}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF30913F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    ContractActivationModel item,
    bool isDark,
    Color cardBg,
    Color darkText,
    Color subText,
  ) {
    // Timer color handling
    Color timerBg;
    Color timerFg;
    if (item.timerColor == 'red') {
      timerBg = isDark ? const Color(0xFF3B1F2B) : const Color(0xFFFEE2E2);
      timerFg = const Color(0xFFDC2626);
    } else if (item.timerColor == 'orange') {
      timerBg = isDark ? const Color(0xFF2A241C) : const Color(0xFFFFFBEB);
      timerFg = const Color(0xFFD97706);
    } else {
      timerBg = isDark ? const Color(0xFF1B3322) : const Color(0xFFE8F5E9);
      timerFg = const Color(0xFF30913F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.to(() => ContractActivationScreen(
                  storeId: item.storeId,
                  storeName: item.storeName,
                  contractNumber: item.contractNumber,
                ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1: Store Icon + Store Name + Contract Number + Arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B3322) : const Color(0xFFE8F5E9),
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
                            item.storeName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${'contract_number_label'.tr}: ${item.contractNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subText),
                  ],
                ),

                const SizedBox(height: 14),

                // Row 2: Countdown Timer Capsule
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: timerBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(IconlyBold.timeCircle, size: 16, color: timerFg),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.timerStatusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: timerFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Row 3: Progress percentage & Completed Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'activation_checklist_progress'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B3322) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.completedItems}/${item.totalItems} ${'items_completed'.tr} (${item.progressPercentage}%)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF30913F),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (item.progressPercentage / 100.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.progressPercentage >= 100
                          ? const Color(0xFF10B981)
                          : const Color(0xFF30913F),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action Callout
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'tap_to_view_checklist'.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF30913F),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_left_rounded, size: 16, color: Color(0xFF30913F)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkText),
            ),
            const SizedBox(height: 8),
            Text(
              'no_in_activation_stores_hint'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: subText),
            ),
          ],
        ),
      ),
    );
  }
}

