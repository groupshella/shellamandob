// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/core/widgets/skeleton_loading_widgets.dart';
import '../controllers/store_visits_controller.dart';
import '../domain/models/contract_activation_model.dart';
import 'store_customer_preview_screen.dart';

class ContractActivationScreen extends StatefulWidget {
  final int storeId;
  final String storeName;
  final String contractNumber;

  const ContractActivationScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.contractNumber,
  });

  @override
  State<ContractActivationScreen> createState() => _ContractActivationScreenState();
}

class _ContractActivationScreenState extends State<ContractActivationScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        final ctrl = Get.find<StoreVisitsController>();
        ctrl.loadContractActivation(
          widget.storeId,
          contractNumber: widget.contractNumber,
        );
        ctrl.checkFirstOrderStatus(widget.storeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final bool isDark = themeController.darkTheme;
        final bool isRtl = Directionality.of(context) == TextDirection.rtl;
        final Color screenBg = isDark ? const Color(0xFF111827) : Colors.white;
        final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color textDark = isDark ? Colors.white : const Color(0xFF111B18);
        final Color textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF555555);
        final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E9E5);

        return Scaffold(
          backgroundColor: screenBg,
          appBar: AppBar(
            title: Text(
              'store_activation_details_title'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            centerTitle: true,
            backgroundColor: cardBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: isRtl ? Matrix4.identity() : Matrix4.rotationY(math.pi),
                child: SvgPicture.asset(
                  'assets/image/figma_activation_arrow_right.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(textDark, BlendMode.srcIn),
                ),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: GetBuilder<StoreVisitsController>(
            builder: (controller) {
              if (controller.isActivationLoading) {
                return SkeletonLoadingWidgets.visitDetailSkeleton(isDark: isDark);
              }

              final activation = controller.currentActivation;
              if (activation == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: textSub),
                      const SizedBox(height: 16),
                      Text(
                        'no_activation_data'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: textSub,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.loadContractActivation(
                          widget.storeId,
                          contractNumber: widget.contractNumber,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF30913F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'retry'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Store Summary & Countdown Card (Figma 9779-56448 / 9781-57295)
                    _buildHeaderCard(activation, isDark, cardBg, textDark, textSub, borderColor),
                    const SizedBox(height: 20),

                    // 2. Section Header: Right = خطوات التفعيل | Left = 3/7 badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'activation_steps_title'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF143326) : const Color(0xFFDEF4E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${activation.completedItems}/${activation.totalItems}',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF247832),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Unified Timeline Stepper Card containing all 7 steps
                    _buildTimelineStepperCard(
                      activation,
                      controller,
                      isDark,
                      cardBg,
                      textDark,
                      textSub,
                      borderColor,
                    ),
                    const SizedBox(height: 20),

                    // 4. Bottom Action Buttons (Figma 9779-56448)
                    _buildActionButtons(controller, isDark, textDark),
                    const SizedBox(height: 28),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =========================================================================
  // 1. Top Store Summary & Countdown Card (Figma 9779-56448)
  // =========================================================================
  Widget _buildHeaderCard(
    ContractActivationModel activation,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
    Color borderColor,
  ) {
    final String displayStoreName =
        activation.storeName.isNotEmpty ? activation.storeName : widget.storeName;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0F18361E),
                  blurRadius: 28,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top White Part: Store Icon + Name + Contract Number (Right) & Status Pill (Left)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF143326) : const Color(0xFFF0FAF2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/image/figma_activation_shop.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayStoreName,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${'contract_number_label'.tr}  ${activation.contractNumber}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6F7871),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(minHeight: 28),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF143326) : const Color(0xFFEBFEEB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'in_activation_badge'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF30913F),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Light-Green Part: Calendar icon + Remaining Time + Completion Rate + Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF132A20) : const Color(0xFFF0FAF2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Right in RTL: White rounded box with Calendar Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/image/figma_activation_calendar_lg.svg',
                    width: 22,
                    height: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'remaining_time_for_activation'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white70 : const Color(0xFF111B18),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                color: Color(0xFF247832),
                              ),
                              children: [
                                TextSpan(
                                  text: '${activation.remainingDays}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${'days_unit'.tr}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'completion_rate_label'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white70 : const Color(0xFF111B18),
                            ),
                          ),
                          Text(
                            '${activation.progressPercentage}%',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF247832),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EBE8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: (activation.progressPercentage / 100.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3EC856), Color(0xFF30913F)],
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. Unified Vertical Stepper Card (Figma 9779-56448 & 9781-57295)
  // =========================================================================
  Widget _buildTimelineStepperCard(
    ContractActivationModel activation,
    StoreVisitsController controller,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
    Color borderColor,
  ) {
    final items = activation.items;
    // Determine the active/current step index (first non-completed step)
    int currentActiveIndex = items.indexWhere((e) => e.status != 'completed');
    if (currentActiveIndex == -1 && items.isNotEmpty) {
      currentActiveIndex = items.length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isLast = index == items.length - 1;
          final bool isCurrentActive = index == currentActiveIndex;
          return _buildTimelineStepRow(
            index: index,
            stepNumber: index + 1,
            item: item,
            isCurrentActive: isCurrentActive,
            isLast: isLast,
            controller: controller,
            isDark: isDark,
            textDark: textDark,
            textSub: textSub,
          );
        }),
      ),
    );
  }

  Widget _buildTimelineStepRow({
    required int index,
    required int stepNumber,
    required ChecklistItemModel item,
    required bool isCurrentActive,
    required bool isLast,
    required StoreVisitsController controller,
    required bool isDark,
    required Color textDark,
    required Color textSub,
  }) {
    final String lang = Get.locale?.languageCode ?? 'ar';
    final String title = item.getLocalizedTitle(lang);
    final String description = _getStepDescription(index, item.key);
    final bool isCompleted = item.status == 'completed';
    final bool isInProgress = item.status == 'in_progress';

    final Color lineColor = isCompleted
        ? const Color(0xFF30913F)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Right in RTL: Stepper Node Circle + Vertical Connecting Line
          SizedBox(
            width: 30,
            child: Column(
              children: [
                _buildStepCircle(
                  stepNumber: stepNumber,
                  isCompleted: isCompleted,
                  isCurrentActive: isCurrentActive || isInProgress,
                  isDark: isDark,
                  textSub: textSub,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Left in RTL: Step Content (Title, Description, Date / Action Widgets)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row (with optional "قيد التنفيذ" pill badge on the left when in_progress)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                      if (isInProgress) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'status_in_progress'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Step Description
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textSub,
                    ),
                  ),

                  // Completed Date Info (for completed steps except stand photo which shows its own green bar)
                  if (isCompleted && item.type != 'camera_photo' && item.updatedAt != null && item.updatedAt!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/image/figma_activation_calendar_sm.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(textSub, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${'completed_on_date'.tr} ${_formatCompletedDate(item.updatedAt!)}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textSub.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Camera Photo Step (Step 4: الستاند الدعائي أمام الكاشير)
                  if (item.type == 'camera_photo') ...[
                    const SizedBox(height: 10),
                    _buildStandPhotoSection(item, controller, isCompleted, isDark),
                  ],

                  // Manual Input for Cashier System Name (when not completed)
                  if (item.type == 'manual_input' && !isCompleted) ...[
                    const SizedBox(height: 10),
                    _buildCashierSystemInput(item, controller, isDark, textDark),
                  ],

                  // Action Buttons for Manual Steps (e.g. Step 5 & Step 6) when not completed and not camera/readonly
                  if (!item.isReadonly && item.type != 'camera_photo' && item.type != 'manual_input' && !isCompleted) ...[
                    const SizedBox(height: 10),
                    _buildManualStepActionButtons(item, controller, isInProgress, isDark),
                  ],

                  // [R13] Step 7: First Real Order Live Tracking & Actions
                  if (item.key == 'first_real_order' || (item.isReadonly && index == 6)) ...[
                    const SizedBox(height: 10),
                    _buildFirstOrderTrackingSection(controller, isCompleted, isDark, textDark, textSub),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepNumber,
    required bool isCompleted,
    required bool isCurrentActive,
    required bool isDark,
    required Color textSub,
  }) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF30913F),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF30913F), width: 0.8),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/image/figma_activation_check_white.svg',
          width: 16,
          height: 16,
        ),
      );
    }

    if (isCurrentActive) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF30913F),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF143326) : const Color(0xFFDEF4E2),
            width: 4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF30913F),
              spreadRadius: 1,
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      );
    }

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$stepNumber',
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSub,
          height: 1.1,
        ),
      ),
    );
  }

  // =========================================================================
  // [R13] First Real Order Step Actions (Matching Figma Steps 5 & 6 exactly)
  // =========================================================================
  Widget _buildFirstOrderTrackingSection(
    StoreVisitsController controller,
    bool isCompleted,
    bool isDark,
    Color textDark,
    Color textSub,
  ) {
    if (isCompleted) {
      return const SizedBox.shrink();
    }

    final tracking = controller.firstOrderTrackingData;
    final String shareUrl = tracking?['share_url']?.toString() ?? 'https://shellafood.com/store/${widget.storeId}';
    final shareMsg = '${'share_store_first_order_text'.tr}\n$shareUrl';

    final Color greenBtnBg = isDark ? const Color(0xFF143326) : const Color(0xFFECFDF5);
    final Color greenBtnText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
    final Color grayBtnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final Color grayBtnText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475467);

    return Row(
      children: [
        // Right button: تحديث حالة الطلب (نفس ستايل مكتمل باللون الأخضر الفاتح المريح)
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: controller.isFirstOrderLoading
                  ? null
                  : () => controller.evaluateFirstOrder(widget.storeId),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenBtnBg,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.isFirstOrderLoading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: greenBtnText, strokeWidth: 2),
                    )
                  : Text(
                      'check_order_status_btn'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: greenBtnText,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Left button: مشاركة رابط المتجر (نفس ستايل قيد التنفيذ بالرمادي الهادئ الموحد)
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () async {
                // 1. Copy directly to clipboard immediately
                await Clipboard.setData(ClipboardData(text: shareMsg));
                showCustomSnackBar('store_link_copied_success'.tr, isError: false);

                // 2. Try launching share or whatsapp if supported
                try {
                  final waUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareMsg)}');
                  if (await canLaunchUrl(waUri)) {
                    await launchUrl(waUri, mode: LaunchMode.externalApplication);
                  } else {
                    await Share.share(shareMsg, subject: widget.storeName);
                  }
                } catch (_) {}
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: grayBtnBg,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'share_store_link'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: grayBtnText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Stand Photo Capture Section (Figma 9779-56448 before & 9781-57295 after)
  // =========================================================================
  Widget _buildStandPhotoSection(
    ChecklistItemModel item,
    StoreVisitsController controller,
    bool isCompleted,
    bool isDark,
  ) {
    final String? photoUrl = controller.currentActivation?.standPhotoPath;
    final bool hasUploadedPhoto = isCompleted || (photoUrl != null && photoUrl.trim().isNotEmpty);

    Future<void> pickAndUploadPhoto() async {
      XFile? picked;
      try {
        picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      } catch (e) {
        debugPrint('Stand photo camera error: $e. Falling back to gallery...');
        try {
          picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        } catch (e2) {
          debugPrint('Gallery fallback error: $e2');
        }
      }

      if (picked != null) {
        await controller.updateContractActivationItem(
          widget.storeId,
          item.key,
          'completed',
          photoFile: picked,
        );
      }
    }

    // State B (Figma 9781-57295): Uploaded confirmation bar with retake icon
    if (hasUploadedPhoto) {
      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF143326) : const Color(0xFFF0FAF2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right in RTL: Checkmark + تم إرفاق صورة الستاند بنجاح
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/image/figma_activation_check_green.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'stand_photo_attached_success'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF247832),
                  ),
                ),
              ],
            ),
            // Left in RTL: Retake icon button
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: pickAndUploadPhoto,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/image/figma_activation_refresh.svg',
                  width: 12,
                  height: 12,
                  colorFilter: isDark
                      ? const ColorFilter.mode(Color(0xFF94A3B8), BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // State A (Figma 9779-56448): Dashed Green Border Button "إرفاق صورة الستاند"
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: pickAndUploadPhoto,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFF30913F),
          strokeWidth: 0.8,
          radius: 12,
        ),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132A20) : const Color(0xFFF0FAF2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/image/figma_activation_gallery.svg',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'attach_stand_photo'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF247832),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Manual Step Action Buttons (Figma 9779-56448 & 9781-57295)
  // =========================================================================
  Widget _buildManualStepActionButtons(
    ChecklistItemModel item,
    StoreVisitsController controller,
    bool isInProgress,
    bool isDark,
  ) {
    // When already in_progress (Figma 9781-57295 Step 5): Single full-width light-green "مكتمل" button
    if (isInProgress) {
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: ElevatedButton(
          onPressed: () => controller.updateContractActivationItem(
            widget.storeId,
            item.key,
            'completed',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF143326) : const Color(0xFFECFDF5),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'status_completed'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
            ),
          ),
        ),
      );
    }

    // When not_started (Figma 9779-56448 Step 5 & 6): Two equal buttons (Right = مكتمل | Left = قيد التنفيذ)
    return Row(
      children: [
        // Right in RTL: مكتمل (Figma #EBFEEB bg, #30913F text)
        Expanded(
          child: SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () => controller.updateContractActivationItem(
                widget.storeId,
                item.key,
                'completed',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF143326) : const Color(0xFFEBFEEB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'status_completed'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF30913F),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Left in RTL: قيد التنفيذ (Figma #F6F6F6 bg, #343434 text)
        Expanded(
          child: SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () => controller.updateContractActivationItem(
                widget.storeId,
                item.key,
                'in_progress',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF6F6F6),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'status_in_progress'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF343434),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Cashier System Input
  // =========================================================================
  Widget _buildCashierSystemInput(
    ChecklistItemModel item,
    StoreVisitsController controller,
    bool isDark,
    Color textDark,
  ) {
    final textController = TextEditingController(text: item.value?.toString() ?? '');

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: textController,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: textDark),
              decoration: InputDecoration(
                hintText: 'cashier_system_name_hint'.tr,
                hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.updateContractActivationItem(
                  widget.storeId,
                  item.key,
                  'completed',
                  value: textController.text.trim(),
                );
              } else {
                showCustomSnackBar('please_enter_cashier_system_name'.tr);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF30913F),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'save'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Bottom Action Buttons (Figma 9779-56448 exact order & styling)
  // =========================================================================
  Widget _buildActionButtons(
    StoreVisitsController controller,
    bool isDark,
    Color textDark,
  ) {
    final Color secondaryBtnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF6F6F6);
    final Color secondaryBtnText = isDark ? Colors.white : const Color(0xFF343434);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. جدولة متابعة تفعيل (Solid Primary Green Button — Figma #30913F)
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showScheduleFollowUpPicker(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF30913F),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'schedule_follow_up_activation'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 11),
        // 2. معاينة المتجر للتحقق من الجاهزية (Soft Neutral Gray Button — Figma #F6F6F6)
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Get.to(
                () => StoreCustomerPreviewScreen(
                  storeId: widget.storeId,
                  storeName: widget.storeName,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryBtnBg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'preview_store_readiness_btn'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: secondaryBtnText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 11),
        // 3. الإبلاغ عن عائق تقني (Soft Neutral Gray Button — Figma #F6F6F6)
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showReportIssueDialog(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryBtnBg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'report_technical_obstacle'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: secondaryBtnText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStepDescription(int index, String key) {
    switch (index) {
      case 0:
        return 'step_desc_merchant_login'.tr;
      case 1:
        return 'step_desc_cashier_system'.tr;
      case 2:
        return 'step_desc_products_prices'.tr;
      case 3:
        return 'step_desc_stand_photo'.tr;
      case 4:
        return 'step_desc_cashier_marketer'.tr;
      case 5:
        return 'step_desc_launch_promo'.tr;
      case 6:
      default:
        return 'step_desc_first_order'.tr;
    }
  }

  String _formatCompletedDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      final String monthKey = 'month_${dt.month}';
      return '${dt.day} ${monthKey.tr} ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  void _showScheduleFollowUpPicker(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final timePicked = await showTimePicker(
        context: Get.context ?? context,
        initialTime: const TimeOfDay(hour: 11, minute: 0),
      );

      if (timePicked != null) {
        showCustomSnackBar('follow_up_scheduled_successfully'.tr, isError: false);
      }
    }
  }

  void _showReportIssueDialog(BuildContext context, StoreVisitsController controller) {
    final textCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'report_technical_obstacle'.tr,
          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report_technical_obstacle_desc'.tr,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'obstacle_notes_hint'.tr,
                hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textCtrl.text.trim().length >= 5) {
                Get.back();
                await controller.reportContractActivationIssue(
                  widget.storeId,
                  textCtrl.text.trim(),
                );
              } else {
                showCustomSnackBar('please_enter_detailed_notes'.tr);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF30913F)),
            child: Text(
              'send'.tr,
              style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.radius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    const double dashWidth = 5.0;
    const double dashSpace = 3.5;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
