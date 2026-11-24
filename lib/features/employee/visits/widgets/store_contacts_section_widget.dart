import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  String _getLanguageCodeBadge(String lang) {
    switch (lang.toLowerCase()) {
      case 'ar':
        return 'AR';
      case 'en':
        return 'EN';
      case 'ur':
        return 'UR';
      case 'bn':
        return 'BN';
      case 'tl':
        return 'TL';
      default:
        return lang.toUpperCase();
    }
  }

  Widget _buildLangBadgeChip(String langCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252B37) : const Color(0xFFF0FAF2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getLanguageCodeBadge(langCode),
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF4ADE80) : _primaryGreen,
        ),
      ),
    );
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
                            _buildLangBadgeChip(contact.preferredLanguage),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _makePhoneCall(contact.phone);
                      },
                      icon: const Icon(Icons.phone_outlined, size: 18, color: _primaryGreen),
                      label: Text(
                        'call_phone_action'.tr,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: _primaryGreen),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openWhatsApp(contact.phone);
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                      label: Text(
                        'whatsapp_action'.tr,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Figma Node 9716-48376: إضافة جهة اتصال بالمتجر
  void _showAddContactModal(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    String selectedRole = 'owner';
    String selectedLang = 'ar';
    bool consent = true;

    // Figma Roles: المالك, شريك, مدير فرع, كاشير, عامل
    final roles = [
      {'key': 'owner', 'label': 'role_owner'.tr},
      {'key': 'partner', 'label': 'role_partner'.tr},
      {'key': 'manager', 'label': 'role_branch_manager'.tr},
      {'key': 'cashier', 'label': 'role_cashier'.tr},
      {'key': 'worker', 'label': 'role_worker'.tr},
    ];

    // Languages with vector code badges (no emoji flags)
    final languages = [
      {'key': 'ar', 'label': 'العربية', 'code': 'AR'},
      {'key': 'en', 'label': 'English', 'code': 'EN'},
      {'key': 'ur', 'label': 'اردو (Urdu)', 'code': 'UR'},
      {'key': 'tl', 'label': 'Tagalog', 'code': 'TL'},
      {'key': 'bn', 'label': 'বাংলা (Bengali)', 'code': 'BN'},
    ];

    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final darkText = isDark ? Colors.white : const Color(0xFF111827);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);
    final inputFill = isDark ? const Color(0xFF252B37) : const Color(0xFFF8F9FA);
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Sheet Title
                    Text(
                      'add_store_contact_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. الدور في المتجر
                    Text(
                      'role_in_store'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: roles.map((r) {
                          final isSelected = selectedRole == r['key'];
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onTap: () => setStateModal(() => selectedRole = r['key'] as String),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF163E20) : const Color(0xFFEBFDF2))
                                      : (isDark ? const Color(0xFF252B37) : Colors.white),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? _primaryGreen : borderColor,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  r['label'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? _primaryGreen : darkText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. الاسم الكامل
                    Text(
                      'person_full_name'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: darkText),
                      decoration: InputDecoration(
                        hintText: 'name_example_hint'.tr,
                        hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: subText),
                        filled: true,
                        fillColor: inputFill,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. رقم الواتساب للتواصل والتدريب (+966 with WhatsApp Icon)
                    Text(
                      'whatsapp_number_label'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: darkText),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '+966',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                                ),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '12 234 5678',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: subText),
                          filled: true,
                          fillColor: inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4. اللغة المفضلة للتدريب والمراسلة
                    Text(
                      'preferred_training_language'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: languages.map((lang) {
                        final isSelected = selectedLang == lang['key'];
                        return InkWell(
                          onTap: () => setStateModal(() => selectedLang = lang['key']!),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF163E20) : const Color(0xFFEBFDF2))
                                  : (isDark ? const Color(0xFF252B37) : Colors.white),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? _primaryGreen : borderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  lang['label']!,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? _primaryGreen : darkText,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildLangBadgeChip(lang['code']!),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 5. بطاقة الموافقة على استلام رسائل الواتساب
                    InkWell(
                      onTap: () => setStateModal(() => consent = !consent),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF163E20).withValues(alpha: 0.35) : const Color(0xFFEBFDF2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: consent ? _primaryGreen.withValues(alpha: 0.5) : borderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: consent ? _primaryGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: consent ? _primaryGreen : const Color(0xFF9CA3AF),
                                  width: 1.5,
                                ),
                              ),
                              child: consent
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'whatsapp_consent_declaration'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'whatsapp_consent_desc'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 11.5,
                                      color: subText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 6. زر حفظ جهة الاتصال
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'save_store_contact_btn'.tr,
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
    final contacts = controller.storeContacts;
    final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
    final darkText = isDark ? Colors.white : const Color(0xFF111B18);
    final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final pillBg = isDark ? const Color(0xFF252B37) : const Color(0xFFF6F5F8);

    // Figma 9694:35150: Compact white card with title inside + إضافة شخص pill button
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'store_contacts_and_training'.tr,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            if (!readOnly) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showAddContactModal(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 39,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? borderColor : const Color(0xFFF6F5F8),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/image/figma_visit_summary/profile_add.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(darkText, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'add_person_btn'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (contacts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(color: borderColor, height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contacts.length,
                separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
                itemBuilder: (ctx, index) {
                  final c = contacts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getRoleIcon(c.role), color: _primaryGreen, size: 19),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildLangBadgeChip(c.preferredLanguage),
                      ],
                    ),
                    subtitle: Text(
                      '${'role_${c.role}'.tr} • ${c.phone}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: subText,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert, size: 20, color: subText),
                      onPressed: () => _showContactActionModal(context, c),
                    ),
                    onTap: () => _showContactActionModal(context, c),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
