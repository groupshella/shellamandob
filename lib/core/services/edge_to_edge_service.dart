import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service to handle edge-to-edge display for Android 15+ compatibility
class EdgeToEdgeService {
  static const MethodChannel _channel = MethodChannel('edge_to_edge');

  /// Initialize edge-to-edge support
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('enableEdgeToEdge');
    } catch (e) {
      debugPrint('Failed to enable edge-to-edge: $e');
    }
  }

  /// Set system UI overlay style for proper edge-to-edge display
  static void setSystemUIOverlayStyle({
    bool? isDark,
    SystemUiOverlayStyle? statusBarStyle,
    SystemUiOverlayStyle? navigationBarStyle,
  }) {
    final bool dark = isDark ?? false;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarStyle?.statusBarIconBrightness ??
            (dark ? Brightness.light : Brightness.dark),
        statusBarBrightness: statusBarStyle?.statusBarBrightness ??
            (dark ? Brightness.dark : Brightness.light),
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            navigationBarStyle?.systemNavigationBarIconBrightness ??
                (dark ? Brightness.light : Brightness.dark),
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  /// Handle safe area insets for edge-to-edge content
  static Widget wrapWithSafeArea({
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
