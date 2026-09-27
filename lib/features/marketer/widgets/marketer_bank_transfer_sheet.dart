import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

/// Modal Bottom Sheet for Bank Transfer (Figma 9054:70244, 70279, 70343 - التحويل البنكي)
class MarketerBankTransferSheet extends StatefulWidget {
  const MarketerBankTransferSheet({super.key});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _errorRed = Color(0xFFE53935);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MarketerBankTransferSheet(),
    );
  }

  @override
  State<MarketerBankTransferSheet> createState() => _MarketerBankTransferSheetState();
}

class _MarketerBankTransferSheetState extends State<MarketerBankTransferSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _bankFocus = FocusNode();
  final FocusNode _holderFocus = FocusNode();
  final FocusNode _ibanFocus = FocusNode();

  bool _isSubmitting = false;

  final List<String> _popularBanks = [
    'البنك الأهلي السعودي',
    'مصرف الراجحي',
    'بنك الرياض',
    'مصرف الإنماء',
    'البنك السعودي الأول (SAB)',
    'البنك العربي الوطني',
  ];

  @override
  void initState() {
    super.initState();
    // Default or pre-filled values
    final profileCtrl = Get.find<ProfileController>();
    final userInfo = profileCtrl.userInfoModel;
    final fullName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
    if (fullName.isNotEmpty) {
      _accountHolderController.text = fullName;
    }

    _bankNameController.text = 'البنك الأهلي السعودي';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _ibanController.dispose();
    _amountFocus.dispose();
    _bankFocus.dispose();
    _holderFocus.dispose();
    _ibanFocus.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountController.text.trim()) ?? 0.0;
  bool get _isAmountBelowMin => _amountController.text.isNotEmpty && _enteredAmount < 200.0;
  bool get _isIbanInvalid =>
      _ibanController.text.isNotEmpty && _ibanController.text.replaceAll(' ', '').length < 15;

  void _submit() async {
    final amount = _enteredAmount;
    if (_amountController.text.isEmpty || amount < 200) {
      showCustomSnackBar('min_transfer_warning'.tr);
      return;
    }
    if (_bankNameController.text.trim().isEmpty) {
      showCustomSnackBar('bank_name_label'.tr);
      return;
    }
    if (_accountHolderController.text.trim().isEmpty) {
      showCustomSnackBar('account_holder_name_label'.tr);
      return;
    }
    if (_ibanController.text.trim().isEmpty || _isIbanInvalid) {
      showCustomSnackBar('invalid_iban_warning'.tr);
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      showCustomSnackBar('transfer_request_sent_success'.tr, isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB);

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header with title and close icon (Figma 9054:70245)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'enter_bank_account'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : MarketerBankTransferSheet._darkText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note Container (Figma 9054:70250)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2838)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2B3B52) : const Color(0xFFDBEAFE),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'bank_account_owner_note'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Amount field (Figma 9054:70255 / 70289 / 70353)
                _buildFieldLabel('enter_transfer_amount'.tr, isDark),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAmountBelowMin
                          ? MarketerBankTransferSheet._errorRed
                          : borderColor,
                      width: _isAmountBelowMin ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      SarCurrencyWidget(
                        size: 20,
                        color: _isAmountBelowMin
                            ? MarketerBankTransferSheet._errorRed
                            : (isDark ? Colors.white : MarketerBankTransferSheet._darkText),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          focusNode: _amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : MarketerBankTransferSheet._darkText,
                          ),
                          decoration: InputDecoration(
                            hintText: '200',
                            hintStyle: TextStyle(
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Warning message for Amount (Figma 9054:70262 / 70297)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 4, left: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: _isAmountBelowMin
                            ? MarketerBankTransferSheet._errorRed
                            : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'min_transfer_warning'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isAmountBelowMin
                              ? MarketerBankTransferSheet._errorRed
                              : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Bank Name field (Figma 9054:70265 / 70301)
                _buildFieldLabel('bank_name_label'.tr, isDark),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _popularBanks.contains(_bankNameController.text)
                          ? _bankNameController.text
                          : _popularBanks.first,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                      dropdownColor: cardBg,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : MarketerBankTransferSheet._darkText,
                      ),
                      items: _popularBanks.map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _bankNameController.text = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Triple name of account holder (Figma 9054:70269 / 70306)
                _buildFieldLabel('account_holder_name_label'.tr, isDark),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: TextField(
                    controller: _accountHolderController,
                    focusNode: _holderFocus,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : MarketerBankTransferSheet._darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'account_holder_name_label'.tr,
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. IBAN Number field (Figma 9054:70273 / 70314 / 70372)
                _buildFieldLabel('iban_label'.tr, isDark),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isIbanInvalid ? MarketerBankTransferSheet._errorRed : borderColor,
                      width: _isIbanInvalid ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'SA',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ibanController,
                          focusNode: _ibanFocus,
                          keyboardType: TextInputType.text,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark ? Colors.white : MarketerBankTransferSheet._darkText,
                          ),
                          decoration: InputDecoration(
                            hintText: '5285 5285 5285 5285',
                            hintStyle: TextStyle(
                              letterSpacing: 1.0,
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isIbanInvalid)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 4, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 15,
                          color: MarketerBankTransferSheet._errorRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'invalid_iban_warning'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: MarketerBankTransferSheet._errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Submit Button (Figma 9054:70278 / 70342 / 70397)
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MarketerBankTransferSheet._primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'save_action'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : MarketerBankTransferSheet._darkText,
      ),
    );
  }
}
