import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/domain/models/wallet_kaidha_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';

// ==== خطوط Tajawal الخاصة ببطاقة محفظة قيدها ====
const String _fontTajawal = 'Tajawal';

TextStyle _tajawal(
  double size,
  FontWeight weight, {
  Color color = Colors.white,
  double? height,
}) {
  return TextStyle(
    fontFamily: _fontTajawal,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

class PaymentDetails extends StatelessWidget {
  final Wallet wallet;
  const PaymentDetails({super.key, required this.wallet});

  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _statusLabel() {
    final String status = (wallet.status ?? '').toString().toLowerCase();
    if (status == 'active') return 'متاح';
    if (status == 'pending') return 'قيد المراجعة';
    return 'مغلق';
  }

  @override
  Widget build(BuildContext context) {
    final double availableBalance =
        _parseToDouble(wallet.availableBalance) ?? 0.0;
    final double usedBalance = _parseToDouble(wallet.usedBalance) ?? 0.0;
    final double creditLimit = _parseToDouble(wallet.creditLimit) ??
        _parseToDouble(wallet.purchaseLimit) ??
        0.0;

    // نسبة الاستخدام لشريط التقدّم (0..1)
    double progress = 0;
    final double? usedPct = _parseToDouble(wallet.usedPercentage);
    if (usedPct != null && usedPct > 0) {
      progress = (usedPct / 100).clamp(0.0, 1.0);
    } else if (creditLimit > 0) {
      progress = (usedBalance / creditLimit).clamp(0.0, 1.0);
    }

    // مساحة إضافية بالأسفل ليبرز صندوق "الرصيد المستخدم" خارج البطاقة (ستاك).
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // البطاقة الخضراء
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: const DecorationImage(
                image: AssetImage(Images.card_quidha),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF30913F).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // أعلى البطاقة: شارة الحالة + الرصيد المتاح
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الرصيد المتاح + المبلغ
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الرصيد المتاح',
                            style: _tajawal(13, FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9)),
                          ),
                          const SizedBox(height: 4),
                          _AmountText(
                            amount: availableBalance,
                            fontSize: 32,
                            weight: FontWeight.w800,
                            symbolSize: 20,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // شارة الحالة وزر العقد
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 1),
                            ),
                            child: Text(
                              _statusLabel(),
                              style: _tajawal(12, FontWeight.w700),
                            ),
                          ),
                          if (wallet.signatureStatus == 1 &&
                              wallet.signaturePath != null &&
                              wallet.signaturePath.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _ContractButton(),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // رقم البطاقة وتاريخ الانتهاء
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _CardInfoRow(
                          label: 'card_number_label'.tr,
                          value: wallet.serialNumber?.toString() ?? '—',
                        ),
                        const Divider(color: Colors.white24, height: 12),
                        _CardInfoRow(
                          label: 'expiry_month'.tr,
                          value: wallet.lockDay?.toString() ?? '—',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // صندوق "الرصيد المستخدم" البارز أسفل البطاقة
          Positioned(
            left: 14,
            right: 14,
            bottom: -44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرصيد المستخدم',
                        style: _tajawal(12, FontWeight.w700,
                            color: const Color(0xFF374151)),
                      ),
                      _AmountText(
                        amount: usedBalance,
                        fontSize: 13,
                        weight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                        symbolSize: 13,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF30913F)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'حد البطاقة',
                        style: _tajawal(11, FontWeight.w500,
                            color: const Color(0xFF6B7280)),
                      ),
                      _AmountText(
                        amount: creditLimit,
                        fontSize: 12,
                        weight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                        symbolSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// نص المبلغ مع رمز الريال
class _AmountText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final FontWeight weight;
  final Color color;
  final double symbolSize;
  const _AmountText({
    required this.amount,
    required this.fontSize,
    required this.weight,
    this.color = Colors.white,
    this.symbolSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          amount.toStringAsFixed(2),
          style: _tajawal(fontSize, weight, color: color),
        ),
        const SizedBox(width: 5),
        Image.asset(
          Images.sar,
          width: symbolSize,
          height: symbolSize,
          cacheWidth: (symbolSize * 3).round(),
          cacheHeight: (symbolSize * 3).round(),
          color: color,
        ),
      ],
    );
  }
}

// سطر معلومة على البطاقة (عنوان + قيمة)
class _CardInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _CardInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // في الاتجاه RTL: العنوان على اليمين والقيمة على اليسار بسطر واحد.
    return Row(
      children: [
        Text(
          label,
          style: _tajawal(14, FontWeight.w500, color: Colors.white),
        ),
        const Spacer(),
        Text(
          value,
          style: _tajawal(16, FontWeight.w500, color: Colors.white),
        ),
      ],
    );
  }
}

// زر عرض العقد
class _ContractButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Get.dialog(
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('loading_contract'.tr,
                      style: _tajawal(14, FontWeight.w500,
                          color: const Color(0xFF2D3633))),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        try {
          await Get.find<KaidhaSubscriptionController>().get_Pdf();
          Get.back();
          Get.toNamed(RouteHelper.getContract_ReviewRoute());
        } catch (e) {
          Get.back();
          Get.snackbar(
            'خطأ',
            'فشل في تحميل العقد. يرجى المحاولة مرة أخرى.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined,
                color: Colors.white, size: 15),
            const SizedBox(width: 4),
            Text('view_contract'.tr, style: _tajawal(11, FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ========================================================================================================

class PaymentDetailsShimmer extends StatelessWidget {
  const PaymentDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF31A342).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
