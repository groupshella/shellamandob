// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/labeled_input_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/dual_date_picker_field.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/file_upload_widget.dart';
import 'package:sixam_mart/util/styles.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final kaidhaController = Get.find<KaidhaSubscriptionController>();
      final profileController = Get.find<ProfileController>();

      if (profileController.userInfoModel == null) {
        await profileController.getUserInfo();
      }
      final userInfo = profileController.userInfoModel;

      if (userInfo != null) {
        if (kaidhaController.firstname.text.trim().isEmpty &&
            (userInfo.fName?.isNotEmpty ?? false)) {
          kaidhaController.firstname.text = userInfo.fName!;
        }
        if (kaidhaController.last_name.text.trim().isEmpty &&
            (userInfo.lName?.isNotEmpty ?? false)) {
          kaidhaController.last_name.text = userInfo.lName!;
        }
      }

      final profilePhone = userInfo?.phone?.toString().trim();
      final authPhone = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().getUserNumber().trim()
          : '';
      final phone =
          (profilePhone != null && profilePhone.isNotEmpty) ? profilePhone : authPhone;
      if (kaidhaController.phoneController.text.trim().isEmpty &&
          phone.isNotEmpty) {
        // Store only local digits (strip country-code prefix so the input
        // field shows just the local number, e.g. 599966674 for Saudi).
        final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
        final codeDigits = kaidhaController.selectedCountryDialCode
            .replaceAll(RegExp(r'\D'), ''); // e.g. "966"
        final local = digitsOnly.startsWith(codeDigits)
            ? digitsOnly.substring(codeDigits.length)
            : digitsOnly.startsWith('0')
                ? digitsOnly.substring(1)
                : digitsOnly;
        kaidhaController.phoneController.text = local;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    // الدول العربية

    final List<Map<String, dynamic>> nationalities = [
      {'name': 'select_nationality'.tr, 'code': '', 'flag': ''},

      {
        'name': Get.locale?.languageCode == 'ar' ? 'جزائري' : 'Algerian',
        'code': 'DZ',
        'flag': '🇩🇿'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'بحريني' : 'Bahraini',
        'code': 'BH',
        'flag': '🇧🇭'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'جزر القمر' : 'Comorian',
        'code': 'KM',
        'flag': '🇰🇲'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'جيبوتي' : 'Djiboutian',
        'code': 'DJ',
        'flag': '🇩🇯'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'مصري' : 'Egyptian',
        'code': 'EG',
        'flag': '🇪🇬'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'عراقي' : 'Iraqi',
        'code': 'IQ',
        'flag': '🇮🇶'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'أردني' : 'Jordanian',
        'code': 'JO',
        'flag': '🇯🇴'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'كويتي' : 'Kuwaiti',
        'code': 'KW',
        'flag': '🇰🇼'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'لبناني' : 'Lebanese',
        'code': 'LB',
        'flag': '🇱🇧'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'ليبي' : 'Libyan',
        'code': 'LY',
        'flag': '🇱🇾'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'موريتاني' : 'Mauritanian',
        'code': 'MR',
        'flag': '🇲🇷'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'مغربي' : 'Moroccan',
        'code': 'MA',
        'flag': '🇲🇦'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'عماني' : 'Omani',
        'code': 'OM',
        'flag': '🇴🇲'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'فلسطيني' : 'Palestinian',
        'code': 'PS',
        'flag': '🇵🇸'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'قطري' : 'Qatari',
        'code': 'QA',
        'flag': '🇶🇦'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'سعودي' : 'Saudi',
        'code': 'SA',
        'flag': '🇸🇦'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'صومالي' : 'Somali',
        'code': 'SO',
        'flag': '🇸🇴'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'سوداني' : 'Sudanese',
        'code': 'SD',
        'flag': '🇸🇩'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'سوري' : 'Syrian',
        'code': 'SY',
        'flag': '🇸🇾'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'تونسي' : 'Tunisian',
        'code': 'TN',
        'flag': '🇹🇳'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'إماراتي' : 'Emirati',
        'code': 'AE',
        'flag': '🇦🇪'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'يمني' : 'Yemeni',
        'code': 'YE',
        'flag': '🇾🇪'
      },

      // دول رئيسية أخرى
      {
        'name': Get.locale?.languageCode == 'ar' ? 'أمريكي' : 'American',
        'code': 'US',
        'flag': '🇺🇸'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'أسترالي' : 'Australian',
        'code': 'AU',
        'flag': '🇦🇺'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'برازيلي' : 'Brazilian',
        'code': 'BR',
        'flag': '🇧🇷'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'بريطاني' : 'British',
        'code': 'GB',
        'flag': '🇬🇧'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'كندي' : 'Canadian',
        'code': 'CA',
        'flag': '🇨🇦'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'صيني' : 'Chinese',
        'code': 'CN',
        'flag': '🇨🇳'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'فرنسي' : 'French',
        'code': 'FR',
        'flag': '🇫🇷'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'ألماني' : 'German',
        'code': 'DE',
        'flag': '🇩🇪'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'هندي' : 'Indian',
        'code': 'IN',
        'flag': '🇮🇳'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'إيطالي' : 'Italian',
        'code': 'IT',
        'flag': '🇮🇹'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'ياباني' : 'Japanese',
        'code': 'JP',
        'flag': '🇯🇵'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'روسي' : 'Russian',
        'code': 'RU',
        'flag': '🇷🇺'
      },
      {
        'name':
            Get.locale?.languageCode == 'ar' ? 'جنوب أفريقي' : 'South African',
        'code': 'ZA',
        'flag': '🇿🇦'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'إسباني' : 'Spanish',
        'code': 'ES',
        'flag': '🇪🇸'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'تركي' : 'Turkish',
        'code': 'TR',
        'flag': '🇹🇷'
      },
    ];

    return GetBuilder<KaidhaSubscriptionController>(
        builder: (KaidhaSub_Controller) {
      return Form(
        key: KaidhaSub_Controller.formstate,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('personal_information'.tr),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  // Full Name
                  _customTextFormAuth(
                    KaidhaSub_Controller,
                    context: context,
                    text: 'full_name_as_in_id'.tr,
                    hintText: (Get.locale?.languageCode == 'ar')
                        ? 'enter_full_name_as_in_id'.tr
                        : 'Enter your full name as in ID',
                    mycontroller: KaidhaSub_Controller.fullNameController,
                    focusNode: KaidhaSub_Controller.firstNameFocus,
                    isEmpty: KaidhaSub_Controller.isFullNameEmpty,
                  ),
                  const SizedBox(height: 14),

                  // Dual Birth Date Field (Hijri + Gregorian)
                  DualDatePickerField(
                    label: 'birth_date'.tr,
                    isoDateValue: KaidhaSub_Controller.birthDate,
                    isBirthDate: true,
                    hasError: KaidhaSub_Controller.isBirthDateEmpty,
                    errorMessage: (Get.locale?.languageCode == 'ar')
                        ? 'please_select_birth_date'.tr
                        : 'Please select date of birth',
                    scrollKey: KaidhaSubscriptionController.birthDateKey,
                    focusNode: KaidhaSub_Controller.birthDateFocus,
                    onDateSelected: (isoDate) {
                      KaidhaSub_Controller.updateBirthDate(isoDate);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Nationality Dropdown
                  _buildNationalityDropdown(context, KaidhaSub_Controller, nationalities),
                  const SizedBox(height: 14),

                  // Marital Status (Horizontal Radio)
                  _buildMaritalStatusRadio(context),
                  const SizedBox(height: 14),

                  // Family Members Count
                  _custom_number(
                    KaidhaSub_Controller,
                    mycontroller: KaidhaSub_Controller.number_of_family_members,
                    disallowZero: true,
                    text: 'number_of_family_members'.tr,
                    context: context,
                    focusNode: KaidhaSub_Controller.numberOfFamilyFocus,
                    containerKey: KaidhaSubscriptionController.numberOfFamilyKey,
                    isEmpty: KaidhaSub_Controller.isNumberOfFamilyEmpty,
                  ),
                  const SizedBox(height: 14),

                  // National ID / Iqama Number
                  _custom_number(
                    KaidhaSub_Controller,
                    hintText: 'ten_digits_example'.tr,
                    obscureText: false,
                    mycontroller: KaidhaSub_Controller.identity_card_number,
                    text: 'identity_card_number'.tr,
                    context: context,
                    focusNode: KaidhaSub_Controller.identityCardFocus,
                    containerKey: KaidhaSubscriptionController.identityCardKey,
                    isEmpty: KaidhaSub_Controller.isIdentityCardEmpty,
                    isInvalid: KaidhaSub_Controller.isIdentityCardInvalid,
                    errorKey: 'identity_card_number',
                    errorText: KaidhaSub_Controller.fieldErrors['identity_card_number'],
                  ),
                  const SizedBox(height: 14),

                  // ID Expiry Date (Hijri + Gregorian)
                  DualDatePickerField(
                    label: 'identity_card_expiry'.tr,
                    isoDateValue: KaidhaSub_Controller.end_date,
                    isBirthDate: false,
                    hasError: KaidhaSub_Controller.isEndDateEmpty,
                    errorMessage: (Get.locale?.languageCode == 'ar')
                        ? 'please_select_expiry_date'.tr
                        : 'Please select expiry date',
                    scrollKey: KaidhaSubscriptionController.endDateKey,
                    focusNode: KaidhaSub_Controller.endDateFocus,
                    onDateSelected: (isoDate) {
                      KaidhaSub_Controller.updateExpirationDate(isoDate);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Phone Field
                  _buildPhoneField(context, KaidhaSub_Controller),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('housing_data'.tr),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  // House Type (Horizontal Radio)
                  _buildHouseType(context),
                  const SizedBox(height: 14),

                  // Building Number
                  _customTextFormAuth(
                    KaidhaSub_Controller,
                    mycontroller: KaidhaSub_Controller.building_number,
                    text: 'building_number'.tr,
                    hintText: 'enter_building_number'.tr,
                    context: context,
                    focusNode: null,
                    isEmpty: false,
                  ),
                  const SizedBox(height: 14),

                  // City Selection
                  _buildCitySelection(context),
                  const SizedBox(height: 14),

                  // Street Name
                  _customTextFormAuth(
                    KaidhaSub_Controller,
                    mycontroller: KaidhaSub_Controller.street_name,
                    text: 'street_name'.tr,
                    hintText: 'enter_street_name'.tr,
                    context: context,
                    focusNode: null,
                    isEmpty: false,
                  ),
                  const SizedBox(height: 14),

                  // Neighborhood
                  _customTextFormAuth(
                    KaidhaSub_Controller,
                    mycontroller: KaidhaSub_Controller.neighborhood,
                    text: 'neighborhood'.tr,
                    hintText: 'enter_neighborhood_name'.tr,
                    context: context,
                    focusNode: KaidhaSub_Controller.neighborhoodFocus,
                    isEmpty: KaidhaSub_Controller.isNeighborhoodEmpty,
                  ),
                  const SizedBox(height: 14),

                  // Postal Code
                  _customTextFormAuth(
                    KaidhaSub_Controller,
                    isNumber: true,
                    mycontroller: KaidhaSub_Controller.postal_code,
                    text: 'postal_code'.tr,
                    hintText: 'enter_postal_code'.tr,
                    context: context,
                    focusNode: null,
                    isEmpty: false,
                  ),
                  const SizedBox(height: 14),

                  // Housing Ownership (Horizontal Radio)
                  _buildHousingOwnershipRadio(context),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('المستندات'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FileUploadWithNameWidget(
                isIncome: false,
                instruction: 'attach_documents_instruction'.tr,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF30913F),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: tajawalBold.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111B18),
          ),
        ),
      ],
    );
  }

  Widget _buildNationalityDropdown(
    BuildContext context,
    KaidhaSubscriptionController ctrl,
    List<Map<String, dynamic>> nationalities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(
              'select_nationality'.tr,
              style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Focus(
          focusNode: ctrl.nationalityFocus,
          child: Container(
            key: KaidhaSubscriptionController.nationalityKey,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ctrl.isNationalityEmpty ? Colors.red : const Color(0xFFE5E7EB),
                width: ctrl.isNationalityEmpty ? 1.5 : 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (nationalities.firstWhere(
                  (c) => c['name'] == ctrl.nationality,
                  orElse: () => {'code': null},
                )['code'] as String?),
                icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6B7280)),
                isExpanded: true,
                hint: Text(
                  'select_nationality'.tr,
                  style: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
                ),
                onChanged: (String? newCode) {
                  if (newCode != null && newCode.isNotEmpty) {
                    final selectedCountry = nationalities.firstWhere(
                      (country) => country['code'] == newCode,
                      orElse: () => {'name': '', 'code': '', 'flag': ''},
                    );
                    ctrl.updateNationality((selectedCountry['name'] as String?) ?? '');
                  }
                },
                items: nationalities.map((country) {
                  final code = country['code'] ?? '';
                  final name = country['name'] ?? '';
                  final flag = country['flag'] ?? '';
                  return DropdownMenuItem<String>(
                    value: code.toString(),
                    child: Row(
                      children: [
                        if (flag.toString().isNotEmpty)
                          Text(flag.toString(), style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          name.toString(),
                          style: robotoMedium.copyWith(fontSize: 13, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaritalStatusRadio(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (controller) {
        final options = [
          {'label': 'single'.tr, 'value': 'single'},
          {'label': 'married'.tr, 'value': 'married'},
          {'label': 'divorced'.tr, 'value': 'absolute'},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  'marital_status'.tr,
                  style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: options.map((opt) {
                final isSelected = controller.marital_status == opt['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildRadioPill(
                      label: opt['label']!,
                      isSelected: isSelected,
                      onTap: () {
                        controller.updateMaritalStatus(opt['value']!);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHouseType(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (c) {
        final options = [
          {'label': 'house'.tr, 'value': 'منزل'},
          {'label': 'apartment'.tr, 'value': 'شقة'},
          {'label': 'villa'.tr, 'value': 'فيلا'},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  'house_type'.tr,
                  style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: options.map((opt) {
                final isSelected = c.house_type == opt['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildRadioPill(
                      label: opt['label']!,
                      isSelected: isSelected,
                      onTap: () {
                        c.updateHousetype(opt['value']!);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHousingOwnershipRadio(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (c) {
        final options = [
          {'label': 'owned'.tr, 'value': 'owned'},
          {'label': 'rent'.tr, 'value': 'rent'},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  'housing_type'.tr,
                  style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: options.map((opt) {
                final isSelected = c.home_ownership == opt['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildRadioPill(
                      label: opt['label']!,
                      isSelected: isSelected,
                      onTap: () {
                        c.updateHomeOwnership(opt['value']!);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
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
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF6F5F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF30913F) : const Color(0xFFE5E7EB),
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
                  color: isSelected ? const Color(0xFF30913F) : const Color(0xFF9CA3AF),
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
                  color: isSelected ? const Color(0xFF30913F) : const Color(0xFF374151),
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

  Widget _buildCitySelection(BuildContext context) {
    // Saudi cities list - display names change based on language, but values stay consistent
    final List<Map<String, String>> cities = [
      {'name': 'select_city'.tr, 'value': ''},
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الرياض' : 'Riyadh',
        'value': 'الرياض'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'جدة' : 'Jeddah',
        'value': 'جدة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'مكة' : 'Makkah',
        'value': 'مكة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'المدينة' : 'Madinah',
        'value': 'المدينة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الدمام' : 'Dammam',
        'value': 'الدمام'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الطائف' : 'Taif',
        'value': 'الطائف'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'تبوك' : 'Tabuk',
        'value': 'تبوك'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'بريدة' : 'Buraydah',
        'value': 'بريدة'
      },
      {
        'name':
            Get.locale?.languageCode == 'ar' ? 'خميس مشيط' : 'Khamis Mushait',
        'value': 'خميس مشيط'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الهفوف' : 'Al-Hufuf',
        'value': 'الهفوف'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'المبرز' : 'Al-Mubarraz',
        'value': 'المبرز'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'حائل' : 'Hail',
        'value': 'حائل'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'نجران' : 'Najran',
        'value': 'نجران'
      },
      {
        'name':
            Get.locale?.languageCode == 'ar' ? 'حفر الباطن' : 'Hafar Al-Batin',
        'value': 'حفر الباطن'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الجبيل' : 'Jubayl',
        'value': 'الجبيل'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'أبها' : 'Abha',
        'value': 'أبها'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الخرج' : 'Al Khardj',
        'value': 'الخرج'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الثقبة' : 'Tuqba',
        'value': 'الثقبة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'ينبع البحر' : 'Yanbu',
        'value': 'ينبع البحر'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الخبر' : 'Khobar',
        'value': 'الخبر'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'عرعر' : 'Arar',
        'value': 'عرعر'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الحوية' : 'Al-Hawiyya',
        'value': 'الحوية'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'عنيزة' : 'Unaizah',
        'value': 'عنيزة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'سكاكة' : 'Sakaka',
        'value': 'سكاكة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'جيزان' : 'Jizan',
        'value': 'جيزان'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'القرية' : 'Al-Qurayyat',
        'value': 'القرية'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'القطيف' : 'Al-Qatif',
        'value': 'القطيف'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الظهران' : 'Dhahran',
        'value': 'الظهران'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الباحة' : 'Al Bahah',
        'value': 'الباحة'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'تاروت' : 'Tarut',
        'value': 'تاروت'
      },
      {
        'name': Get.locale?.languageCode == 'ar' ? 'الرس' : 'Ar-Rass',
        'value': 'الرس'
      },
      {
        'name': Get.locale?.languageCode == 'ar'
            ? 'وادى الدواسر'
            : 'Wadi ad-Dawasir',
        'value': 'وادى الدواسر'
      },
    ];

    return GetBuilder<KaidhaSubscriptionController>(
      builder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(
                'city'.tr,
                style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (c.city.isNotEmpty &&
                        cities.any((city) => city['value'] == c.city))
                    ? c.city
                    : null,
                icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6B7280)),
                isExpanded: true,
                hint: Text(
                  'select_city'.tr,
                  style: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
                ),
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city['value'],
                    child: Text(
                      city['name']!,
                      style: robotoMedium.copyWith(fontSize: 13, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      c.updateCity(newValue);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _custom_number(
    KaidhaSubscriptionController KaidhaSub_Controller, {
    String? hintText,
    final bool? obscureText,
    final TextEditingController? mycontroller,
    bool disallowZero = false,
    String? errorKey,
    String? errorText,
    int maxLength = 10,
    bool isInvalid = false,
    required String text,
    required BuildContext context,
    required FocusNode focusNode,
    required GlobalKey containerKey,
    required bool isEmpty,
  }) {
    final bool hasFieldError = isEmpty || isInvalid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(
              text,
              style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Focus(
          focusNode: focusNode,
          child: Container(
            key: containerKey,
            margin: const EdgeInsets.only(bottom: 4),
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxLength),
              ],
              cursorColor: const Color(0xFF30913F),
              controller: mycontroller,
              obscureText: obscureText ?? false,
              onChanged: (value) {
                if (disallowZero && value == '0') {
                  mycontroller?.clear();
                  return;
                }
                if (errorKey != null && errorKey.isNotEmpty) {
                  KaidhaSub_Controller.clearFieldError(errorKey);
                  KaidhaSub_Controller.clearFieldError('national_id');
                }
                if (KaidhaSub_Controller.isIdentityCardInvalid) {
                  KaidhaSub_Controller.isIdentityCardInvalid = false;
                  KaidhaSub_Controller.update();
                }
                KaidhaSub_Controller.debouncedSaveState();
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
                filled: true,
                fillColor: const Color(0xFFF6F5F8),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasFieldError ? Colors.red : const Color(0xFFE5E7EB),
                    width: hasFieldError ? 1.5 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasFieldError ? Colors.red : const Color(0xFF30913F),
                    width: hasFieldError ? 1.5 : 1.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'required'.tr;
                }
                // ignore: deprecated_member_use
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'enter_numbers_only'.tr;
                }
                return null;
              },
            ),
          ),
        ),
        if (errorText != null && errorText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: robotoRegular.copyWith(
              color: Colors.red,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ] else if (isInvalid) ...[
          const SizedBox(height: 6),
          Text(
            'qidha_identity_card_must_be_10_digits'.tr,
            style: robotoRegular.copyWith(
              color: Colors.red,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _customTextFormAuth(
    KaidhaSubscriptionController KaidhaSub_Controller, {
    String? hintText,
    bool isNumber = false,
    TextEditingController? mycontroller,
    required FocusNode? focusNode,
    required String text,
    required BuildContext context,
    required bool isEmpty,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LabeledInputField(
        label: text,
        hint: hintText ?? text,
        required: true,
        controller: mycontroller,
        focusNode: focusNode,
        inputType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (value) {
          KaidhaSub_Controller.debouncedSaveState();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'required'.tr;
          }
          return null;
        },
      ),
    );
  }

  /// Phone field with a country-code picker prefix + local number input.
  Widget _buildPhoneField(
      BuildContext context, KaidhaSubscriptionController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(
              'phone_number'.tr,
              style: robotoMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Focus(
          focusNode: ctrl.phoneFocus,
          child: Container(
            key: KaidhaSubscriptionController.phoneKey,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ctrl.isPhoneEmpty ? Colors.red : const Color(0xFFE5E7EB),
                width: ctrl.isPhoneEmpty ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: CountryCodePicker(
                    initialSelection: 'SA',
                    favorite: const ['+966'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: robotoMedium.copyWith(fontSize: 13, color: const Color(0xFF111B18), fontFamily: 'Tajawal'),
                    onChanged: (code) {
                      ctrl.setCountryDialCode(code.dialCode ?? '+966');
                    },
                    onInit: (code) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (code != null && code.dialCode != null) {
                          ctrl.setCountryDialCode(code.dialCode!);
                        }
                      });
                    },
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: const Color(0xFFD1D5DB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: ctrl.phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    cursorColor: const Color(0xFF30913F),
                    decoration: InputDecoration(
                      hintText: '12 234 5678',
                      hintStyle: robotoMedium.copyWith(color: const Color(0xFF9CA3AF), fontSize: 13, fontFamily: 'Tajawal'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    ),
                    onChanged: (value) {
                      ctrl.clearFieldError('mobile');
                      ctrl.debouncedSaveState();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required'.tr;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if ((ctrl.fieldErrors['mobile'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            ctrl.fieldErrors['mobile']!,
            style: robotoRegular.copyWith(
              color: Colors.red,
              fontSize: Dimensions.fontSizeSmall,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ],
    );
  }
}
