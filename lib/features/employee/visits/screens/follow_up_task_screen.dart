import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/store_visit_model.dart';
import '../controllers/store_visits_controller.dart';

class FollowUpTaskScreen extends StatefulWidget {
  final StoreVisitModel visit;

  const FollowUpTaskScreen({super.key, required this.visit});

  @override
  State<FollowUpTaskScreen> createState() => _FollowUpTaskScreenState();
}

class _FollowUpTaskScreenState extends State<FollowUpTaskScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  String _selectedReason = 'طلب مهلة لدراسة العرض ومقارنة العمولات';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _commitmentsController = TextEditingController();

  final List<String> _notClosedReasons = [
    'طلب مهلة لدراسة العرض ومقارنة العمولات',
    'المدير المسؤول غير متواجد حالياً',
    'مرتبط بعقد حالي مع تطبيق آخر حتى نهاية الشهر',
    'تفاوض حول نسبة الخصم الممنوحة للعملاء',
    'تحتاج موافقة المالك الرئيسي / الشركاء',
    'مخاوف تقنية بشأن ربط نظام الكاشير',
    'أخرى (توضيح التفاصيل)',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _commitmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'جدولة مهمة متابعة قادمة',
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
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded, color: Color(0xFF2563EB), size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.visit.storeName,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'سيتم إدراج هذه المهمة تلقائياً في أجندتك اليومية وتذكيرك بالموعد.',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reason Not Closed
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
                    const Text(
                      'سبب عدم الإغلاق والتعاقد الفوري *',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedReason,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      items: _notClosedReasons.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(
                            r,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedReason = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Date & Time Picker
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
                    const Text(
                      'موعد المتابعة القادمة *',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF30913F)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time picker
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF30913F)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Required Commitments & Deliverables
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
                    const Text(
                      'الالتزامات المطلوبة للزيارة القادمة',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commitmentsController,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'follow_up_task_example_hint'.tr,
                        hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Confirm Button
              ElevatedButton.icon(
                onPressed: _handleSaveFollowUp,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                label: const Text(
                  'حفظ وجدولة المهمة في الأجندة',
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _handleSaveFollowUp() {
    if (Get.isRegistered<StoreVisitsController>()) {
      final ctrl = Get.find<StoreVisitsController>();
      ctrl.setFollowUpDate(_selectedDate);
      ctrl.setFollowUpTime(_selectedTime);
      ctrl.commitmentsController.text = _commitmentsController.text.trim();
      ctrl.setClosingReason(_selectedReason);
    }

    Get.back();
    Get.snackbar(
      'تمت جدولة المهمة بنجاح',
      'تم حفظ موعد المتابعة لمتجر ${widget.visit.storeName} في أجندتك.',
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
