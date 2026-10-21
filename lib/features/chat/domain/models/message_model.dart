import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';

class MessageModel {
  int? totalSize;
  int? limit;
  int? offset;
  bool? status;
  Conversation? conversation;
  List<Message>? messages;

  MessageModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.messages,
    this.status,
    this.conversation,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    status = json['status'] ?? false;
    conversation = json['conversation'] != null
        ? Conversation.fromJson(json['conversation'])
        : null;
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) {
        messages!.add(Message.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['status'] = status;
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Message {
  int? id;
  int? conversationId;
  int? senderId;
  String? message;
  List<String>? filesFullUrl;
  int? isSeen;
  String? createdAt;
  String? updatedAt;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    this.message,
    this.filesFullUrl,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    message = json['message'];
    if (json['file_full_url'] != null && json['file_full_url'] is List) {
      filesFullUrl = (json['file_full_url'] as List).map((e) => e.toString()).toList();
    } else {
      filesFullUrl = [];
    }
    isSeen = json['is_seen'];
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['file_full_url'] = filesFullUrl;
    data['is_seen'] = isSeen;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
