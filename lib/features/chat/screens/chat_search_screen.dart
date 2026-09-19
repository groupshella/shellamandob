import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/enums/user_type_enum.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChatController>().removeSearchMode();
      Get.find<ChatController>().getChatSearchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    Get.find<ChatController>().removeSearchMode();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios,
                      color: Color(0xFF111B18), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5F8),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFF6F5F8), width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        color: Color(0xFF111B18),
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          Get.find<ChatController>()
                              .saveChatSearchHistory(text.trim());
                        }
                        Get.find<ChatController>().searchConversation(text);
                      },
                      onChanged: (text) {
                        Get.find<ChatController>().searchConversation(text);
                      },
                      decoration: InputDecoration(
                        hintText: 'search_label'.tr,
                        hintStyle: const TextStyle(
                          color: Color(0xFF707784),
                          fontSize: 16,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: SvgPicture.asset(Images.searchIconFigma),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  Get.find<ChatController>().removeSearchMode();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear,
                                    color: Color(0xFF707784), size: 20),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GetBuilder<ChatController>(builder: (chatController) {
        if (chatController.isSearchLoading) {
          return ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.1))),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 14,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        StoreModel? storeModel = chatController.searchStoreModel;

        if (storeModel == null && _searchController.text.isEmpty) {
          if (chatController.chatSearchHistory.isEmpty) {
            return const SizedBox();
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'عمليات البحث الأخيرة',
                      style: TextStyle(
                        color: Color(0xFF111B18),
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        chatController.clearChatSearchHistory();
                      },
                      child: const Icon(Icons.delete_outline,
                          color: Color(0xFF707784), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chatController.chatSearchHistory.map((history) {
                    return InkWell(
                      onTap: () {
                        _searchController.text = history;
                        chatController.searchConversation(history);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F5F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          history,
                          style: const TextStyle(
                            color: Color(0xFF111B18),
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }

        if (storeModel != null &&
            storeModel.stores != null &&
            storeModel.stores!.isEmpty) {
          return Center(
              child: Text('no_results'.tr,
                  style: const TextStyle(color: Color(0xFF707784))));
        }

        return ListView.builder(
          itemCount: storeModel?.stores?.length ?? 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemBuilder: (context, index) {
            final store = storeModel!.stores![index];

            return Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.1))),
              ),
              child: CustomInkWell(
                onTap: () {
                  if (_searchController.text.trim().isNotEmpty) {
                    Get.find<ChatController>()
                        .saveChatSearchHistory(_searchController.text.trim());
                  }

                  Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: NotificationBodyModel(
                      type: UserType.vendor.name,
                      notificationType: NotificationType.message,
                      restaurantId: store.id,
                      name: store.name,
                      image: store.logoFullUrl,
                    ),
                    conversationID: null,
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImage(
                          height: 44,
                          width: 44,
                          image: store.logoFullUrl ?? '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name ?? '',
                              style: const TextStyle(
                                color: Color(0xFF111B18),
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.description?.isNotEmpty == true ? store.description! : 'وصف لمنتجات المتجر',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF707784),
                                fontSize: 14,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
