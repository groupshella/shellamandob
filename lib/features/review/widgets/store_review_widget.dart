import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class StoreReviewWidget extends StatefulWidget {
  final Store? store;
  final String orderID;

  const StoreReviewWidget({
    super.key,
    required this.store,
    required this.orderID,
  });

  @override
  State<StoreReviewWidget> createState() => _StoreReviewWidgetState();
}

class _StoreReviewWidgetState extends State<StoreReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  static const Color _ink = Color(0xFF121C19);
  static const Color _muted = Color(0xFF8A8A8A);
  static const Color _border = Color(0xFFEDEFF1);
  static const Color _green = Color(0xFF1FA64A);
  static const Color _gold = Color(0xFFF59E0B);
  static const Color _inputBg = Color(0xFFF7F8FA);

  @override
  void initState() {
    super.initState();
    final reviewController = Get.find<ReviewController>();
    if (reviewController.storeReview.isNotEmpty) {
      _controller.text = reviewController.storeReview;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return Get.locale?.languageCode == 'ar'
            ? 'ممتاز جداً ⭐⭐⭐⭐⭐'
            : 'Excellent ⭐⭐⭐⭐⭐';
      case 4:
        return Get.locale?.languageCode == 'ar'
            ? 'جيد جداً 👍'
            : 'Very Good 👍';
      case 3:
        return Get.locale?.languageCode == 'ar' ? 'جيد 👌' : 'Good 👌';
      case 2:
        return Get.locale?.languageCode == 'ar'
            ? 'مقبول / يحتاج تحسين'
            : 'Fair / Needs Improvement';
      case 1:
        return Get.locale?.languageCode == 'ar'
            ? 'تجربة سيئة 👎'
            : 'Poor Experience 👎';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(
      builder: (reviewController) {
        final int currentRating = reviewController.storeRating;
        final bool isSubmitted = reviewController.isStoreSubmitted;
        final bool isLoading = reviewController.isStoreLoading;
        final String logoUrl = widget.store?.logoFullUrl ?? '';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Header
                if (widget.store != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: CustomImage(
                            image: logoUrl,
                            fit: BoxFit.cover,
                            height: 58,
                            width: 58,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.store?.name ?? '',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                Get.locale?.languageCode == 'ar'
                                    ? 'المتجر / المطعم'
                                    : 'Store / Restaurant',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: _green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: _border, height: 1),
                  const SizedBox(height: 16),
                ],

                if (isSubmitted) ...[
                  // Submitted Rating Stars Display
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (starIndex) {
                        final isSelected = currentRating >= (starIndex + 1);
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 36,
                            color: isSelected
                                ? _gold
                                : const Color(0xFFCBD5E1),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (currentRating > 0) ...[
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        _getRatingText(currentRating),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],

                  if (_controller.text.isNotEmpty ||
                      reviewController.storeReview.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Text(
                        _controller.text.isNotEmpty
                            ? _controller.text
                            : reviewController.storeReview,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          color: _ink,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Success badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: _green.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: _green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? 'تم إرسال تقييمك للمطعم بنجاح'
                              : 'Store review submitted successfully',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Rating prompt
                  Center(
                    child: Text(
                      Get.locale?.languageCode == 'ar'
                          ? 'قيّم تجربة المطعم وجودة الخدمة'
                          : 'Rate your experience with the store',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _ink,
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
                            reviewController.setStoreRating(starIndex + 1);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 38,
                              color:
                                  isSelected ? _gold : const Color(0xFFCBD5E1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  if (currentRating > 0) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: _gold.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          _getRatingText(currentRating),
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Text(
                    'share_your_opinion'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Text Input
                  Container(
                    decoration: BoxDecoration(
                      color: _inputBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: _ink,
                      ),
                      decoration: InputDecoration(
                        hintText: Get.locale?.languageCode == 'ar'
                            ? 'أخبرنا برأيك في جودة الطعام، سرعة التحضير، التغليف، وتجربة المطعم ككل...'
                            : 'write_your_review_here'.tr,
                        hintStyle: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(_green),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
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
                              final FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              final ReviewBodyModel reviewBody =
                                  ReviewBodyModel(
                                storeId: widget.store?.id?.toString() ?? '',
                                rating: currentRating.toString(),
                                comment: _controller.text.trim(),
                                orderId: widget.orderID,
                              );
                              reviewController
                                  .submitStoreReview(reviewBody)
                                  .then((value) {
                                if (value.isSuccess) {
                                  showCustomSnackBar(value.message,
                                      isError: false);
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
                                  Get.locale?.languageCode == 'ar'
                                      ? 'إرسال تقييم المطعم'
                                      : 'Submit Store Review',
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
