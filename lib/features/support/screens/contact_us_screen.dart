import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/support/controllers/support_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _subjectNode = FocusNode();
  final FocusNode _messageNode = FocusNode();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _titleColor => _isDark ? Colors.white : const Color(0xFF2D3633);
  Color get _subtitleColor => const Color(0xFF8A9199);
  Color get _cardColor => _isDark ? const Color(0xFF1E293B) : Colors.white;

  @override
  void initState() {
    super.initState();
    // Pre-fill if we want, but actually we will just not show them and pass the data from ProfileController when submitting
  }

  void _submitForm(SupportController supportController,
      ProfileController profileController) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String subject = _subjectController.text.trim();
    String message = _messageController.text.trim();

    final userInfo = profileController.userInfoModel;

    bool needsName =
        userInfo == null || userInfo.fName == null || userInfo.fName!.isEmpty;
    bool needsEmail =
        userInfo == null || userInfo.email == null || userInfo.email!.isEmpty;
    bool needsPhone =
        userInfo == null || userInfo.phone == null || userInfo.phone!.isEmpty;

    if (needsName && name.isEmpty) {
      showCustomSnackBar('please_enter_your_name'.tr);
      return;
    }
    if (needsEmail && email.isEmpty) {
      showCustomSnackBar('please_enter_email'.tr);
      return;
    }
    if (needsEmail && !GetUtils.isEmail(email)) {
      showCustomSnackBar('invalid_email_address'.tr);
      return;
    }
    if (needsPhone && phone.isEmpty) {
      showCustomSnackBar('please_enter_phone_number'.tr);
      return;
    }
    if (subject.isEmpty) {
      showCustomSnackBar('please_enter_subject'.tr);
      return;
    }
    if (message.isEmpty) {
      showCustomSnackBar('please_enter_message'.tr);
      return;
    }

    Map<String, String> data = {
      'subject': subject,
      'message': message,
    };

    if (needsName) data['name'] = name;
    if (needsEmail) data['email'] = email;
    if (needsPhone) data['phone'] = phone;

    final response = await supportController.submitSupportRequest(data);
    if (response.isSuccess) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 60, color: Theme.of(context).primaryColor),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(
                    'support_request_sent_successfully'.tr,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    'support_request_sent_desc'.tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                        color: _subtitleColor,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomButton(
                    buttonText: 'ok'.tr,
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // close screen
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'help_and_technical_support'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: _titleColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final userInfo = profileController.userInfoModel;
        bool needsName = userInfo == null ||
            userInfo.fName == null ||
            userInfo.fName!.isEmpty;
        bool needsEmail = userInfo == null ||
            userInfo.email == null ||
            userInfo.email!.isEmpty;
        bool needsPhone = userInfo == null ||
            userInfo.phone == null ||
            userInfo.phone!.isEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(Images.shellaLogo,
                        width: 100, height: 70, fit: BoxFit.contain),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'how_can_we_help_you'.tr,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: _titleColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'support_hero_desc'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: _subtitleColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Form
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (needsName) ...[
                      Text('name'.tr,
                          style: robotoMedium.copyWith(color: _titleColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      CustomTextField(
                        hintText: 'write_something'.tr,
                        controller: _nameController,
                        focusNode: _nameNode,
                        nextFocus: needsEmail
                            ? _emailNode
                            : (needsPhone ? _phoneNode : _subjectNode),
                        inputType: TextInputType.name,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                    if (needsEmail) ...[
                      Text('email'.tr,
                          style: robotoMedium.copyWith(color: _titleColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      CustomTextField(
                        hintText: 'write_something'.tr,
                        controller: _emailController,
                        focusNode: _emailNode,
                        nextFocus: needsPhone ? _phoneNode : _subjectNode,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                    if (needsPhone) ...[
                      Text('phone'.tr,
                          style: robotoMedium.copyWith(color: _titleColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      CustomTextField(
                        hintText: 'write_something'.tr,
                        controller: _phoneController,
                        focusNode: _phoneNode,
                        nextFocus: _subjectNode,
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                    Text('message_subject'.tr,
                        style: robotoMedium.copyWith(color: _titleColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    CustomTextField(
                      hintText: 'write_something'.tr,
                      controller: _subjectController,
                      focusNode: _subjectNode,
                      nextFocus: _messageNode,
                      inputType: TextInputType.text,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Text('message'.tr,
                        style: robotoMedium.copyWith(color: _titleColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    CustomTextField(
                      hintText: 'write_something'.tr,
                      controller: _messageController,
                      focusNode: _messageNode,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.multiline,
                      maxLines: 5,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    GetBuilder<SupportController>(builder: (supportController) {
                      return CustomButton(
                        buttonText: 'send_request'.tr,
                        isLoading: supportController.isLoading,
                        onPressed: () =>
                            _submitForm(supportController, profileController),
                        icon: Icons.send,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        );
      }),
    );
  }
}
