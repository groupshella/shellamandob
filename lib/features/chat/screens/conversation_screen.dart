import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/enums/user_type_enum.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/chat/widgets/web_chat_view_widget.dart';

class ConversationScreen extends StatefulWidget {
  final bool fromNavBar;
  const ConversationScreen({super.key, this.fromNavBar = false});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  String _getGroupLabel(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final DateTime? dateTime = DateConverter.tryParseDateTimeSafely(dateStr);
    if (dateTime == null) return '';
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'today'.tr;
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'yesterday'.tr;
    } else {
      return DateConverter.stringToLocalDateOnly(dateStr);
    }
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<ChatController>().getConversationList(1,
          type: Get.context != null && ResponsiveHelper.isDesktop(Get.context!)
              ? 'vendor1'
              : '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      ConversationsModel? conversation = chatController.conversationModel;

      return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Color(0xFF111B18),
                    ),
                  ),
                  Spacer(),
                  // Title & Info
                  Text(
                    'live_chat'.tr,
                    style: TextStyle(
                      color: const Color(0xFF111B18) /* Text-Headline */,
                      fontSize: 18,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      height: 1.60,
                    ),
                  ),
                  Spacer(),
                  // Search Icon
                ],
              ),
            ),
          ),
        ),
        body: ResponsiveHelper.isDesktop(context)
            ? WebChatViewWidget(
                scrollController: _scrollController,
                conversation: conversation,
                chatController: chatController,
                searchController: _searchController,
                initCall: initCall,
              )
            : Column(
                children: [
                  // Top Button: Start New Conversation
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(RouteHelper.getNewConversationRoute());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBFEEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  Images.messages_v2,
                                  width: 24,
                                  height: 24,
                                  color: const Color(0xFF111B18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'بدأ محادثة جديدة',
                                  style: TextStyle(
                                    color: const Color(
                                        0xFF111B18) /* Text-Headline */,
                                    fontSize: 15,
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w700,
                                    height: 1.60,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Color(0xFF111B18)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title: Conversation History
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Get.find<LocalizationController>().isLtr
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(
                        'سجل المحادثات',
                        style: TextStyle(
                          color: const Color(0xFF111B18) /* Text-Headline */,
                          fontSize: 16,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          height: 1.60,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: AuthHelper.isLoggedIn()
                        ? (conversation != null &&
                                conversation.conversations != null)
                            ? conversation.conversations!.isNotEmpty
                                ? RefreshIndicator(
                                    onRefresh: () async {
                                      await Get.find<ChatController>()
                                          .getConversationList(1);
                                    },
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: PaginatedListView(
                                        scrollController: _scrollController,
                                        onPaginate: (int? offset) =>
                                            chatController
                                                .getConversationList(offset!),
                                        totalSize: conversation.totalSize,
                                        offset: conversation.offset,
                                        enabledPagination: true,
                                        itemView: ListView.builder(
                                          itemCount: conversation
                                              .conversations!.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            User? user;
                                            String? type;
                                            final currentConv = conversation.conversations![index]!;

                                            if (currentConv.senderType ==
                                                    UserType.user.name ||
                                                currentConv.senderType ==
                                                    UserType.customer.name) {
                                              user = currentConv.receiver;
                                              type = currentConv.receiverType;
                                            } else {
                                              user = currentConv.sender;
                                              type = currentConv.senderType;
                                            }

                                            String currentConvDate = currentConv.lastMessageTime ?? currentConv.updatedAt ?? currentConv.createdAt ?? '';
                                            String currentLabel = _getGroupLabel(currentConvDate);
                                            bool showDateHeader = false;
                                            if (currentLabel.isNotEmpty) {
                                              if (index == 0) {
                                                showDateHeader = true;
                                              } else {
                                                final prevConv = conversation.conversations![index - 1];
                                                String prevConvDate = prevConv?.lastMessageTime ?? prevConv?.updatedAt ?? prevConv?.createdAt ?? '';
                                                showDateHeader = _getGroupLabel(prevConvDate) != currentLabel;
                                              }
                                            }

                                            String statusText = 'مفتوح';
                                            Color statusColor = const Color(0xFF31A342);

                                            switch (currentConv.status) {
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

                                            Widget cardWidget = Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                                alpha: 0.1))),
                                              ),
                                              child: CustomInkWell(
                                                onLongPress: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'أرشفة المحادثة',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Tajawal')),
                                                      content: const Text(
                                                          'هل أنت متأكد من أرشفة هذه المحادثة؟',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Tajawal')),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              'إلغاء',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Tajawal',
                                                                  color: Colors
                                                                      .grey)),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Get.find<
                                                                    ChatController>()
                                                                .archiveConversation(
                                                                    currentConv
                                                                        .id);
                                                          },
                                                          child: const Text(
                                                              'أرشفة',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Tajawal',
                                                                  color: Colors
                                                                      .red)),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                onTap: () {
                                                  if (user != null) {
                                                    Get.toNamed(RouteHelper
                                                        .getChatRoute(
                                                      notificationBody:
                                                          NotificationBodyModel(
                                                        type: currentConv
                                                            .senderType,
                                                        notificationType:
                                                            NotificationType
                                                                .message,
                                                        adminId: type ==
                                                                UserType
                                                                    .admin.name
                                                            ? 0
                                                            : null,
                                                        restaurantId: type ==
                                                                UserType
                                                                    .vendor.name
                                                            ? user.id
                                                            : null,
                                                        deliverymanId: type ==
                                                                UserType
                                                                    .delivery_man
                                                                    .name
                                                            ? user.id
                                                            : null,
                                                      ),
                                                      conversationID:
                                                          currentConv.id,
                                                      index: index,
                                                    ));
                                                  } else {
                                                    showCustomSnackBar(
                                                        '${type?.tr ?? ''} ${'not_found'.tr}');
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Row(
                                                    children: [
                                                      // Logo (Index 0 in RTL visually rightmost)
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: CustomImage(
                                                          height: 44,
                                                          width: 44,
                                                          image:
                                                              '${user != null ? user.imageFullUrl : ''}',
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),

                                                      // Texts
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              user != null
                                                                  ? '${user.fName} ${user.lName}'
                                                                  : '${type?.tr ?? ''} ${'deleted'.tr}',
                                                              style: robotoBold
                                                                  .copyWith(
                                                                      fontSize:
                                                                          16,
                                                                      color: const Color(
                                                                          0xFF111B18)),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              type == UserType.admin.name
                                                                  ? 'إدارة شلة'
                                                                  : (type == UserType.vendor.name)
                                                                      ? 'متجر'
                                                                      : (type == UserType.delivery_man.name)
                                                                          ? 'مندوب التوصيل'
                                                                          : (type?.tr ?? ''),
                                                              style: robotoMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: const Color(
                                                                          0xFF111B18)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),

                                                      // Badge and Chevron
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color:
                                                                      statusColor,
                                                                  width: 0.8),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Text(
                                                              statusText,
                                                              style: robotoMedium
                                                                  .copyWith(
                                                                      color:
                                                                          statusColor,
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 12),
                                                          const Icon(
                                                              Icons
                                                                  .arrow_back_ios_new,
                                                              size: 14,
                                                              textDirection: TextDirection.ltr,
                                                              color: Color(
                                                                  0xFF707784)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );

                                            if (showDateHeader) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: Text(
                                                      currentLabel,
                                                      style: const TextStyle(
                                                        color: Color(0xFF707784),
                                                        fontSize: 18,
                                                        fontFamily: 'Tajawal',
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.60,
                                                      ),
                                                    ),
                                                  ),
                                                  cardWidget,
                                                ],
                                              );
                                            }
                                            return cardWidget;
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text('no_conversation_found'.tr))
                            : const Center(child: CircularProgressIndicator())
                        : NotLoggedInScreen(callBack: (value) {
                            initCall();
                            setState(() {});
                          }),
                  ),

                  // Archive button
                  if (AuthHelper.isLoggedIn())
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(RouteHelper.getArchiveRoute());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F5F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    Images.archive,
                                    width: 24,
                                    height: 24,
                                    color: const Color(0xFF111B18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'أرشيف',
                                    style: TextStyle(
                                      color: const Color(
                                          0xFF111B18) /* Text-Headline */,
                                      fontSize: 15,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w700,
                                      height: 1.60,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Color(0xFF111B18)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      );
    });
  }
}
