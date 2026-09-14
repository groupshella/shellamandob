import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/util/styles.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;

  const DeliveryManReviewWidget({
    super.key,
    required this.deliveryMan,
    required this.orderID,
  });

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return Get.locale?.languageCode == 'ar' ? 'ممتاز ⭐⭐⭐⭐⭐' : 'Excellent ⭐⭐⭐⭐⭐';
      case 4:
        return Get.locale?.languageCode == 'ar' ? 'جيد جداً 👍' : 'Very Good 👍';
      case 3:
        return Get.locale?.languageCode == 'ar' ? 'جيد 👌' : 'Good 👌';
      case 2:
        return Get.locale?.languageCode == 'ar' ? 'مقبول 😐' : 'Fair 😐';
      case 1:
        return Get.locale?.languageCode == 'ar' ? 'سيء 👎' : 'Poor 👎';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color primaryColor = Theme.of(context).primaryColor;
    const Color starColor = Color(0xFFFFB800);

    return GetBuilder<ReviewController>(
      builder: (reviewController) {
        final currentRating = reviewController.deliveryManRating;
        final isLoading = reviewController.isLoading;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Man Profile Header
                    if (widget.deliveryMan != null) ...[
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: CustomImage(
                                image: '${widget.deliveryMan!.imageFullUrl}',
                                fit: BoxFit.cover,
                                height: 64,
                                width: 64,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.deliveryMan!.fName ?? ''} ${widget.deliveryMan!.lName ?? ''}'.trim(),
                                  style: robotoBold.copyWith(
                                    fontSize: 16,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.delivery_dining_rounded, size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'delivery_man'.tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Divider(color: borderColor, height: 1),
                      const SizedBox(height: 18),
                    ],

                    // Rating Title
                    Center(
                      child: Text(
                        'rate_his_service'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Interactive Star Rating Bar
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          final isSelected = currentRating >= (starIndex + 1);
                          return InkWell(
                            onTap: () {
                              reviewController.setDeliveryManRating(starIndex + 1);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 38,
                                color: isSelected ? starColor : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    if (currentRating > 0) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: starColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getRatingText(currentRating),
                            style: robotoBold.copyWith(
                              fontSize: 12,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    Text(
                      'share_your_opinion'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Text Input
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: 4,
                        style: robotoRegular.copyWith(
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'write_your_review_here'.tr,
                          hintStyle: robotoRegular.copyWith(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                if (currentRating == 0) {
                                  showCustomSnackBar('give_a_rating'.tr);
                                  return;
                                }
                                final FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                final ReviewBodyModel reviewBody = ReviewBodyModel(
                                  deliveryManId: widget.deliveryMan?.id?.toString() ?? '',
                                  rating: currentRating.toString(),
                                  comment: _controller.text,
                                  orderId: widget.orderID,
                                );
                                reviewController.submitDeliveryManReview(reviewBody).then((value) {
                                  if (value.isSuccess) {
                                    showCustomSnackBar(value.message, isError: false);
                                    _controller.clear();
                                  } else {
                                    showCustomSnackBar(value.message);
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'submit'.tr,
                                    style: robotoBold.copyWith(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}