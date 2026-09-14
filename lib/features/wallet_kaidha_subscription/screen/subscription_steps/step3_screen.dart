
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/widget/before_Pdf.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/util/styles.dart';

class Step3Screen extends StatefulWidget {
  const Step3Screen({super.key});

  @override
  State<Step3Screen> createState() => _Step3ScreenState();
}

class _Step3ScreenState extends State<Step3Screen> {
  bool isExpanded = false;

  String timeNow = '';
  String dayNow = '';
  Timer? _pollTimer;
  DateTime? _pollStartTime;

  static const Color _textPrimary = Color(0xFF111B18);
  static const Color _codeNumber = Color(0xFF237D2D);
  static const Color _secondaryBtnBg = Color(0xFFF6F6F6);

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollStartTime = null;
  }

  void _startPolling(KaidhaSubscriptionController controller) {
    if (_pollTimer != null) return;
    _pollStartTime = controller.nafathRequestCreatedAt ?? DateTime.now();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final DateTime pollStart = _pollStartTime ?? DateTime.now();
      if (DateTime.now().difference(pollStart).inSeconds >= 120) {
        _stopPolling();
        return;
      }
      if (!mounted) {
        _stopPolling();
        return;
      }
      await controller.Nafath_send_checkStatus(
          context, controller.identity_card_number.text,
          silent: true,
          allowAutoRetry: false);
      final status = controller.nafath_checkStatus?.status;
      final requestId = controller.nafath_checkStatus?.requestId;
      debugPrint(
          '🔎 Nafath checkStatus: status=$status, request_id=$requestId, at=${DateTime.now().toIso8601String()}');
      if (status == 'approved' ||
          status == 'rejected' ||
          status == 'expired' ||
          status == 'cancelled' ||
          status == 'no_request') {
        _stopPolling();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initS();
    final controller = Get.find<KaidhaSubscriptionController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final nationalId = controller.identity_card_number.text.trim();
      if (nationalId.isEmpty) return;

      final statusResp = await controller.Nafath_send_checkStatus(
        context,
        nationalId,
        silent: true,
      );

      if (!mounted) return;
      if (statusResp == null ||
          statusResp.status == 'no_request' ||
          statusResp.random == null ||
          statusResp.random == 0) {
        await controller.Nafath_send_National_Id(
          context,
          nationalId,
          forceNew: true,
        );
      }
    });
  }

  Future<void> _initS() async {
    await initializeDateFormatting('ar');
    timeNow = getCurrentTime();
    dayNow = getCurrentDay();
  }

  String getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'am'.tr : 'pm'.tr;
    String timeString = '$hour12:$minute $period';
    if (Get.find<LocalizationController>().locale.languageCode == 'ar') {
      const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      for (int i = 0; i < western.length; i++) {
        timeString = timeString.replaceAll(western[i], arabicIndic[i]);
      }
    }
    return timeString;
  }

  String getCurrentDay() {
    final now = DateTime.now();
    final locale = Get.find<LocalizationController>().locale;
    final formatter = DateFormat('EEEE', locale.toString());
    return formatter.format(now);
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.9,
            offset: Offset(0, 4),
          ),
        ],
      );

  Widget _sectionHeading(String text) {
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
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  String? _resolveNafathCode(KaidhaSubscriptionController controller) {
    final String? fromStatus =
        controller.nafath_checkStatus?.random?.toString();
    if (fromStatus != null && fromStatus.isNotEmpty && fromStatus != '0') {
      return fromStatus;
    }
    final String displayCode = controller.getNafathDisplayCode();
    if (displayCode.isNotEmpty && displayCode != '0') {
      return displayCode;
    }
    final String? fromNationalId = controller.nafath_national_id?.code;
    if (fromNationalId != null && fromNationalId.isNotEmpty && fromNationalId != '0') {
      return fromNationalId;
    }
    final String? fromCache = controller.cachedNafathRequest?.code;
    if (fromCache != null && fromCache.isNotEmpty && fromCache != '0') {
      return fromCache;
    }
    return null;
  }

  Widget _nafathCodeGauge(String? code, bool isLoading) {
    return SizedBox(
      width: 220,
      height: 178,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _NafathGaugeRing(size: 155),
          if (isLoading)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _codeNumber,
              ),
            )
          else if (code != null && code.isNotEmpty)
            Text(
              code,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 52,
                fontWeight: FontWeight.w700,
                height: 62 / 52,
                color: _codeNumber,
              ),
            )
          else
            const Text(
              '--',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: _codeNumber,
              ),
            ),
        ],
      ),
    );
  }

  Widget _nafathCodeCard(KaidhaSubscriptionController controller) {
    final String? code = _resolveNafathCode(controller);
    final bool hasCode = code != null && code.isNotEmpty;
    final bool isLoading = controller.isLoading_OTP;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          _nafathCodeGauge(code, isLoading),
          const SizedBox(height: 8),
          const Text(
            'قم بإدخال هذا الكود إلى تطبيق نفاذ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 22 / 14,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasCode
                ? 'افتح تطبيق نفاذ واختر الرقم ($code) لتأكيد هويتك'
                : 'جاري جلب رمز التحقق من نفاذ...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 22 / 14,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أهلاً بك في عائلة قيدها، ونهنئك على وصولك للخطوة النهائية في رحلة انضمامك!',
            style: tajawalBold.copyWith(fontSize: 13, height: 1.6, color: _textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'يسعدنا خدمتك في هذه المرحلة الحاسمة، وهي توثيق العقد الرسمي عبر منصة "نفاذ".',
            style: robotoMedium.copyWith(fontSize: 12, height: 1.5, color: const Color(0xFF4B5563), fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 10),
          Text(
            'لتسهيل الأمر عليك، اتبع خطوات التوثيق التالية:',
            style: tajawalBold.copyWith(fontSize: 12, color: _textPrimary),
          ),
          const SizedBox(height: 6),
          _bulletPoint('1. اضغط على "استعراض العقد" للاطلاع عليه بعناية قبل التوقيع.'),
          _bulletPoint('2. تأكد من الرقم الظاهر أعلاه في مؤشر نفاذ.'),
          _bulletPoint('3. افتح تطبيق "نفاذ" في هاتفك واختر الطلب الذي يحمل نفس الرقم.'),
          _bulletPoint('4. أكمل إجراءات الموافقة، ثم اضغط "التحقق من المصادقة".'),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: robotoMedium.copyWith(
          fontSize: 12,
          height: 1.5,
          color: const Color(0xFF4B5563),
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _secondaryActionButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _secondaryBtnBg,
          disabledBackgroundColor: _secondaryBtnBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3633),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (KaidhaSubController) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final status = KaidhaSubController.nafath_checkStatus?.status;
          if (status == 'approved') {
            _stopPolling();
            return;
          }
          if (status == 'pending') {
            _startPolling(KaidhaSubController);
          } else {
            _stopPolling();
          }
        });
        
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeading('كود تطبيق نفاذ'),
              const SizedBox(height: 10),
              _nafathCodeCard(KaidhaSubController),
              const SizedBox(height: 12),
              _instructionsCard(),
              const SizedBox(height: 20),
              CustomButton(
                radius: 12,
                height: 48,
                color: const Color(0xFF30913F),
                buttonText: 'استعراض العقد قبل التوقيع',
                onPressed: () async {
                  Get.to(
                    () => Befor_Pdf_Screen(
                      time: timeNow,
                      day: dayNow,
                      name: KaidhaSubController
                              .fullNameController.text.isNotEmpty
                          ? KaidhaSubController.fullNameController.text
                          : '${KaidhaSubController.firstname.text} ${KaidhaSubController.fathername.text} ${KaidhaSubController.grandfathername.text} ${KaidhaSubController.last_name.text}',
                      identityNumber: KaidhaSubController
                          .identity_card_number.text
                          .toString(),
                      nationality:
                          KaidhaSubController.nationality.toString(),
                      neighborhood:
                          KaidhaSubController.neighborhood.text.toString(),
                      house_type:
                          KaidhaSubController.house_type.toString(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _secondaryActionButton(
                label: 'تحقق من الحالة',
                isLoading: KaidhaSubController.isLoading_Status,
                onPressed: () async {
                  await KaidhaSubController.Nafath_send_checkStatus(
                    context,
                    KaidhaSubController.identity_card_number.text,
                    silent: false,
                  );
                },
              ),
              const SizedBox(height: 10),
              _secondaryActionButton(
                label: 'التحقق من المصادقة',
                isLoading: KaidhaSubController.isLoading_OTP,
                onPressed: () async {
                  await KaidhaSubController.Nafath_send_National_Id(
                    context,
                    KaidhaSubController.identity_card_number.text,
                    forceNew: true,
                  );
                },
              ),
              if (KaidhaSubController.nafath_checkStatus != null &&
                  KaidhaSubController.nafath_checkStatus!.status ==
                      'approved')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomButton(
                    radius: 12,
                    height: 48,
                    buttonText: 'sign_contract_and_send_data'.tr,
                    onPressed: () async {
                      Get.dialog(
                        barrierDismissible: false,
                        ConfirmationDialog(
                          icon: Images.warning,
                          title: 'تأكيد توقيع العقد',
                          description:
                              'هل أنت متأكد من توقيع العقد وإرسال البيانات؟',
                          onYesPressed: () async {
                            Get.back();
                            await KaidhaSubController.Nafath_send_All_Data(
                              context,
                              KaidhaSubController.identity_card_number.text,
                              KaidhaSubController.city,
                              KaidhaSubController.neighborhood.text,
                              KaidhaSubController.house_type,
                            ).then(
                              (onValue) async {
                                debugPrint(
                                    '\x1B[32m  Contract Signing API Call   ${onValue?.statusCode}  \x1B[0m');
                                if (onValue != null &&
                                    (onValue.statusCode == 200 ||
                                        onValue.statusCode == 201 ||
                                        onValue.statusCode == 302)) {
                                  showCustomSnackBar(
                                      'wallet_created_success'.tr,
                                      isError: false);
                                  Get.toNamed(
                                      RouteHelper.getKiadaWalletSubscription());
                                } else if (onValue?.statusCode == 404) {
                                  KaidhaSubController.update_isShow();
                                  showCustomSnackBar('try_again_later'.tr);
                                } else {
                                  KaidhaSubController.update_isShow();
                                  showCustomSnackBar(
                                      'wallet_creation_error'.tr);
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NafathGaugeRing extends StatelessWidget {
  const _NafathGaugeRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NafathGaugeRingPainter(),
      ),
    );
  }
}

class _NafathGaugeRingPainter extends CustomPainter {
  static const Color _trackColor = Color(0xFFEDF2EE);
  static const Color _arcStart = Color(0xFFB9A8E8);
  static const Color _arcMid = Color(0xFF4CAF57);
  static const Color _arcEnd = Color(0xFF237D2D);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 12;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    const double strokeWidth = 16;
    final Paint trackPaint = Paint()
      ..color = _trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, trackPaint);
    final Paint arcPaint = Paint()
      ..shader = SweepGradient(
        colors: const [_arcStart, _arcMid, _arcEnd],
        stops: const [0.0, 0.35, 1.0],
        transform: GradientRotation(-math.pi * 0.85),
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      -math.pi * 0.72,
      math.pi * 1.55,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
