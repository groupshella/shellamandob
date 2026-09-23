import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  final String? img;
  final bool isNotificationCenter;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backButton = true,
    this.onBackPressed,
    this.showCart = false,
    this.leadingIcon,
    this.onVegFilterTap,
    this.type,
    this.img,
    this.isNotificationCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        backgroundColor: isNotificationCenter 
            ? const Color(0xFF31A342)
            : Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Stack(
          children: [
            // Status bar elements (only for notification center)
            if (isNotificationCenter)

            
            // Main title - positioned exactly as in Figma design
            Positioned(
              left: 0,
              right: 0,
              bottom: isNotificationCenter ? 16 : 2,
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                        color: Colors.white,
                        fontSize: isNotificationCenter ? 18 : null,
                        fontWeight: isNotificationCenter ? FontWeight.bold : null,

                      ),
                ),
              ),
            ),
            
            // Close button for notification center - positioned exactly as in Figma design
            if (backButton && isNotificationCenter)
              PositionedDirectional(
                bottom: 8,
                start: 12,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
                ),
              ),
            
            // Back button for other screens
            if (backButton && !isNotificationCenter)
              PositionedDirectional(
                bottom: 10,
                start: 15,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
                ),
              ),
            
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
