import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// [R12] Potential Logistic Company lead form, opened automatically for company-employed
/// drivers from [AddDriverLeadScreen] (R11) or standalone.
class PotentialLogisticCompanyScreen extends StatefulWidget {
  final int? driverLeadId;
  final double? initialLat;
  final double? initialLng;

  const PotentialLogisticCompanyScreen({
    super.key,
    this.driverLeadId,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<PotentialLogisticCompanyScreen> createState() =>
      _PotentialLogisticCompanyScreenState();
}

class _PotentialLogisticCompanyScreenState
    extends State<PotentialLogisticCompanyScreen> {
  static const Color _brandGreen = Color(0xFF30913F);

  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _phonesCtrl = TextEditingController();
  final TextEditingController _personNameCtrl = TextEditingController();
  final TextEditingController _personRoleCtrl = TextEditingController();
  final TextEditingController _fleetSizeCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  double? _lat;
  double? _lng;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _resolveAutoLocation();
  }

  Future<void> _resolveAutoLocation() async {
    if (_lat != null && _lng != null) return;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null && mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _phonesCtrl.dispose();
    _personNameCtrl.dispose();
    _personRoleCtrl.dispose();
    _fleetSizeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final companyName = _companyNameCtrl.text.trim();
    if (companyName.isEmpty) {
      showCustomSnackBar('logistic_company_name_required'.tr, isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final res = await Get.find<ApiClient>().postData(
        AppConstants.marketerLogisticCompaniesUri,
        {
          'company_name': companyName,
          'contact_phones': _phonesCtrl.text.trim(),
          'contact_person_name': _personNameCtrl.text.trim(),
          'contact_person_role': _personRoleCtrl.text.trim(),
          if (_fleetSizeCtrl.text.trim().isNotEmpty)
            'estimated_fleet_size': int.tryParse(_fleetSizeCtrl.text.trim()),
          if (_addressCtrl.text.trim().isNotEmpty)
            'meeting_address': _addressCtrl.text.trim(),
          if (_lat != null) 'latitude': _lat,
          if (_lng != null) 'longitude': _lng,
          if (widget.driverLeadId != null) 'driver_lead_id': widget.driverLeadId,
        },
        handleError: false,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        showCustomSnackBar('logistic_company_saved_success'.tr, isError: false);
        Get.back(result: true);
      } else {
        showCustomSnackBar('logistic_company_save_failed'.tr, isError: true);
      }
    } catch (_) {
      showCustomSnackBar('logistic_company_save_failed'.tr, isError: true);
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
          'potential_logistic_company_title'.tr,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field('logistic_company_name_label'.tr, _companyNameCtrl, 'logistic_company_name_hint'.tr, inputFill, borderColor, textDark, textSub),
                const SizedBox(height: 12),
                _field('logistic_phones_label'.tr, _phonesCtrl, 'logistic_phones_hint'.tr, inputFill, borderColor, textDark, textSub),
                const SizedBox(height: 12),
                _field('logistic_person_name_label'.tr, _personNameCtrl, 'logistic_person_name_hint'.tr, inputFill, borderColor, textDark, textSub),
                const SizedBox(height: 12),
                _field('logistic_person_role_label'.tr, _personRoleCtrl, 'logistic_person_role_hint'.tr, inputFill, borderColor, textDark, textSub),
                const SizedBox(height: 12),
                _field('logistic_fleet_size_label'.tr, _fleetSizeCtrl, 'logistic_fleet_size_hint'.tr, inputFill, borderColor, textDark, textSub, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _field('logistic_meeting_address_label'.tr, _addressCtrl, 'logistic_meeting_address_hint'.tr, inputFill, borderColor, textDark, textSub),
                if (_lat != null && _lng != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF143326) : const Color(0xFFE9F5EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location_outlined, size: 16, color: _brandGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${'logistic_auto_location_label'.tr}: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF4ADE80) : _brandGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
                      'logistic_submit_btn'.tr,
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
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    Color inputFill,
    Color borderColor,
    Color textDark,
    Color textSub, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: textDark),
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
            controller: ctrl,
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
