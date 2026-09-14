import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/chat/widgets/image_file_view_widget.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final User? user;
  final String userType;
  const MessageBubbleWidget(
      {super.key,
      required this.message,
      required this.user,
      required this.userType});

  @override
  Widget build(BuildContext context) {
    final ProfileController? profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : null;
    int? currentUserId = profileController?.userInfoModel?.userInfo?.id;

    if (currentUserId == null && Get.isRegistered<ChatController>()) {
      final ChatController chatController = Get.find<ChatController>();
      final conversation = chatController.messageModel?.conversation;
      if (conversation != null) {
        if (conversation.senderType == 'user' || conversation.senderType == 'customer') {
          currentUserId = conversation.sender?.id ?? conversation.senderId;
        } else if (conversation.receiverType == 'user' || conversation.receiverType == 'customer') {
          currentUserId = conversation.receiver?.id ?? conversation.receiverId;
        } else {
          currentUserId = conversation.sender?.id ?? conversation.senderId;
        }
      }
    }

    currentUserId ??= profileController?.userInfoModel?.id;

    final int? peerUserId = user?.id;
    final bool isMyMessage;

    if (currentUserId != null && currentUserId != 0 && message.senderId != null) {
      isMyMessage = (message.senderId == currentUserId);
    } else if (peerUserId != null && message.senderId != null) {
      isMyMessage = (message.senderId != peerUserId);
    } else {
      isMyMessage = true;
    }

    final String timeString = _formatDateOrEmpty(message.createdAt);
    final hasFiles = message.fileFullUrl != null && message.fileFullUrl!.isNotEmpty;
    final hasText = message.message != null && message.message!.trim().isNotEmpty;
    final double maxWidth = MediaQuery.of(context).size.width * 0.78;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.5),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: isMyMessage
                  ? const Color(0xFFE8F7EB) // Subtle Premium Green
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                bottomRight: Radius.circular(isMyMessage ? 4 : 16),
              ),
              border: Border.all(
                color: isMyMessage
                    ? const Color(0xFFC8E6C9)
                    : const Color(0xFFE8ECEF),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: hasFiles && !hasText
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment:
                    isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.order != null)
                    adminOrderMessage(context, message.order!),
                  if (hasFiles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: ImageFileViewWidget(
                        currentMessage: message,
                        isRightMessage: isMyMessage,
                      ),
                    ),
                  Wrap(
                    alignment: isMyMessage ? WrapAlignment.end : WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      if (hasText)
                        Text(
                          message.message ?? '',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111B21),
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (timeString.isNotEmpty)
                              Text(
                                timeString,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Tajawal',
                                  color: Color(0xFF8696A0),
                                ),
                              ),
                            if (isMyMessage) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.done_all_rounded,
                                size: 16,
                                color: message.isSeen == 1
                                    ? const Color(0xFF31A342) // Active seen green
                                    : const Color(0xFF8696A0), // Delivered grey
                              ),
                            ],
                          ],
                        ),
                      ),
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

  Widget adminOrderMessage(BuildContext context, Order order) {
    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 400 : 350,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimensions.radiusDefault),
        ),
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusDefault),
            ),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('${'order_id'.tr} ', style: robotoMedium),
                          Text('#${order.id}', style: robotoBold),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(
                          _formatDateOrEmpty(order.createdAt),
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor),
                        ),
                      ]),
                ),
                Text(
                  PriceConverter.convertPrice(order.orderAmount),
                  style: robotoBold.copyWith(
                      color: Theme.of(context).primaryColor),
                ),
              ]),
        ),
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.detailsCount} ${order.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                  style: robotoMedium,
                ),
                Text(
                  order.orderStatus!.tr,
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor),
                ),
              ]),
        ),
      ]),
    );
  }

  String _formatDateOrEmpty(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return '';
    }
    try {
      return DateConverter.localDateToIsoStringAMPM(DateTime.parse(rawDate));
    } catch (_) {
      return '';
    }
  }
}
