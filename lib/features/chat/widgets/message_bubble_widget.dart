import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/message_model.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final bool isMyMessage;
  final bool showSenderHeader;
  final bool isConsecutive;

  static const Color _primaryGreen = Color(0xFF30913F);

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.showSenderHeader = true,
    this.isConsecutive = false,
  });

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a', Get.locale?.languageCode ?? 'ar').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().darkTheme;
    final hasFiles = message.filesFullUrl != null && message.filesFullUrl!.isNotEmpty;
    final hasText = message.message != null && message.message!.trim().isNotEmpty;
    final timeString = _formatTime(message.createdAt);
    final double maxWidth = MediaQuery.of(context).size.width * 0.78;

    // Shella Design System Tokens
    final myBg = isDark ? const Color(0xFF16321D) : const Color(0xFFEBFEEB);
    final myBorder = isDark ? const Color(0xFF225B2E) : const Color(0xFFC3ECC8);
    final otherBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final otherBorder = isDark ? const Color(0xFF2B3240) : const Color(0xFFECEEF2);
    final textColor = isDark ? Colors.white : const Color(0xFF111B18);
    final timeColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: isConsecutive ? 2.0 : 6.0,
        bottom: 2.0,
      ),
      child: Align(
        alignment: isMyMessage
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isMyMessage ? myBg : otherBg,
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(isMyMessage && isConsecutive ? 8 : 16),
                topEnd: Radius.circular(!isMyMessage && isConsecutive ? 8 : 16),
                bottomStart: Radius.circular(isMyMessage ? 4 : 16),
                bottomEnd: Radius.circular(isMyMessage ? 16 : 4),
              ),
              border: Border.all(
                color: isMyMessage ? myBorder : otherBorder,
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8.9,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMyMessage && showSenderHeader)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        ('admin_management_title'.tr.isNotEmpty &&
                                'admin_management_title'.tr != 'admin_management_title')
                            ? 'admin_management_title'.tr
                            : 'إدارة شلة',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _primaryGreen,
                        ),
                      ),
                    ),

                  if (hasFiles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: message.filesFullUrl!.map((url) {
                            return GestureDetector(
                              onTap: () => _showImageDialog(context, url),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  placeholder: (_, __) => const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _primaryGreen,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 40),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  if (hasText)
                    Text(
                      message.message ?? '',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        height: 1.45,
                      ),
                    ),

                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: timeColor,
                        ),
                      ),
                      if (isMyMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: (message.isSeen == 1) ? _primaryGreen : timeColor,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: imageUrl),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
