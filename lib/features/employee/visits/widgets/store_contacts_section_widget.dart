import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_contact_model.dart';
import '../models/store_visit_model.dart';

class StoreContactsSectionWidget extends StatelessWidget {
  final StoreVisitsController controller;
  final StoreVisitModel visit;
  final bool isDark;
  final bool readOnly;

  const StoreContactsSectionWidget({
    super.key,
    required this.controller,
    required this.visit,
    required this.isDark,
    this.readOnly = false,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    var clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('05')) {
      clean = '966${clean.substring(1)}';
    } else if (clean.startsWith('5')) {
      clean = '966$clean';
    }
    final Uri url = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _getLanguageFlag(String lang) {
    switch (lang.toLowerCase()) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇬🇧';
      case 'ur':
        return '🇵🇰';
      case 'bn':
        return '🇧🇩';
      case 'tl':
        return '🇵🇭';
      default:
        return '🌐';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Icons.admin_panel_settings_outlined;
      case 'partner':
        return Icons.handshake_outlined;
      case 'manager':
      case 'branch_manager':
        return Icons.manage_accounts_outlined;
      case 'cashier':
        return Icons.point_of_sale_outlined;
      case 'worker':
        return Icons.badge_outlined;
      default:
        return Icons.person_outline;
    }
  }

  void _showContactActionModal(BuildContext context, StoreContactModel contact) {
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111827);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getRoleIcon(contact.role), color: _primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              contact.name,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getLanguageFlag(contact.preferredLanguage),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${'role_${contact.role}'.tr} • ${contact.phone}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12.5,
                            color: subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (contact.whatsappConsent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF163E20) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: _primaryGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'whatsapp_consent_verified'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openWhatsApp(contact.phone);
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18, color: Colors.white),
                      label: Text('whatsapp'.tr, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _makePhoneCall(contact.phone);
                      },
                      icon: const Icon(Icons.phone_rounded, size: 18, color: Colors.white),
                      label: Text('call'.tr, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              if (!readOnly && contact.id != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await controller.deleteStoreContact(contact.id!);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                    label: Text(
                      'delete_contact'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAddContactModal(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    String selectedRole = 'cashier';
    String selectedLang = 'ar';
    bool consent = true;

    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111827);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final inputFill = isDark ? const Color(0xFF252B37) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

    final roles = [
      {'key': 'owner', 'label': 'role_owner'.tr, 'icon': Icons.admin_panel_settings_outlined},
      {'key': 'partner', 'label': 'role_partner'.tr, 'icon': Icons.handshake_outlined},
      {'key': 'manager', 'label': 'role_branch_manager'.tr, 'icon': Icons.manage_accounts_outlined},
      {'key': 'cashier', 'label': 'role_cashier'.tr, 'icon': Icons.point_of_sale_outlined},
      {'key': 'worker', 'label': 'role_worker'.tr, 'icon': Icons.badge_outlined},
    ];

    final languages = [
      {'key': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
      {'key': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'key': 'ur', 'label': 'اردو (Urdu)', 'flag': '🇵🇰'},
      {'key': 'bn', 'label': 'বাংলা (Bengali)', 'flag': '🇧🇩'},
      {'key': 'tl', 'label': 'Tagalog', 'flag': '🇵🇭'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'add_store_contact_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role selection chips
                    Text(
                      'role_in_store'.tr,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: darkText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: roles.map((r) {
                        final isSelected = selectedRole == r['key'];
                        return ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(r['icon'] as IconData, size: 16, color: isSelected ? Colors.white : _primaryGreen),
                          label: Text(
                            r['label'] as String,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : darkText,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: _primaryGreen,
                          backgroundColor: inputFill,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: isSelected ? _primaryGreen : borderColor),
                          ),
                          onSelected: (_) => setStateModal(() => selectedRole = r['key'] as String),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      'person_full_name'.tr,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: darkText),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: darkText),
                      decoration: InputDecoration(
                        hintText: 'name_example_hint'.tr,
                        hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: subText),
                        filled: true,
                        fillColor: inputFill,
                        prefixIcon: const Icon(Icons.person_outline, size: 18, color: _primaryGreen),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryGreen, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone / WhatsApp
                    Text(
                      'whatsapp_number_label'.tr,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: darkText),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: darkText),
                      decoration: InputDecoration(
                        hintText: '05XXXXXXXX',
                        hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: subText),
                        filled: true,
                        fillColor: inputFill,
                        prefixIcon: const Icon(Icons.chat_outlined, size: 18, color: _primaryGreen),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryGreen, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Preferred Language
                    Text(
                      'preferred_training_language'.tr,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: darkText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: languages.map((lang) {
                        final isSelected = selectedLang == lang['key'];
                        return ChoiceChip(
                          showCheckmark: false,
                          avatar: Text(lang['flag']!, style: const TextStyle(fontSize: 14)),
                          label: Text(
                            lang['label']!,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : darkText,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: _primaryGreen,
                          backgroundColor: inputFill,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: isSelected ? _primaryGreen : borderColor),
                          ),
                          onSelected: (_) => setStateModal(() => selectedLang = lang['key']!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // WhatsApp Consent Checkbox (Legal requirement)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: consent
                            ? (isDark ? const Color(0xFF163E20) : const Color(0xFFF0FDF4))
                            : inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: consent ? _primaryGreen.withValues(alpha: 0.4) : borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: consent,
                            activeColor: _primaryGreen,
                            onChanged: (val) => setStateModal(() => consent = val ?? true),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'whatsapp_consent_declaration'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'whatsapp_consent_desc'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 11,
                                    color: subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final phone = phoneController.text.trim();
                          if (name.isEmpty || phone.isEmpty) {
                            Get.snackbar('warning'.tr, 'please_fill_contact_name_phone'.tr,
                                backgroundColor: const Color(0xFFF59E0B), colorText: Colors.white);
                            return;
                          }
                          Navigator.pop(ctx);
                          final sId = visit.storeId ?? int.tryParse(visit.id) ?? 0;
                          final vId = int.tryParse(visit.id);
                          await controller.addStoreContact(
                            storeId: sId,
                            marketerVisitId: vId,
                            name: name,
                            role: selectedRole,
                            phone: phone,
                            preferredLanguage: selectedLang,
                            whatsappConsent: consent,
                            notes: notesController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'save_contact_btn'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111827);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final tagBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF8FAFC);
    final contacts = controller.storeContacts;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF163E20) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people_outline_rounded, size: 17, color: _primaryGreen),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'store_contacts_registry_title'.tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                ],
              ),
              if (contacts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${contacts.length}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Tags & Chips interactive Wrap layout
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 1. Add Person Action Tag
              if (!readOnly)
                InkWell(
                  onTap: () => _showAddContactModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF163E20) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primaryGreen.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 15, color: _primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          'add_person_btn'.tr,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 2. Contact Chips
              ...contacts.map((contact) {
                return InkWell(
                  onTap: () => _showContactActionModal(context, contact),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getRoleIcon(contact.role), size: 14, color: _primaryGreen),
                        const SizedBox(width: 5),
                        Text(
                          contact.name,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLanguageFlag(contact.preferredLanguage),
                          style: const TextStyle(fontSize: 11),
                        ),
                        if (contact.whatsappConsent) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 13, color: _primaryGreen),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          if (contacts.isEmpty && readOnly)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'no_contacts_registered_yet'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: subText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
