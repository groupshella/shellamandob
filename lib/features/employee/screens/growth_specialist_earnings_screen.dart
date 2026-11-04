import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/employee/controllers/monthly_earnings_controller.dart';
import 'package:sixam_mart/features/employee/models/monthly_earnings_model.dart';

class GrowthSpecialistEarningsScreen extends StatefulWidget {
  const GrowthSpecialistEarningsScreen({super.key});

  @override
  State<GrowthSpecialistEarningsScreen> createState() => _GrowthSpecialistEarningsScreenState();
}

class _GrowthSpecialistEarningsScreenState extends State<GrowthSpecialistEarningsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().darkTheme;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final subTextColor = isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085);
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAECF0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'أرباح ومستحقات أخصائي النمو',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _primaryGreen),
            onPressed: () {
              if (Get.isRegistered<MonthlyEarningsController>()) {
                Get.find<MonthlyEarningsController>().refreshCurrentMonth();
              }
            },
          ),
        ],
      ),
      body: GetBuilder<MonthlyEarningsController>(
        init: Get.isRegistered<MonthlyEarningsController>()
            ? Get.find<MonthlyEarningsController>()
            : null,
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            );
          }

          if (controller.errorMessage != null && controller.earningsData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: subTextColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => controller.refreshCurrentMonth(),
                      child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = controller.earningsData;
          if (data == null) {
            return const SizedBox.shrink();
          }

          final isFinalized = data.status == 'finalized';

          return RefreshIndicator(
            color: _primaryGreen,
            onRefresh: () => controller.refreshCurrentMonth(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month Picker Selector Bar
                  _buildMonthSelector(controller, cardBg, textColor, borderColor),
                  const SizedBox(height: 12),

                  // Total Earnings Header Card with Snapshot Status Badge
                  _buildTotalEarningsCard(data, isFinalized, isDark),
                  const SizedBox(height: 14),

                  // Layer 1: Salary & Attendance Breakdown
                  _buildLayer1Card(data.layer1Salary, data.workingDays, cardBg, textColor, subTextColor, borderColor),
                  const SizedBox(height: 14),

                  // Layer 2: Contract Activation Incentive Breakdown
                  _buildLayer2Card(data.layer2Incentive, cardBg, textColor, subTextColor, borderColor),
                  const SizedBox(height: 14),

                  // Layer 3: Network Supervision & Milestone Earnings
                  _buildLayer3Card(data.layer3Network, cardBg, textColor, subTextColor, borderColor),
                  const SizedBox(height: 14),

                  // Layer 4: Direct Acquisition Commissions
                  _buildLayer4Card(data.layer4Direct, cardBg, textColor, subTextColor, borderColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(
    MonthlyEarningsController controller,
    Color cardBg,
    Color textColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(IconlyLight.calendar, color: _primaryGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'الشهر المالي:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              final parts = controller.selectedMonth.split('-');
              final initialYear = int.tryParse(parts[0]) ?? DateTime.now().year;
              final initialMonth = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? DateTime.now().month;

              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(initialYear, initialMonth, 1),
                firstDate: DateTime(2025, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                initialDatePickerMode: DatePickerMode.year,
              );

              if (picked != null) {
                final formattedMonth = DateFormat('yyyy-MM').format(picked);
                controller.changeMonth(formattedMonth);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    controller.selectedMonth,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: _primaryGreen, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsCard(MonthlyEarningsModel data, bool isFinalized, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A24), const Color(0xFF16291B)]
              : [const Color(0xFF30913F), const Color(0xFF236A2E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي مستحقات الشهر الصافية',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFinalized ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFinalized ? Icons.lock_outline_rounded : Icons.pending_actions_rounded,
                      size: 13,
                      color: isFinalized ? _primaryGreen : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFinalized ? 'معتمد ومقفل' : 'مستحقات مبدئية',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isFinalized ? _primaryGreen : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                NumberFormat('#,##0.00').format(data.summary.totalMonthlyEarnings),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'ر.س',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'آخر احتساب: ${data.calculatedAt}',
            style: const TextStyle(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildLayer1Card(
    Layer1Salary salary,
    WorkingDaysInfo workingDays,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF8FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(IconlyLight.wallet, color: Color(0xFF175CD3), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الطبقة 1: الراتب التعاقدي الأساسي',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              Text(
                '${salary.netCalculatedSalary.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildDetailRow('الراتب التعاقدي الشهري:', '${salary.baseContractualSalary.toStringAsFixed(2)} ر.س', textColor, subTextColor),
          _buildDetailRow('أيام العمل المعتمدة:', '${workingDays.totalBaselineDays} يوم', textColor, subTextColor),
          _buildDetailRow('معدل اليومية:', '${salary.dailySalaryRate.toStringAsFixed(2)} ر.س / يوم', textColor, subTextColor),
          if (salary.approvedUnpaidLeaveDays > 0)
            _buildDetailRow(
              'خصم إجازات غير مدفوعة (${salary.approvedUnpaidLeaveDays} يوم):',
              '-${salary.unpaidLeaveDeduction.toStringAsFixed(2)} ر.س',
              Colors.redAccent,
              subTextColor,
            ),
        ],
      ),
    );
  }

  Widget _buildLayer2Card(
    Layer2Incentive incentive,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    final percent = (incentive.achievementPercentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(IconlyLight.work, color: Color(0xFFC11574), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الطبقة 2: حوافز تفعيل العقود',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              Text(
                '${incentive.totalConfirmedIncentive.toStringAsFixed(2)} ر.س',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Progress & Qualification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإنجاز: ${incentive.activatedContractsCount} / ${incentive.adjustedMonthlyTarget} عقد',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                '${incentive.achievementPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: incentive.isQualified ? _primaryGreen : const Color(0xFFB54708),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: borderColor,
              color: incentive.isQualified ? _primaryGreen : const Color(0xFFF79009),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Threshold Status Banner
          if (!incentive.isQualified)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD6AE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFC4320A), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'متبقي ${incentive.contractsNeededToQualify} عقد لفتح حد التأهيل الأدنى (30%) وصرف الحافز التراكمي من العقد رقم 1.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFC4320A)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          _buildDetailRow('الحافز القياسي المحقق:', '${incentive.standardIncentiveEarned.toStringAsFixed(2)} ر.س', textColor, subTextColor),
          if (incentive.overTargetContractsCount > 0)
            _buildDetailRow(
              'مكافأة الفائض (${incentive.overTargetContractsCount} عقد × 20 ر.س):',
              '+${incentive.overTargetBonusEarned.toStringAsFixed(2)} ر.س',
              _primaryGreen,
              subTextColor,
            ),
          _buildDetailRow('معدل العقد المعياري للعرض:', '~${incentive.displayedPerContractRate.toStringAsFixed(2)} ر.س', subTextColor, subTextColor),

          // Potential Pending Box
          if (incentive.pendingContracts.count > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'عقود معلقة مؤهلة للتفعيل:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        '${incentive.pendingContracts.count} عقد',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الحافز الإضافي المحتمل عند تفعيلها بالكامل: +${incentive.pendingContracts.potentialIncrementalIncentive.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(fontSize: 11, color: _primaryGreen, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLayer3Card(
    Layer3Network network,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(IconlyLight.user2, color: Color(0xFF0E9384), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الطبقة 3: إشراف ومكافآت الشبكة',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              Text(
                '${network.totalNetworkEarnings.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildDetailRow('المسوقون النشطون تحت الإشراف:', '${network.activeSupervisedMarketersCount} مسوق', textColor, subTextColor),
          _buildDetailRow('عمولات إشراف الشبكة المباشرة:', '${network.networkSupervisionCommissions.toStringAsFixed(2)} ر.س', textColor, subTextColor),
          _buildDetailRow('مكافآت مراحل إنجاز الفريق (Milestones):', '${network.milestoneBonusesEarned.toStringAsFixed(2)} ر.س', textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildLayer4Card(
    Layer4Direct direct,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF6EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(IconlyLight.bag2, color: Color(0xFFE04F16), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الطبقة 4: اكتساب العملاء المباشر',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              Text(
                '${direct.customerAcquisitionCommissions.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildDetailRow('العملاء المسجلون عبر الكود الشخصي:', '${direct.registeredUsersCount} عميل', textColor, subTextColor),
          _buildDetailRow('الطلبات الأولى المؤهلة والمكتملة:', '${direct.qualifiedFirstOrdersCount} طلب', textColor, subTextColor),
          _buildDetailRow('إجمالي عمولات الاكتساب المباشرة:', '${direct.customerAcquisitionCommissions.toStringAsFixed(2)} ر.س', textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }
}
