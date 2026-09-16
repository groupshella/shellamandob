import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

class MarketerHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final bool showBackButton;

  const MarketerHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.trailing,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBackPressed ?? () => Get.back(),
              icon: const Icon(
                IconlyLight.arrowRight2,
                size: 22,
                color: Color(0xFF111B18),
              ),
              splashRadius: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            const SizedBox(width: 32),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111B18),
                height: 1.3,
              ),
            ),
          ),
          trailing ?? const SizedBox(width: 32),
        ],
      ),
    );
  }
}
