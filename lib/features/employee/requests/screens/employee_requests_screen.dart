import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../models/employee_request_model.dart';

class EmployeeRequestsScreen extends StatefulWidget {
  const EmployeeRequestsScreen({super.key});

  @override
  State<EmployeeRequestsScreen> createState() => _EmployeeRequestsScreenState();
}

class _EmployeeRequestsScreenState extends State<EmployeeRequestsScreen> {
  final List<EmployeeRequestModel> _requests = [
    EmployeeRequestModel(
      id: 'REQ-101',
      type: RequestType.sickLeave,
      status: RequestStatus.approved,
      startDate: DateTime(2026, 9, 5),
      endDate: DateTime(2026, 9, 6),
      reason: 'req_101_reason',
      attachmentName: 'medical_report_hospital.pdf',
      createdAt: DateTime(2026, 9, 5),
    ),
    EmployeeRequestModel(
      id: 'REQ-102',
      type: RequestType.annualLeave,
      status: RequestStatus.underReview,
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 7),
      reason: 'req_102_reason',
      attachmentName: 'leave_form_signed.pdf',
      createdAt: DateTime(2026, 9, 14),
    ),
    EmployeeRequestModel(
      id: 'REQ-103',
      type: RequestType.permission,
      status: RequestStatus.rejected,
      startDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 10),
      reason: 'req_103_reason',
      rejectReason: 'req_103_reject_reason',
      createdAt: DateTime(2026, 9, 9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'requests_and_leaves_management'.tr,
          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Balance Cards
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      title: 'annual_leave_balance'.tr,
                      value: '18 ${'day_unit'.tr}',
                      icon: Icons.beach_access_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  Container(height: 36, width: 1, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child: _buildBalanceItem(
                      title: 'remaining_sick_leave'.tr,
                      value: '14 ${'day_unit'.tr}',
                      icon: Icons.medical_information_outlined,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  Container(height: 36, width: 1, color: const Color(0xFFE5E7EB)),
                  Expanded(
                    child: _buildBalanceItem(
                      title: 'permission_hours'.tr,
                      value: '04:00 ${'hour_unit'.tr}',
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),

            // Requests List Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'previous_requests_history'.tr,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  Text(
                    '${_requests.length} ${'requests_count_label'.tr}',
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final req = _requests[index];
                  return _buildRequestCard(req);
                },
              ),
            ),

            // Bottom CTA: Add new request
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _showNewRequestModal,
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text(
                  'submit_new_request_or_leave'.tr,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30913F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildRequestCard(EmployeeRequestModel req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: req.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(req.type.icon, color: req.type.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.type.localizedTitle,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    Text(
                      '${'request_number'.tr}: ${req.id} • ${req.startDate.year}/${req.startDate.month}/${req.startDate.day}',
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: req.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(req.status.icon, size: 14, color: req.status.color),
                    const SizedBox(width: 4),
                    Text(
                      req.status.localizedLabel,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.bold, color: req.status.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${'reason_label'.tr}: ${req.localizedReason}',
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF374151)),
          ),
          if (req.attachmentName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF30913F)),
                const SizedBox(width: 4),
                Text(
                  req.attachmentName!,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF30913F), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          if (req.rejectReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${'reject_reason_label'.tr}: ${req.localizedRejectReason}',
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNewRequestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _NewRequestModal(
        onSubmit: (newReq) {
          setState(() {
            _requests.insert(0, newReq);
          });
        },
      ),
    );
  }
}

class _NewRequestModal extends StatefulWidget {
  final ValueChanged<EmployeeRequestModel> onSubmit;

  const _NewRequestModal({required this.onSubmit});

  @override
  State<_NewRequestModal> createState() => _NewRequestModalState();
}

class _NewRequestModalState extends State<_NewRequestModal> {
  RequestType _selectedType = RequestType.sickLeave;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  final TextEditingController _reasonController = TextEditingController();
  String? _pickedFileName;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'submit_new_leave_request'.tr,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 14),

            // Request Type Radio / Choice
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(RequestType.sickLeave, 'sick_leave'.tr),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTypeOption(RequestType.annualLeave, 'annual_leave'.tr),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTypeOption(RequestType.permission, 'hourly_permission'.tr),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date Pickers
            Row(
              children: [
                Expanded(
                  child: _buildDateBox(
                    label: 'from_date'.tr,
                    date: _startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDateBox(
                    label: 'to_date'.tr,
                    date: _endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reason field
            TextField(
              controller: _reasonController,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
              decoration: InputDecoration(
                labelText: 'request_reason_clarification'.tr,
                labelStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                hintText: 'request_reason_hint'.tr,
                hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 14),

            // Attachment picker
            InkWell(
              onTap: _pickAttachment,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file_rounded, color: Color(0xFF16A34A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _pickedFileName ??
                            (_selectedType == RequestType.sickLeave
                                ? 'attach_medical_report_required'.tr
                                : 'attach_supporting_doc_optional'.tr),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: _pickedFileName != null ? const Color(0xFF15803D) : const Color(0xFF4B5563),
                          fontWeight: _pickedFileName != null ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30913F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'send_request_to_company'.tr,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(RequestType type, String label) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? type.color : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox({required String label, required DateTime date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Color(0xFF6B7280))),
            const SizedBox(height: 2),
            Text(
              '${date.year}/${date.month}/${date.day}',
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          _pickedFileName = res.files.first.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking attachment: $e');
    }
  }

  void _handleSubmit() {
    if (_reasonController.text.trim().isEmpty) {
      Get.snackbar('field_required'.tr, 'please_enter_leave_reason'.tr, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newReq = EmployeeRequestModel(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      type: _selectedType,
      status: RequestStatus.underReview,
      startDate: _startDate,
      endDate: _endDate,
      reason: _reasonController.text.trim(),
      attachmentName: _pickedFileName,
      createdAt: DateTime.now(),
    );

    widget.onSubmit(newReq);
    Get.back();
    Get.snackbar(
      'request_submitted_successfully'.tr,
      'request_under_review_hr_ops'.tr,
      backgroundColor: const Color(0xFF30913F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
