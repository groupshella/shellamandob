// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'package:sixam_mart/common/performance/page_tracker.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:sixam_mart/features/auth/screens/succsessflyCreated.dart';
import 'package:sixam_mart/features/location/screens/my_Location.dart';
import 'package:sixam_mart/features/location/screens/select_location_screen.dart';
import 'package:sixam_mart/features/address/screens/address_details_screen.dart';
import 'package:sixam_mart/features/address/screens/delivery_addresses_screen.dart';
import 'package:sixam_mart/features/address/domain/models/check_zone_model.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/employee/screens/employee_main_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/address/screens/add_address_screen.dart';
import 'package:sixam_mart/features/address/screens/address_screen.dart';
import 'package:sixam_mart/features/auth/screens/delivery_man_registration_screen.dart';
// ignore: unused_import
import 'package:sixam_mart/features/auth/screens/sign_in_screen.dart';
import 'package:sixam_mart/features/auth/screens/welcome_screen.dart';
import 'package:sixam_mart/features/auth/screens/phone_login_screen.dart';
import 'package:sixam_mart/features/auth/screens/otp_verification_screen.dart';
import 'package:sixam_mart/features/auth/screens/create_account_screen.dart';
import 'package:sixam_mart/features/auth/screens/sign_up_screen.dart';
import 'package:sixam_mart/features/auth/screens/store_registration_screen.dart';
import 'package:sixam_mart/features/location/screens/map_screen.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/html_type.dart';
import 'package:sixam_mart/common/widgets/image_viewer_screen.dart';
import 'package:sixam_mart/common/widgets/not_found.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/verification/screens/forget_pass_screen.dart';
import 'package:sixam_mart/features/verification/screens/new_pass_screen.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/features/language/screens/language_screen.dart';
// 🔥 SIMPLIFIED FLOW: AccessLocationScreen removed - using PickMapScreen directly
// AccessLocationScreen is now just a redirect, no longer used in routes
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/screens/notification_screen.dart';
import 'package:sixam_mart/features/profile/screens/profile_screen.dart';
import 'package:sixam_mart/features/profile/screens/update_profile_screen.dart';
import 'package:sixam_mart/features/splash/screens/splash_screen.dart';
import 'package:sixam_mart/features/update/screens/update_screen.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../features/employee/attendance/screens/select_work_zone_screen.dart';
import '../features/employee/attendance/screens/attendance_stepper_screen.dart';
import '../features/employee/visits/screens/daily_visits_screen.dart';
import '../features/employee/reports/screens/daily_performance_summary_screen.dart';
import '../features/employee/requests/screens/employee_requests_screen.dart';
import '../features/employee/screens/employee_settings_screen.dart';
import '../features/employee/screens/employee_profile_screen.dart';

class RouteHelper {
  static const String posCheckout = '/pos-checkout';
  static String getPosCheckoutRoute(String token) => '$posCheckout?token=$token';

  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onBoarding = '/on-boarding';
  static const String welcome = '/welcome';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String createAccount = '/create-account';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String verification = '/verification';
  static const String loginOtp = 'login-otp';
  static const String accessLocation = '/access-location';
  static const String pickMap = '/pick-map';
  static const String my_Location = '/my_Location';
  static const String selectLocation = '/select-location';
  static const String addressDetails = '/address-details';
  static const String deliveryAddresses = '/delivery-addresses';

  static const String interest = '/interest';
  static const String main = '/main';
  static const String moduleHome = '/module/:moduleId';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String search = '/search';
  static const String store = '/store';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String coupon = '/coupon';
  static const String notification = '/notification';
  static const String map = '/map';
  static const String address = '/address';
  static const String orderSuccess = '/order-successful';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String orderTracking = '/track-order';
  static const String basicCampaign = '/basic-campaign';
  static const String html = '/html-page';
  static const String categories = '/categories';
  static const String categoryItem = '/category-item';
  static const String popularItems = '/popular-items';
  static const String itemCampaign = '/item-campaign';
  static const String support = '/help-and-support';
  static const String contactUs = '/contact-us';
  static const String rateReview = '/rate-and-review';
  static const String offersItemScreen = '/offers-item-screen';
  static const String update = '/update';
  static const String cart = '/cart';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String storeReview = '/store-review';
  static const String allStores = '/stores';
  static const String itemImages = '/item-images';
  static const String parcelCategory = '/parcel-category';
  static const String parcelLocation = '/parcel-location';
  static const String parcelRequest = '/parcel-request';
  static const String searchStoreItem = '/search-store-item';
  static const String order = '/order';
  static const String itemDetails = '/item-details';
  static const String wallet = '/wallet';

  static const String old_wallet = '/old_wallet';

  static const String sendFunds = '/send-funds';
  static const String chooseReceiver = '/choose-receiver';
  static const String transferSuccess = '/transfer-success';

  static const String walletTransactionDetail = '/wallet-transaction-detail';

  static const String loyalty = '/loyalty';
  static const String referAndEarn = '/refer-and-earn';
  static const String marketer = '/marketer';
  static const String employeeMain = '/employee-main';
  static String getEmployeeMainRoute() => employeeMain;
  static const String selectWorkZone = '/select-work-zone';
  static String getSelectWorkZoneRoute() => selectWorkZone;
  static const String attendanceStepper = '/attendance-stepper';
  static String getAttendanceStepperRoute() => attendanceStepper;
  static const String dailyVisits = '/daily-visits';
  static String getDailyVisitsRoute() => dailyVisits;
  static const String dailySummary = '/daily-performance-summary';
  static String getDailySummaryRoute() => dailySummary;
  static const String employeeRequests = '/employee-requests';
  static String getEmployeeRequestsRoute() => employeeRequests;
  static const String employeeSettings = '/employee-settings';
  static String getEmployeeSettingsRoute() => employeeSettings;
  static const String employeeProfile = '/employee-profile';
  static String getEmployeeProfileRoute() => employeeProfile;
  static const String messages = '/messages';
  static const String conversation = '/conversation';
  static const String chatSearch = '/chat-search';
  static const String newConversation = '/new-conversation';
  static const String archive = '/archive';
  static const String restaurantRegistration = '/store-registration';
  static const String deliveryManRegistration = '/delivery-man-registration';
  static const String refund = '/refund';

  static const String succsessflycreated = '/succsessflycreated';

  static const String offlinePaymentScreen = '/offline-payment-screen';
  static const String flashSaleDetailsScreen = '/flash-sale-details-screen';
  static const String guestTrackOrderScreen = '/guest-track-order-screen';
  static const String favourite = '/favourite';
  static const String brands = '/brands';
  static const String brandsItemScreen = '/brands-item-screen';

  static const String subscriptionSuccess = '/subscription-success';
  static const String subscriptionPayment = '/subscription-payment';
  static const String newUserSetupScreen = '/new-user-setup-screen';
  static const String statistics = '/statistics';

  static const String qr_screen = '/qr';

  static const String add_delegate_screen = '/add_delegate_screen';

  static const String discount = '/discount';

  static const String KiadaWalletSubscription = '/KiadaWallet_Subscription';
  static const String kaidhaWallet = '/kaidha-allet';

  static const String IsLoggedIn_Kiadha_Screen = '/isLoggedIn_kiadha_screen';

  static const String Contract_Review = '/contract_review_screen';
  static const String qidhaDiscoverStores = '/qidha-discover-stores';
  static const String firstOrderGift = '/first-order-gift';

  static String getFirstOrderGiftRoute({int? storeId}) =>
      '$firstOrderGift?store_id=${storeId ?? 0}';

  static String getInitialRoute(
      {bool fromSplash = false, bool skipSplash = false}) {
    // Build route string for fromSplash (backward compatibility)
    // skipSplash is passed via Get.arguments (type-safe) instead of URL parameters
    final route = '$initial?from-splash=$fromSplash';
    return route;
  }

  static String getSplashRoute(NotificationBodyModel? body) {
    String data = 'null';
    if (body != null) {
      final List<int> encoded = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encoded);
    }
    return '$splash?data=$data';
  }

  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getOnBoardingRoute() => onBoarding;
  static String getWelcomeRoute() => welcome;
  static String getPhoneLoginRoute() => phoneLogin;
  static String getOtpVerificationRoute() => otpVerification;
  static String getCreateAccountRoute() => createAccount;
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getSignUpRoute() => signUp;

  static String getVerificationRoute(String? number, String? email,
      String? token, String page, String? pass, String loginType,
      {String? session, UpdateUserModel? updateUserModel, String? nextPage}) {
    final List<String> params = ['page=$page'];

    // Add number only if not null and not empty
    if (number != null && number.isNotEmpty) {
      params.add('number=${Uri.encodeQueryComponent(number)}');
    }

    // Add email only if not null and not empty
    if (email != null && email.isNotEmpty) {
      params.add('email=${Uri.encodeQueryComponent(email)}');
    }

    // Add token only if not null and not empty
    if (token != null && token.isNotEmpty) {
      params.add('token=${Uri.encodeQueryComponent(token)}');
    }

    // Add pass only if not null and not empty
    if (pass != null && pass.isNotEmpty) {
      params.add('pass=${Uri.encodeQueryComponent(pass)}');
    }

    // Add login_type only if not empty
    if (loginType.isNotEmpty) {
      params.add('login_type=${Uri.encodeQueryComponent(loginType)}');
    }

    // Add session only if not null
    if (session != null && session.isNotEmpty) {
      final String authSession = base64Url.encode(utf8.encode(session));
      params.add('session=$authSession');
    }

    // Add user_model only if not null
    if (updateUserModel != null) {
      final List<int> encoded =
          utf8.encode(jsonEncode(updateUserModel.toJson()));
      final String userModel = base64Encode(encoded);
      params.add('user_model=$userModel');
    }

    // Add next page only if provided
    if (nextPage != null && nextPage.isNotEmpty) {
      params.add('next=${Uri.encodeQueryComponent(nextPage)}');
    }

    return '$verification?${params.join('&')}';
  }

  static String getLoginOtpRoute(String number, String loginType,
          {String? nextPage}) =>
      getVerificationRoute(number, null, null, loginOtp, null, loginType,
          nextPage: nextPage);

  static String getAccessLocationRoute(String page) =>
      '$accessLocation?page=$page';

  static String getPickMapRoute(String? page, bool canRoute) =>
      '$pickMap?page=$page&route=${canRoute.toString()}';

  static String getSelectLocationRoute({String? page}) =>
      '$selectLocation?page=${page ?? ''}';

  static String getAddressDetailsRoute() => addressDetails;

  static String getDeliveryAddressesRoute() => deliveryAddresses;

  static String getMy_LocationRoute(String? page, bool canRoute) =>
      '$my_Location?page=$page&route=${canRoute.toString()}';

  static String getInterestRoute() => interest;
  static String getMainRoute(String page) => '$main?page=$page';
  static String getModuleHomeRoute(int moduleId) => '/module/$moduleId';

  static String getForgotPassRoute() => forgotPassword;

  static String getResetPasswordRoute(
          String? phone, String token, String page) =>
      '$resetPassword?phone=${Uri.encodeQueryComponent(phone ?? '')}&token=${Uri.encodeQueryComponent(token)}&page=$page';

  static String getSearchRoute({String? queryText}) =>
      '$search?query=${Uri.encodeQueryComponent(queryText ?? '')}';

  static String getStoreRoute({
    required int? id,
    required String page,
    int? categoryId,
    int? itemId,
  }) {
    if (kDebugMode) {
      debugPrint(
          'RouteHelper.getStoreRoute called: id=$id, page=$page, categoryId=$categoryId, itemId=$itemId');
    }

    final StringBuffer route = StringBuffer('$store?id=$id&page=$page');
    if (categoryId != null && categoryId > 0) {
      route.write('&category_id=$categoryId');
    }
    if (itemId != null && itemId > 0) {
      route.write('&item_id=$itemId');
    }
    return route.toString();
  }

  static String getOrderDetailsRoute(int? orderID,
      {bool? fromNotification, bool? fromOffline, String? contactNumber}) {
    return '$orderDetails?id=$orderID&from=${fromNotification.toString()}&from_offline=$fromOffline&contact=${Uri.encodeQueryComponent(contactNumber ?? '')}';
  }

  static String getOrderDetailsRouteBypass(int? orderID,
      {bool? fromNotification, bool? fromOffline, String? contactNumber}) {
    return '$orderDetails?id=$orderID&from=${fromNotification.toString()}&from_offline=$fromOffline&contact=${Uri.encodeQueryComponent(contactNumber ?? '')}&bypass=true';
  }

  static String getProfileRoute() => profile;
  static String getUpdateProfileRoute() => updateProfile;
  static String getCouponRoute() => coupon;
  static String getNotificationRoute({bool? fromNotification}) =>
      '$notification?from=${fromNotification.toString()}';
  static String getMapRoute(AddressModel addressModel, String page, bool isFood,
      {String? storeName}) {
    final List<int> encoded = utf8.encode(jsonEncode(addressModel.toJson()));
    final String data = base64Encode(encoded);
    return '$map?address=$data&page=$page&module=$isFood&store-name=$storeName';
  }

  static String getAddressRoute() => address;
  static String getOrderSuccessRoute(String orderID, String? contactNumber,
      {bool? createAccount, String guestId = ''}) {
    return '$orderSuccess?id=$orderID&contact_number=${Uri.encodeQueryComponent(contactNumber ?? '')}&create_account=$createAccount&guest_id=${Uri.encodeQueryComponent(guestId)}';
  }

  static String getOffersItemScreen(int? offerId, String? offerName,
          {double? offerDiscount}) =>
      '$offersItemScreen?offerId=$offerId&offerName=${Uri.encodeQueryComponent(offerName ?? '')}&offerDiscount=${offerDiscount ?? ''}';
  static String getStatistics() => statistics;

  static String getQr_screen() => qr_screen;

  static String getAdd_DelegateScreen() => add_delegate_screen;

  static String getDiscount() => discount;
  static String getKiadaWalletSubscription() => KiadaWalletSubscription;
  static String getKaidhaWallet() => kaidhaWallet;

  static String get_isLoggedIn_Kiadha_Screen() => IsLoggedIn_Kiadha_Screen;

  static String getQidhaDiscoverStoresRoute() => qidhaDiscoverStores;

  static String getold_wallet() => old_wallet;

  static String getSendFundsRoute() => sendFunds;

  static String getChooseReceiverRoute() => chooseReceiver;

  static String getTransferSuccessRoute() => transferSuccess;

  static String getWalletTransactionDetailRoute() => walletTransactionDetail;

  static String getContract_ReviewRoute() => Contract_Review;

  static String getPaymentRoute(String id, int? user, String? type,
          double amount, bool? codDelivery, String? paymentMethod,
          {required String guestId,
          String? contactNumber,
          String? addFundUrl,
          String? subscriptionUrl,
          int? storeId,
          bool? createAccount,
          int? createUserId}) =>
      '$payment?id=$id&user=$user&type=$type&amount=$amount&cod-delivery=$codDelivery&add-fund-url=${Uri.encodeQueryComponent(addFundUrl ?? '')}&payment-method=${Uri.encodeQueryComponent(paymentMethod ?? '')}&guest-id=${Uri.encodeQueryComponent(guestId)}&number=${Uri.encodeQueryComponent(contactNumber ?? '')}&subscription-url=${Uri.encodeQueryComponent(subscriptionUrl ?? '')}&store_id=$storeId&create_account=$createAccount&create_user_id=$createUserId';

  /// Navigate to checkout screen
  ///
  /// ⚠️ DEPRECATED: Use navigateToCheckout() instead for cart checkout!
  /// This method only returns the route string and does NOT pass cartList.
  /// Using this for cart checkout causes duplicate calculations and bugs.
  ///
  /// Only use this for:
  /// - Prescription checkout (page='prescription')
  /// - Campaign checkout (page='campaign')
  @Deprecated(
      'For cart checkout, use RouteHelper.navigateToCheckout() instead. '
      'This method does not pass cartList and causes duplicate calculations.')
  static String getCheckoutRoute(String page, {int? storeId}) =>
      '$checkout?page=$page&store-id=$storeId';

  /// ✅ Non-deprecated helpers for non-cart checkout flows
  /// Use these for prescription/campaign flows where cartList is not required.
  static String getPrescriptionCheckoutRoute({required int storeId}) =>
      '$checkout?page=prescription&store-id=$storeId';

  static String getCampaignCheckoutRoute() =>
      '$checkout?page=campaign&store-id=null';

  /// ✅ ARCHITECTURAL FIX: Navigate to checkout with cartList passed via arguments
  /// This prevents duplicate cart loading and price calculations
  ///
  /// Usage:
  /// ```dart
  /// RouteHelper.navigateToCheckout(
  ///   cartList: cartController.cartList,
  ///   storeId: storeId,
  /// );
  /// ```
  static void navigateToCheckout({
    required List<dynamic> cartList,
    required int storeId,
  }) {
    final List<dynamic> checkoutCartSnapshot = List<dynamic>.from(cartList);
    debugPrint('🛒 RouteHelper.navigateToCheckout:');
    debugPrint('   - cartList length: ${checkoutCartSnapshot.length}');
    debugPrint('   - storeId: $storeId');

    // ✅ Pass cartList via arguments (type-safe, no URL encoding)
    Get.toNamed(
      '$checkout?page=cart&store-id=$storeId',
      arguments: {
        'cartList': checkoutCartSnapshot,
        'storeId': storeId,
        'fromCart': true,
      },
    );
  }

  static String getOrderTrackingRoute(int? id, String? contactNumber) =>
      '$orderTracking?id=$id&number=${Uri.encodeQueryComponent(contactNumber ?? '')}';
  static String getBasicCampaignRoute(BasicCampaignModel basicCampaignModel) {
    final String data =
        base64Encode(utf8.encode(jsonEncode(basicCampaignModel.toJson())));
    return '$basicCampaign?data=$data';
  }

  static String getHtmlRoute(String page) => '$html?page=$page';
  static String getCategoryRoute() => categories;
  static String getCategoryItemRoute(int? id, String name) {
    final List<int> encoded = utf8.encode(name);
    final String data = base64Encode(encoded);
    return '$categoryItem?id=$id&name=$data';
  }

  static String getPopularItemRoute(bool isPopular, bool isSpecial) =>
      '$popularItems?page=${isPopular ? 'popular' : 'reviewed'}&special=${isSpecial.toString()}';
  static String getItemCampaignRoute({bool isJustForYou = false}) =>
      itemCampaign +
      (isJustForYou ? '?just-for-you=${isJustForYou.toString()}' : '');
  static String getSupportRoute() => support;
  static String getContactUsRoute() => contactUs;
  static String getReviewRoute() => rateReview;
  static String getUpdateRoute(bool isUpdate) =>
      '$update?update=${isUpdate.toString()}';
  static String getCartRoute() => cart;
  static String getAddAddressRoute(
          bool fromCheckout, bool fromRide, int? zoneId,
          {bool isNavbar = false}) =>
      '$addAddress?page=${fromCheckout ? 'checkout' : 'address'}&ride=$fromRide&zone_id=$zoneId&navbar=$isNavbar';

  static String getEditAddressRoute(AddressModel? address,
      {bool fromGuest = false}) {
    String data = 'null';
    if (address != null) {
      data = base64Url.encode(utf8.encode(jsonEncode(address.toJson())));
    }
    return '$editAddress?data=$data&from-guest=$fromGuest';
  }

  static String getStoreReviewRoute(
      int? storeID, String? storeName, Store store) {
    final String data =
        base64Url.encode(utf8.encode(jsonEncode(store.toJson())));
    return '$storeReview?storeID=$storeID&storeName=${Uri.encodeQueryComponent(storeName ?? '')}&store=$data';
  }

  static String getAllStoreRoute(String page, {bool isNearbyStore = false}) =>
      '$allStores?page=$page${isNearbyStore ? '&nearby=${isNearbyStore.toString()}' : ''}';
  static String getItemImagesRoute(Item item) {
    final String data =
        base64Url.encode(utf8.encode(jsonEncode(item.toJson())));
    return '$itemImages?item=$data';
  }

  static String getParcelCategoryRoute() => parcelCategory;

  static String getSearchStoreItemRoute(int? storeID) =>
      '$searchStoreItem?id=$storeID';
  static String getOrderRoute() => order;
  static String getItemDetailsRoute(int? itemID, bool isRestaurant) =>
      '$itemDetails?id=$itemID&page=${isRestaurant ? 'restaurant' : 'item'}';

  static String getWalletRoute(
          {String? fundStatus, String? token, bool fromNotification = false}) =>
      '$wallet?payment_status=$fundStatus&token=$token&from_notification=$fromNotification';

  static String getold_walletRoute(
          {String? fundStatus, String? token, bool fromNotification = false}) =>
      '$old_wallet?payment_status=$fundStatus&token=$token&from_notification=$fromNotification';

  static String getLoyaltyRoute({bool fromNotification = false}) =>
      '$loyalty?from_notification=$fromNotification';
  static String getReferAndEarnRoute() => referAndEarn;
  static String getMarketerRoute() => marketer;
  static String getChatRoute(
      {required NotificationBodyModel? notificationBody,
      User? user,
      int? conversationID,
      int? index,
      bool? fromNotification,
      OrderChatModel? orderChatModel,
      bool isClosed = false}) {
    String notificationBody0 = 'null';
    if (notificationBody != null) {
      notificationBody0 =
          base64Encode(utf8.encode(jsonEncode(notificationBody.toJson())));
    }
    String user0 = 'null';
    if (user != null) {
      user0 = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    String orderChat = 'null';
    if (orderChatModel != null) {
      orderChat = base64Encode(utf8.encode(jsonEncode(orderChatModel.toJson())));
    }
    return '$messages?notification=$notificationBody0&user=$user0&conversation_id=$conversationID&index=$index&from=${fromNotification.toString()}&order-chat=$orderChat&isClosed=$isClosed';
  }

  static String getConversationRoute() => conversation;
  static String getNewConversationRoute() => newConversation;
  static String getArchiveRoute() => archive;
  static String getRestaurantRegistrationRoute() => restaurantRegistration;
  static String getDeliverymanRegistrationRoute() => deliveryManRegistration;
  static String getRefundRequestRoute(String orderID) => '$refund?id=$orderID';

  static String getOfflinePaymentScreen({
    required PlaceOrderBodyModel placeOrderBody,
    required int? zoneId,
    required double total,
    required double? maxCodOrderAmount,
    required bool fromCart,
    required bool? isCodActive,
    required bool forParcel,
  }) {
    final List<int> encoded = utf8.encode(jsonEncode(placeOrderBody.toJson()));
    final String data = base64Encode(encoded);
    return '$offlinePaymentScreen?order_body=$data&zone_id=$zoneId&total=$total&max_cod_amount=$maxCodOrderAmount&from_cart=$fromCart&cod_active=$isCodActive&for_parcel=$forParcel';
  }

  static String getFlashSaleDetailsScreen(int id) =>
      '$flashSaleDetailsScreen?id=$id';
  static String getGuestTrackOrderScreen(String orderId, String number) =>
      '$guestTrackOrderScreen?order_id=$orderId&number=${Uri.encodeQueryComponent(number)}';
  static String getFavouriteScreen() => favourite;
  static String getBrandsScreen() => brands;
  static String getBrandsItemScreen(int brandId, String brandName) =>
      '$brandsItemScreen?brandId=$brandId&brandName=${Uri.encodeQueryComponent(brandName)}';

  static String getSubscriptionSuccessRoute(
          {String? status, required bool fromSubscription, int? storeId}) =>
      '$subscriptionSuccess?flag=$status&from_subscription=$fromSubscription&store_id=$storeId';
  static String getSubscriptionPaymentRoute(
          {required int? storeId, required int? packageId}) =>
      '$subscriptionPayment?store-id=$storeId&package-id=$packageId';

  static String getNewUserSetupScreen(
      {required String name,
      required String loginType,
      required String? phone,
      required String? email}) {
    return '$newUserSetupScreen?name=${Uri.encodeQueryComponent(name)}&login_type=${Uri.encodeQueryComponent(loginType)}&phone=${Uri.encodeQueryComponent(phone ?? '')}&email=${Uri.encodeQueryComponent(email ?? '')}';
  }

  static String getSuccsessfly_createdRoute() => succsessflycreated;

  static List<GetPage> routes = [
    GetPage(name: posCheckout, page: () => const NotFound()),
    GetPage(
        name: initial,
        page: () => const PageTracker(
              pageName: 'EmployeeMainScreen',
              child: MarketerScreen(),
            )),
    GetPage(name: newConversation, page: () => const NotFound()),
    GetPage(name: sendFunds, page: () => const NotFound()),
    GetPage(
        name: splash,
        page: () {
          NotificationBodyModel? data;
          if (Get.parameters['data'] != 'null') {
            final List<int> decode =
                base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
            data = NotificationBodyModel.fromJson(
                jsonDecode(utf8.decode(decode)) as Map<String, dynamic>);
          }
          return PageTracker(
            pageName: 'SplashScreen',
            child: SplashScreen(body: data),
          );
        }),
    GetPage(
        name: language,
        page: () =>
            ChooseLanguageScreen(fromMenu: Get.parameters['page'] == 'menu')),
    GetPage(name: onBoarding, page: () => const NotFound()),
    GetPage(
        name: welcome,
        page: () => const PageTracker(
              pageName: 'WelcomeScreen',
              child: WelcomeScreen(),
            )),
    GetPage(
        name: phoneLogin,
        page: () => const PageTracker(
              pageName: 'PhoneLoginScreen',
              child: PhoneLoginScreen(),
            )),
    GetPage(
        name: otpVerification,
        page: () {
          final args = Get.arguments;
          final Map<String, dynamic> data =
              args is Map<String, dynamic> ? args : <String, dynamic>{};
          return PageTracker(
            pageName: 'OtpVerificationScreen',
            child: OtpVerificationScreen(
              phone: data['phone']?.toString() ?? '',
              cooldownSeconds: data['cooldown'] is int ? data['cooldown'] as int : 120,
              expiresInSeconds: data['expires'] is int ? data['expires'] as int : 600,
            ),
          );
        }),
    GetPage(
        name: createAccount,
        page: () => const PageTracker(
              pageName: 'CreateAccountScreen',
              child: CreateAccountScreen(),
            )),
    // Passwordless flow: every sign-in entry point now opens the new Welcome
    // screen. The legacy SignInScreen widget is kept for the upcoming cleanup
    // phase but is no longer routed to.
    GetPage(
        name: signIn,
        page: () => const PageTracker(
              pageName: 'WelcomeScreen',
              child: WelcomeScreen(),
            )),

    GetPage(
        name: signUp,
        page: () => const PageTracker(
              pageName: 'SignUpScreen',
              child: SignUpScreen(),
            )),

    GetPage(
        name: verification,
        page: () {
          String? pass;
          if (Get.parameters['pass'] != null &&
              Get.parameters['pass'] != 'null') {
            final List<int> decode =
                base64Decode(Get.parameters['pass']!.replaceAll(' ', '+'));
            pass = utf8.decode(decode);
          }
          String? session;
          if (Get.parameters['session'] != null &&
              Get.parameters['session'] != 'null') {
            session =
                utf8.decode(base64Url.decode(Get.parameters['session'] ?? ''));
          }
          UpdateUserModel? userModel;
          if (Get.parameters['user_model'] != null &&
              Get.parameters['user_model'] != 'null') {
            final List<int> decode = base64Decode(
                Get.parameters['user_model'] != null
                    ? Get.parameters['user_model']!.replaceAll(' ', '+')
                    : '');
            userModel = UpdateUserModel.fromJson(
                jsonDecode(utf8.decode(decode)) as Map<String, dynamic>);
          }
          return VerificationScreen(
            number: Get.parameters['number'] != '' &&
                    Get.parameters['number'] != 'null'
                ? Get.parameters['number']
                : null,
            fromSignUp: Get.parameters['page'] == signUp,
            token: Get.parameters['token'],
            password: pass,
            email: Get.parameters['email'] != '' &&
                    Get.parameters['email'] != 'null'
                ? Get.parameters['email']
                : null,
            loginType: Get.parameters['login_type'] ?? 'manual',
            firebaseSession: session,
            fromForgetPassword: Get.parameters['page'] == forgotPassword,
            fromLogin2fa: Get.parameters['page'] == loginOtp,
            userModel: userModel,
            nextPage:
                Get.parameters['next'] != '' && Get.parameters['next'] != 'null'
                    ? Get.parameters['next']
                    : null,
          );
        }),

    GetPage(name: accessLocation, page: () => const NotFound()),
    GetPage(name: pickMap, page: () => const NotFound()),

    GetPage(name: selectLocation, page: () => const NotFound()),

    GetPage(name: deliveryAddresses, page: () => const NotFound()),

    GetPage(name: addressDetails, page: () => const NotFound()),

    GetPage(name: my_Location, page: () => const NotFound()),

    //

    GetPage(name: interest, page: () => const NotFound()),

    GetPage(name: forgotPassword, page: () => const ForgetPassScreen()),

    GetPage(
        name: resetPassword,
        page: () => NewPassScreen(
              resetToken: Get.parameters['token'],
              number: Get.parameters['phone'],
              fromPasswordChange: Get.parameters['page'] == 'password-change',
            )),

    GetPage(name: search, page: () => const NotFound()),

    GetPage(name: store, page: () => const NotFound()),
    GetPage(name: orderDetails, page: () => const NotFound()),

    GetPage(name: statistics, page: () => const NotFound()),

    GetPage(name: qr_screen, page: () => const NotFound()),

    GetPage(name: discount, page: () => const NotFound()),

    GetPage(name: kaidhaWallet, page: () => const NotFound()),
    GetPage(name: IsLoggedIn_Kiadha_Screen, page: () => const NotFound()),
    GetPage(name: qidhaDiscoverStores, page: () => const NotFound()),
    GetPage(name: coupon, page: () => const NotFound()),

    GetPage(name: old_wallet, page: () => const NotFound()),

    GetPage(name: profile, page: () => getRoute(const ProfileScreen())),
    GetPage(
        name: updateProfile, page: () => getRoute(const UpdateProfileScreen())),
    GetPage(
        name: notification,
        page: () => getRoute(NotificationScreen(
            fromNotification: Get.parameters['from'] == 'true'))),
    GetPage(name: map, page: () => const NotFound()),
    GetPage(name: address, page: () => const NotFound()),
    GetPage(name: payment, page: () => const NotFound()),
    GetPage(name: checkout, page: () => const NotFound()),
    GetPage(name: orderTracking, page: () => const NotFound()),
    GetPage(name: basicCampaign, page: () => const NotFound()),
    GetPage(name: html, page: () => const NotFound()),
    GetPage(name: categories, page: () => const NotFound()),
    GetPage(name: popularItems, page: () => const NotFound()),
    GetPage(name: contactUs, page: () => const NotFound()),
    GetPage(name: cart, page: () => const NotFound()),
    GetPage(name: editAddress, page: () => const NotFound()),
    GetPage(name: rateReview, page: () => const NotFound()),
    GetPage(name: storeReview, page: () => const NotFound()),
    GetPage(name: itemImages, page: () => const NotFound()),
    GetPage(name: parcelCategory, page: () => const NotFound()),
    GetPage(name: parcelRequest, page: () => const NotFound()),
    GetPage(name: order, page: () => const NotFound()),

    GetPage(name: loyalty, page: () => const NotFound()),
    GetPage(name: marketer, page: () => getRoute(const MarketerScreen())),
    GetPage(name: employeeMain, page: () => getRoute(const EmployeeMainScreen())),
    GetPage(name: selectWorkZone, page: () => getRoute(const SelectWorkZoneScreen())),
    GetPage(name: attendanceStepper, page: () => getRoute(const AttendanceStepperScreen())),
    GetPage(name: dailyVisits, page: () => getRoute(const DailyVisitsScreen())),
    GetPage(name: dailySummary, page: () => getRoute(const DailyPerformanceSummaryScreen())),
    GetPage(name: employeeRequests, page: () => getRoute(const EmployeeRequestsScreen())),
    GetPage(name: employeeSettings, page: () => getRoute(const EmployeeSettingsScreen())),
    GetPage(name: employeeProfile, page: () => getRoute(const EmployeeProfileScreen())),
    GetPage(
        name: messages,
        page: () {
          NotificationBodyModel? notificationBody;
          if (Get.parameters['notification'] != 'null') {
            notificationBody = NotificationBodyModel.fromJson(jsonDecode(
                    utf8.decode(base64Url.decode(
                        Get.parameters['notification']!.replaceAll(' ', '+'))))
                as Map<String, dynamic>);
          }
          OrderChatModel? orderChat;
          if (Get.parameters['order-chat'] != 'null') {
            orderChat = OrderChatModel.fromJson(jsonDecode(utf8.decode(
                    base64Url.decode(
                        Get.parameters['order-chat']!.replaceAll(' ', '+'))))
                as Map<String, dynamic>);
          }
          User? user;
          if (Get.parameters['user'] != 'null') {
            user = User.fromJson(jsonDecode(utf8.decode(base64Url
                    .decode(Get.parameters['user']!.replaceAll(' ', '+'))))
                as Map<String, dynamic>);
          }
          return getRoute(ChatScreen(
            notificationBody: notificationBody,
            user: user,
            index: Get.parameters['index'] != 'null'
                ? int.parse(Get.parameters['index']!)
                : null,
            fromNotification: Get.parameters['from'] == 'true',
            isClosed: Get.parameters['isClosed'] == 'true',
            conversationID: (Get.parameters['conversation_id'] != null &&
                    Get.parameters['conversation_id'] != 'null')
                ? int.parse(Get.parameters['conversation_id']!)
                : null,
            orderChatModel: orderChat,
          ));
        }),
    GetPage(name: conversation, page: () => const NotFound()),

    GetPage(name: succsessflycreated, page: () => const NotFound()),
    GetPage(name: restaurantRegistration, page: () => const NotFound()),
    GetPage(name: deliveryManRegistration, page: () => const NotFound()),
    GetPage(name: refund, page: () => const NotFound()),
    GetPage(name: offlinePaymentScreen, page: () => const NotFound()),
    GetPage(name: flashSaleDetailsScreen, page: () => const NotFound()),
    GetPage(name: favourite, page: () => const NotFound()),
    GetPage(name: brandsItemScreen, page: () => const NotFound()),

    GetPage(name: subscriptionSuccess, page: () => const NotFound()),
    GetPage(name: subscriptionPayment, page: () => const NotFound()),
    GetPage(name: newUserSetupScreen, page: () => const NotFound()),
    GetPage(name: firstOrderGift, page: () => const NotFound()),
  ];

  static bool _shouldBypassAddressCheck() {
    // Check if we're navigating to order details with bypass parameter
    return Get.parameters['bypass'] == 'true';
  }

  static Widget getRoute(Widget navigateTo,
      {PickMapScreen? locationScreen, bool byPuss = false}) {
    double? minimumVersion = 0;
    if (GetPlatform.isAndroid) {
      minimumVersion =
          Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      minimumVersion =
          Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }

    // ✅ تسجيل Search dependencies فقط إذا كانت الشاشة SearchScreen
    if (navigateTo is SearchScreen &&
        !Get.isRegistered<SearchServiceInterface>()) {
      Get.lazyPut<SearchRepositoryInterface>(() => SearchRepository(
          apiClient: Get.find(), sharedPreferences: Get.find()));

      Get.lazyPut<SearchServiceInterface>(
          () => SearchService(searchRepositoryInterface: Get.find()));

      Get.lazyPut(() => SearchController(
            searchServiceInterface: Get.find(),
          ));
    }


    // Check if we have a valid location (either saved in SharedPreferences or in LocationController)
    bool hasValidLocation = false;

    // First check SharedPreferences
    final AddressModel? savedAddress =
        AddressHelper.getUserAddressFromSharedPref();
    if (savedAddress != null &&
        savedAddress.latitude != null &&
        savedAddress.longitude != null &&
        savedAddress.latitude!.isNotEmpty &&
        savedAddress.longitude!.isNotEmpty) {
      try {
        final double lat = double.parse(savedAddress.latitude!);
        final double lng = double.parse(savedAddress.longitude!);
        // Check if coordinates are valid (not 0.0, 0.0)
        if (lat != 0.0 || lng != 0.0) {
          hasValidLocation = true;
        }
      } catch (e) {
        // Invalid saved address, continue checking LocationController
      }
    }

    // If no saved address, check LocationController position
    if (!hasValidLocation && Get.isRegistered<LocationController>()) {
      try {
        final locationController = Get.find<LocationController>();
        final position = locationController.position;
        // Check if position is valid (not 0.0, 0.0)
        if (position.latitude != 0.0 || position.longitude != 0.0) {
          hasValidLocation = true;
        }
      } catch (e) {
        // LocationController not available or error, continue
      }
    }

    return (AppConstants.appVersion < (minimumVersion ?? 0.0) &&
            !GetPlatform.isWeb)
        ? const UpdateScreen(isUpdate: true)
        : Get.find<SplashController>().configModel!.maintenanceMode!
            ? const UpdateScreen(isUpdate: false)
            : (!hasValidLocation && !byPuss && !_shouldBypassAddressCheck())
                ? PickMapScreen(
                    fromSignUp: false,
                    fromAddAddress: false,
                    canRoute: false,
                    route: Get.currentRoute,
                  )
                : navigateTo;
  }
}
