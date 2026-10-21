import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/message_model.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
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

    final myBg = isDark ? const Color(0xFF163E20) : const Color(0xFFE8F7EB);
    final myBorder = isDark ? const Color(0xFF225B2F) : const Color(0xFFC8E6C9);
    final otherBg = isDark ? const Color(0xFF1F242F) : Colors.white;
    final otherBorder = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111B21);
    final timeColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: isMyMessage ? myBg : otherBg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                bottomRight: Radius.circular(isMyMessage ? 4 : 16),
              ),
              border: Border.all(
                color: isMyMessage ? myBorder : otherBorder,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMyMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      ('admin_management_title'.tr.isNotEmpty && 'admin_management_title'.tr != 'admin_management_title')
                          ? 'admin_management_title'.tr
                          : 'إدارة شلة',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),

                if (hasFiles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: message.filesFullUrl!.map((url) {
                          return GestureDetector(
                            onTap: () {
                              _showImageDialog(context, url);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (_, __) => const SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
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
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),

                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 10,
                        color: timeColor,
                      ),
                    ),
                    if (isMyMessage) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 13,
                        color: (message.isSeen == 1) ? const Color(0xFF16A34A) : timeColor,
                      ),
                    ],
                  ],
                ),
              ],
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
              borderRadius: BorderRadius.circular(12),
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
