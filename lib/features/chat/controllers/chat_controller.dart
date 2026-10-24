import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/core/services/pusher_service.dart';
import 'package:sixam_mart/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/domain/repositories/chat_repository.dart';

class ChatController extends GetxController implements GetxService {
  final ChatRepository chatRepository;

  ChatController({required this.chatRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSending = false;
  bool get isSending => _isSending;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  int? _conversationId;
  int? get conversationId => _conversationId;

  final List<XFile> _chatImages = [];
  List<XFile> get chatImages => _chatImages;

  String? _currentPusherChannel;
  Timer? _pollingTimer;

  @override
  void onClose() {
    stopPolling();
    closePusher();
    super.onClose();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_conversationId != null && !_isSending) {
        getMessages(1, convId: _conversationId, isFirstLoad: false);
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void initPusher(int convId) {
    final String channelName = 'conversation.$convId';
    final String privateChannel = 'private-conversation.$convId';
    if (_currentPusherChannel == channelName) return;

    closePusher();
    _currentPusherChannel = channelName;

    try {
      if (!Get.isRegistered<PusherService>()) {
        Get.lazyPut(() => PusherService());
        Get.find<PusherService>().init();
      }
      final pusher = Get.find<PusherService>();

      void onNewMessage(dynamic data) {
        try {
          final decoded = data is String ? jsonDecode(data) : data;
          if (decoded != null && decoded['message'] != null) {
            final newMessage = Message.fromJson(
              Map<String, dynamic>.from(decoded['message'] as Map),
            );
            if (_messageModel != null) {
              _messageModel!.messages ??= [];
              final bool exists = _messageModel!.messages!.any((m) => m.id == newMessage.id);
              if (!exists) {
                _messageModel!.messages!.insert(0, newMessage);
                _messageModel!.totalSize = (_messageModel!.totalSize ?? 0) + 1;
                update();
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('[CHAT_PUSHER] Error parsing incoming message: $e');
          }
        }
      }

      // Bind all channel variations and event name formats for guaranteed real-time delivery
      for (final ch in [channelName, privateChannel]) {
        for (final ev in ['NewMessageSent', '.NewMessageSent', 'App\\Events\\Conversation\\NewMessageSent']) {
          pusher.subscribe(ch, eventName: ev, onEvent: onNewMessage);
          pusher.subscribePrivate(ch, eventName: ev, onEvent: onNewMessage);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CHAT_PUSHER] Failed to initialize pusher listener: $e');
      }
    }
  }

  void closePusher() {
    if (_currentPusherChannel != null) {
      try {
        final pusher = Get.find<PusherService>();
        pusher.unsubscribe('private-$_currentPusherChannel');
        pusher.unsubscribe(_currentPusherChannel!);
      } catch (_) {}
      _currentPusherChannel = null;
    }
  }

  Future<void> getMessages(int offset, {int? convId, bool isFirstLoad = true}) async {
    if (isFirstLoad) {
      _isLoading = true;
      update();
    }

    _conversationId = convId ?? _conversationId;

    try {
      MessageModel? model = await chatRepository.getMessages(offset, _conversationId);
      if (model != null) {
        if (offset == 1) {
          final existingLen = _messageModel?.messages?.length ?? 0;
          final newLen = model.messages?.length ?? 0;
          final existingFirstId = (_messageModel?.messages?.isNotEmpty == true) ? _messageModel!.messages!.first.id : null;
          final newFirstId = (model.messages?.isNotEmpty == true) ? model.messages!.first.id : null;

          _messageModel = model;

          // Only trigger UI update if it is first load or data changed
          if (isFirstLoad || existingLen != newLen || existingFirstId != newFirstId) {
            update();
          }
        } else {
          _messageModel?.messages?.addAll(model.messages ?? []);
          _messageModel?.offset = model.offset;
          update();
        }

        if (model.conversation?.id != null) {
          _conversationId = model.conversation!.id;
          initPusher(_conversationId!);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CHAT_CONTROLLER] getMessages error: $e');
      }
    } finally {
      if (isFirstLoad) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<bool> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty && _chatImages.isEmpty) return false;

    _isSending = true;
    update();

    List<MultipartBody> multipartImages = [];
    for (var img in _chatImages) {
      multipartImages.add(MultipartBody('image[]', img));
    }

    try {
      Response response = await chatRepository.sendMessage(
        message: cleanText,
        files: multipartImages,
        conversationId: _conversationId,
        receiverType: 'admin',
      );

      if (response.statusCode == 200) {
        _chatImages.clear();

        final responseBody = response.body;
        if (responseBody is Map) {
          // If conversation was established in the response
          if (responseBody['conversation'] != null && responseBody['conversation'] is Map) {
            final convObj = Conversation.fromJson(
              Map<String, dynamic>.from(responseBody['conversation'] as Map),
            );
            _messageModel ??= MessageModel();
            _messageModel!.conversation = convObj;
            final newConvId = convObj.id;
            if (newConvId != null && _conversationId != newConvId) {
              _conversationId = newConvId;
              initPusher(_conversationId!);
            }
          }

          // Laravel ConversationController returns the updated list in 'messages'
          if (responseBody['messages'] != null && responseBody['messages'] is List) {
            final list = (responseBody['messages'] as List)
                .map((m) => Message.fromJson(Map<String, dynamic>.from(m as Map)))
                .toList();
            _messageModel ??= MessageModel();
            _messageModel!.messages = list;
          } else if (responseBody['message'] != null && responseBody['message'] is Map) {
            final sentMsg = Message.fromJson(Map<String, dynamic>.from(responseBody['message'] as Map));
            _messageModel?.messages ??= [];
            if (!_messageModel!.messages!.any((m) => m.id == sentMsg.id)) {
              _messageModel!.messages!.insert(0, sentMsg);
            }
          }
        }

        _isSending = false;
        update();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CHAT_CONTROLLER] sendMessage error: $e');
      }
    }

    _isSending = false;
    update();
    return false;
  }

  void pickImage(bool isCamera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) {
      _chatImages.add(file);
      update();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _chatImages.length) {
      _chatImages.removeAt(index);
      update();
    }
  }
}
