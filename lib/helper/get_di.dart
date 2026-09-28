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
import 'package:sixam_mart/core/network/api_client.dart';
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
import 'package:sixam_mart/core/network/api_call_manager.dart';
import 'package:sixam_mart/core/network/optimized_api_client.dart';

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

  Get.lazyPut<AddressRepositoryInterface<AddressModel>>(
      () => AddressRepository(apiClient: Get.find()));

  final LanguageRepositoryInterface languageRepositoryInterface =
      LanguageRepository(apiClient: Get.find(), sharedPreferences: Get.find());
  Get.lazyPut(() => languageRepositoryInterface);

  final NotificationRepositoryInterface notificationRepositoryInterface =
      NotificationRepository(
          sharedPreferences: Get.find(), apiClient: Get.find());
  Get.lazyPut(() => notificationRepositoryInterface);

  final ProfileRepositoryInterface profileRepositoryInterface =
      ProfileRepository(apiClient: Get.find());
  Get.lazyPut(() => profileRepositoryInterface);

  final SplashRepositoryInterface splashRepositoryInterface =
      SplashRepository(sharedPreferences: Get.find(), apiClient: Get.find());
  Get.lazyPut(() => splashRepositoryInterface);

  final VerificationRepositoryInterface verificationRepositoryInterface =
      VerificationRepository(
          apiClient: Get.find(), sharedPreferences: Get.find());
  Get.lazyPut(() => verificationRepositoryInterface);

  /// Service Interface
  final AuthServiceInterface authServiceInterface =
      AuthService(authRepositoryInterface: Get.find());
  Get.lazyPut(() => authServiceInterface);

  final LocationServiceInterface locationServiceInterface =
      LocationService(locationRepoInterface: Get.find());
  Get.lazyPut(() => locationServiceInterface);

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

  final AddressServiceInterface addressServiceInterface = AddressService(
      addressRepoInterface:
          Get.find<AddressRepositoryInterface<AddressModel>>());
  Get.lazyPut(() => addressServiceInterface);

  final LanguageServiceInterface languageServiceInterface =
      LanguageService(languageRepositoryInterface: Get.find());
  Get.lazyPut(() => languageServiceInterface);

  final NotificationServiceInterface notificationServiceInterface =
      NotificationService(notificationRepositoryInterface: Get.find());
  Get.lazyPut(() => notificationServiceInterface);

  final ProfileServiceInterface profileServiceInterface =
      ProfileService(profileRepositoryInterface: Get.find());
  Get.lazyPut(() => profileServiceInterface);

  final SplashServiceInterface splashServiceInterface =
      SplashService(splashRepositoryInterface: Get.find());
  Get.lazyPut(() => splashServiceInterface);

  final VerificationServiceInterface verificationServiceInterface =
      VerificationService(
          verificationRepoInterface: Get.find(), authRepoInterface: Get.find());
  Get.lazyPut(() => verificationServiceInterface);

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
  Get.lazyPut(
      () => NotificationController(notificationServiceInterface: Get.find()));
  Get.lazyPut(
      () => VerificationController(verificationServiceInterface: Get.find()),
      fenix: true);

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
