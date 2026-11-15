import 'package:get/get.dart';
import 'package:sixam_mart/core/network/api_client.dart';

String mapOtpAuthError(String? code, String? fallbackMessage) {
  switch (code) {
    case 'invalid_otp':
      return 'invalid_otp_code'.tr;
    case 'otp_expired':
    case 'otp_not_found':
      return 'otp_expired_code'.tr;
    case 'otp_temp_blocked':
      return 'otp_temp_blocked_code'.tr;
    case 'invalid_registration_token':
      return 'invalid_registration_token_code'.tr;
    case 'invalid_referral_token':
      return 'invalid_referral_token'.tr;
    case 'validation_error':
      return 'invalid_phone_number'.tr;
    default:
      // ApiClient synthesizes its own already-localized "no connection"
      // message when the request never reaches the server at all (no
      // internet, DNS failure, timeout) -- that's safe to show as-is and
      // far more actionable than a generic message. Anything else (a raw
      // backend/exception string) stays masked, since that could leak
      // untranslated English text.
      if (fallbackMessage != null && fallbackMessage == ApiClient.noInternetMessage) {
        return fallbackMessage;
      }
      return 'something_went_wrong'.tr;
  }
}
