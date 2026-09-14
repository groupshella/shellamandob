// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/util/styles.dart';

class FileUploadWithNameWidget extends StatefulWidget {
  final bool isIncome;
  final String instruction;

  const FileUploadWithNameWidget({
    super.key,
    required this.isIncome,
    required this.instruction,
  });

  @override
  State<FileUploadWithNameWidget> createState() =>
      _FileUploadWithNameWidgetState();
}

class _FileUploadWithNameWidgetState extends State<FileUploadWithNameWidget> {
  static const Color _green = Color(0xFF30913F);
  static const Color _ink = Color(0xFF111B18);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _uploadedBg = Color(0xFFEBFEEB);
  static const Color _uploadedBorder = Color(0xFFC7F3C7);

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (controller) {
        final docs = widget.isIncome
            ? controller.incomeDocuments
            : controller.personalDocuments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.instruction,
              style: robotoMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),

            // Upload Box
            InkWell(
              onTap: () => controller.pickDocuments(isIncome: widget.isIncome),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: _green,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر ملفاً وأضفه',
                            style: robotoBold.copyWith(
                              fontSize: 13,
                              color: _ink,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'برجاء التأكد أن الحد أقصى 5 ميجا pdf, jpg, png',
                            style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF9CA3AF),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Uploaded Documents List
            if (docs.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...docs.asMap().entries.map((entry) {
                final int idx = entry.key;
                final doc = entry.value;
                final String sizeStr = _formatFileSize(doc.file.size);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _uploadedBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _uploadedBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: _green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              style: robotoBold.copyWith(
                                fontSize: 13,
                                color: _ink,
                                fontFamily: 'Tajawal',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (sizeStr.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'حجم الملف $sizeStr',
                                style: robotoMedium.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        onPressed: () => controller.removeDocument(
                          idx,
                          isIncome: widget.isIncome,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}
