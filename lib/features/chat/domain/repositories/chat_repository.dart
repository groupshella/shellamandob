import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:sixam_mart/features/chat/enums/user_type_enum.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class ChatRepository implements ChatRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ChatRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<StoreModel?> searchStoreList(String name) async {
    StoreModel? storeModel;
    final String safeQuery = Uri.encodeQueryComponent(name.trim());
    final String endpoint = '${AppConstants.searchUri}stores/search?name=$safeQuery&offset=1&limit=50';
    final Response response = await apiClient.getData(
      endpoint,
      useEtag: false,
      headers: <String, String>{
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );
    if(response.statusCode == 200) {
      storeModel = StoreModel.fromJson(response.body as Map<String, dynamic>);
    }
    return storeModel;
  }

  @override
  Future getList({int? offset, bool conversationList = false, String? type, bool searchConversationalList = false, String? name}) async {
    if(conversationList) {
      return await _getConversationList(offset!, type!);
    }else if(searchConversationalList) {
      return await _searchConversationList(name!);
    }
  }

  Future<ConversationsModel?> _getConversationList(int offset, String type) async {
    ConversationsModel? conversationModel;
    final String endpoint =
        '${AppConstants.conversationListUri}?limit=10&offset=$offset&type=$type';
    final Response response = await apiClient.getData(
      endpoint,
      useEtag: false,
      headers: <String, String>{
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );
    if(response.statusCode == 200){
      conversationModel = ConversationsModel.fromJson(response.body as Map<String, dynamic>);
    }
    return conversationModel;
  }

  Future<ConversationsModel?> _searchConversationList(String name) async {
    ConversationsModel? searchConversationModel;
    final String endpoint =
        '${AppConstants.searchConversationListUri}?name=$name&limit=20&offset=1';
    final Response response = await apiClient.getData(
      endpoint,
      useEtag: false,
      headers: <String, String>{
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );
    if(response.statusCode == 200) {
      searchConversationModel = ConversationsModel.fromJson(response.body as Map<String, dynamic>);
    }
    return searchConversationModel;
  }

  @override
  Future<Response> getMessages(int offset, int? userID, String userType, int? conversationID) async {
    final String endpoint =
        '${AppConstants.messageListUri}?${conversationID != null ? 'conversation_id' : userType == UserType.admin.name ? 'admin_id'
        : userType == UserType.vendor.name ? 'vendor_id' : 'delivery_man_id'}=${conversationID ?? userID}&offset=$offset&limit=10';
    debugPrint('[CHAT:getMessages][ENDPOINT] $endpoint');
    debugPrint(
        '[CHAT:getMessages][REQUEST_PARAMS] offset=$offset userID=$userID userType=$userType conversationID=$conversationID');
    return await apiClient.getData(
      endpoint,
      useEtag: false,
      headers: <String, String>{
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );
  }

  @override
  Future<Response> sendMessage(String message, String orderId, List<MultipartBody> images, int? userID, String userType, int? conversationID) async {
    final Map<String, String> fields = {};
    if(orderId.isNotEmpty) {
      fields.addAll({'order_id': orderId});
    }
    fields.addAll({'message': message, 'receiver_type': userType, 'offset': '1', 'limit': '10'});
    if(conversationID != null) {
      fields.addAll({'conversation_id': conversationID.toString()});
    }else {
      fields.addAll({'receiver_id': userID.toString()});
    }
    return await apiClient.postMultipartData(AppConstants.sendMessageUri, fields, images);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> archiveConversation(int conversationId) async {
    Response response = await apiClient.postData(
      AppConstants.archiveConversationUri,
      {'conversation_id': conversationId},
    );
    return response.statusCode == 200;
  }

  @override
  List<String> getChatSearchHistory() {
    return sharedPreferences.getStringList(AppConstants.chatSearchHistory) ?? [];
  }

  @override
  void saveChatSearchHistory(List<String> searchHistory) {
    sharedPreferences.setStringList(AppConstants.chatSearchHistory, searchHistory);
  }

  @override
  void clearChatSearchHistory() {
    sharedPreferences.remove(AppConstants.chatSearchHistory);
  }
}