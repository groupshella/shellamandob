import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import '../../../../helper/route_helper.dart';
import '../../controllers/employee_navigation_controller.dart';

enum ContractFlowStage {
  review,      // Frames 8945:39779 & 8945:40547 (مراجعة العقد)
  nafathCode,  // Frame 9142:10138 (توثيق عبر نفاذ)
  waiting,     // Frame 9146:10289 (انتظار توثيق السند عبر نافذ)
  success,     // Frame 9148:10414 (تم توقيع العقد بنجاح)
  failed,      // Frame 9148:31121 (تعذر توثيق السند عبر نافذ)
}

class ContractSigningScreen extends StatefulWidget {
  final StoreVisitModel visit;

  const ContractSigningScreen({super.key, required this.visit});

  @override
  State<ContractSigningScreen> createState() => _ContractSigningScreenState();
}

class _ContractSigningScreenState extends State<ContractSigningScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  ContractFlowStage _currentStage = ContractFlowStage.review;

  bool _isAgreed = false;
  String _signedTime = '';
  String _signedDate = '';
  String _contractNumber = '';
  String _nafathCode = '54';
  String? _nafathRequestId;
  String? _nafathNationalId;

  Timer? _countdownTimer;
  Timer? _pollTimer;
  int _waitingSecondsRemaining = 90;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    try {
      final lang = Get.locale?.languageCode ?? 'ar';
      _signedDate = DateFormat('d MMMM y', lang).format(now);
      _signedTime = DateFormat('hh:mm a', lang).format(now);
    } catch (_) {
      _signedDate = '${now.day}/${now.month}/${now.year}';
      _signedTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    }
    final idPad = widget.visit.id.padLeft(4, '0');
    _contractNumber = '#CTR-${now.year}-$idPad';
    _generateRandomNafathCode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().loadContractTemplateClauses();
      }
    });
  }

  void _generateRandomNafathCode() {
    final rand = Random().nextInt(90) + 10;
    _nafathCode = rand.toString();
  }

  String _getIdentifierForNafath() {
    if (widget.visit.crNumber.trim().isNotEmpty) {
      final digits = widget.visit.crNumber.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) return digits.substring(0, 10);
    }
    if (widget.visit.phone.trim().isNotEmpty) {
      final digits = widget.visit.phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) return digits.substring(0, 10);
      if (digits.length == 9) return '1$digits';
    }
    final rawDigits = widget.visit.id.replaceAll(RegExp(r'\D'), '');
    final idNum = int.tryParse(rawDigits) ?? 1;
    return (1000000000 + (idNum % 899999999)).toString();
  }

  Future<void> _initiateNafathRequest() async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final nationalId = _getIdentifierForNafath();
        _nafathNationalId = nationalId;
        final response = await Get.find<ApiClient>().postData(
          '/api/v1/nafath/initiate',
          {'national_id': nationalId},
        );
        if (response.statusCode == 200 && response.body != null) {
          final reqId = response.body['request_id']?.toString() ??
              response.body['data']?['request_id']?.toString() ??
              response.body['transId']?.toString() ??
              response.body['data']?['transId']?.toString();
          if (reqId != null && reqId.isNotEmpty) {
            _nafathRequestId = reqId;
          }
          final code = response.body['code']?.toString() ??
              response.body['random']?.toString() ??
              response.body['data']?['random']?.toString() ??
              response.body['external_response']?[0]?['random']?.toString();
          if (code != null && code.isNotEmpty && mounted) {
            setState(() {
              _nafathCode = code;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error initiating Nafath request: $e');
    }
  }

  void _startWaitingVerification() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();

    setState(() {
      _currentStage = ContractFlowStage.waiting;
      _waitingSecondsRemaining = 90;
      _isCheckingStatus = false;
    });

    // Realistic countdown timer (every 1 second)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_waitingSecondsRemaining > 1) {
        _waitingSecondsRemaining--;
      } else {
        timer.cancel();
        _pollTimer?.cancel();
        setState(() {
          _waitingSecondsRemaining = 0;
          _currentStage = ContractFlowStage.failed;
        });
      }
    });

    // Regular polling every 6 seconds against backend
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      _checkNafathStatus(isAutoPoll: true);
    });
  }

  Future<void> _checkNafathStatus({bool isManual = false, bool isAutoPoll = false}) async {
    if (_isCheckingStatus) return;
    if (isManual) {
      setState(() {
        _isCheckingStatus = true;
      });
    }

    try {
      final nationalId = _getIdentifierForNafath();
      if (Get.isRegistered<ApiClient>()) {
        final response = await Get.find<ApiClient>().getData(
          '/api/v1/nafath/checkStatus?national_id=$nationalId',
        );

        if (response.statusCode == 200 && response.body != null) {
          final body = response.body;
          final status = (body['status'] ?? '').toString().toLowerCase();

          if (status == 'approved' || status == 'completed' || status == 'success') {
            _applyContractSuccess();
            return;
          } else if (status == 'failed' || status == 'rejected') {
            _countdownTimer?.cancel();
            _pollTimer?.cancel();
            if (mounted) {
              setState(() {
                _isCheckingStatus = false;
                _currentStage = ContractFlowStage.failed;
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Check Nafath status error: $e');
    } finally {
      if (mounted && isManual) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  void _applyContractSuccess() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    if (Get.isRegistered<StoreVisitsController>()) {
      Get.find<StoreVisitsController>().recordContractSignedReward();
    }
    if (mounted) {
      setState(() {
        _isCheckingStatus = false;
        _currentStage = ContractFlowStage.success;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        switch (_currentStage) {
          case ContractFlowStage.review:
            return _buildReviewContractScreen(isDark);
          case ContractFlowStage.nafathCode:
            return _buildNafathCodeScreen(isDark);
          case ContractFlowStage.waiting:
            return _buildWaitingScreen(isDark);
          case ContractFlowStage.success:
            return _buildSuccessScreen(isDark);
          case ContractFlowStage.failed:
            return _buildFailedScreen(isDark);
        }
      },
    );
  }

  // =========================================================================
  // 1. Figma Frames 8945:39779 & 8945:40547: مراجعة العقد
  // =========================================================================
  Widget _buildReviewContractScreen(bool isDark) {
    final screenBg = isDark ? const Color(0xFF121418) : const Color(0xFFF9FAFB);
    final appBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final bodyDark = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final headerCardBg = isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB);
    final bottomBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: darkText,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'review_contract'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card: عقد الشراكة التجارية
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: headerCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E7D32) : const Color(0x3030913F),
                  width: 0.8,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'commercial_partnership_contract'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF81C784) : const Color(0xFF236B30),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'shella_food_with'.tr} ${widget.visit.storeName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _signedDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Dynamic Clauses from Admin API Settings
            GetBuilder<StoreVisitsController>(
              builder: (visitsCtrl) {
                final clauses = visitsCtrl.dynamicContractClauses;
                if (clauses.isNotEmpty) {
                  final isAr = Get.locale?.languageCode == 'ar';
                  return Column(
                    children: clauses.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final c = entry.value;
                      final title = isAr
                          ? (c['title_ar']?.toString() ?? c['title_en']?.toString() ?? '')
                          : (c['title_en']?.toString() ?? c['title_ar']?.toString() ?? '');
                      final content = isAr
                          ? (c['content_ar']?.toString() ?? c['content_en']?.toString() ?? '')
                          : (c['content_en']?.toString() ?? c['content_ar']?.toString() ?? '');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildClauseItem(
                          number: '$idx',
                          title: title,
                          content: content,
                          cardBg: cardBg,
                          bodyDark: bodyDark,
                          subText: subText,
                        ),
                      );
                    }).toList(),
                  );
                }

                // Fallback default clauses from translation files
                return Column(
                  children: [
                    _buildClauseItem(
                      number: '1',
                      title: 'clause_1_title'.tr,
                      content: 'clause_1_content'.tr,
                      cardBg: cardBg,
                      bodyDark: bodyDark,
                      subText: subText,
                    ),
                    const SizedBox(height: 12),
                    _buildClauseItem(
                      number: '2',
                      title: 'clause_2_title'.tr,
                      content: 'clause_2_content'.tr,
                      cardBg: cardBg,
                      bodyDark: bodyDark,
                      subText: subText,
                    ),
                    const SizedBox(height: 12),
                    _buildClauseItem(
                      number: '3',
                      title: 'clause_3_title'.tr,
                      content: 'clause_3_content'.tr,
                      cardBg: cardBg,
                      bodyDark: bodyDark,
                      subText: subText,
                    ),
                    const SizedBox(height: 12),
                    _buildClauseItem(
                      number: '4',
                      title: 'clause_4_title'.tr,
                      content: 'clause_4_content'.tr,
                      cardBg: cardBg,
                      bodyDark: bodyDark,
                      subText: subText,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Agreement Checkbox Container
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAgreed = !_isAgreed;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _isAgreed
                      ? (isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB))
                      : cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isAgreed
                        ? (isDark ? const Color(0xFF2E7D32) : const Color(0x3030913F))
                        : borderColor,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _isAgreed
                            ? _primaryGreen
                            : (isDark ? const Color(0xFF252B37) : Colors.white),
                        borderRadius: BorderRadius.circular(6),
                        border: _isAgreed
                            ? null
                            : Border.all(color: borderColor, width: 1.6),
                      ),
                      child: _isAgreed
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'agree_to_terms_checkbox'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: _isAgreed ? FontWeight.w700 : FontWeight.w500,
                          color: _isAgreed
                              ? (isDark ? const Color(0xFF81C784) : _primaryGreen)
                              : subText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bottomBarBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isAgreed
                  ? () {
                      setState(() {
                        _currentStage = ContractFlowStage.nafathCode;
                      });
                      _initiateNafathRequest();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAgreed
                    ? _primaryGreen
                    : (isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6)),
                disabledBackgroundColor:
                    isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'authenticate_contract_electronically'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isAgreed ? Colors.white : subText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClauseItem({
    required String number,
    required String title,
    required String content,
    required Color cardBg,
    required Color bodyDark,
    required Color subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: bodyDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: subText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. Figma Frame 9142:10138: توثيق عبر نفاذ
  // =========================================================================
  Widget _buildNafathCodeScreen(bool isDark) {
    final screenBg = isDark ? const Color(0xFF121418) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final instructionsBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: darkText,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _currentStage = ContractFlowStage.review;
            });
          },
        ),
        title: Text(
          'authenticate_via_nafath'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Big Circular Badge with Code (e.g. 54)
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF163E20) : const Color(0xFFE8F5E9),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                _nafathCode,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF237D2D),
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'enter_code_in_nafath'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'open_nafath_and_choose_code'.trParams({'code': _nafathCode}),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: subText,
              ),
            ),

            const SizedBox(height: 24),

            // Detailed Instructions Card from Figma
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: instructionsBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 0.8),
              ),
              child: Text(
                'nafath_instructions'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: darkText.withValues(alpha: 0.85),
                  height: 1.65,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStage = ContractFlowStage.review;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'view_contract'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _startWaitingVerification,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'check_status'.tr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanHeader(Color iconColor, VoidCallback onBack) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: IconButton(
          onPressed: onBack,
          icon: Transform.flip(
            flipX: !isRtl,
            child: SvgPicture.asset(
              'assets/image/figma_arrow_right.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 3. Figma Frame 9146:10289: انتظار توثيق السند عبر نافذ
  // =========================================================================
  Widget _buildWaitingScreen(bool isDark) {
    final screenBg = isDark ? const Color(0xFF121418) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildCleanHeader(darkText, () {
              _countdownTimer?.cancel();
              _pollTimer?.cancel();
              setState(() {
                _currentStage = ContractFlowStage.nafathCode;
              });
            }),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    SvgPicture.asset(
                      'assets/image/figma_nafath_waiting.svg',
                      width: 188,
                      height: 196,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 41),
                    Text(
                      'waiting_nafath_verification'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          _countdownTimer?.cancel();
                          _pollTimer?.cancel();
                          setState(() {
                            _currentStage = ContractFlowStage.review;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'view_contract'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. Figma Frame 9148:10414: تم توقيع العقد بنجاح
  // =========================================================================
  Widget _buildSuccessScreen(bool isDark) {
    final screenBg = isDark ? const Color(0xFF121418) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final valueText = isDark ? Colors.white : const Color(0xFF1F2937);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final dividerColor = isDark
        ? const Color(0xFF2B3240)
        : const Color(0xFFE5E7EB).withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildCleanHeader(darkText, () => Get.back()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    SvgPicture.asset(
                      'assets/image/figma_nafath_success.svg',
                      width: 173,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'contract_signed_success'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Details Metadata Card (Figma 9148:10529)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildMetaRow(
                              'store_label'.tr,
                              widget.visit.storeName,
                              valueText,
                              subText,
                            ),
                          ),
                          Divider(color: dividerColor, height: 1, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildMetaRow(
                              'signing_date'.tr,
                              _signedDate,
                              valueText,
                              subText,
                            ),
                          ),
                          Divider(color: dividerColor, height: 1, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildMetaRow(
                              'signing_time'.tr,
                              _signedTime,
                              valueText,
                              subText,
                            ),
                          ),
                          Divider(color: dividerColor, height: 1, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildMetaRow(
                              'contract_number'.tr,
                              _contractNumber,
                              valueText,
                              subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Primary Action Button: بدء الزيارة التالية (Figma 9148:10558)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (Get.isRegistered<StoreVisitsController>()) {
                            final controller =
                                Get.find<StoreVisitsController>();
                            controller.setPipelineStep(
                                StorePipelineStep.contractSigned);
                            await controller.submitAndFinishVisit(
                              targetVisit: widget.visit,
                              isNafathVerified: true,
                            );
                            if (Get.isRegistered<ApiClient>()) {
                              try {
                                await Get.find<ApiClient>().postData(
                                  '/api/v1/customer/marketer/contracts/confirm-nafath-signing',
                                  {
                                    'visit_id': int.tryParse(widget.visit.id) ?? widget.visit.id,
                                    if (widget.visit.storeId != null)
                                      'store_id': widget.visit.storeId,
                                    if (_nafathRequestId != null && _nafathRequestId!.isNotEmpty)
                                      'nafath_request_id': _nafathRequestId,
                                    'national_id': _nafathNationalId ?? _getIdentifierForNafath(),
                                    'owner_name': widget.visit.managerName.isNotEmpty
                                        ? widget.visit.managerName
                                        : widget.visit.storeName,
                                    'store_name': widget.visit.storeName,
                                    if (widget.visit.crNumber.isNotEmpty)
                                      'cr_number': widget.visit.crNumber,
                                    'contract_number': _contractNumber,
                                  },
                                );
                              } catch (e) {
                                debugPrint('confirm-nafath-signing error: $e');
                              }
                            }
                            await controller.loadInActivationContracts();
                            await controller.loadVisits();
                          }
                          if (Get.isRegistered<
                              EmployeeNavigationController>()) {
                            Get.find<EmployeeNavigationController>()
                                .changeIndex(1);
                          }
                          Get.offAllNamed(RouteHelper.getEmployeeMainRoute());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'start_next_visit'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. Figma Frame 9148:31121: تعذر توثيق السند عبر نافذ
  // =========================================================================
  Widget _buildFailedScreen(bool isDark) {
    final screenBg = isDark ? const Color(0xFF121418) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildCleanHeader(darkText, () {
              setState(() {
                _currentStage = ContractFlowStage.nafathCode;
              });
            }),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Image.asset(
                      'assets/image/figma_nafath_failed.png',
                      width: 243,
                      height: 248,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 38),
                    Text(
                      'failed_nafath_verification'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          _generateRandomNafathCode();
                          _initiateNafathRequest();
                          setState(() {
                            _currentStage = ContractFlowStage.nafathCode;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'send_code_again'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, Color valueColor, Color labelColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12.5,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
