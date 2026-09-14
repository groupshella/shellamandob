import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/api/api_client.dart';

class PusherService extends GetxService {
  static PusherService get to => Get.find<PusherService>();

  late PusherChannelsClient pusher;
  String? socketId;
  final Map<String, Channel> _channels = {};
  bool _isInitialized = false;

  Future<PusherService> init() async {
    if (_isInitialized) return this;

    final host = AppConstants.pusherHost;
    final scheme = AppConstants.pusherScheme;
    final port = AppConstants.pusherPort;
    final key = AppConstants.pusherKey;

    if (kDebugMode) {
      print('[PUSHER] Initializing with host=$host, port=$port, scheme=$scheme, key=$key');
    }

    final options = PusherChannelsOptions.fromHost(
      host: host,
      scheme: scheme,
      port: port,
      key: key,
    );

    pusher = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        if (kDebugMode) print('[PUSHER] Connection Error: $exception');
        refresh();
      },
    );

    pusher.onConnectionEstablished.listen((_) {
      socketId = pusher.socketId;
      if (kDebugMode) {
        print('[PUSHER] Connection Established. socketId=$socketId');
      }
      _channels.clear();
    });

    pusher.connect();
    _isInitialized = true;
    return this;
  }

  /// Subscribe to a public channel
  void subscribe(
    String channelName, {
    String? eventName,
    Function(dynamic)? onEvent,
  }) {
    try {
      Channel channel;
      if (_channels.containsKey(channelName)) {
        channel = _channels[channelName]!;
      } else {
        channel = pusher.publicChannel(channelName);
        channel.subscribe();
        _channels[channelName] = channel;
      }

      if (eventName != null && onEvent != null) {
        channel.bind(eventName).listen((event) {
          if (kDebugMode) {
            print('[PUSHER] Public Event [$eventName] on [$channelName]');
          }
          onEvent(event.data);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PUSHER] subscribe error on $channelName: $e');
      }
    }
  }

  /// Subscribe to a private channel with endpoint authorization and bind an event
  void subscribePrivate(
    String channelName, {
    String? eventName,
    required void Function(dynamic data) onEvent,
  }) {
    try {
      final token = Get.find<ApiClient>().token;
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('[PUSHER] subscribePrivate aborted: No valid auth token available for $channelName');
        }
        return;
      }

      Channel channel;
      if (_channels.containsKey(channelName)) {
        channel = _channels[channelName]!;
      } else {
        channel = pusher.privateChannel(
          channelName,
          authorizationDelegate:
              EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint:
                Uri.parse('${AppConstants.baseUrl}/api/broadcasting/auth'),
            headers: {
              'Authorization': 'Bearer $token',
              'vendorType': 'customer',
              'Accept': 'application/json',
            },
          ),
        );
        channel.subscribe();
        _channels[channelName] = channel;
        if (kDebugMode) {
          print('[PUSHER] Subscribed to private channel: $channelName');
        }
      }

      if (eventName != null) {
        channel.bind(eventName).listen((event) {
          if (kDebugMode) {
            print('[PUSHER] Event [$eventName] on [$channelName]');
          }
          onEvent(event.data);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PUSHER] subscribePrivate error on $channelName: $e');
      }
    }
  }

  /// Subscribe to a presence channel and track members
  void subscribePresence(
    String channelName, {
    Function(dynamic)? onMemberAdded,
    Function(dynamic)? onMemberRemoved,
    Function(dynamic)? onSubscriptionSucceeded,
  }) {
    try {
      final token = Get.find<ApiClient>().token;
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('[PUSHER] subscribePresence aborted: No valid auth token available for $channelName');
        }
        return;
      }

      Channel channel;
      if (_channels.containsKey(channelName)) {
        channel = _channels[channelName]!;
      } else {
        channel = pusher.presenceChannel(
          channelName,
          authorizationDelegate:
              EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
            authorizationEndpoint:
                Uri.parse('${AppConstants.baseUrl}/api/broadcasting/auth'),
            headers: {
              'Authorization': 'Bearer $token',
              'vendorType': 'customer',
              'Accept': 'application/json',
            },
          ),
        );
        channel.subscribe();
        _channels[channelName] = channel;
        if (kDebugMode) {
          print('[PUSHER] Subscribed to presence channel: $channelName');
        }
      }

      if (onSubscriptionSucceeded != null) {
        channel.bind('pusher:subscription_succeeded').listen((event) {
          if (kDebugMode) {
            print('[PUSHER] Presence Succeeded on $channelName');
          }
          onSubscriptionSucceeded(event.data);
        });
      }
      if (onMemberAdded != null) {
        channel.bind('pusher:member_added').listen((event) {
          if (kDebugMode) {
            print('[PUSHER] Member Added on $channelName');
          }
          onMemberAdded(event.data);
        });
      }
      if (onMemberRemoved != null) {
        channel.bind('pusher:member_removed').listen((event) {
          if (kDebugMode) {
            print('[PUSHER] Member Removed on $channelName');
          }
          onMemberRemoved(event.data);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PUSHER] subscribePresence error on $channelName: $e');
      }
    }
  }

  /// Trigger a client event on a private channel
  void triggerEvent(String channelName, String eventName, Map<String, dynamic> data) {
    try {
      if (_channels.containsKey(channelName)) {
        final channel = _channels[channelName]!;
        try {
          (channel as dynamic).trigger(eventName: eventName, data: data);
          if (kDebugMode) {
            print('[PUSHER] Triggered [$eventName] on [$channelName]');
          }
        } catch (innerError) {
          if (kDebugMode) {
            print('[PUSHER] Inner trigger error on $channelName: $innerError');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PUSHER] triggerEvent error on $channelName: $e');
      }
    }
  }

  /// Unsubscribe from a channel and release listener
  void unsubscribe(String channelName) {
    try {
      if (_channels.containsKey(channelName)) {
        _channels[channelName]?.unsubscribe();
        _channels.remove(channelName);
        if (kDebugMode) {
          print('[PUSHER] Unsubscribed from: $channelName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PUSHER] unsubscribe error on $channelName: $e');
      }
    }
  }

  String? getSocketId() => socketId;
}