import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/pos/domain/models/pos_checkout_model.dart';
import 'package:sixam_mart/features/pos/domain/repositories/pos_checkout_repository.dart';
import 'package:sixam_mart/features/pos/helper/pos_checkout_token_storage.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class PosCheckoutController extends GetxController implements GetxService {
  final PosCheckoutRepository repository;
  final SharedPreferences sharedPreferences;

  PosCheckoutController({required this.repository, required this.sharedPreferences});

  bool _isLoading = false;
  bool _isPaying = false;
  String? _errorMessage;
  PosCheckoutOrderModel? _order;
  String _selectedPaymentMethod = 'digital_payment'; // 'digital_payment', 'wallet'
  int? _selectedPaymentMethodId;
  bool _isExpired = false;
  bool _isClaimedByOther = false;

  bool get isLoading => _isLoading;
  bool get isPaying => _isPaying;
  String? get errorMessage => _errorMessage;
  PosCheckoutOrderModel? get order => _order;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  int? get selectedPaymentMethodId => _selectedPaymentMethodId;
  bool get isExpired => _isExpired;
  bool get isClaimedByOther => _isClaimedByOther;

  void setSelectedPaymentMethod(String method, {int? methodId}) {
    _selectedPaymentMethod = method;
    _selectedPaymentMethodId = methodId;
    update();
  }

  /// Resolve and claim POS Checkout Order
  Future<void> resolveAndClaim(String token) async {
    final String activeToken = token.trim().isNotEmpty
        ? token.trim()
        : (PosCheckoutTokenStorage(sharedPreferences).getToken() ?? '');

    _isLoading = true;
    _errorMessage = null;
    _isExpired = false;
    _isClaimedByOther = false;
    update();

    if (activeToken.isEmpty) {
      _isLoading = false;
      _errorMessage = 'رمز جلسة الدفع غير صالح أو غير موجود';
      update();
      return;
    }

    final storage = PosCheckoutTokenStorage(sharedPreferences);
    await storage.saveToken(activeToken);

    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if (!isLoggedIn) {
      _isLoading = false;
      update();
      return;
    }

    try {
      // 1. Resolve checkout order details
      Response resolveRes = await repository.resolveCheckout(activeToken);
      if (resolveRes.statusCode == 200 && resolveRes.body is Map && resolveRes.body['success'] == true) {
        _order = PosCheckoutOrderModel.fromJson(resolveRes.body['data']);
        
        // 2. Claim checkout session for logged-in user
        Response claimRes = await repository.claimCheckout(activeToken);
        if (claimRes.statusCode == 200 && claimRes.body is Map && claimRes.body['success'] == true) {
          _isClaimedByOther = false;
        } else if (claimRes.statusCode == 409) {
          _isClaimedByOther = true;
          _errorMessage = (claimRes.body is Map ? claimRes.body['message'] : null) ?? 'جلسة الدفع هذه قيد الاستخدام من قبل عميل آخر';
        }
      } else {
        _errorMessage = (resolveRes.body is Map ? resolveRes.body['message'] : null) ?? 'طلب الكاشير غير متاح أو منتهي';
        if (resolveRes.statusCode == 410 || (resolveRes.body is Map && resolveRes.body['reason'] == 'expired')) {
          _isExpired = true;
        }
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحميل تفاصيل الطلب';
      debugPrint('[POS_CHECKOUT_RESOLVE_ERROR] $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Initiate POS Payment (Wallet or Digital Payment / MyFatoorah)
  Future<void> initiatePayment(String token) async {
    if (_isPaying || _order == null) return;

    _isPaying = true;
    update();

    try {
      final Map<String, dynamic> payload = {
        'payment_method': _selectedPaymentMethod,
        if (_selectedPaymentMethodId != null) 'payment_method_id': _selectedPaymentMethodId,
      };

      Response response = await repository.initiatePayment(token, payload);

      if (response.statusCode == 200 && response.body is Map && response.body['success'] == true) {
        final data = response.body['data'];
        final storage = PosCheckoutTokenStorage(sharedPreferences);

        if (_selectedPaymentMethod == 'wallet') {
          // Wallet payment successful!
          await storage.clearToken();
          showCustomSnackBar('تم دفع الطلب بنجاح من رصيد المحفظة', isError: false);
          
          // Refresh user wallet balance
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().getUserInfo();
          }

          final String? userPhone = Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>().userInfoModel?.phone
              : null;
          Get.offAllNamed(RouteHelper.getOrderSuccessRoute(
              _order?.orderId ?? '0', userPhone));
        } else if (data != null && data['payment_url'] != null) {
          // Digital payment redirect (MyFatoorah / Apple Pay / Mada)
          // payment_url verified
          Get.toNamed(RouteHelper.getPaymentRoute(
            _order?.orderId ?? '0',
            Get.find<ProfileController>().userInfoModel?.id ?? 0,
            'pos',
            _order?.orderAmount ?? 0.0,
            false,
            _selectedPaymentMethod,
            guestId: '',
          ));
        }
      } else {
        String msg = (response.body is Map ? response.body['message'] : null) ?? 'فشلت عملية إتمام الدفع';
        showCustomSnackBar(msg);
      }
    } catch (e) {
      showCustomSnackBar('حدث خطأ غير متوقع أثناء معالجة الدفع');
      debugPrint('[POS_PAYMENT_ERROR] $e');
    } finally {
      _isPaying = false;
      update();
    }
  }
}

