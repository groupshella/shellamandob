import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/domain/repositories/chat_repository.dart';
import 'package:sixam_mart/features/chat/widgets/message_bubble_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

class ChatScreen extends StatefulWidget {
  final int? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatController _chatController;

  String _t(String key, String fallback) {
    final val = key.tr;
    return (val.isNotEmpty && val != key) ? val : fallback;
  }

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut(() => ChatRepository(apiClient: Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<ChatController>()) {
      Get.lazyPut(() => ChatController(chatRepository: Get.find<ChatRepository>()));
    }

    _chatController = Get.find<ChatController>();
    _chatController.getMessages(1, convId: widget.conversationId, isFirstLoad: true);
    _chatController.startPolling();
  }

  @override
  void dispose() {
    _chatController.stopPolling();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text;
    if (text.trim().isEmpty && _chatController.chatImages.isEmpty) return;

    _textController.clear();
    final success = await _chatController.sendMessage(text);
    if (success) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _makePhoneCall() async {
    const supportPhone = 'tel:+966920000000';
    if (await canLaunchUrlString(supportPhone)) {
      await launchUrlString(supportPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF4F6F8);
        final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B21);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
        const primaryGreen = Color(0xFF16A34A);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0.5,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: darkText,
              ),
              onPressed: () => Get.back(),
            ),
            title: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF14532D) : const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E3A2B) : const Color(0xFFDCFCE7),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.support_agent_rounded, color: primaryGreen, size: 24),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('chat_with_admin_title', 'إدارة شلة • الدعم الميداني'),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _t('field_support_online', 'متصل الآن'),
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: primaryGreen, size: 22),
                tooltip: 'اتصال هاتفي',
                onPressed: _makePhoneCall,
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: darkText, size: 22),
                tooltip: 'تحديث',
                onPressed: () => _chatController.getMessages(1, isFirstLoad: true),
              ),
            ],
          ),
          body: GetBuilder<ChatController>(
            builder: (controller) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                );
              }

              final messages = controller.messageModel?.messages ?? [];
              final myUserId = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>().userInfoModel?.id
                  : null;

              return Column(
                children: [
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: borderColor, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.headset_mic_rounded, size: 34, color: primaryGreen),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _t('no_messages_yet', 'لا توجد رسائل سابقة'),
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _t('start_conversation_with_admin', 'ابدأ المحادثة المباشرة مع المشرف للحصول على الدعم والتوجيه الميداني الفوري.'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 12.5,
                                      color: subText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: primaryGreen,
                            onRefresh: () async {
                              await _chatController.getMessages(1, convId: widget.conversationId, isFirstLoad: false);
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final conv = controller.messageModel?.conversation;
                                bool isMyMessage = false;
                                if (msg.senderId == 0) {
                                  isMyMessage = false;
                                } else if (conv != null) {
                                  if (conv.receiverType == 'admin') {
                                    isMyMessage = (msg.senderId == conv.senderId) || (myUserId != null && msg.senderId == myUserId);
                                  } else if (conv.senderType == 'admin') {
                                    isMyMessage = (msg.senderId == conv.receiverId) || (myUserId != null && msg.senderId == myUserId);
                                  } else {
                                    final int? customerId = (conv.senderType == 'customer')
                                        ? conv.senderId
                                        : ((conv.receiverType == 'customer') ? conv.receiverId : null);
                                    isMyMessage = (customerId != null && msg.senderId == customerId)
                                        || (myUserId != null && msg.senderId == myUserId);
                                  }
                                } else {
                                  isMyMessage = (myUserId != null && msg.senderId == myUserId);
                                }

                                return MessageBubbleWidget(
                                  message: msg,
                                  isMyMessage: isMyMessage,
                                );
                              },
                            ),
                          ),
                  ),

                  // Selected Images Preview Bar
                  if (controller.chatImages.isNotEmpty)
                    Container(
                      height: 75,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      color: cardBg,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.chatImages.length,
                        itemBuilder: (context, idx) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(File(controller.chatImages[idx].path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -2,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () => controller.removeImage(idx),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  // Bottom Input Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border(top: BorderSide(color: borderColor, width: 1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded, color: primaryGreen, size: 24),
                            onPressed: () => _showAttachmentOptions(context, controller),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor, width: 0.8),
                              ),
                              child: TextField(
                                controller: _textController,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13.5,
                                  color: darkText,
                                ),
                                decoration: InputDecoration(
                                  hintText: _t('type_message_hint', 'اكتب رسالة للمشرف...'),
                                  hintStyle: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 13,
                                    color: subText,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                maxLines: 4,
                                minLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: controller.isSending ? null : _sendMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: controller.isSending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showAttachmentOptions(BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachItem(
                  icon: Icons.camera_alt_rounded,
                  label: _t('camera_option', 'الكاميرا'),
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(true);
                  },
                ),
                _buildAttachItem(
                  icon: Icons.photo_library_rounded,
                  label: _t('gallery_option', 'معرض الصور'),
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
