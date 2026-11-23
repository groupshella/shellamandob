import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/domain/models/message_model.dart';
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
  static const Color _primaryGreen = Color(0xFF30913F);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _chatController.getMessages(1, convId: widget.conversationId, isFirstLoad: true);
      _chatController.startPolling();
    });
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

  bool _isMyMessage(Message msg, Conversation? conv, int? myUserId) {
    if (msg.senderId == 0) return false;
    if (conv != null) {
      if (conv.receiverType == 'admin') {
        return (msg.senderId == conv.senderId) || (myUserId != null && msg.senderId == myUserId);
      } else if (conv.senderType == 'admin') {
        return (msg.senderId == conv.receiverId) || (myUserId != null && msg.senderId == myUserId);
      } else {
        final int? customerId = (conv.senderType == 'customer')
            ? conv.senderId
            : ((conv.receiverType == 'customer') ? conv.receiverId : null);
        return (customerId != null && msg.senderId == customerId) ||
            (myUserId != null && msg.senderId == myUserId);
      }
    }
    return myUserId != null && msg.senderId == myUserId;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isSameCalendarDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateBadge(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(dt.year, dt.month, dt.day);

    if (target == today) {
      return _t('today_filter', 'اليوم');
    }
    if (target == yesterday) {
      return _t('yesterday', 'أمس');
    }
    final lang = Get.locale?.languageCode ?? 'ar';
    return DateFormat('d MMMM yyyy', lang).format(dt);
  }

  Widget _buildDateChip(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2028) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2B3240) : const Color(0xFFECEEF2),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatSkeleton(bool isDark) {
    final bubbleColor = isDark ? const Color(0xFF1C2028) : Colors.white;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, idx) {
        final isMine = idx.isEven;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Align(
            alignment: isMine
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: Shimmer(
              duration: const Duration(seconds: 2),
              child: Container(
                width: MediaQuery.of(context).size.width * (idx % 3 == 0 ? 0.62 : 0.45),
                height: idx % 2 == 0 ? 54 : 68,
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final bg = isDark ? const Color(0xFF121418) : const Color(0xFFF6F5F8);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF707784);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFECEEF2);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: borderColor),
            ),
            leading: IconButton(
              icon: Icon(
                isRtl ? IconlyLight.arrowRight2 : IconlyLight.arrowLeft2,
                size: 22,
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
                        color: isDark ? const Color(0xFF16321D) : const Color(0xFFEBFEEB),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF225B2E) : const Color(0xFFC3ECC8),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.headset_mic_outlined,
                          color: _primaryGreen,
                          size: 22,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: _primaryGreen,
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
                        _t('chat_with_admin_title', 'تواصل مع الإدارة / المشرف'),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _t('field_support_online', 'متصل الآن • الدعم الميداني'),
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
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
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16321D) : const Color(0xFFEBFEEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(IconlyLight.call, color: _primaryGreen, size: 19),
                  ),
                  onPressed: _makePhoneCall,
                ),
              ),
            ],
          ),
          body: GetBuilder<ChatController>(
            builder: (controller) {
              if (controller.isLoading && (controller.messageModel?.messages ?? []).isEmpty) {
                return _buildChatSkeleton(isDark);
              }

              final messages = controller.messageModel?.messages ?? [];
              final myUserId = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>().userInfoModel?.id
                  : null;
              final conv = controller.messageModel?.conversation;

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
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x08000000),
                                          blurRadius: 8.9,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.headset_mic_outlined,
                                        size: 34,
                                        color: _primaryGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _t('no_messages_yet', 'لا توجد رسائل سابقة'),
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _t(
                                      'start_conversation_with_admin',
                                      'ابدأ المحادثة المباشرة مع المشرف للحصول على الدعم والتوجيه الميداني الفوري.',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      color: subText,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: _primaryGreen,
                            onRefresh: () async {
                              await _chatController.getMessages(
                                1,
                                convId: widget.conversationId,
                                isFirstLoad: false,
                              );
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMine = _isMyMessage(msg, conv, myUserId);

                                // Since reverse: true, index + 1 is the chronologically older message above it
                                final olderMsg = (index + 1 < messages.length)
                                    ? messages[index + 1]
                                    : null;
                                final isOlderSameSender = olderMsg != null &&
                                    _isMyMessage(olderMsg, conv, myUserId) == isMine;

                                final msgDate = _parseDate(msg.createdAt);
                                final olderDate = _parseDate(olderMsg?.createdAt);
                                final showDateHeader = msgDate != null &&
                                    (olderMsg == null || !_isSameCalendarDay(msgDate, olderDate));

                                final isConsecutive = isOlderSameSender && !showDateHeader;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (showDateHeader)
                                      _buildDateChip(_formatDateBadge(msgDate), isDark),
                                    MessageBubbleWidget(
                                      message: msg,
                                      isMyMessage: isMine,
                                      showSenderHeader: !isConsecutive,
                                      isConsecutive: isConsecutive,
                                    ),
                                  ],
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
                                  borderRadius: BorderRadius.circular(10),
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
                                      color: Color(0xFFE53935),
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

                  // Bottom Input Bar (Shella Design System)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border(top: BorderSide(color: borderColor, width: 1)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8.9,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showAttachmentOptions(context, controller, isDark),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                IconlyLight.image,
                                color: _primaryGreen,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: _textController,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: darkText,
                                ),
                                decoration: InputDecoration(
                                  hintText: _t('type_message_hint', 'اكتب رسالة للمشرف...'),
                                  hintStyle: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 13.5,
                                    color: subText,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                                ),
                                maxLines: 4,
                                minLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: controller.isSending ? null : _sendMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _primaryGreen,
                                borderRadius: BorderRadius.circular(12),
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
                                    : Transform(
                                        alignment: Alignment.center,
                                        transform: isRtl
                                            ? Matrix4.rotationY(math.pi)
                                            : Matrix4.identity(),
                                        child: const Icon(
                                          IconlyBold.send,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
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

  void _showAttachmentOptions(
    BuildContext context,
    ChatController controller,
    bool isDark,
  ) {
    final sheetBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111B18);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachItem(
                  icon: IconlyBold.camera,
                  label: _t('camera_option', 'الكاميرا'),
                  color: _primaryGreen,
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(true);
                  },
                ),
                _buildAttachItem(
                  icon: IconlyBold.image,
                  label: _t('gallery_option', 'معرض الصور'),
                  color: _primaryGreen,
                  textColor: textColor,
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
    required Color textColor,
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
