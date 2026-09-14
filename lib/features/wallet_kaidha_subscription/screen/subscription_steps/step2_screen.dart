import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/screen/credit_review_screen.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/file_upload_widget.dart';
import 'package:sixam_mart/util/styles.dart';

class Step2Screen extends StatefulWidget {
  const Step2Screen({super.key});

  @override
  State<Step2Screen> createState() => _Step2ScreenState();
}

class _Step2ScreenState extends State<Step2Screen> {
  final List<String> _incomeSourceOptions = [
    'راتب حكومي',
    'راتب قطاع خاص',
    'أعمال حرة',
    'تجارة',
    'معاش تقاعدي',
  ];

  static const Color _green = Color(0xFF30913F);
  static const Color _ink = Color(0xFF111B18);
  static const Color _bg = Color(0xFFF6F5F8);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _error = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (controller) {
        // Check verification status of income from wallet if available
        final wallet = controller.walletKaidhaModel?.wallet;
        final String? status = wallet?.status?.toString().toLowerCase();
        final bool isApproved = status == 'active' || status == 'approved';
        final bool isPending = status == 'in_progress' || status == 'pending';
        final String verificationBadgeText = isApproved
            ? 'موثق'
            : (isPending ? 'تحت مراجعة الإدارة' : 'غير موثق');
        final Color badgeBg = isApproved
            ? const Color(0xFFF0FDF4)
            : (isPending ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB));
        final Color badgeTextColor = isApproved
            ? _green
            : (isPending ? const Color(0xFF2563EB) : const Color(0xFF6B7280));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('مصدر الدخل'),
              const SizedBox(height: 12),

              // ── Income Details Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Income Source Dropdown
                    _requiredLabel(context, 'اختر مصدر الدخل الرئيسي'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.isJobSpecificationEmpty ? _error : _border,
                          width: controller.isJobSpecificationEmpty ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.jobSpecification.isNotEmpty &&
                                  _incomeSourceOptions.contains(controller.jobSpecification)
                              ? controller.jobSpecification
                              : null,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6B7280)),
                          hint: Text(
                            'اختر مصدر الدخل الرئيسي',
                            style: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
                          ),
                          items: _incomeSourceOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(
                                opt,
                                style: robotoMedium.copyWith(fontSize: 13, color: _ink, fontFamily: 'Tajawal'),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.jobSpecification = val;
                              controller.isJobSpecificationEmpty = false;
                              controller.update();
                              controller.debouncedSaveState();
                            }
                          },
                        ),
                      ),
                    ),
                    if (controller.isJobSpecificationEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'هذا الحقل مطلوب',
                        style: robotoRegular.copyWith(color: _error, fontSize: 11, fontFamily: 'Tajawal'),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Employer Name
                    _requiredLabel(context, 'اسم جهة العمل'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.name_of_employer,
                      focusNode: controller.employerFocus,
                      cursorColor: _green,
                      decoration: _inputDecoration(
                        controller.isEmployerEmpty,
                        hintText: 'اسم جهة العمل',
                      ),
                      onChanged: (_) {
                        if (controller.isEmployerEmpty) {
                          controller.isEmployerEmpty = false;
                          controller.update();
                        }
                        controller.debouncedSaveState();
                      },
                    ),
                    if (controller.isEmployerEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'هذا الحقل مطلوب',
                        style: robotoRegular.copyWith(color: _error, fontSize: 11, fontFamily: 'Tajawal'),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Monthly Income + Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _requiredLabel(context, 'الدخل الشهري'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeTextColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isApproved ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                size: 13,
                                color: badgeTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                verificationBadgeText,
                                style: robotoBold.copyWith(
                                  fontSize: 11,
                                  color: badgeTextColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.monthlyIncome,
                      focusNode: controller.monthlyIncomeFocus,
                      keyboardType: TextInputType.number,
                      cursorColor: _green,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        controller.isMonthlyIncomeEmpty,
                        hintText: 'ادخل رقم',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Text(
                            'sar'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 13,
                              color: const Color(0xFF4B5563),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (controller.isMonthlyIncomeEmpty) {
                          controller.isMonthlyIncomeEmpty = false;
                          controller.update();
                        }
                        controller.debouncedSaveState();
                      },
                    ),
                    if (controller.isMonthlyIncomeEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'هذا الحقل مطلوب',
                        style: robotoRegular.copyWith(color: _error, fontSize: 11, fontFamily: 'Tajawal'),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Salary Day Dropdown
                    _requiredLabel(context, 'ما هو يوم استلام راتبك'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.isSalaryDayEmpty ? _error : _border,
                          width: controller.isSalaryDayEmpty ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: int.tryParse(controller.salary_day.text),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6B7280)),
                          hint: Text(
                            'اختر اليوم',
                            style: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
                          ),
                          items: List.generate(31, (index) {
                            final int day = index + 1;
                            return DropdownMenuItem(
                              value: day,
                              child: Text(
                                'يوم $day من الشهر',
                                style: robotoMedium.copyWith(fontSize: 13, color: _ink, fontFamily: 'Tajawal'),
                              ),
                            );
                          }),
                          onChanged: (newDay) {
                            if (newDay != null) {
                              controller.salary_day.text = newDay.toString();
                              controller.isSalaryDayEmpty = false;
                              controller.update();
                              controller.debouncedSaveState();
                            }
                          },
                        ),
                      ),
                    ),
                    if (controller.isSalaryDayEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'هذا الحقل مطلوب',
                        style: robotoRegular.copyWith(color: _error, fontSize: 11, fontFamily: 'Tajawal'),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Installments Question (Horizontal Radio Pills)
                    _requiredLabel(context, 'هل لديك أي أقساط'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioPill(
                            label: 'نعم',
                            isSelected: controller.Installments == 'yes',
                            onTap: () {
                              controller.Installments = 'yes';
                              controller.update();
                              controller.debouncedSaveState();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRadioPill(
                            label: 'لا',
                            isSelected: controller.Installments == 'no',
                            onTap: () {
                              controller.Installments = 'no';
                              controller.update();
                              controller.debouncedSaveState();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Conditional Installment Amount Input
                    if (controller.Installments == 'yes') ...[
                      _requiredLabel(context, 'برجاء ذكر مبلغ القسط'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.another_amount,
                        keyboardType: TextInputType.number,
                        cursorColor: _green,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _inputDecoration(
                          false,
                          hintText: 'ادخل رقم',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Text(
                              'sar'.tr,
                              style: robotoBold.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF4B5563),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                        onChanged: (_) => controller.debouncedSaveState(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionTitle('المستندات'),
              const SizedBox(height: 12),

              // ── Income Documents Card ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const FileUploadWithNameWidget(
                  isIncome: true,
                  instruction: 'أرفق صوراً واضحة لمستنداتك لإثبات الدخل (مثل كشف حساب أو تعريف بالراتب )',
                ),
              ),

              const SizedBox(height: 24),

              // ── Bottom Action Buttons ───────────────────────────────────────
              // Primary Button: "التالي"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          await controller.validate_Fields_Screen_2(context, null, true);
                        },
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'next'.tr,
                          style: robotoBold.copyWith(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Button: "مراجعة ملفك الائتماني"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F6F6),
                    foregroundColor: _ink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: _border),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const CreditReviewScreen());
                  },
                  child: Text(
                    'مراجعة ملفك الائتماني',
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: tajawalBold.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _requiredLabel(BuildContext context, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '*',
          style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: robotoMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ink,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    bool hasError, {
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      fillColor: _bg,
      filled: true,
      prefixIcon: prefixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _error : _border,
          width: hasError ? 1.5 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _error : _green,
          width: hasError ? 1.5 : 1.0,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildRadioPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _green : _border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _green : const Color(0xFF9CA3AF),
                  width: isSelected ? 4.5 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: robotoBold.copyWith(
                  fontSize: 12,
                  color: isSelected ? _green : const Color(0xFF374151),
                  fontFamily: 'Tajawal',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
