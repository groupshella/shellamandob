import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/review/domain/services/review_service_interface.dart';

class ReviewController extends GetxController implements GetxService {
  final ReviewServiceInterface reviewServiceInterface;
  ReviewController({required this.reviewServiceInterface});

  List<ReviewModel>? _storeReviewList;
  List<ReviewModel>? get storeReviewList => _storeReviewList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  List<int> _ratingList = [];
  List<int> get ratingList => _ratingList;

  List<String> _reviewList = [];
  List<String> get reviewList => _reviewList;

  List<bool> _loadingList = [];
  List<bool> get loadingList => _loadingList;

  List<bool> _submitList = [];
  List<bool> get submitList => _submitList;

  int _deliveryManRating = 0;
  int get deliveryManRating => _deliveryManRating;

  int _storeRating = 0;
  int get storeRating => _storeRating;

  String _storeReview = '';
  String get storeReview => _storeReview;

  bool _isStoreSubmitted = false;
  bool get isStoreSubmitted => _isStoreSubmitted;

  bool _isStoreLoading = false;
  bool get isStoreLoading => _isStoreLoading;

  Future<void> getStoreReviewList(String? storeID) async {
    _hasError = false;
    _storeReviewList = null;
    try {
      final List<ReviewModel>? storeReviewList =
          await reviewServiceInterface.getStoreReviewList(storeID);
      if (storeReviewList != null) {
        _storeReviewList = [];
        _storeReviewList!.addAll(storeReviewList);
      } else {
        _hasError = true;
      }
    } catch (_) {
      _hasError = true;
      _storeReviewList = <ReviewModel>[];
    }
    update();
  }

  void initRatingData(
    List<OrderDetailsModel> orderDetailsList, {
    int? initialStoreRating,
    String? initialStoreComment,
    bool initialStoreSubmitted = false,
  }) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    _storeRating = initialStoreRating ?? 0;
    _storeReview = initialStoreComment ?? '';
    _isStoreSubmitted = initialStoreSubmitted || (_storeRating > 0);
    _isStoreLoading = false;

    for (final orderDetails in orderDetailsList) {
      final bool alreadyReviewed = (orderDetails.isReviewed == 1 ||
          (orderDetails.reviewRating != null &&
              orderDetails.reviewRating! > 0));
      _ratingList.add(alreadyReviewed ? (orderDetails.reviewRating ?? 5) : 0);
      _reviewList.add(orderDetails.reviewComment ?? '');
      _loadingList.add(false);
      _submitList.add(alreadyReviewed);
      if (kDebugMode) {
        debugPrint(orderDetails.toString());
      }
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    update();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  void setStoreRating(int rate) {
    _storeRating = rate;
    update();
  }

  void setStoreReview(String review) {
    _storeReview = review;
  }

  Future<ResponseModel> submitReview(
      int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    update();
    final ResponseModel responseModel =
        await reviewServiceInterface.submitReview(reviewBody);
    if (responseModel.isSuccess) {
      _submitList[index] = true;
      update();
    }
    _loadingList[index] = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(
      ReviewBodyModel reviewBody) async {
    _isLoading = true;
    update();
    final ResponseModel responseModel =
        await reviewServiceInterface.submitDeliveryManReview(reviewBody);
    if (responseModel.isSuccess) {
      _deliveryManRating = 0;
      update();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitStoreReview(ReviewBodyModel reviewBody) async {
    _isStoreLoading = true;
    update();
    final ResponseModel responseModel =
        await reviewServiceInterface.submitStoreReview(reviewBody);
    if (responseModel.isSuccess) {
      _isStoreSubmitted = true;
      update();
    }
    _isStoreLoading = false;
    update();
    return responseModel;
  }
}
