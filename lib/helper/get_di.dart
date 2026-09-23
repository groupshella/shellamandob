import 'dart:convert';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/employee/services/marketer_shift_service.dart';
import 'package:sixam_mart/features/update/controllers/update_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/domain/repository/language_repository.dart';
import 'package:sixam_mart/features/language/domain/repository/language_repository_interface.dart';
import 'package:sixam_mart/features/language/domain/service/language_service.dart';
import 'package:sixam_mart/features/language/domain/service/language_service_interface.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/address/domain/repositories/address_repository.dart';
import 'package:sixam_mart/features/address/domain/repositories/address_repository_interface.dart';
import 'package:sixam_mart/features/address/domain/services/address_service.dart';
import 'package:sixam_mart/features/address/domain/services/address_service_interface.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:sixam_mart/features/auth/controllers/store_registration_controller.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/auth_repository.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/deliveryman_registration_repository.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/deliveryman_registration_repository_interface.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/store_registration_repository.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/store_registration_repository_interface.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/features/auth/domain/services/deliveryman_registration_service.dart';
import 'package:sixam_mart/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:sixam_mart/features/auth/domain/services/store_registration_service.dart';
import 'package:sixam_mart/features/auth/domain/services/store_registration_service_interface.dart';
import 'package:sixam_mart/features/location/domain/repositories/location_repository.dart';
import 'package:sixam_mart/features/location/domain/repositories/location_repository_interface.dart';
import 'package:sixam_mart/features/location/domain/services/location_service.dart';
import 'package:sixam_mart/features/location/domain/services/location_service_interface.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/notification/domain/repository/notification_repository.dart';
import 'package:sixam_mart/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:sixam_mart/features/notification/domain/service/notification_service.dart';
import 'package:sixam_mart/features/notification/domain/service/notification_service_interface.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/repositories/profile_repository.dart';
import 'package:sixam_mart/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:sixam_mart/features/profile/domain/services/profile_service.dart';
import 'package:sixam_mart/features/profile/domain/services/profile_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/splash/domain/repositories/splash_repository.dart';
import 'package:sixam_mart/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/features/verification/domein/reposotories/verification_repository.dart';
import 'package:sixam_mart/features/verification/domein/reposotories/verification_repository_interface.dart';
import 'package:sixam_mart/features/verification/domein/services/verification_service.dart';
import 'package:sixam_mart/features/verification/domein/services/verification_service_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/utils/app_logger.dart';
import 'package:sixam_mart/common/api/api_call_manager.dart';
import 'package:sixam_mart/common/api/optimized_api_client.dart';

import 'package:sixam_mart/core/services/pusher_service.dart';

Future<Map<String, Map<String, String>>> init() async {
  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(
      appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));

  // Initialize optimized API client
  Get.lazyPut(() => OptimizedApiClient(
      appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));

  // Initialize API call manager
  Get.lazyPut(() => ApiCallManager());

  // Initialize token from secure storage
  await Get.find<ApiClient>().initializeTokenFromSecureStorage();

  // Initialize Pusher Real-Time Service
  Get.lazyPut(() => PusherService());
  Get.find<PusherService>().init();

// ====================================

  /// Repository interface
  final AuthRepositoryInterface authRepositoryInterface =
      AuthRepository(apiClient: Get.find(), sharedPreferences: Get.find());
  Get.lazyPut(() => authRepositoryInterface);

          apiClient: Get.find(),
          sharedPreferences: Get.find(),
          authRepositoryInterface: Get.find());
  Get.lazyPut(() => checkoutRepositoryInterface);

  final LocationRepositoryInterface locationRepositoryInterface =
      LocationRepository(apiClient: Get.find());
  Get.lazyPut(() => locationRepositoryInterface);

  final DeliverymanRegistrationRepositoryInterface
      deliverymanRegistrationRepositoryInterface =
      DeliverymanRegistrationRepository(
          apiClient: Get.find(), sharedPreferences: Get.find());
  Get.lazyPut(() => deliverymanRegistrationRepositoryInterface);

  final StoreRegistrationRepositoryInterface
      storeRegistrationRepositoryInterface =
      StoreRegistrationRepository(apiClient: Get.find());
  Get.lazyPut(() => storeRegistrationRepositoryInterface);

  Get.lazyPut(() => parcelRepositoryInterface);

  Get.lazyPut<AddressRepositoryInterface<AddressModel>>(
      () => AddressRepository(apiClient: Get.find()));

  Get.lazyPut(() => orderRepositoryInterface);

  Get.lazyPut(() => paymentRepositoryInterface);

  Get.lazyPut(() => campaignRepositoryInterface);

  Get.lazyPut(() => chatRepositoryInterface);

  Get.lazyPut(() => couponRepositoryInterface);

  Get.lazyPut(() => favouriteRepositoryInterface);

  Get.lazyPut(() => flashSaleRepositoryInterface);

  Get.lazyPut(() => homeRepositoryInterface);

  Get.lazyPut(() => bannerRepositoryInterface);

  Get.lazyPut(() => htmlRepositoryInterface);

  final LanguageRepositoryInterface languageRepositoryInterface =
      LanguageRepository(apiClient: Get.find(), sharedPreferences: Get.find());
  Get.lazyPut(() => languageRepositoryInterface);

  final NotificationRepositoryInterface notificationRepositoryInterface =
      NotificationRepository(
          sharedPreferences: Get.find(), apiClient: Get.find());
  Get.lazyPut(() => notificationRepositoryInterface);

  Get.lazyPut(() => onboardRepositoryInterface);

  final ProfileRepositoryInterface profileRepositoryInterface =
      ProfileRepository(apiClient: Get.find());
  Get.lazyPut(() => profileRepositoryInterface);

  Get.lazyPut(() => searchRepositoryInterface);

  final SplashRepositoryInterface splashRepositoryInterface =
      SplashRepository(sharedPreferences: Get.find(), apiClient: Get.find());
  Get.lazyPut(() => splashRepositoryInterface);

  Get.lazyPut(() => reviewRepositoryInterface);

  Get.lazyPut(() => storeRepositoryInterface);

  Get.lazyPut(() => walletRepositoryInterface);

  Get.lazyPut(() => supportRepositoryInterface);

  Get.lazyPut(() => itemRepositoryInterface);

  Get.lazyPut(() => categoryRepositoryInterface);

  Get.lazyPut(() => loyaltyRepositoryInterface);

  Get.lazyPut(() => cartRepositoryInterface);

  final VerificationRepositoryInterface verificationRepositoryInterface =
      VerificationRepository(
          apiClient: Get.find(), sharedPreferences: Get.find());
  Get.lazyPut(() => verificationRepositoryInterface);

  Get.lazyPut(() => brandsRepositoryInterface);

  Get.lazyPut(() => businessRepoInterface);

  Get.lazyPut(() => advertisementRepositoryInterface);

  // Analytics Dependencies

  // 🎯 MARKETER: Rental/Taxi module is not used in marketer app — skip all registration
  if (!AppConstants.isMarketerApp) {
    Get.lazyPut(() => taxiRepositoryInterface);

    Get.lazyPut(() => taxiHomeRepositoryInterface);

    Get.lazyPut(() => taxiCartRepositoryInterface);

    Get.lazyPut(() => taxiVendorRepositoryInterface);

    Get.lazyPut(() => taxiOrderRepositoryInterface);

    Get.lazyPut(() => taxiFavouriteRepositoryInterface);
  }

  /// Service Interface
  Get.lazyPut(() => checkoutServiceInterface, fenix: true);

  final AuthServiceInterface authServiceInterface =
      AuthService(authRepositoryInterface: Get.find());
  Get.lazyPut(() => authServiceInterface);

  final LocationServiceInterface locationServiceInterface =
      LocationService(locationRepoInterface: Get.find());

  final DeliverymanRegistrationServiceInterface
      deliverymanRegistrationServiceInterface = DeliverymanRegistrationService(
          deliverymanRegistrationRepoInterface: Get.find(),
          authRepositoryInterface: Get.find());
  Get.lazyPut(() => deliverymanRegistrationServiceInterface);

  final StoreRegistrationServiceInterface storeRegistrationServiceInterface =
      StoreRegistrationService(
          deliverymanRegistrationRepositoryInterface: Get.find(),
          storeRegistrationRepoInterface: Get.find());
  Get.lazyPut(() => storeRegistrationServiceInterface);

  Get.lazyPut(() => parcelServiceInterface);

  final AddressServiceInterface addressServiceInterface = AddressService(
      addressRepoInterface:
          Get.find<AddressRepositoryInterface<AddressModel>>());
  Get.lazyPut(() => addressServiceInterface);

  Get.lazyPut(() => orderServiceInterface);

  Get.lazyPut(() => paymentServiceInterface);

  // This ensures the service is always available and can be revived if deleted during module switching
  Get.lazyPut(() => campaignServiceInterface, fenix: true);

  Get.lazyPut(() => chatServiceInterface);

  Get.lazyPut(() => couponServiceInterface);

  Get.lazyPut(() => favouriteServiceInterface);

  Get.lazyPut(() => homeServiceInterface);

  Get.lazyPut(() => flashSaleServiceInterface);

  Get.lazyPut(() => bannerServiceInterface);

  Get.lazyPut(() => htmlServiceInterface);

  final LanguageServiceInterface languageServiceInterface =
      LanguageService(languageRepositoryInterface: Get.find());
  Get.lazyPut(() => languageServiceInterface);

  final NotificationServiceInterface notificationServiceInterface =
      NotificationService(notificationRepositoryInterface: Get.find());
  Get.lazyPut(() => notificationServiceInterface);

  Get.lazyPut(() => onboardServiceInterface);

  final ProfileServiceInterface profileServiceInterface =
      ProfileService(profileRepositoryInterface: Get.find());
  Get.lazyPut(() => profileServiceInterface);

  Get.lazyPut(() => searchServiceInterface);

  final SplashServiceInterface splashServiceInterface =
      SplashService(splashRepositoryInterface: Get.find());
  Get.lazyPut(() => splashServiceInterface);

  Get.lazyPut(() => reviewServiceInterface);

  Get.lazyPut(() => storeServiceInterface);

  Get.lazyPut(() => walletServiceInterface);

  Get.lazyPut(() => supportServiceInterface);

  Get.lazyPut(() => itemServiceInterface);

  Get.lazyPut(() => categoryServiceInterface);

  Get.lazyPut(() => loyaltyServiceInterface);

  Get.lazyPut(() => cartServiceInterface);

  final VerificationServiceInterface verificationServiceInterface =
      VerificationService(
          verificationRepoInterface: Get.find(), authRepoInterface: Get.find());
  Get.lazyPut(() => verificationServiceInterface);

  Get.lazyPut(() => brandsServiceInterface);

  Get.lazyPut(() => businessServiceInterface);

  Get.lazyPut(() => advertisementServiceInterface);

  // Analytics Service (using repository directly as service)
  // AnalyticsRepositoryInterface is already registered above


  /// Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashServiceInterface: Get.find()));
  Get.lazyPut(() => AddressController(addressServiceInterface: Get.find()));

  Get.lazyPut(() =>
      LocationController(locationServiceInterface: locationServiceInterface));

  Get.lazyPut(
      () => LocalizationController(languageServiceInterface: Get.find()));
  Get.lazyPut(() => AuthController(authServiceInterface: Get.find()));
  Get.lazyPut(() => DeliverymanRegistrationController(
      deliverymanRegistrationServiceInterface: Get.find()));
  Get.lazyPut(() => StoreRegistrationController(
      storeRegistrationServiceInterface: Get.find(),
      locationServiceInterface: locationServiceInterface));
  Get.lazyPut(() => ProfileController(profileServiceInterface: Get.find()));
  Get.put(
    permanent: true,
  );
  // This prevents race conditions and stale state when navigating between category screens
      categoryServiceInterface: Get.find(),
      searchServiceInterface: Get.find(),
    ),
    permanent: true,
  );
      fenix: true);



      fenix: true);
  // âڑ، BFF API v2: Home Unified Controller (for /api/v2/home-unified endpoint)
  // âڑ، TITAN BOARD: Permanent singleton to survive route flushes during module switching
  // This ensures loadHomeData() calls don't fail when Get.offAllNamed() executes
  // Note: Get.put() with permanent: true ensures controller survives route navigation
  Get.put(
      permanent: true);
        searchServiceInterface: Get.find(),
      ));
  Get.lazyPut(
      () => NotificationController(notificationServiceInterface: Get.find()));
  // This ensures controller is always available and can be revived if deleted
      fenix: true);
      fenix: true);
  Get.lazyPut(
      () => VerificationController(verificationServiceInterface: Get.find()),
      fenix: true);
        brandsServiceInterface: Get.find(),
        itemRepository: Get.find(),
      ));
  Get.lazyPut(

  // Marketer and Update Controllers
  Get.lazyPut(() => MarketerController(apiClient: Get.find()));
  Get.lazyPut(() => MarketerShiftService(apiClient: Get.find()));
  Get.lazyPut(() => UpdateController());

  // ======================================================================================================================

  /// Retrieving localized data
  /// NOTE: Load all configured languages so runtime language switch works.
  final Map<String, Map<String, String>> languages = {};

  for (final languageModel in AppConstants.languages) {
    try {
      final String jsonStringValues = await rootBundle
          .loadString('assets/language/${languageModel.languageCode}.json');
      final mappedJson = jsonDecode(jsonStringValues) as Map<String, dynamic>;

      final Map<String, String> json = {};
      mappedJson.forEach((key, value) {
        json[key] = value.toString();
      });

      final String key =
          '${languageModel.languageCode}_${languageModel.countryCode}';
      languages[key] = json;
      languages[languageModel.languageCode!] = json;

      if (kDebugMode) {
        appLogger.debug('🔍 Loaded ${json.length} translations for $key');
      }
    } catch (e) {
      if (kDebugMode) {
        appLogger.error(
            '🔍 Error loading language ${languageModel.languageCode}_${languageModel.countryCode}: $e',
            e);
      }
    }
  }

  if (languages.isEmpty) {
    try {
      final fallbackLang = AppConstants.languages[0];
      final String jsonStringValues = await rootBundle
          .loadString('assets/language/${fallbackLang.languageCode}.json');
      final mappedJson = jsonDecode(jsonStringValues) as Map<String, dynamic>;
      final Map<String, String> json = {};
      mappedJson.forEach((key, value) {
        json[key] = value.toString();
      });
      final String key =
          '${fallbackLang.languageCode}_${fallbackLang.countryCode}';
      languages[key] = json;
      languages[fallbackLang.languageCode!] = json;
      if (kDebugMode) {
        appLogger.debug('🔍 Loaded fallback language: $key');
      }
    } catch (fallbackError) {
      if (kDebugMode) {
        appLogger.error('🔍 Error loading fallback language: $fallbackError',
            fallbackError);
      }
    }
  }

  if (kDebugMode) {
    appLogger.debug('🔍 Total languages loaded: ${languages.keys}');
  }
  return languages;
}
