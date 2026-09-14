import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/util/app_colors.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String _trashSvg =
    '''<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M15.75 4.48499C13.2525 4.23749 10.74 4.10999 8.235 4.10999C6.75 4.10999 5.265 4.18499 3.78 4.33499L2.25 4.48499" stroke="#EE4444" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.375 3.7275L6.54 2.745C6.66 2.0325 6.75 1.5 8.0175 1.5H9.9825C11.25 1.5 11.3475 2.0625 11.46 2.7525L11.625 3.7275" stroke="#EE4444" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M14.1373 6.85498L13.6498 14.4075C13.5673 15.585 13.4998 16.5 11.4073 16.5H6.5923C4.4998 16.5 4.4323 15.585 4.3498 14.4075L3.8623 6.85498" stroke="#EE4444" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M7.74756 12.375H10.2451" stroke="#EE4444" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M7.125 9.375H10.875" stroke="#EE4444" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

const String _documentSvg =
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M22 10V15C22 20 20 22 15 22H9C4 22 2 20 2 15V9C2 4 4 2 9 2H14" stroke="#111B18" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M22 10H18C15 10 14 9 14 6V2L22 10Z" stroke="#111B18" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

class CreditReviewScreen extends StatelessWidget {
  const CreditReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (controller) {
        final fullName = controller.fullNameController.text.isNotEmpty
            ? controller.fullNameController.text
            : '${controller.firstname.text} ${controller.fathername.text} ${controller.grandfathername.text} ${controller.last_name.text}'
                .trim();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.wtColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              'review_credit_file'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3633),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF2D3633), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  'review_your_data_carefully_before_submitting'.tr,
                  style: font10Grey500W(context, size: 12).copyWith(
                    color: const Color(0xFF707070),
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card 1: Personal Information ───────────────────────────────
                _reviewCardHeader('personal_information_title'.tr, onEdit: () {
                  controller.backStage();
                  Get.back();
                }),
                const SizedBox(height: 8),
                _cardContainer(
                  child: Column(
                    children: [
                      _dataRow('full_name_as_in_id'.tr, fullName),
                      _dataRow('date_of_birth'.tr, controller.birthDate),
                      _dataRow(
                          'select_nationality'.tr,
                          controller.nationality.isNotEmpty
                              ? controller.nationality
                              : 'سعودي'),
                      _dataRow('marital_status'.tr,
                          _mapMaritalStatus(controller.marital_status)),
                      _dataRow('number_of_family_members'.tr,
                          controller.number_of_family_members.text),
                      _dataRow('id_card_number'.tr,
                          controller.identity_card_number.text),
                      _dataRow('expiry_date'.tr, controller.end_date),
                      _dataRow(
                          'phone_number'.tr,
                          controller.phoneController.text.isNotEmpty
                              ? '+966 ${controller.phoneController.text}'
                              : 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card 2: Housing Details ─────────────────────────────────────
                _reviewCardHeader('housing_details_title'.tr, onEdit: () {
                  controller.backStage();
                }),
                const SizedBox(height: 8),
                _cardContainer(
                  child: Column(
                    children: [
                      _dataRow(
                          'house_type'.tr,
                          controller.house_type.isNotEmpty
                              ? controller.house_type
                              : 'house_type'.tr),
                      _dataRow('building_number'.tr, '22'),
                      _dataRow('national_address'.tr,
                          '${controller.city.isNotEmpty ? controller.city : ""} ${controller.neighborhood.text.isNotEmpty ? controller.neighborhood.text : ""}'),
                      _dataRow('postal_code'.tr, '12345'),
                      _dataRow(
                          'housing_type'.tr,
                          controller.home_ownership == 'rent'
                              ? 'rent'.tr
                              : 'own'.tr),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card 3: Documents ──────────────────────────────────────────
                _reviewCardHeader('attach_documents'.tr, onEdit: () {
                  controller.backStage();
                  Get.back();
                }),
                const SizedBox(height: 8),
                _cardContainer(
                  child: controller.personalDocuments.isEmpty
                      ? Center(
                          child: Text(
                            'no_documents_attached'.tr,
                            style: const TextStyle(
                                fontFamily: 'Tajawal',
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                        )
                      : Column(
                          children: controller.personalDocuments
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            var doc = entry.value;
                            double sizeInMb = doc.file.size / (1024 * 1024);
                            String sizeStr =
                                '${sizeInMb.toStringAsFixed(1)} MB';
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: idx ==
                                          controller.personalDocuments.length -
                                              1
                                      ? 0.0
                                      : 8.0),
                              child: _uploadedFileBox(doc.name, sizeStr,
                                  onDelete: () {
                                controller.removeDocument(idx, isIncome: false);
                              }),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),

                // ── Card 4: Income Source ───────────────────────────────────────
                _reviewCardHeader('income_source'.tr, onEdit: () {
                  Get.back();
                }),
                const SizedBox(height: 8),
                _cardContainer(
                  child: Column(
                    children: [
                      _dataRow(
                          'select_main_income_source'.tr,
                          controller.jobSpecification.isNotEmpty
                              ? controller.jobSpecification
                              : '-'),
                      _dataRow(
                          'employer_name'.tr,
                          controller.name_of_employer.text.isNotEmpty
                              ? controller.name_of_employer.text
                              : '-'),
                      _dataRowWithBadge(
                          'monthly_income'.tr,
                          '${controller.monthlyIncome.text.isNotEmpty ? controller.monthlyIncome.text : "0"} ${"sar".tr}',
                          'unverified'.tr),
                      _dataRow(
                          'what_is_your_salary_day'.tr,
                          controller.salary_day.text.isNotEmpty
                              ? controller.salary_day.text
                              : '1'),
                      _dataRow(
                          'do_you_have_installments'.tr,
                          controller.Installments == 'yes'
                              ? 'yes'.tr
                              : 'no'.tr),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card 5: Documents ──────────────────────────────────────────
                _reviewCardHeader('attach_documents'.tr, onEdit: () {
                  Get.back();
                }),
                const SizedBox(height: 8),
                _cardContainer(
                  child: controller.incomeDocuments.isEmpty
                      ? Center(
                          child: Text(
                            'no_documents_attached'.tr,
                            style: const TextStyle(
                                fontFamily: 'Tajawal',
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                        )
                      : Column(
                          children: controller.incomeDocuments
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            var doc = entry.value;
                            double sizeInMb = doc.file.size / (1024 * 1024);
                            String sizeStr =
                                '${sizeInMb.toStringAsFixed(1)} MB';
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: idx ==
                                          controller.incomeDocuments.length - 1
                                      ? 0.0
                                      : 8.0),
                              child: _uploadedFileBox(doc.name, sizeStr,
                                  onDelete: () {
                                controller.removeDocument(idx, isIncome: true);
                              }),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 24),

                // ── Submit Button ──────────────────────────────────────────────
                CustomButton(
                  buttonText: 'submit_request'.tr,
                  isLoading: controller.isLoading,
                  onPressed: () async {
                    bool success = await controller
                        .validate_Fields_Screen_Combined(context);
                    if (success) {
                      Get.back();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewCardHeader(String title, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: tajawalBold.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF707070),
          ),
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined,
                size: 18, color: Color(0xFF707070)),
          ),
      ],
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E8)),
      ),
      child: child,
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B18),
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : '-',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF707070),
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataRowWithBadge(String label, String value, String badgeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111B18),
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E5E8)),
                  ),
                  child: Text(
                    badgeText,
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF9AA0A6)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B18),
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadedFileBox(String fileName, String fileSize,
      {required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greenColor),
      ),
      child: Row(
        children: [
          SvgPicture.string(_documentSvg,
              colorFilter: const ColorFilter.mode(
                  AppColors.greenColor, BlendMode.srcIn)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111B18),
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  '${"image_size".tr} $fileSize',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF707070),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: SvgPicture.string(_trashSvg),
          ),
        ],
      ),
    );
  }

  String _mapMaritalStatus(String status) {
    switch (status) {
      case 'single':
        return 'single'.tr;
      case 'married':
        return 'married'.tr;
      case 'absolute':
        return 'divorced'.tr;
      default:
        return status.isNotEmpty ? status : 'single'.tr;
    }
  }
}
