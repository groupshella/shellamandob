// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import '../controllers/store_visits_controller.dart';
import '../domain/models/contract_activation_model.dart';

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
        Get.find<StoreVisitsController>().loadContractActivation(
          widget.storeId,
          contractNumber: widget.contractNumber,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().darkTheme;
    final screenBg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF1E2228) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF111B18);
    final textSub = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2C323C) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: Text(
          'store_activation'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textDark),
        ),
        centerTitle: true,
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<StoreVisitsController>(
        builder: (controller) {
          if (controller.isActivationLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    style: robotoMedium.copyWith(color: textSub, fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadContractActivation(widget.storeId, contractNumber: widget.contractNumber),
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Card with Timer & Progress
                _buildHeaderCard(activation, isDark, cardBg, textDark, textSub, borderColor),
                const SizedBox(height: 16),

                // 2. Checklist Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'activation_checklist'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activation.completedItems}/${activation.totalItems}',
                        style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Dynamic Checklist Items
                ...activation.items.map((item) => _buildChecklistItemCard(
                      item,
                      controller,
                      isDark,
                      cardBg,
                      textDark,
                      textSub,
                      borderColor,
                    )),
                const SizedBox(height: 24),

                // 4. Action Buttons
                _buildActionButtons(controller, isDark),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // Header Card with Countdown Timer
  // =========================================================================
  Widget _buildHeaderCard(
    ContractActivationModel activation,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
    Color borderColor,
  ) {
    Color timerBg;
    Color timerText;
    IconData timerIcon;

    switch (activation.timerColor) {
      case 'red':
        timerBg = const Color(0xFFFDE8E8);
        timerText = const Color(0xFFDC2626);
        timerIcon = Icons.warning_rounded;
        break;
      case 'orange':
        timerBg = const Color(0xFFFEF3C7);
        timerText = const Color(0xFFD97706);
        timerIcon = Icons.access_time_filled_rounded;
        break;
      case 'green':
      default:
        timerBg = const Color(0xFFE8F8EE);
        timerText = const Color(0xFF16A34A);
        timerIcon = Icons.timer_outlined;
        break;
    }

    final lang = Get.locale?.languageCode ?? 'ar';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.storefront_rounded, color: Theme.of(context).primaryColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activation.storeName.isNotEmpty ? activation.storeName : widget.storeName,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'contract_number_label'.tr}: ${activation.contractNumber}',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textSub),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 16),

          // Countdown Timer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: timerBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: timerText.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(timerIcon, color: timerText, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activation.timerStatusText.isNotEmpty
                            ? activation.timerStatusText
                            : (lang == 'ar'
                                ? 'متبقٍ ${activation.remainingDays} يوماً لأول طلب'
                                : '${activation.remainingDays} days remaining for first order'),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: timerText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'target_first_real_order_desc'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: timerText.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'activation_progress'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: textSub),
              ),
              Text(
                '${activation.progressPercentage}%',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (activation.progressPercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Checklist Item Card
  // =========================================================================
  Widget _buildChecklistItemCard(
    ChecklistItemModel item,
    StoreVisitsController controller,
    bool isDark,
    Color cardBg,
    Color textDark,
    Color textSub,
    Color borderColor,
  ) {
    final lang = Get.locale?.languageCode ?? 'ar';
    final title = item.getLocalizedTitle(lang);

    final bool isCompleted = item.status == 'completed';
    final bool isInProgress = item.status == 'in_progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF16A34A).withOpacity(0.4)
              : (isInProgress ? const Color(0xFFD97706).withOpacity(0.4) : borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFFE8F8EE)
                      : (isInProgress ? const Color(0xFFFEF3C7) : (isDark ? Colors.grey[800] : const Color(0xFFF3F4F6))),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : (isInProgress ? Icons.timelapse_rounded : Icons.radio_button_unchecked_rounded),
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                      : (isInProgress ? const Color(0xFFD97706) : textSub),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: textDark,
                        decoration: isCompleted ? TextDecoration.none : null,
                      ),
                    ),
                    if (item.isReadonly) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14, color: textSub),
                          const SizedBox(width: 4),
                          Text(
                            'system_auto_updated_note'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: textSub),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Custom Input for Stand Photo
          if (item.type == 'camera_photo') ...[
            const SizedBox(height: 12),
            _buildStandPhotoSection(item, controller, isDark),
          ],

          // Custom Input for Cashier System Name
          if (item.type == 'manual_input' && !isCompleted) ...[
            const SizedBox(height: 12),
            _buildCashierSystemInput(item, controller, isDark),
          ],

          // Status Action Chips (Only if not system_auto)
          if (!item.isReadonly) ...[
            const SizedBox(height: 12),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStatusChip(
                  label: 'status_not_started'.tr,
                  isSelected: item.status == 'not_started',
                  activeColor: textSub,
                  onTap: () => controller.updateContractActivationItem(widget.storeId, item.key, 'not_started'),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  label: 'status_in_progress'.tr,
                  isSelected: item.status == 'in_progress',
                  activeColor: const Color(0xFFD97706),
                  onTap: () => controller.updateContractActivationItem(widget.storeId, item.key, 'in_progress'),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  label: 'status_completed'.tr,
                  isSelected: item.status == 'completed',
                  activeColor: const Color(0xFF16A34A),
                  onTap: () => controller.updateContractActivationItem(widget.storeId, item.key, 'completed'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // Stand Photo Capture Section
  // =========================================================================
  Widget _buildStandPhotoSection(ChecklistItemModel item, StoreVisitsController controller, bool isDark) {
    final photoUrl = controller.currentActivation?.standPhotoPath;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF15181D) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'stand_live_photo_label'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (photoUrl != null && photoUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photoUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (picked != null) {
                await controller.updateContractActivationItem(
                  widget.storeId,
                  item.key,
                  'completed',
                  photoFile: picked,
                );
              }
            },
            icon: const Icon(Icons.photo_camera_rounded, size: 18),
            label: Text(photoUrl != null ? 'retake_stand_photo'.tr : 'take_live_stand_photo'.tr),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Cashier System Input
  // =========================================================================
  Widget _buildCashierSystemInput(ChecklistItemModel item, StoreVisitsController controller, bool isDark) {
    final textController = TextEditingController(text: item.value?.toString() ?? '');

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'cashier_system_name_hint'.tr,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('save'.tr),
        ),
      ],
    );
  }

  // =========================================================================
  // Status Chip
  // =========================================================================
  Widget _buildStatusChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : activeColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: isSelected ? Colors.white : activeColor,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Action Buttons
  // =========================================================================
  Widget _buildActionButtons(StoreVisitsController controller, bool isDark) {
    return Column(
      children: [
        CustomButton(
          buttonText: 'schedule_follow_up_activation'.tr,
          icon: Icons.calendar_today_rounded,
          onPressed: () => _showScheduleFollowUpPicker(context),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showReportIssueDialog(context, controller),
          icon: const Icon(Icons.report_problem_outlined, size: 20, color: Color(0xFFDC2626)),
          label: Text(
            'report_technical_obstacle'.tr,
            style: robotoBold.copyWith(color: const Color(0xFFDC2626)),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: Color(0xFFDC2626)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
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
        title: Text('report_technical_obstacle'.tr, style: robotoBold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('report_technical_obstacle_desc'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'obstacle_notes_hint'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              if (textCtrl.text.trim().length >= 5) {
                Get.back();
                await controller.reportContractActivationIssue(widget.storeId, textCtrl.text.trim());
              } else {
                showCustomSnackBar('please_enter_detailed_notes'.tr);
              }
            },
            child: Text('send'.tr),
          ),
        ],
      ),
    );
  }
}

