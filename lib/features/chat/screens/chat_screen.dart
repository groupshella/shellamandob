import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/order_chat_model.dart';
import 'package:sixam_mart/features/chat/enums/user_type_enum.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/widgets/support_reason_bottom_sheet.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/chat/widgets/message_bubble_widget.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final User? user;
  final int? conversationID;
  final int? index;
  final bool fromNotification;
  final bool isClosed;
  final OrderChatModel? orderChatModel;
  const ChatScreen(
      {super.key,
      required this.notificationBody,
      required this.user,
      this.conversationID,
      this.index,
      this.fromNotification = false,
      this.isClosed = false,
      this.orderChatModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  StreamSubscription? _stream;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      if (widget.orderChatModel != null) {
        Get.find<ChatController>().sendMessage(
          message:
              '${widget.orderChatModel!.reason!}\n${widget.orderChatModel!.customMessage!}',
          orderId: widget.orderChatModel!.orderId,
          notificationBody: widget.notificationBody,
          conversationID: widget.conversationID,
          index: widget.index,
        );
      }

      Get.find<ChatController>().getMessages(
          1, widget.notificationBody, widget.user, widget.conversationID,
          firstLoad: true);

      _scrollController.addListener(() {
        if (_scrollController.hasClients &&
            _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
          final chatCtrl = Get.find<ChatController>();
          final offset = chatCtrl.messageModel?.offset ?? 1;
          final totalSize = chatCtrl.messageModel?.totalSize ?? 0;
          final pageSize = (totalSize / 10).ceil();
          if (offset < pageSize && !chatCtrl.isLoading) {
            chatCtrl.getMessages(
              offset + 1,
              widget.notificationBody,
              widget.user,
              widget.conversationID,
            );
          }
        }
      });

      if (Get.find<ProfileController>().userInfoModel == null ||
          Get.find<ProfileController>().userInfoModel!.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }

      if (widget.orderChatModel != null) {
        Get.find<OrderController>().getSupportReasons();
      }

      _startPolling();
    }
  }

  void _startPolling() {
    // Polling is now disabled in favor of Pusher WebSockets
    // _pollingTimer?.cancel();
    // _pollingTimer = Timer.periodic(const Duration(seconds: 7), (_) {
    //   final route = ModalRoute.of(context);
    //   if (!mounted || route?.isCurrent != true) return;
    //   Get.find<ChatController>().timerRefreshMessages(
    //     widget.notificationBody,
    //     widget.conversationID,
    //   );
    // });
  }

  @override
  void dispose() {
    Get.find<ChatController>().unsubscribePusher();
    _pollingTimer?.cancel();
    _stream?.cancel();
    super.dispose();
  }

  String _getRecipientName(ChatController chatController) {
    if (widget.notificationBody?.adminId != null ||
        (widget.notificationBody?.restaurantId == null &&
            widget.notificationBody?.deliverymanId == null &&
            widget.user == null &&
            widget.conversationID == null)) {
      return widget.notificationBody?.name ?? 'الدعم الفني';
    }

    final conversation = chatController.messageModel?.conversation;
    if (conversation != null) {
      User? otherUser = (conversation.senderType == UserType.user.name ||
              conversation.senderType == UserType.customer.name)
          ? conversation.receiver
          : conversation.sender;
      if (otherUser != null && (otherUser.fName ?? '').isNotEmpty) {
        return '${otherUser.fName ?? ''} ${otherUser.lName ?? ''}'.trim();
      }
    }

    if (widget.user != null && (widget.user!.fName ?? '').isNotEmpty) {
      return '${widget.user!.fName ?? ''} ${widget.user!.lName ?? ''}'.trim();
    }

    if (widget.notificationBody?.name != null &&
        widget.notificationBody!.name!.isNotEmpty) {
      return widget.notificationBody!.name!;
    }

    if (widget.notificationBody?.deliverymanId != null) {
      return 'مندوب التوصيل';
    }

    return 'متجر';
  }

  String _getRecipientSubtitle() {
    if (widget.notificationBody?.adminId != null ||
        (widget.notificationBody?.restaurantId == null &&
            widget.notificationBody?.deliverymanId == null &&
            widget.user == null &&
            widget.conversationID == null)) {
      return 'إدارة شلة';
    }
    if (widget.notificationBody?.deliverymanId != null) {
      return 'مندوب التوصيل';
    }
    return 'متجر';
  }

  String? _getRecipientImage(ChatController chatController) {
    if (widget.notificationBody?.adminId != null) {
      return null;
    }
    final conversation = chatController.messageModel?.conversation;
    if (conversation != null) {
      User? otherUser = (conversation.senderType == UserType.user.name ||
              conversation.senderType == UserType.customer.name)
          ? conversation.receiver
          : conversation.sender;
      if (otherUser?.imageFullUrl != null &&
          otherUser!.imageFullUrl!.isNotEmpty) {
        return otherUser.imageFullUrl;
      }
    }
    if (widget.user?.imageFullUrl != null &&
        widget.user!.imageFullUrl!.isNotEmpty) {
      return widget.user!.imageFullUrl;
    }
    if (widget.notificationBody?.image != null &&
        widget.notificationBody!.image!.isNotEmpty) {
      return widget.notificationBody!.image;
    }
    return null;
  }

  Widget _buildStatusChip(String status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case 'closed':
        statusText = 'مغلق';
        statusColor = const Color(0xFF707784);
        break;
      case 'in_progress':
        statusText = 'قيد المعالجة';
        statusColor = const Color(0xFF1E88E5);
        break;
      case 'pending':
        statusText = 'معلق';
        statusColor = const Color(0xFFFFA000);
        break;
      case 'resolved':
        statusText = 'تم الحل';
        statusColor = const Color(0xFF00897B);
        break;
      case 'urgent':
        statusText = 'عاجل';
        statusColor = const Color(0xFFE53935);
        break;
      case 'open':
      default:
        statusText = 'مفتوح';
        statusColor = const Color(0xFF31A342);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 0.8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 11,
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      final bool isLoggedIn = AuthHelper.isLoggedIn();

      return PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            return;
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          resizeToAvoidBottomInset: true,
          appBar: ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Get.back(),
                  ),
                  title: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomImage(
                            height: 40,
                            width: 40,
                            image: _getRecipientImage(chatController) ?? '',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getRecipientName(chatController),
                                style: const TextStyle(
                                  color: Color(0xFF111B18),
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w700,
                                  height: 1.60,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _getRecipientSubtitle(),
                                    style: const TextStyle(
                                      color: Color(0xFF707784),
                                      fontSize: 13,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                  if (chatController.messageModel?.conversation?.status != null) ...[
                                    const SizedBox(width: 8),
                                    _buildStatusChip(chatController.messageModel!.conversation!.status!),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: isLoggedIn
              ? ResponsiveHelper.isDesktop(context)
                  ? Column(
                      children: [
                        Container(
                          height: 64,
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.10),
                          child: Center(
                              child: Text(
                            'live_chat'.tr,
                            style: TextStyle(
                              color:
                                  const Color(0xFF111B18) /* Text-Headline */,
                              fontSize: 18,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                              height: 1.60,
                            ),
                          )),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: FooterView(
                              child: Column(
                                children: [
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  Center(
                                    child: SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeLarge),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(
                                                  Dimensions.radiusDefault)),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                spreadRadius: 1)
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            ResponsiveHelper.isDesktop(context)
                                                ? Container(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                        vertical: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    child: Row(children: [
                                                      ClipOval(
                                                          child: CustomImage(
                                                        image:
                                                            '${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.imageFullUrl : ''}',
                                                        height: 35,
                                                        width: 35,
                                                      )),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            chatController
                                                                        .messageModel !=
                                                                    null
                                                                ? Text(
                                                                    widget.notificationBody?.deliverymanId !=
                                                                            null
                                                                        ? '${chatController.messageModel!.conversation!.receiver!.fName}'
                                                                            ' ${chatController.messageModel!.conversation!.receiver!.lName}'
                                                                        : 'المسئول',
                                                                    style:
                                                                        robotoRegular,
                                                                  )
                                                                : Container(
                                                                    height: 20,
                                                                    width: 100,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor,
                                                                  ),
                                                            (chatController.messageModel !=
                                                                        null &&
                                                                    chatController
                                                                            .messageModel!
                                                                            .conversation!
                                                                            .receiver!
                                                                            .phone !=
                                                                        null)
                                                                ? Text(
                                                                    '${chatController.messageModel!.conversation!.receiver!.phone}',
                                                                    style: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions
                                                                                .fontSizeSmall,
                                                                        color: Theme.of(context)
                                                                            .hintColor),
                                                                  )
                                                                : const SizedBox(),
                                                          ]),
                                                    ]),
                                                  )
                                                : const SizedBox(),
                                            const Divider(),
                                            GetBuilder<ChatController>(
                                                builder: (chatController) {
                                              return SizedBox(
                                                height: 500,
                                                child: chatController
                                                            .messageModel !=
                                                        null
                                                    ? chatController
                                                            .messageModel!
                                                            .messages!
                                                            .isNotEmpty
                                                        ? ListView.builder(
                                                            controller: _scrollController,
                                                            physics: const AlwaysScrollableScrollPhysics(
                                                                parent: BouncingScrollPhysics()),
                                                            reverse: true,
                                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                                            itemCount: chatController.messageModel!.messages!.length,
                                                            itemBuilder: (context, index) {
                                                              return MessageBubbleWidget(
                                                                message: chatController.messageModel!.messages![index],
                                                                user: chatController.messageModel!.conversation!.receiver,
                                                                userType: widget.notificationBody!.adminId != null
                                                                    ? UserType.admin.name
                                                                    : widget.notificationBody!.deliverymanId != null
                                                                        ? UserType.delivery_man.name
                                                                        : UserType.vendor.name,
                                                              );
                                                            },
                                                          )
                                                        : Center(
                                                            child: Text(
                                                                'no_message_found'
                                                                    .tr))
                                                    : const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                              );
                                            }),
                                            GetBuilder<ChatController>(builder: (chatController) {
                                              if (chatController.isTyping) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        height: 15,
                                                        width: 15,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                                      Text('is_typing'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                                                    ],
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            }),
                                            (chatController.messageModel !=
                                                        null &&
                                                    (chatController
                                                            .messageModel!
                                                            .status! ||
                                                        chatController
                                                            .messageModel!
                                                            .messages!
                                                            .isEmpty))
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeSmall),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  Dimensions
                                                                      .radiusDefault)),
                                                      border: Border.all(
                                                          color:
                                                              Theme.of(context)
                                                                  .disabledColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.6)),
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                    ),
                                                    child: Column(children: [
                                                      GetBuilder<
                                                              ChatController>(
                                                          builder:
                                                              (chatController) {
                                                        return chatController
                                                                .chatImage
                                                                .isNotEmpty
                                                            ? SizedBox(
                                                                height: 100,
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemCount:
                                                                      chatController
                                                                          .chatImage
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          index) {
                                                                    return chatController
                                                                            .chatImage
                                                                            .isNotEmpty
                                                                        ? Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Stack(
                                                                              clipBehavior: Clip.none,
                                                                              children: [
                                                                                Container(
                                                                                  width: 70,
                                                                                  height: 90,
                                                                                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                                                                    child: Image.memory(
                                                                                      chatController.chatRawImage[index],
                                                                                      width: 70,
                                                                                      height: 90,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Positioned(
                                                                                  top: -5,
                                                                                  right: -5,
                                                                                  child: InkWell(
                                                                                    onTap: () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                                                                    child: Container(
                                                                                      decoration: const BoxDecoration(
                                                                                        color: Color(0xff9EADC1),
                                                                                        borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                                                                      ),
                                                                                      child: const Padding(
                                                                                        padding: EdgeInsets.all(4.0),
                                                                                        child: Icon(Icons.clear, color: Colors.white, size: 15),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : const SizedBox();
                                                                  },
                                                                ),
                                                              )
                                                            : const SizedBox();
                                                      }),
                                                      Row(children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            Get.find<
                                                                    ChatController>()
                                                                .pickImage(
                                                                    false);
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeDefault),
                                                            child: Image.asset(
                                                                Images.image,
                                                                width: 25,
                                                                height: 25,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                          ),
                                                        ),

                                                        /* SizedBox(
                                        height: 25,
                                        child: VerticalDivider(width: 0, thickness: 1, color: Theme.of(context).hintColor),
                                      ),*/
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Expanded(
                                                          child: TextField(
                                                            inputFormatters: [
                                                              LengthLimitingTextInputFormatter(
                                                                  Dimensions
                                                                      .messageInputLength)
                                                            ],
                                                            controller:
                                                                _inputMessageController,
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .sentences,
                                                            style:
                                                                robotoRegular,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            maxLines: null,
                                                            decoration:
                                                                InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText:
                                                                  'type_here'
                                                                      .tr,
                                                              hintStyle: robotoRegular.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeLarge),
                                                            ),
                                                            onSubmitted: (String
                                                                newText) {
                                                              if (newText
                                                                      .trim()
                                                                      .isNotEmpty &&
                                                                  !Get.find<
                                                                          ChatController>()
                                                                      .isSendButtonActive) {
                                                                Get.find<
                                                                        ChatController>()
                                                                    .toggleSendButtonActivity();
                                                              } else if (newText
                                                                      .isEmpty &&
                                                                  Get.find<
                                                                          ChatController>()
                                                                      .isSendButtonActive) {
                                                                Get.find<
                                                                        ChatController>()
                                                                    .toggleSendButtonActivity();
                                                              }
                                                              // Trigger typing event when user types
                                                              if (newText.isNotEmpty) {
                                                                Get.find<ChatController>().sendTypingEvent();
                                                              }
                                                            },
                                                            onChanged: (String
                                                                newText) {
                                                              if (newText.isNotEmpty) {
                                                                Get.find<ChatController>().sendTypingEvent();
                                                              }
                                                              if (newText
                                                                      .trim()
                                                                      .isNotEmpty &&
                                                                  !Get.find<
                                                                          ChatController>()
                                                                      .isSendButtonActive) {
                                                                Get.find<
                                                                        ChatController>()
                                                                    .toggleSendButtonActivity();
                                                              } else if (newText
                                                                      .isEmpty &&
                                                                  Get.find<
                                                                          ChatController>()
                                                                      .isSendButtonActive) {
                                                                Get.find<
                                                                        ChatController>()
                                                                    .toggleSendButtonActivity();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        GetBuilder<
                                                                ChatController>(
                                                            builder:
                                                                (chatController) {
                                                          final bool
                                                              showMessageSuggestion =
                                                              (widget
                                                                          .orderChatModel !=
                                                                      null &&
                                                                  _inputMessageController
                                                                      .text
                                                                      .isEmpty &&
                                                                  chatController
                                                                      .chatImage
                                                                      .isEmpty &&
                                                                  Get.find<OrderController>()
                                                                          .supportReasons !=
                                                                      null &&
                                                                  Get.find<
                                                                          OrderController>()
                                                                      .supportReasons!
                                                                      .isNotEmpty);

                                                          return chatController
                                                                  .isLoading
                                                              ? const Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          Dimensions
                                                                              .paddingSizeDefault),
                                                                  child: SizedBox(
                                                                      height:
                                                                          25,
                                                                      width: 25,
                                                                      child:
                                                                          CircularProgressIndicator()),
                                                                )
                                                              : InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if (showMessageSuggestion) {
                                                                      if (ResponsiveHelper
                                                                          .isDesktop(
                                                                              context)) {
                                                                        Get.dialog(const MessageSuggestionWidget(),
                                                                                barrierColor: Colors.transparent)
                                                                            .then((value) async {
                                                                          if (value !=
                                                                              null) {
                                                                            _inputMessageController.text =
                                                                                value as String;
                                                                            chatController.toggleSendButtonActivity();
                                                                          }
                                                                        });
                                                                      } else {
                                                                        Get.bottomSheet(const SupportReasonBottomSheet(orderId: null, fromChatPage: true),
                                                                                backgroundColor: Colors.transparent,
                                                                                isScrollControlled: true)
                                                                            .then((value) async {
                                                                          if (value !=
                                                                              null) {
                                                                            _inputMessageController.text =
                                                                                value as String;
                                                                            chatController.toggleSendButtonActivity();
                                                                          }
                                                                        });
                                                                      }
                                                                    } else {
                                                                      if (chatController
                                                                          .isSendButtonActive) {
                                                                        await chatController
                                                                            .sendMessage(
                                                                          message:
                                                                              _inputMessageController.text,
                                                                          notificationBody:
                                                                              widget.notificationBody,
                                                                          conversationID:
                                                                              widget.conversationID,
                                                                          index:
                                                                              widget.index,
                                                                          orderId: widget
                                                                              .orderChatModel
                                                                              ?.orderId,
                                                                        );
                                                                        _inputMessageController
                                                                            .clear();
                                                                      } else {
                                                                        showCustomSnackBar(
                                                                            'write_something'.tr);
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            Dimensions.paddingSizeDefault),
                                                                    child: Image
                                                                        .asset(
                                                                      showMessageSuggestion
                                                                          ? Images
                                                                              .suggestionMessage
                                                                          : Images
                                                                              .send,
                                                                      width: 25,
                                                                      height:
                                                                          25,
                                                                      color: chatController.isSendButtonActive ||
                                                                              showMessageSuggestion
                                                                          ? Theme.of(context)
                                                                              .primaryColor
                                                                          : Theme.of(context)
                                                                              .hintColor,
                                                                    ),
                                                                  ),
                                                                );
                                                        }),
                                                      ]),
                                                    ]),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SafeArea(
                      bottom: false,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: double.infinity,
                        child: Column(
                          children: [
                            GetBuilder<ChatController>(
                                builder: (chatController) {
                              return Expanded(
                                  child: chatController.messageModel != null
                                      ? chatController.messageModel!.messages!
                                              .isNotEmpty
                                          ? SingleChildScrollView(
                                              controller: _scrollController,
                                              reverse: true,
                                              child: PaginatedListView(
                                                scrollController:
                                                    _scrollController,
                                                reverse: true,
                                                totalSize: chatController
                                                    .messageModel?.totalSize,
                                                offset: chatController
                                                    .messageModel?.offset,
                                                onPaginate:
                                                    (int? offset) async =>
                                                        await chatController
                                                            .getMessages(
                                                  offset!,
                                                  widget.notificationBody,
                                                  widget.user,
                                                  widget.conversationID,
                                                ),
                                                itemView: ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  reverse: true,
                                                  itemCount: chatController
                                                      .messageModel!
                                                      .messages!
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return MessageBubbleWidget(
                                                      message: chatController
                                                          .messageModel!
                                                          .messages![index],
                                                      user: chatController
                                                          .messageModel!
                                                          .conversation!
                                                          .receiver,
                                                      userType: widget
                                                                  .notificationBody!
                                                                  .adminId !=
                                                              null
                                                          ? UserType.admin.name
                                                          : widget.notificationBody!
                                                                      .deliverymanId !=
                                                                  null
                                                              ? UserType
                                                                  .delivery_man
                                                                  .name
                                                              : UserType
                                                                  .vendor.name,
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child:
                                                  Text('no_message_found'.tr))
                                      : chatController.isGetMessageError
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.error_outline,
                                                      color: Colors.red,
                                                      size: 40),
                                                  const SizedBox(height: 8),
                                                  Text('failed_to_load_message'
                                                      .tr),
                                                  TextButton(
                                                    onPressed: () =>
                                                        chatController
                                                            .getMessages(
                                                      1,
                                                      widget.notificationBody,
                                                      widget.user,
                                                      widget.conversationID,
                                                      firstLoad: true,
                                                    ),
                                                    child: Text('try_again'.tr),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator()));
                            }),
                            if (chatController.isTyping)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('store_is_typing'.tr, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                              ),
                            (chatController.messageModel != null &&
                                    (chatController.messageModel!.status! ||
                                        chatController
                                            .messageModel!.messages!.isEmpty))
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeSmall),
                                    child: Column(children: [
                                      GetBuilder<ChatController>(
                                          builder: (chatController) {
                                        return chatController
                                                .chatImage.isNotEmpty
                                            ? SizedBox(
                                                height: 100,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: chatController
                                                      .chatImage.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          index) {
                                                    return chatController
                                                            .chatImage
                                                            .isNotEmpty
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Stack(
                                                              clipBehavior:
                                                                  Clip.none,
                                                              children: [
                                                                Container(
                                                                  width: 70,
                                                                  height: 90,
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(20))),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(Dimensions.paddingSizeSmall)),
                                                                    child: Image
                                                                        .memory(
                                                                      chatController
                                                                              .chatRawImage[
                                                                          index],
                                                                      width: 70,
                                                                      height:
                                                                          90,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: -5,
                                                                  right: -5,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () => chatController.removeImage(
                                                                        index,
                                                                        _inputMessageController
                                                                            .text
                                                                            .trim()),
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Color(
                                                                            0xff9EADC1),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                                                      ),
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(4.0),
                                                                        child: Icon(
                                                                            Icons
                                                                                .clear,
                                                                            color:
                                                                                Colors.white,
                                                                            size: 15),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : const SizedBox();
                                                  },
                                                ),
                                              )
                                            : const SizedBox();
                                      }),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: widget.isClosed
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 56,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFF6F5F8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        'you_have_closed_the_chat'
                                                            .tr,
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF111B18),
                                                          fontSize: 14,
                                                          fontFamily: 'Tajawal',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFFE5E7EB),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.send_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  GetBuilder<ChatController>(
                                                      builder:
                                                          (chatController) {
                                                    return InkWell(
                                                      onTap: () async {
                                                        if (chatController
                                                                .isSendButtonActive &&
                                                            !chatController
                                                                .isLoading) {
                                                          await chatController
                                                              .sendMessage(
                                                            message:
                                                                _inputMessageController
                                                                    .text,
                                                            notificationBody: widget
                                                                .notificationBody,
                                                            conversationID: widget
                                                                .conversationID,
                                                            index: widget.index,
                                                            orderId: widget
                                                                .orderChatModel
                                                                ?.orderId,
                                                          );
                                                          _inputMessageController
                                                              .clear();
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: chatController
                                                                      .isSendButtonActive &&
                                                                  !chatController
                                                                      .isLoading
                                                              ? const Color(
                                                                  0xFF30913F)
                                                              : const Color(
                                                                  0xFFE5E7EB),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: chatController
                                                                  .isLoading
                                                              ? const SizedBox(
                                                                  height: 20,
                                                                  width: 20,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                )
                                                              : const Icon(
                                                                  Icons.near_me,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 20,
                                                                ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Container(
                                                      height: 56,
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: const Color(
                                                            0xFFF6F5F8),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              inputFormatters: [
                                                                LengthLimitingTextInputFormatter(
                                                                    Dimensions
                                                                        .messageInputLength)
                                                              ],
                                                              controller:
                                                                  _inputMessageController,
                                                              textCapitalization:
                                                                  TextCapitalization
                                                                      .sentences,
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFF111B18),
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Tajawal',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .multiline,
                                                              minLines: 1,
                                                              maxLines: 4,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8),
                                                                hintText:
                                                                    'write_your_message_here'
                                                                        .tr,
                                                                hintStyle:
                                                                    const TextStyle(
                                                                  color: Color(
                                                                      0xFF555555),
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Tajawal',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  height: 1.60,
                                                                ),
                                                              ),
                                                              onChanged: (String
                                                                  newText) {
                                                                if (newText
                                                                        .trim()
                                                                        .isNotEmpty &&
                                                                    !Get.find<
                                                                            ChatController>()
                                                                        .isSendButtonActive) {
                                                                  Get.find<
                                                                          ChatController>()
                                                                      .toggleSendButtonActivity();
                                                                } else if (newText
                                                                        .isEmpty &&
                                                                    Get.find<
                                                                            ChatController>()
                                                                        .isSendButtonActive) {
                                                                  Get.find<
                                                                          ChatController>()
                                                                      .toggleSendButtonActivity();
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () async {
                                                              Get.find<
                                                                      ChatController>()
                                                                  .pickImage(
                                                                      false);
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12),
                                                              child: Image.asset(
                                                                  Images.image,
                                                                  height: 24,
                                                                  width: 24,
                                                                  color: Color(
                                                                      0xFF707784)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ]),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    )
              : NotLoggedInScreen(callBack: (value) {
                  initCall();
                  setState(() {});
                }),
        ),
      );
    });
  }
}

class MessageSuggestionWidget extends StatelessWidget {
  const MessageSuggestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final bool isDesktop = ResponsiveHelper.isDesktop(context);

      return Container(
        width: Dimensions.webMaxWidth,
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge, vertical: 50),
        alignment: Get.find<LocalizationController>().isLtr
            ? Alignment.bottomRight
            : Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            orderController.supportReasons!.isNotEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: context.height * 0.5, minHeight: 30),
                        width: isDesktop ? 600 : context.width * 0.8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10)
                          ],
                        ),
                        margin: EdgeInsets.only(
                            right: isDesktop ? context.width * 0.1 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.paddingSizeDefault),
                                    child: Text(
                                        'choose_the_reason_for_support'.tr,
                                        style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault)),
                                  ),
                                  IconButton(
                                      onPressed: () => Get.back(),
                                      icon: const Icon(Icons.clear)),
                                ]),
                            Container(
                              constraints: BoxConstraints(
                                  maxHeight: context.height * 0.3,
                                  minHeight: 30),
                              child: ListView.builder(
                                  itemCount:
                                      orderController.supportReasons!.length,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Get.back(
                                            result: orderController
                                                .supportReasons![index]);
                                      },
                                      child: TextHover(builder: (isHovered) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5),
                                                width: 0.3),
                                            boxShadow: isHovered
                                                ? [
                                                    BoxShadow(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                                alpha: 0.5),
                                                        blurRadius: 10)
                                                  ]
                                                : null,
                                          ),
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall),
                                          margin: const EdgeInsets.all(
                                              Dimensions.paddingSizeExtraSmall),
                                          child: Text(
                                              orderController
                                                      .supportReasons![index] ??
                                                  '',
                                              style: isHovered
                                                  ? robotoMedium
                                                  : robotoRegular),
                                        );
                                      }),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      );
    });
  }
}
