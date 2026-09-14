import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/enums/user_type_enum.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<ChatController>().getConversationList(1, type: 'archive');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // Refresh original list before popping
                    Get.find<ChatController>().getConversationList(1,
                        type: Get.context != null &&
                                ResponsiveHelper.isDesktop(Get.context!)
                            ? 'vendor1'
                            : '');
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF111B18),
                  ),
                ),
                const Spacer(),
                Text(
                  'archive_title'.tr,
                  style: const TextStyle(
                    color: Color(0xFF111B18),
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    height: 1.60,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
      body: GetBuilder<ChatController>(builder: (chatController) {
        ConversationsModel? conversation = chatController.conversationModel;

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search_here'.tr,
                          hintStyle: const TextStyle(
                            color: Color(0xFF707784),
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _initCall();
                          }
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            chatController.searchConversation(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.search,
                      color: Color(0xFF111B18),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // List of archived chats
            Expanded(
              child: AuthHelper.isLoggedIn()
                  ? (conversation != null && conversation.conversations != null)
                      ? conversation.conversations!.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: () async {
                                _initCall();
                              },
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: conversation.conversations!.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) {
                                  User? user;
                                  String? type;
                                  final currentConv =
                                      conversation.conversations![index]!;

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

                                  Widget cardWidget = Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withValues(alpha: 0.1))),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Get.toNamed(RouteHelper.getChatRoute(
                                          notificationBody:
                                              NotificationBodyModel(
                                            type: currentConv.senderType,
                                            notificationType:
                                                NotificationType.message,
                                            adminId: type == UserType.admin.name
                                                ? 0
                                                : null,
                                            restaurantId:
                                                type == UserType.vendor.name
                                                    ? user?.id
                                                    : null,
                                            deliverymanId: type == UserType.delivery_man.name ? user?.id : null,
                                          ),
                                          conversationID: currentConv.id,
                                          index: index,
                                          isClosed: true,
                                        ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: Row(
                                          children: [
                                            // Logo
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user != null
                                                        ? '${user.fName} ${user.lName}'
                                                        : '${type?.tr ?? ''} ${'deleted'.tr}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF111B18),
                                                      fontSize: 16,
                                                      fontFamily: 'Tajawal',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.60,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                   Text(
                                                     type == UserType.admin.name
                                                         ? 'إدارة شلة'
                                                          : (type == UserType.vendor.name)
                                                             ? 'متجر'
                                                             : (type == UserType.delivery_man.name)
                                                                 ? 'مندوب التوصيل'
                                                                 : (type?.tr ?? ''),
                                                    style: const TextStyle(
                                                      color: Color(0xFF111B18),
                                                      fontSize: 14,
                                                      fontFamily: 'Tajawal',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.60,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Closed Badge and Chevron
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFFF1F1F1), // Grey background for Closed
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    'closed'.tr,
                                                    style: const TextStyle(
                                                      color: Color(
                                                          0xFF8A92A6), // Grey text for Closed
                                                      fontSize: 12,
                                                      fontFamily: 'Tajawal',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: Color(0xFF707784),
                                                ),
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
                            )
                          : Center(child: Text('no_conversation_found'.tr))
                      : const Center(child: CircularProgressIndicator())
                  : const SizedBox(),
            ),
          ],
        );
      }),
    );
  }
}
