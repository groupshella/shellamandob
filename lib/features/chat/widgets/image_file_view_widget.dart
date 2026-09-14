import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_model.dart';
import 'package:sixam_mart/features/chat/widgets/image_preview_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/styles.dart';

class ImageFileViewWidget extends StatefulWidget {
  final Message currentMessage;
  final bool isRightMessage;
  const ImageFileViewWidget({super.key, required this.currentMessage, required this.isRightMessage});

  @override
  State<ImageFileViewWidget> createState() => _ImageFileViewWidgetState();
}

class _ImageFileViewWidgetState extends State<ImageFileViewWidget> {

  @override
  Widget build(BuildContext context) {
    final files = widget.currentMessage.fileFullUrl ?? [];
    if (files.isEmpty) return const SizedBox();

    if (files.length == 1) {
      return InkWell(
        onTap: () {
          if (ResponsiveHelper.isDesktop(context)) {
            Get.dialog(
              Dialog(
                insetPadding: EdgeInsets.zero,
                child: ImagePreviewWidget(
                    currentMessage: widget.currentMessage, currentIndex: 0),
              ),
            );
          } else {
            Get.to(() => ImagePreviewWidget(
                currentMessage: widget.currentMessage, currentIndex: 0));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 220,
              maxWidth: 260,
            ),
            child: CustomImage(
              image: files[0],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length > 4 ? 4 : files.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final bool isLastFourth = (index == 3 && files.length > 4);

        return InkWell(
          onTap: () {
            if (ResponsiveHelper.isDesktop(context)) {
              Get.dialog(
                Dialog(
                  insetPadding: EdgeInsets.zero,
                  child: ImagePreviewWidget(
                      currentMessage: widget.currentMessage,
                      currentIndex: index),
                ),
              );
            } else {
              Get.to(() => ImagePreviewWidget(
                  currentMessage: widget.currentMessage, currentIndex: index));
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImage(
                  image: files[index],
                  fit: BoxFit.cover,
                ),
              ),
              if (isLastFourth)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+${files.length - 3}',
                    style: robotoBold.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
