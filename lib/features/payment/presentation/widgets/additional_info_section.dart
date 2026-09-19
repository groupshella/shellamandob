// 'additional_info'.tr: tableware toggle + an "unavailable items" action row.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/payment/presentation/keeta_pay_style.dart';
import 'package:sixam_mart/features/payment/presentation/widgets/payment_option_tile.dart';

class AdditionalInfoSection extends StatelessWidget {
  final bool tableware;
  final ValueChanged<bool> onTablewareChanged;
  final VoidCallback? onUnavailableTap;

  const AdditionalInfoSection({
    super.key,
    required this.tableware,
    required this.onTablewareChanged,
    this.onUnavailableTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = KeetaPayStyle.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('additional_info'.tr, style: s.t(16, weight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: s.card,
            border: Border.all(color: s.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              PaymentOptionTile(
                leading: Icon(Icons.restaurant, color: s.ink, size: 20),
                title: 'cutlery'.tr,
                subtitle: 'added_if_restaurant_provides'.tr,
                trailing: KeetaSwitch(
                  value: tableware,
                  amber: true,
                  onChanged: onTablewareChanged,
                ),
              ),
              Divider(height: 1, color: s.border, indent: 15, endIndent: 15),
              PaymentOptionTile(
                leading: Icon(Icons.room_service_outlined, color: s.ink, size: 20),
                title: 'for_unavailable_items'.tr,
                subtitle: 'contact_me'.tr,
                trailing: Icon(Icons.chevron_left, color: s.muted, size: 22),
                onTap: onUnavailableTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
