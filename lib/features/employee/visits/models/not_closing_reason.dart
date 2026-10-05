enum NotClosingReason {
  needsTime('needs_time', 'reason_needs_time'),
  differentOffer('different_offer', 'reason_custom_offer'),
  waitingOwnerApproval('waiting_owner_approval', 'reason_waiting_owner'),
  needsMoreDetails('needs_more_details', 'reason_more_details'),
  unsureAboutService('unsure_about_service', 'reason_unsure_service'),
  currentlyBusy('currently_busy', 'reason_currently_busy'),
  other('other', 'reason_other');

  final String key;
  final String translationKey;

  const NotClosingReason(this.key, this.translationKey);

  String get label {
    switch (this) {
      case NotClosingReason.needsTime:
        return 'يحتاج وقت للتفكير';
      case NotClosingReason.differentOffer:
        return 'طلب عرض مختلف';
      case NotClosingReason.waitingOwnerApproval:
        return 'بانتظار موافقة المالك';
      case NotClosingReason.needsMoreDetails:
        return 'يحتاج تفاصيل إضافية';
      case NotClosingReason.unsureAboutService:
        return 'غير متأكد من الخدمة';
      case NotClosingReason.currentlyBusy:
        return 'مشغول حالياً';
      case NotClosingReason.other:
        return 'سبب آخر';
    }
  }

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
    return NotClosingReason.other;
  }
}
