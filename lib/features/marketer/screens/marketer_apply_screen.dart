import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_success_dialog.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

class MarketerApplyScreen extends StatefulWidget {
  const MarketerApplyScreen({super.key});

  @override
  State<MarketerApplyScreen> createState() => _MarketerApplyScreenState();
}

class _MarketerApplyScreenState extends State<MarketerApplyScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);
  static const Color _inputBg = Color(0xFFF6F5F8);

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  String _countryCode = '+966';
  bool _agreedToTerms = false;
  XFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    // Prefill from user profile if available
    if (Get.isRegistered<ProfileController>()) {
      final user = Get.find<ProfileController>().userInfoModel;
      if (user != null) {
        _firstNameController.text = user.fName ?? '';
        _lastNameController.text = user.lName ?? '';
        if (user.phone != null && user.phone!.isNotEmpty) {
          String rawPhone = user.phone!;
          if (rawPhone.startsWith('+966')) {
            rawPhone = rawPhone.substring(4);
          } else if (rawPhone.startsWith('966')) {
            rawPhone = rawPhone.substring(3);
          }
          _phoneController.text = rawPhone;
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _professionController.text.trim().isNotEmpty &&
      _agreedToTerms;

  Future<void> _pickDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedFile = image;
      });
    }
  }

  void _showTermsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'terms_and_conditions'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 24),

                // Terms List
                _buildTermItem('term_1'.tr),
                const SizedBox(height: 14),
                _buildTermItem('term_2'.tr),
                const SizedBox(height: 14),
                _buildTermItem('term_3'.tr),
                const SizedBox(height: 14),
                _buildTermItem('term_4'.tr),
                const SizedBox(height: 14),
                _buildTermItem('term_5'.tr),
                const SizedBox(height: 28),

                // Done Button
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (!_agreedToTerms) {
                        setState(() {
                          _agreedToTerms = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'done'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermItem(String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.6,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    final controller = Get.find<MarketerController>();
    final fullPhone = '$_countryCode${_phoneController.text.trim()}';

    final ok = await controller.apply(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: fullPhone,
      profession: _professionController.text.trim(),
      documentFile: _selectedFile,
    );

    if (ok && mounted) {
      bool navigated = false;
      void navigateToMarketerScreen() {
        if (!navigated) {
          navigated = true;
          Get.offAll(() => const MarketerScreen());
        }
      }

      await MarketerSuccessDialog.show(context, onClose: navigateToMarketerScreen);
      navigateToMarketerScreen();
    } else {
      Get.snackbar(
        'warning'.tr,
        'failed_to_send_application'.tr,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            MarketerHeader(title: 'join_as_marketer'.tr),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'steps_to_become_marketer'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // First Name
                    _buildLabel('first_name'.tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _firstNameController,
                      hintText: 'enter_first_name_hint'.tr,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    _buildLabel('last_name'.tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _lastNameController,
                      hintText: 'enter_last_name_hint'.tr,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    _buildLabel('phone_number'.tr),
                    const SizedBox(height: 8),
                    _buildPhoneField(),
                    const SizedBox(height: 16),

                    // Profession
                    _buildLabel('profession'.tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _professionController,
                      hintText: 'enter_profession_hint'.tr,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Documents Upload
                    Text(
                      'documents'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'documents_desc'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDottedDocumentUploader(),
                    const SizedBox(height: 20),

                    // Terms and conditions checkbox
                    _buildTermsCheckbox(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Submit Button
            GetBuilder<MarketerController>(
              builder: (c) {
                final enabled = _isFormValid && !c.isSubmitting;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: enabled ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: enabled ? _primaryGreen : const Color(0xFFE2E4E6),
                        foregroundColor: enabled ? Colors.white : const Color(0xFF888888),
                        disabledBackgroundColor: const Color(0xFFE2E4E6),
                        disabledForegroundColor: const Color(0xFF888888),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: c.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'submit_application'.tr,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _darkText,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF999999),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      // Force LTR so the flag + dial code sit on the left and "+966" renders
      // correctly (RTL was flipping it to "966+" and pushing the flag right).
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
        children: [
          // Selectable Country Code Picker
          CountryCodePicker(
            onChanged: (CountryCode countryCode) {
              setState(() {
                _countryCode = countryCode.dialCode ?? '+966';
              });
            },
            initialSelection: 'SA',
            favorite: const ['+966', 'SA'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            showFlag: true,
            showFlagMain: true,
            showDropDownButton: false,
            textStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Container(
            height: 24,
            width: 1,
            color: const Color(0xFFD1D5DB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: '5XXXXXXXX',
                hintStyle: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF999999),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDottedDocumentUploader() {
    return GestureDetector(
      onTap: _pickDocument,
      child: DottedBorder(
        color: const Color(0xFFC6C8CE),
        strokeWidth: 1.3,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (_selectedFile != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 22),
                )
              else
                const Icon(
                  IconlyLight.plus,
                  color: _primaryGreen,
                  size: 22,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.name
                          : 'choose_file_and_add'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'file_upload_hint'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  IconlyLight.document,
                  color: Color(0xFF6B7280),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: _primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) {
              setState(() {
                _agreedToTerms = val ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'terms_agree_prefix'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _darkText,
                  ),
                ),
                TextSpan(
                  text: 'terms_agree_link'.tr,
                  recognizer: TapGestureRecognizer()..onTap = _showTermsBottomSheet,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                    decoration: TextDecoration.underline,
                    decorationColor: _primaryGreen,
                  ),
                ),
                TextSpan(
                  text: 'terms_agree_suffix'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
