import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';

class ContractSigningScreen extends StatefulWidget {
  final StoreVisitModel visit;

  const ContractSigningScreen({super.key, required this.visit});

  @override
  State<ContractSigningScreen> createState() => _ContractSigningScreenState();
}

class _ContractSigningScreenState extends State<ContractSigningScreen> {
  final List<Offset?> _points = [];
  bool _agreedToTerms = false;

  // Onboarding checklist items
  final Map<String, bool> _onboardingChecklist = {
    'إرفاق وتوثيق السجل التجاري والشهادة الضريبية': true,
    'تحديد نسبة العمولة وقسائم الخصم المتفق عليها': true,
    'استلام صور قائمة المنتجات / المنيو': false,
    'تحديد وتدريب مسؤول الكاشير في المتجر': false,
    'تسليم ملصق وباركود شلة المعتمد للمتجر': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'توقيع العقد وتفعيل التاجر',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF30913F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Color(0xFF30913F), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.visit.storeName,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'المسؤول: ${widget.visit.managerName} (${widget.visit.phone})',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'عقد جديد',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contract Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description_outlined, color: Color(0xFF30913F), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ملخص بنود اتفاقية الانضمام لشلة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '• التزام التاجر بقبول قسائم وعروض تطبيق شلة للعملاء المعتمدين.\n'
                      '• السجل التجاري: موثق ومعتمد لدى وزارة التجارة.\n'
                      '• نسبة عمولة المبيعات: مطابقة للباقة المعتمدة.\n'
                      '• تفعيل الحساب الفوري بعد مراجعة وضبط الإعدادات التشغيلية.',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                    const Divider(height: 20),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _agreedToTerms,
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                      title: const Text(
                        'أقر بأن التاجر قد اطلع على البنود ووافق على توقيع الاتفاقية إلكترونياً.',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      activeColor: const Color(0xFF30913F),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Signature Pad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.draw_outlined, color: Color(0xFF30913F), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'توقيع التاجر / المفوض إلكترونياً',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _points.clear()),
                          icon: const Icon(Icons.clear_all, size: 18, color: Color(0xFFEF4444)),
                          label: const Text(
                            'مسح',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _points.add(details.localPosition);
                            });
                          },
                          onPanEnd: (details) => _points.add(null),
                          child: CustomPaint(
                            painter: _SignaturePainter(points: _points),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'وقع بإصبعك داخل المربع أعلاه',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Onboarding Checklist
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.checklist_rounded, color: Color(0xFF30913F), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'خطوات تفعيل التاجر (Merchant Onboarding)',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._onboardingChecklist.entries.map((entry) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: entry.value,
                        onChanged: (val) {
                          setState(() {
                            _onboardingChecklist[entry.key] = val ?? false;
                          });
                        },
                        title: Text(
                          entry.key,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            color: entry.value ? const Color(0xFF111827) : const Color(0xFF6B7280),
                            fontWeight: entry.value ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        activeColor: const Color(0xFF30913F),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton.icon(
                onPressed: (_points.isEmpty || !_agreedToTerms) ? null : _handleSaveContract,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                label: const Text(
                  'اعتماد العقد وبدء تفعيل التاجر',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30913F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSaveContract() {
    if (Get.isRegistered<StoreVisitsController>()) {
      Get.find<StoreVisitsController>().setContractSignature('signed_digitally');
    }

    Get.back();
    Get.snackbar(
      'تم توقيع العقد بنجاح',
      'تم تسجيل العقد وتحديث مسار التفعيل لمتجر ${widget.visit.storeName}',
      backgroundColor: const Color(0xFF30913F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
