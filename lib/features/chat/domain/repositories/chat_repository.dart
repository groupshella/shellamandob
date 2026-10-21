import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ChatRepository {
  final ApiClient apiClient;

  ChatRepository({required this.apiClient});

  Future<ConversationsModel?> getConversationList(int offset) async {
    Response response = await apiClient.getData('${AppConstants.conversationListUri}?offset=$offset&limit=20');
    if (response.statusCode == 200) {
      return ConversationsModel.fromJson(response.body);
    }
    return null;
  }

  Future<MessageModel?> getMessages(int offset, int? conversationID) async {
    String uri = '${AppConstants.messageListUri}?offset=$offset&limit=20';
    if (conversationID != null && conversationID > 0) {
      uri += '&conversation_id=$conversationID';
    } else {
      uri += '&receiver_type=admin&admin_id=0';
    }
    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200) {
      return MessageModel.fromJson(response.body);
    }
    return null;
  }

  Future<Response> sendMessage({
    required String message,
    required List<MultipartBody> files,
    int? conversationId,
    String receiverType = 'admin',
    int? receiverId,
  }) async {
    Map<String, String> fields = {
      'message': message,
      'receiver_type': receiverType,
    };
    if (conversationId != null && conversationId > 0) {
      fields['conversation_id'] = conversationId.toString();
    }
    if (receiverId != null) {
      fields['receiver_id'] = receiverId.toString();
    }

    if (files.isNotEmpty) {
      return await apiClient.postMultipartData(AppConstants.sendMessageUri, fields, files);
    } else {
      return await apiClient.postData(AppConstants.sendMessageUri, fields);
    }
  }
}
