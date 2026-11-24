import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'potential_logistic_company_screen.dart';

/// [R11] Driver registration with ownership, work nature, classification & vehicle type.
/// Routes company-employed drivers directly into [PotentialLogisticCompanyScreen] (R12).
class AddDriverLeadScreen extends StatefulWidget {
  const AddDriverLeadScreen({super.key});

  @override
  State<AddDriverLeadScreen> createState() => _AddDriverLeadScreenState();
}

class _AddDriverLeadScreenState extends State<AddDriverLeadScreen> {
  static const Color _brandGreen = Color(0xFF30913F);

  String _vehicleOwnership = 'personal';
  String _workNature = 'self_employed';
  String _classification = 'independent';
  String _vehicleType = 'motorcycle';
  final String _preferredLanguage = 'ar';
  bool _whatsappConsent = true;
  bool _submitting = false;
  bool _loadingHistory = false;
  int _totalDrivers = 0;
  int _todayDrivers = 0;
  List<Map<String, dynamic>> _myDrivers = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMyDrivers();
  }

  Future<void> _loadMyDrivers() async {
    setState(() => _loadingHistory = true);
    try {
      final res = await Get.find<ApiClient>().getData(
        AppConstants.marketerDriverLeadsUri,
        handleError: false,
      );
      if (res.statusCode == 200 && res.body is Map && res.body['data'] is Map) {
        final d = Map<String, dynamic>.from(res.body['data'] as Map);
        if (mounted) {
          setState(() {
            _totalDrivers = (d['total_drivers'] as num?)?.toInt() ?? 0;
            _todayDrivers = (d['today_drivers'] as num?)?.toInt() ?? 0;
            _myDrivers = (d['drivers'] as List? ?? [])
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      showCustomSnackBar('driver_name_phone_required'.tr, isError: true);
      return;
    }

    setState(() => _submitting = true);
    double? lat;
    double? lng;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      lat = pos?.latitude;
      lng = pos?.longitude;
    } catch (_) {}

    try {
      final res = await Get.find<ApiClient>().postData(
        AppConstants.marketerDriverLeadsUri,
        {
          'vehicle_ownership': _vehicleOwnership,
          'work_nature': _workNature,
          'driver_classification': _classification,
          'vehicle_type': _vehicleType,
          'name': name,
          'phone': phone,
          'preferred_language': _preferredLanguage,
          'whatsapp_consent': _whatsappConsent,
          if (lat != null) 'latitude': lat,
          if (lng != null) 'longitude': lng,
        },
        handleError: false,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.body is Map ? res.body['data'] : null;
        final int? driverId = data is Map ? (data['id'] as num?)?.toInt() : null;
        final bool openCompany = data is Map && data['should_open_company_form'] == true;

        showCustomSnackBar('driver_saved_success'.tr, isError: false);
        _nameController.clear();
        _phoneController.clear();
        await _loadMyDrivers();
        if (openCompany) {
          Get.off(
            () => PotentialLogisticCompanyScreen(
              driverLeadId: driverId,
              initialLat: lat,
              initialLng: lng,
            ),
          );
        }
      } else {
        showCustomSnackBar('driver_save_failed'.tr, isError: true);
      }
    } catch (_) {
      showCustomSnackBar('driver_save_failed'.tr, isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().darkTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final screenBg = isDark ? const Color(0xFF111827) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textDark = isDark ? Colors.white : const Color(0xFF111B18);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF555555);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E9E5);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Transform(
            alignment: Alignment.center,
            transform: isRtl ? Matrix4.identity() : Matrix4.rotationY(math.pi),
            child: SvgPicture.asset(
              'assets/image/figma_activation_arrow_right.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(textDark, BlendMode.srcIn),
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'add_driver_title'.tr,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Driver Counter Summary Banner
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF143326) : const Color(0xFFE9F5EB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF1F4D39) : const Color(0xFFC2E5C7),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'drivers_added_total'.tr,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: textSub),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_totalDrivers',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w800, color: _brandGreen),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: borderColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'drivers_added_today'.tr,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: textSub),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_todayDrivers',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w800, color: textDark),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _loadingHistory ? null : _loadMyDrivers,
                  icon: Icon(Icons.refresh_rounded, color: _brandGreen, size: 20),
                ),
              ],
            ),
          ),
          // 1. Driver Info Card (Figma 10049:76471)
          _sectionCard(
            cardBg: cardBg,
            borderColor: borderColor,
            children: [
              _questionTitle('driver_info_title'.tr, textDark),
              const SizedBox(height: 12),
              _inputField(
                label: 'driver_name_label'.tr,
                controller: _nameController,
                hint: 'driver_name_hint'.tr,
                inputFill: inputFill,
                borderColor: borderColor,
                textDark: textDark,
                textSub: textSub,
              ),
              const SizedBox(height: 12),
              _inputField(
                label: 'driver_phone_label'.tr,
                controller: _phoneController,
                hint: '05XXXXXXXX',
                keyboardType: TextInputType.phone,
                inputFill: inputFill,
                borderColor: borderColor,
                textDark: textDark,
                textSub: textSub,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Vehicle Info Card (Figma 10052:92397)
          _sectionCard(
            cardBg: cardBg,
            borderColor: borderColor,
            children: [
              _questionTitle('driver_vehicle_info_title'.tr, textDark),
              const SizedBox(height: 12),
              _questionTitle('driver_q_ownership'.tr, textDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _choicePill(
                      label: 'driver_ownership_personal'.tr,
                      selected: _vehicleOwnership == 'personal',
                      onTap: () => setState(() => _vehicleOwnership = 'personal'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _choicePill(
                      label: 'driver_ownership_rent'.tr,
                      selected: _vehicleOwnership == 'company' || _vehicleOwnership == 'rent',
                      onTap: () => setState(() => _vehicleOwnership = 'company'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _questionTitle('driver_q_work_nature'.tr, textDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _choicePill(
                      label: 'driver_work_full_time'.tr,
                      selected: _workNature == 'self_employed' || _workNature == 'full_time',
                      onTap: () => setState(() => _workNature = 'self_employed'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _choicePill(
                      label: 'driver_work_part_time'.tr,
                      selected: _workNature == 'company_employee' || _workNature == 'part_time',
                      onTap: () => setState(() {
                        _workNature = 'company_employee';
                        _classification = 'company_off_duty';
                      }),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _questionTitle('driver_classification_label'.tr, textDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _choicePill(
                      label: 'driver_class_light'.tr,
                      selected: _classification == 'independent' || _classification == 'light',
                      onTap: () => setState(() => _classification = 'independent'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _choicePill(
                      label: 'driver_class_medium'.tr,
                      selected: _classification == 'company_off_duty' || _classification == 'medium',
                      onTap: () => setState(() => _classification = 'company_off_duty'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _choicePill(
                      label: 'driver_class_heavy'.tr,
                      selected: _classification == 'marketer_only' || _classification == 'heavy',
                      onTap: () => setState(() => _classification = 'marketer_only'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _questionTitle('driver_vehicle_type_label'.tr, textDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _choicePill(
                      label: 'vehicle_sedan'.tr,
                      selected: _vehicleType == 'car' || _vehicleType == 'sedan',
                      onTap: () => setState(() => _vehicleType = 'car'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _choicePill(
                      label: 'vehicle_motorcycle'.tr,
                      selected: _vehicleType == 'motorcycle',
                      onTap: () => setState(() => _vehicleType = 'motorcycle'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _choicePill(
                      label: 'vehicle_van'.tr,
                      selected: _vehicleType == 'bicycle' || _vehicleType == 'van',
                      onTap: () => setState(() => _vehicleType = 'bicycle'),
                      isDark: isDark,
                      textDark: textDark,
                      borderColor: borderColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. WhatsApp Consent Card (Figma 10049:76471)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF6F5F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: InkWell(
              onTap: () => setState(() => _whatsappConsent = !_whatsappConsent),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  SvgPicture.asset(
                    _whatsappConsent
                        ? 'assets/image/figma_freelance_marketer/checkbox_on.svg'
                        : 'assets/image/figma_freelance_marketer/checkbox_off.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'driver_whatsapp_consent_label'.tr,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      (_workNature == 'company_employee' || _classification == 'company_off_duty')
                          ? 'driver_save_and_next_company'.tr
                          : 'driver_save_btn'.tr,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          if (_myDrivers.isNotEmpty || _loadingHistory) ...[
            Text(
              '${'my_added_drivers_title'.tr} ($_totalDrivers)',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: textDark),
            ),
            const SizedBox(height: 10),
            if (_loadingHistory)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: _brandGreen)))
            else
              ..._myDrivers.map((d) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (d['name'] ?? '').toString(),
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (d['phone'] ?? '').toString(),
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: textSub),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF143326) : const Color(0xFFE9F5EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'driver_status_${d['status'] ?? 'new'}'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _brandGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required Color cardBg,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _questionTitle(String text, Color textDark) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
    );
  }

  Widget _choicePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
    required Color textDark,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? const Color(0xFF143326) : const Color(0xFFE9F5EB))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _brandGreen : borderColor,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? (isDark ? const Color(0xFF4ADE80) : _brandGreen) : textDark,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Color inputFill,
    required Color borderColor,
    required Color textDark,
    required Color textSub,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: textSub),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
