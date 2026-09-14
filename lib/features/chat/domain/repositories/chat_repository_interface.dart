import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

abstract class ChatRepositoryInterface extends RepositoryInterface {
  Future<StoreModel?> searchStoreList(String name);
  @override
  Future getList({int? offset, bool conversationList = false, String? type, bool searchConversationalList = false, String? name});
  Future<dynamic> getMessages(int offset, int? userID, String userType, int? conversationID);
  Future<dynamic> sendMessage(String message, String orderId, List<MultipartBody> images, int? userID, String userType, int? conversationID);
  Future<bool> archiveConversation(int conversationId);
  
  List<String> getChatSearchHistory();
  void saveChatSearchHistory(List<String> searchHistory);
  void clearChatSearchHistory();
}