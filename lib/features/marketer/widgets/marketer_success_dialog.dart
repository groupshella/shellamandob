import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketerSuccessDialog extends StatelessWidget {
  final VoidCallback? onClose;

  const MarketerSuccessDialog({super.key, this.onClose});

  static Future<void> show(BuildContext context, {VoidCallback? onClose}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MarketerSuccessDialog(onClose: onClose),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2028) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: GestureDetector(
              onTap: () {
                Get.back();
                onClose?.call();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252B37) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Glowing checkmark with outer rings
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF1E3A24) : const Color(0xFFEBFEEB)).withValues(alpha: 0.6),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 105,
                height: 105,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF48B352),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3330913F),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'application_sent_success'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111B18),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'we_will_contact_you_soon'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF2D3633),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                onClose?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30913F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'track_application_status'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
