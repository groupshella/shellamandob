import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/backend_message_translator.dart';
import 'package:sixam_mart/util/styles.dart';

/// Styled bottom success snackbar (light-green pill + check badge + green text).
/// Ported with the old checkout wallet sheets — a non-blocking confirmation for
/// actions like selecting a payment method.
void showSelectionSnackBar(String message) {
  if (message.isEmpty) return;
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }
  Get.showSnackbar(GetSnackBar(
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFEAF8EE),
    borderRadius: 8,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.all(8),
    duration: const Duration(seconds: 2),
    messageText: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified, color: Color(0xFF2FA84F), size: 22),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: tajawalBold.copyWith(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xFF2FA84F),
            ),
          ),
        ),
      ],
    ),
  ));
}

void showCustomSnackBar(String? message,
    {bool isError = true, bool getXSnackBar = false, int? showDuration}) {
  if (message != null && message.isNotEmpty) {
    final String normalizedMessage = _normalizePotentialMojibake(message);

    // Translate backend messages
    final String translatedMessage =
        BackendMessageTranslator.translate(normalizedMessage);

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    final Color bgColor = isError ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final IconData iconData = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: Duration(seconds: showDuration ?? (isError ? 3 : 2)),
        animationDuration: const Duration(milliseconds: 300),
        isDismissible: true,
        dismissDirection: DismissDirection.up,
        messageText: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(iconData, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  translatedMessage,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _normalizePotentialMojibake(String input) {
  // Common markers when UTF-8 Arabic text is decoded using latin1/win1252.
  final bool looksMojibake = input.contains('�') ||
      input.contains('�') ||
      input.contains('�') ||
      input.contains('�') ||
      input.contains('�') ||
      input.contains('ï»¿');
  if (!looksMojibake) {
    return input;
  }

  try {
    String candidate = input;
    for (int i = 0; i < 2; i++) {
      final List<int> bytes = latin1.encode(candidate);
      final String decoded = utf8.decode(bytes, allowMalformed: false);

      final bool decodedStillBroken = decoded.contains('�') ||
          decoded.contains('�') ||
          decoded.contains('�') ||
          decoded.contains('�') ||
          decoded.contains('�') ||
          decoded.contains('ï»¿');

      if (decoded.isNotEmpty && !decodedStillBroken) {
        return decoded;
      }
      candidate = decoded;
    }
  } catch (e) {
    if (kDebugMode) debugPrint('$e');
  }

  return input;
}
