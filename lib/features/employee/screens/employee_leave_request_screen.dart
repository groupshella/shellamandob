import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

/// Enum for the vacation / leave request type
enum LeaveType {
  sick,
  annual,
}

extension LeaveTypeEx on LeaveType {
  String get title {
    switch (this) {
      case LeaveType.sick:
        return 'sick_leave'.tr;
      case LeaveType.annual:
        return 'annual_leave'.tr;
    }
  }

  String get formHeader {
    switch (this) {
      case LeaveType.sick:
        return 'apply_sick_leave_header'.tr;
      case LeaveType.annual:
        return 'apply_annual_leave_header'.tr;
    }
  }

  bool get requiresAttachment => this == LeaveType.sick;
}

/// Leave Request form screen — faithfully matches Figma nodes 8976:3438 and 8976:6522 in node 8976:27114
/// Fully responsive to Dark Mode and Light Mode.
class EmployeeLeaveRequestScreen extends StatefulWidget {
  final LeaveType leaveType;

  const EmployeeLeaveRequestScreen({
    super.key,
    required this.leaveType,
  });

  @override
  State<EmployeeLeaveRequestScreen> createState() =>
      _EmployeeLeaveRequestScreenState();
}

class _EmployeeLeaveRequestScreenState
    extends State<EmployeeLeaveRequestScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  DateTime? _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate = DateTime.now().add(const Duration(days: 5));

  final TextEditingController _notesCtrl = TextEditingController();
  String? _attachmentFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    if (_startDate == null || _endDate == null) return false;
    if (_endDate!.isBefore(_startDate!)) return false;
    if (widget.leaveType.requiresAttachment && _attachmentFileName == null) {
      return false;
    }
    return true;
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'select_date_hint'.tr;
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryGreen,
              onPrimary: Colors.white,
              onSurface: Color(0xFF111B18),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachmentFileName = result.files.single.name;
        });
      }
    } catch (_) {
      // File picker cancelled or permission denied
    }
  }

  void _submitForm() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show Figma success toast (Figma 8976:27106)
    _showSuccessToast();
  }

  /// Exact Figma success toast (Figma 8976:27106)
  void _showSuccessToast() {
    final isDark = Get.find<ThemeController>().darkTheme;

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 2),
      messageText: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF163E20) : const Color(0xFFEBFEEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFC6F6D5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: _primaryGreen,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'leave_request_submitted_success'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111B18),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lt = widget.leaveType;

    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final appBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final inputBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? IconlyLight.arrowRight2
                    : IconlyLight.arrowLeft2,
                color: darkText,
                size: 22,
              ),
            ),
            title: Text(
              lt.title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Header title (Figma: تقديم على إجازة ...) ──────────
                        Text(
                          lt.formHeader,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ─── Date range (تاريخ النهاية / تاريخ البداية) ─────────
                        Row(
                          children: [
                            // تاريخ البداية
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'start_date'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDatePickerField(
                                    text: _formatDate(_startDate),
                                    isSelected: _startDate != null,
                                    inputBg: inputBg,
                                    darkText: darkText,
                                    subText: subText,
                                    onTap: () => _pickDate(isStart: true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // تاريخ النهاية
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'end_date'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDatePickerField(
                                    text: _formatDate(_endDate),
                                    isSelected: _endDate != null,
                                    inputBg: inputBg,
                                    darkText: darkText,
                                    subText: subText,
                                    onTap: () => _pickDate(isStart: false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ─── Medical Report Attachment (if sick leave) ──────────
                        if (lt.requiresAttachment) ...[
                          const SizedBox(height: 18),
                          Text(
                            'attach_medical_report'.tr,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAttachmentPicker(
                            cardBg: cardBg,
                            borderColor: borderColor,
                            darkText: darkText,
                            subText: subText,
                          ),
                        ],

                        const SizedBox(height: 18),

                        // ─── Notes (ملاحظات (اختياري)) ──────────────────────────
                        Text(
                          'notes_optional'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: TextField(
                            controller: _notesCtrl,
                            maxLines: 4,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: darkText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'notes_placeholder'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0x801F2937),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ─── Bottom Submit Button (Figma 8976:6516 / 8976:6566) ────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isFormValid && !_isSubmitting ? _submitForm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        disabledBackgroundColor: isDark
                            ? const Color(0xFF2B3240)
                            : const Color(0xFFE2E4E6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'submit_leave_request'.tr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _isFormValid
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFF707784)
                                        : const Color(0xFF555555)),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Date picker button field (Figma Date Picker Frame)
  Widget _buildDatePickerField({
    required String text,
    required bool isSelected,
    required Color inputBg,
    required Color darkText,
    required Color subText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? darkText : subText,
              ),
            ),
            Icon(
              IconlyLight.calendar,
              color: subText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Medical report attachment picker (Figma Component 35)
  Widget _buildAttachmentPicker({
    required Color cardBg,
    required Color borderColor,
    required Color darkText,
    required Color subText,
  }) {
    return InkWell(
      onTap: _pickAttachment,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _attachmentFileName != null ? _primaryGreen : borderColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _attachmentFileName ?? 'choose_file_pdf_img'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _attachmentFileName != null
                          ? _primaryGreen
                          : darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'برجاء التأكد أن الحد أقصى 5 ميجا pdf, jpg, png',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: subText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _attachmentFileName != null
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() => _attachmentFileName = null);
                    },
                  )
                : Icon(
                    IconlyLight.document,
                    color: subText,
                    size: 24,
                  ),
          ],
        ),
      ),
    );
  }
}
