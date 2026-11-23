import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

/// Modal Bottom Sheet for Bank Transfer matching Figma node 9632:35339 ("التحويل البنكي")
/// Connected to real Backend API:
/// - GET  /api/v1/customer/marketer/withdrawals (saved bank info + min withdrawal amount)
/// - POST /api/v1/customer/marketer/withdraw    (creates real withdrawal request & updates balance)
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
  double _minWithdrawalAmount = 200.0;
  double _withdrawableBalance = 0.0;

  final List<String> _popularBanks = [
    'البنك الأهلي السعودي',
    'مصرف الراجحي',
    'بنك الرياض',
    'مصرف الإنماء',
    'البنك السعودي الأول (SAB)',
    'البنك العربي الوطني',
    'بنك البلاد',
    'بنك الجزيرة',
  ];

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<MarketerController>()) {
      final mc = Get.find<MarketerController>();
      _minWithdrawalAmount = mc.minTransferAmount;
      _withdrawableBalance = mc.balance;
    }
    if (Get.isRegistered<ProfileController>()) {
      final userInfo = Get.find<ProfileController>().userInfoModel;
      final fullName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
      if (fullName.isNotEmpty) {
        _accountHolderController.text = fullName;
      }
    }
    _bankNameController.text = _popularBanks.first;
    _loadSavedWithdrawalInfo();
  }

  Future<void> _loadSavedWithdrawalInfo() async {
    if (!Get.isRegistered<MarketerController>()) return;
    final info = await Get.find<MarketerController>().loadWithdrawals();
    if (!mounted || info == null) return;
    setState(() {
      if (info['withdrawable_balance'] != null) {
        _withdrawableBalance = double.tryParse('${info['withdrawable_balance']}') ?? _withdrawableBalance;
      }
      if (info['withdrawal_settings'] is Map) {
        final settings = info['withdrawal_settings'] as Map;
        if (settings['min_withdrawal_amount'] != null) {
          _minWithdrawalAmount = double.tryParse('${settings['min_withdrawal_amount']}') ?? _minWithdrawalAmount;
        }
      }
      if (info['saved_bank_info'] is Map) {
        final bank = info['saved_bank_info'] as Map;
        final savedBankName = bank['bank_name']?.toString().trim() ?? '';
        final savedHolder = bank['beneficiary_name']?.toString().trim() ?? '';
        final savedIban = bank['iban']?.toString().trim() ?? '';
        if (savedBankName.isNotEmpty) {
          if (!_popularBanks.contains(savedBankName)) {
            _popularBanks.insert(0, savedBankName);
          }
          _bankNameController.text = savedBankName;
        }
        if (savedHolder.isNotEmpty) {
          _accountHolderController.text = savedHolder;
        }
        if (savedIban.isNotEmpty) {
          _ibanController.text = savedIban.toUpperCase().startsWith('SA')
              ? savedIban.substring(2)
              : savedIban;
        }
      }
    });
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
  bool get _isAmountBelowMin =>
      _amountController.text.isNotEmpty && _enteredAmount < _minWithdrawalAmount;
  bool get _isAmountAboveBalance =>
      _amountController.text.isNotEmpty && _withdrawableBalance > 0 && _enteredAmount > _withdrawableBalance;

  String get _cleanIbanDigits => _ibanController.text.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  bool get _isIbanInvalid {
    if (_ibanController.text.trim().isEmpty) return false;
    final full = _cleanIbanDigits.startsWith('SA') ? _cleanIbanDigits : 'SA$_cleanIbanDigits';
    return !RegExp(r'^SA[0-9]{22}$').hasMatch(full) && !RegExp(r'^[A-Z]{2}[0-9A-Z]{13,32}$').hasMatch(full);
  }

  Future<void> _submit() async {
    final amount = _enteredAmount;
    if (_amountController.text.trim().isEmpty || amount < _minWithdrawalAmount) {
      showCustomSnackBar('min_transfer_warning'.tr);
      return;
    }
    if (_withdrawableBalance > 0 && amount > _withdrawableBalance) {
      showCustomSnackBar('${'insufficient_balance'.tr} (${_withdrawableBalance.toStringAsFixed(2)})');
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

    if (!Get.isRegistered<MarketerController>()) return;

    setState(() => _isSubmitting = true);
    final result = await Get.find<MarketerController>().submitWithdrawal(
      amount: amount,
      bankName: _bankNameController.text.trim(),
      beneficiaryName: _accountHolderController.text.trim(),
      iban: _cleanIbanDigits,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.ok) {
      Navigator.of(context).pop();
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
    final headlineColor = isDark ? Colors.white : MarketerBankTransferSheet._darkText;
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
    final infoBg = isDark ? const Color(0xFF132D1B) : const Color(0xFFEBFEEB);
    final infoBorder = isDark
        ? const Color(0xFF30913F).withValues(alpha: 0.5)
        : const Color(0x8C3EC856);

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header: Title centered + Close SVG button (Figma 9632:35340)
                Row(
                  children: [
                    const SizedBox(width: 28),
                    Expanded(
                      child: Text(
                        'enter_bank_account'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: headlineColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/image/figma_bank_close.svg',
                            width: 25,
                            height: 25,
                            colorFilter: isDark
                                ? const ColorFilter.mode(Colors.white70, BlendMode.srcIn)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Green Info Banner (Figma 9632:35345)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: infoBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: infoBorder, width: 0.8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SvgPicture.asset(
                          'assets/image/figma_bank_info.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'bank_account_owner_note'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MarketerBankTransferSheet._primaryGreen,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Amount field (Figma 9632:35350)
                _buildFieldLabel('enter_transfer_amount'.tr, headlineColor),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: (_isAmountBelowMin || _isAmountAboveBalance)
                        ? Border.all(color: MarketerBankTransferSheet._errorRed, width: 1.2)
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
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
                            color: headlineColor,
                          ),
                          decoration: InputDecoration(
                            hintText: _minWithdrawalAmount.toStringAsFixed(0),
                            hintStyle: TextStyle(
                              fontFamily: 'Tajawal',
                              color: subTextColor.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/image/figma_bank_sar.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          (_isAmountBelowMin || _isAmountAboveBalance)
                              ? MarketerBankTransferSheet._errorRed
                              : headlineColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/image/figma_bank_warning.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        (_isAmountBelowMin || _isAmountAboveBalance)
                            ? MarketerBankTransferSheet._errorRed
                            : subTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _isAmountAboveBalance
                            ? '${'insufficient_balance'.tr} (${_withdrawableBalance.toStringAsFixed(0)})'
                            : 'min_transfer_warning'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: (_isAmountBelowMin || _isAmountAboveBalance)
                              ? MarketerBankTransferSheet._errorRed
                              : subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Bank Name field (Figma 9632:35360)
                _buildFieldLabel('bank_name_label'.tr, headlineColor),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _popularBanks.contains(_bankNameController.text)
                          ? _bankNameController.text
                          : _popularBanks.first,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: subTextColor,
                      ),
                      dropdownColor: surfaceBg,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: headlineColor,
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

                // 5. Account Holder Triple Name (Figma 9632:35364)
                _buildFieldLabel('account_holder_name_label'.tr, headlineColor),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _accountHolderController,
                    focusNode: _holderFocus,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: headlineColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'account_holder_name_label'.tr,
                      hintStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        color: subTextColor.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. IBAN Field (Figma 9632:35368)
                _buildFieldLabel('iban_label'.tr, headlineColor),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: _isIbanInvalid
                        ? Border.all(color: MarketerBankTransferSheet._errorRed, width: 1.2)
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Text(
                          'SA',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: subTextColor,
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
                              letterSpacing: 1.2,
                              color: headlineColor,
                            ),
                            decoration: InputDecoration(
                              hintText: '0000 0000 0000 0000 0000 00',
                              hintStyle: TextStyle(
                                letterSpacing: 0.8,
                                color: subTextColor.withValues(alpha: 0.55),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isIbanInvalid)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/image/figma_bank_warning.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            MarketerBankTransferSheet._errorRed,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'invalid_iban_warning'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MarketerBankTransferSheet._errorRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // 7. Submit Button (Figma 9632:35373 - height 48, radius 12, #30913F)
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MarketerBankTransferSheet._primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: MarketerBankTransferSheet._primaryGreen.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'save'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
