import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/domain/models/wallet_kaidha_model.dart';
import 'package:sixam_mart/util/images.dart';

const String _fontTajawal = 'Tajawal';
const Color _primary = Color(0xFF30913F);
const Color _title = Color(0xFF111B18);
const Color _outline = Color(0xFFE5E7EB);

class PaymentOptions extends StatefulWidget {
  final Wallet wallet;
  const PaymentOptions({super.key, required this.wallet});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double usedBalanceAmount =
        _parseToDouble(widget.wallet.usedBalance) ?? 0.0;
    final double minimumDueAmount =
        _parseToDouble(widget.wallet.minimumDueLimit) ?? 0.0;

    final List<Map<String, dynamic>> list = [
      {'title': 'المبلغ المستحق بالكامل', 'amount': usedBalanceAmount},
      {'title': 'المبلغ الأدنى المستحق', 'amount': minimumDueAmount},
    ];

    return GetBuilder<KaidhaSubscriptionController>(
        builder: (KaidhaSubController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'خيارات الدفع',
                style: TextStyle(
                  fontFamily: _fontTajawal,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(list.length, (int index) {
            final bool isSelected =
                KaidhaSubController.selectedPaymentOption == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => KaidhaSubController.selectPaymentOption(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _primary : _outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? _primary.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _RadioDot(selected: isSelected),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          list[index]['title'] as String,
                          style: const TextStyle(
                            fontFamily: _fontTajawal,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _title,
                          ),
                        ),
                      ),
                      _AmountText(amount: list[index]['amount'] as double),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: selected ? _primary : const Color(0xFFD1D5DB),
          width: selected ? 6 : 2,
        ),
      ),
    );
  }
}

class _AmountText extends StatelessWidget {
  final double amount;
  const _AmountText({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          amount.toStringAsFixed(2),
          style: const TextStyle(
            fontFamily: _fontTajawal,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _title,
          ),
        ),
        const SizedBox(width: 4),
        Image.asset(
          Images.sar,
          width: 14,
          height: 14,
          cacheWidth: 42,
          cacheHeight: 42,
        ),
      ],
    );
  }
}
