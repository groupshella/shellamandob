import 'package:flutter/material.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_model.dart';

/// Resolves a notification's icon + accent colour from its backend `type`
/// (falling back to title/description keywords, since the API's type strings
/// are not always present or consistent).
class NotificationTypeIcon {
  final IconData icon;
  final Color color;
  const NotificationTypeIcon(this.icon, this.color);

  static const _green = Color(0xFF30913F);
  static const _blue = Color(0xFF2F73C8);
  static const _amber = Color(0xFFE0A400);
  static const _purple = Color(0xFF6B4FBB);
  static const _red = Color(0xFFD64545);

  static NotificationTypeIcon fromModel(NotificationModel model) {
    final type = (model.data?.type ?? '').toLowerCase();
    final text =
        '${model.data?.title ?? ''} ${model.data?.description ?? ''}'.trim();

    bool has(List<String> keys) =>
        keys.any((k) => type.contains(k) || text.contains(k));

    // Loyalty points / congratulations → coin.
    if (has(['loyalty', 'point', 'تهنئة', 'نقاط', 'ولاء'])) {
      return const NotificationTypeIcon(Icons.monetization_on_outlined, _amber);
    }
    // Courier on the way → delivery.
    if (has(['on_the_way', 'delivery', 'المندوب', 'الطريق', 'توصيل'])) {
      return const NotificationTypeIcon(Icons.delivery_dining, _green);
    }
    // Order placed / order notification → scissors (ticket).
    if (has(['order_placed', 'placed', 'تقديم', 'إشعار الطلب'])) {
      return const NotificationTypeIcon(Icons.content_cut, _green);
    }
    // Order received → basket.
    if (has(['received', 'accepted', 'استلام', 'استلم'])) {
      return const NotificationTypeIcon(Icons.shopping_basket_outlined, _green);
    }
    // Order confirmed / processing → restaurant.
    if (has(['order_confirmed', 'confirmed', 'processing', 'تأكيد', 'تحضير'])) {
      return const NotificationTypeIcon(Icons.restaurant_menu, _green);
    }
    // Qidha service stopped → blocked card.
    if (has(['qidha_stop', 'suspend', 'إيقاف', 'محظور', 'تعليق'])) {
      return const NotificationTypeIcon(Icons.credit_card_off_outlined, _red);
    }
    // Wallet credit / fund add → wallet.
    if (has(['wallet_credit', 'fund', 'credit', 'إضافة رصيد', 'محفظت'])) {
      return const NotificationTypeIcon(
          Icons.account_balance_wallet_outlined, _green);
    }
    // Balance used / debit → payment card.
    if (has(['debit', 'used', 'استخدام الرصيد', 'خصم'])) {
      return const NotificationTypeIcon(Icons.payment_outlined, _purple);
    }
    // Recommendation from admin → lightbulb / spark
    if (has(['recommendation', 'توصية', 'توجيه'])) {
      return const NotificationTypeIcon(Icons.tips_and_updates_outlined, _blue);
    }
    // Warning or Alert → warning amber
    if (has(['warning', 'alert', 'إنذار', 'تنبيه', 'مخالفة'])) {
      return const NotificationTypeIcon(Icons.warning_amber_rounded, _red);
    }
    // Leave status / request → event note
    if (has(['leave', 'vacation', 'permission', 'إجازة', 'استئذان'])) {
      return const NotificationTypeIcon(Icons.event_note, _green);
    }
    // Contract / agreement → handshake
    if (has(['contract', 'agreement', 'عقد', 'اتفاقية'])) {
      return const NotificationTypeIcon(Icons.handshake_outlined, _blue);
    }
    // Follow-up → timeline
    if (has(['followup', 'follow_up', 'متابعة'])) {
      return const NotificationTypeIcon(Icons.timeline_outlined, _purple);
    }
    // Visit → location pin
    if (has(['visit', 'زيارة', 'ميدانية'])) {
      return const NotificationTypeIcon(Icons.location_on_outlined, _green);
    }

    // Default.
    return const NotificationTypeIcon(Icons.notifications_outlined, _green);
  }
}
