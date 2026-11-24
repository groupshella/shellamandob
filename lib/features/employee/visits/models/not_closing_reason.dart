import 'package:get/get.dart';

enum NotClosingReason {
  needsTime('needs_time', 'reason_needs_time'),
  differentOffer('different_offer', 'reason_custom_offer'),
  waitingOwnerApproval('waiting_owner_approval', 'reason_waiting_owner'),
  needsMoreDetails('needs_more_details', 'reason_more_details'),
  unsureAboutService('unsure_about_service', 'reason_unsure_service'),
  currentlyBusy('currently_busy', 'reason_currently_busy'),
  exclusiveOtherApp('exclusive_other_app', 'reason_exclusive_other_app'),
  otpNafathFear('otp_nafath_fear', 'reason_otp_nafath_fear'),
  noCreditSales('no_credit_sales', 'reason_no_credit_sales'),
  other('other', 'reason_other');

  final String key;
  final String translationKey;

  const NotClosingReason(this.key, this.translationKey);

  String get label => translationKey.tr;

  static NotClosingReason fromKey(String? key) {
    if (key == null || key.isEmpty) return NotClosingReason.needsTime;
    for (final reason in NotClosingReason.values) {
      if (reason.key == key) return reason;
    }
    // Fallback for legacy localized text
    if (key.contains('تفكير') || key.contains('وقت')) return NotClosingReason.needsTime;
    if (key.contains('عرض')) return NotClosingReason.differentOffer;
    if (key.contains('مالك')) return NotClosingReason.waitingOwnerApproval;
    if (key.contains('تفاصيل')) return NotClosingReason.needsMoreDetails;
    if (key.contains('خدمة') || key.contains('متأكد') || key.contains('متاكد')) return NotClosingReason.unsureAboutService;
    if (key.contains('مشغول')) return NotClosingReason.currentlyBusy;
    if (key.contains('حصري')) return NotClosingReason.exclusiveOtherApp;
    if (key.contains('نفاذ') || key.contains('تحقق')) return NotClosingReason.otpNafathFear;
    if (key.contains('آجل') || key.contains('اجل') || key.contains('قيدها')) return NotClosingReason.noCreditSales;
    return NotClosingReason.other;
  }
}
