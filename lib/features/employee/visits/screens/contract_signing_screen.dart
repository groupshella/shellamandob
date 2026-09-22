import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';
import 'daily_visits_screen.dart';

class ContractSigningScreen extends StatefulWidget {
  final StoreVisitModel visit;

  const ContractSigningScreen({super.key, required this.visit});

  @override
  State<ContractSigningScreen> createState() => _ContractSigningScreenState();
}

class _ContractSigningScreenState extends State<ContractSigningScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  bool _isAgreed = false;
  bool _isSignedSuccess = false;
  String _signedTime = '';
  String _signedDate = '';
  String _contractNumber = '';

  final List<Offset?> _signaturePoints = [];

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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        if (_isSignedSuccess) {
          return _buildSuccessScreen(isDark);
        }
        return _buildReviewContractScreen(isDark);
      },
    );
  }

  // ==========================================
  // Figma Frames 8945:39779 & 8945:40547: مراجعة العقد
  // ==========================================
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
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
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
                    '${'contract_intro_text'.tr} - ${widget.visit.storeName}',
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

            // Clauses List
            _buildClauseItem(
              number: '1',
              title: 'contract_terms_title'.tr,
              content: 'contract_terms_content'.tr,
              cardBg: cardBg,
              bodyDark: bodyDark,
              subText: subText,
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
                          color: _isAgreed ? (isDark ? const Color(0xFF81C784) : _primaryGreen) : subText,
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
              onPressed: _isAgreed ? () => _showSignaturePadBottomSheet(isDark) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAgreed ? _primaryGreen : (isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6)),
                disabledBackgroundColor: isDark ? const Color(0xFF252B37) : const Color(0xFFE2E4E6),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'sign_contract_btn'.tr,
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

  // Signature Pad Modal
  void _showSignaturePadBottomSheet(bool isDark) {
    final sheetBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final canvasBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
    final canvasBorder = isDark ? const Color(0xFF3B4455) : const Color(0xFFD1D5DB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B4455) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'signature_area_title'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => _signaturePoints.clear());
                        },
                        child: Text(
                          'clear_signature'.tr,
                          style: const TextStyle(fontFamily: 'Tajawal', color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Canvas container
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: canvasBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: canvasBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: GestureDetector(
                        onPanUpdate: (DragUpdateDetails details) {
                          final RenderBox box = ctx.findRenderObject() as RenderBox;
                          final localPos = box.globalToLocal(details.globalPosition);
                          setModalState(() {
                            _signaturePoints.add(localPos);
                          });
                        },
                        onPanEnd: (_) {
                          setModalState(() {
                            _signaturePoints.add(null);
                          });
                        },
                        child: CustomPaint(
                          painter: _SignaturePainter(
                            points: _signaturePoints,
                            strokeColor: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'draw_signature_hint'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: subText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _completeContract();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'sign_contract_btn'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _completeContract() async {
    if (Get.isRegistered<StoreVisitsController>()) {
      final controller = Get.find<StoreVisitsController>();
      controller.setPipelineStep(StorePipelineStep.contractSigned);
      await controller.submitAndFinishVisit(targetVisit: widget.visit);
    }
    setState(() {
      _isSignedSuccess = true;
    });
  }

  // ==========================================
  // Figma Frame 8945:40635: متابعة الطلب (تم توقيع العقد بنجاح)
  // ==========================================
  Widget _buildSuccessScreen(bool isDark) {
    final screenBg = isDark ? const Color(0xFF121418) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final bodyDark = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final bottomBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: screenBg,
        elevation: 0,
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
            if (Get.isRegistered<StoreVisitsController>()) {
              Get.find<StoreVisitsController>().loadVisits();
            }
            Get.offAll(() => const DailyVisitsScreen());
          },
        ),
        title: Text(
          'contract_signed_success_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Illustration
              Center(
                child: SvgPicture.asset(
                  'assets/image/contract_success.svg',
                  width: 173,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),

              // Heading
              Text(
                'contract_signed_success_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'contract_signed_success_desc'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: subText,
                ),
              ),

              const SizedBox(height: 24),

              // Details Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSuccessRow(label: 'store_name_label'.tr, value: widget.visit.storeName, subText: subText, bodyDark: bodyDark),
                    Divider(color: borderColor, height: 16, thickness: 0.8),
                    _buildSuccessRow(label: 'signing_date'.tr, value: _signedDate, subText: subText, bodyDark: bodyDark),
                    Divider(color: borderColor, height: 16, thickness: 0.8),
                    _buildSuccessRow(label: 'signing_time'.tr, value: _signedTime, subText: subText, bodyDark: bodyDark),
                    Divider(color: borderColor, height: 16, thickness: 0.8),
                    _buildSuccessRow(label: 'contract_number'.tr, value: _contractNumber, subText: subText, bodyDark: bodyDark),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
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
              onPressed: () {
                if (Get.isRegistered<StoreVisitsController>()) {
                  Get.find<StoreVisitsController>().loadVisits();
                }
                Get.offAll(() => const DailyVisitsScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'done_back_to_visits'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow({required String label, required String value, required Color subText, required Color bodyDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: subText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: bodyDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;

  _SignaturePainter({required this.points, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
