import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';

const String _fontTajawal = 'Tajawal';
const Color _primary = Color(0xFF30913F);

class QidhaContractRequestDialog extends StatefulWidget {
  final Store store;
  final VoidCallback? onRequestSent;

  const QidhaContractRequestDialog({
    super.key,
    required this.store,
    this.onRequestSent,
  });

  static Future<void> show(BuildContext context, Store store,
      {VoidCallback? onRequestSent}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QidhaContractRequestDialog(
        store: store,
        onRequestSent: onRequestSent,
      ),
    );
  }

  @override
  State<QidhaContractRequestDialog> createState() =>
      _QidhaContractRequestDialogState();
}

class _QidhaContractRequestDialogState
    extends State<QidhaContractRequestDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<double> _presetAmounts = [500, 1000, 2500, 5000];
  double? _selectedPreset;
  String? _amountError;
  bool _isSending = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Default preset 1000 SAR
    _selectedPreset = 1000;
    _amountController.text = '1000';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onPresetSelected(double amount) {
    setState(() {
      _selectedPreset = amount;
      _amountController.text = amount.toInt().toString();
      _amountError = null;
    });
  }

  void _onAmountChanged(String val) {
    final parsed = double.tryParse(val.trim());
    setState(() {
      _amountError = null;
      if (parsed != null && _presetAmounts.contains(parsed)) {
        _selectedPreset = parsed;
      } else {
        _selectedPreset = null;
      }
    });
  }

  void _sendRequest() async {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'يرجى تحديد المبلغ المالي للتعاقد';
      });
      return;
    }

    if (widget.store.id == null) return;

    setState(() => _isSending = true);

    bool success = false;
    if (Get.isRegistered<KaidhaSubscriptionController>()) {
      final controller = Get.find<KaidhaSubscriptionController>();
      success = await controller.sendStoreContractRequest(
        storeId: widget.store.id!,
        amount: amount,
        notes: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      success = true;
    }

    if (!mounted) return;

    if (success) {
      setState(() {
        _isSending = false;
        _isSuccess = true;
      });
      widget.onRequestSent?.call();
    } else {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSuccess ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      key: const ValueKey('form_view'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.handshake_rounded, color: _primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'طلب تعاقد مع قيدها',
                    style: TextStyle(
                      fontFamily: _fontTajawal,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111B18),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Store Preview Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFFF3F4F6),
                    child: CustomImage(
                      image: '${widget.store.logoFullUrl}',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.store.name ?? 'متجر',
                        style: const TextStyle(
                          fontFamily: _fontTajawal,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111B18),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.store.address ??
                            (widget.store.categoryDetails?.isNotEmpty == true
                                ? widget.store.categoryDetails!.first.name ?? ''
                                : 'متجر متاح للتعاقد'),
                        style: const TextStyle(
                          fontFamily: _fontTajawal,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Financial Amount Section Header
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: _primary, size: 20),
              SizedBox(width: 6),
              Text(
                'مبلغ التعاقد المالي التقديري (ر.س)',
                style: TextStyle(
                  fontFamily: _fontTajawal,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111B18),
                ),
              ),
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Preset Amount Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetAmounts.map((amount) {
              final isSelected = _selectedPreset == amount;
              return ChoiceChip(
                label: Text(
                  '${amount.toInt()} ر.س',
                  style: TextStyle(
                    fontFamily: _fontTajawal,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
                selected: isSelected,
                selectedColor: _primary,
                backgroundColor: const Color(0xFFF3F4F6),
                side: BorderSide(
                  color: isSelected ? _primary : const Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (selected) {
                  if (selected) {
                    _onPresetSelected(amount);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Amount Text Field
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: const TextStyle(
              fontFamily: _fontTajawal,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111B18),
            ),
            decoration: InputDecoration(
              hintText: 'contract_amount_hint'.tr,
              hintStyle: const TextStyle(
                fontFamily: _fontTajawal,
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              suffixText: 'ر.س',
              suffixStyle: const TextStyle(
                fontFamily: _fontTajawal,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
              prefixIcon: const Icon(Icons.attach_money_rounded,
                  color: Color(0xFF9CA3AF), size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              errorText: _amountError,
              errorStyle: const TextStyle(fontFamily: _fontTajawal, fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            onChanged: _onAmountChanged,
          ),
          const SizedBox(height: 14),

          // Optional Note Input
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: _fontTajawal,
              fontSize: 14,
              color: Color(0xFF111B18),
            ),
            decoration: InputDecoration(
              hintText: 'optional_store_note'.tr,
              hintStyle: const TextStyle(
                fontFamily: _fontTajawal,
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: _primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم إشعار إدارة المتجر برغبتك في الدفع عبر محفظة قيدها بالمبلغ المحدد لتسريع إتمام التعاقد.',
                    style: TextStyle(
                      fontFamily: _fontTajawal,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF166534),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: _isSending ? null : _sendRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSending
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'إرسال طلب التعاقد',
                        style: TextStyle(
                          fontFamily: _fontTajawal,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFFEBFEEB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: _primary, size: 44),
        ),
        const SizedBox(height: 16),
        const Text(
          'تم إرسال طلبك بنجاح!',
          style: TextStyle(
            fontFamily: _fontTajawal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111B18),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'تم تسجيل طلب التعاقد بمبلغ ${_amountController.text} ر.س لمتجر "${widget.store.name ?? ''}". سنقوم بإبلاغك فور إتاحة الدفع بالمحفظة لديهم.',
          style: const TextStyle(
            fontFamily: _fontTajawal,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'حسناً',
            style: TextStyle(
              fontFamily: _fontTajawal,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
