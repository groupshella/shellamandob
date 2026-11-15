import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../common/controllers/theme_controller.dart';
import '../controllers/store_visits_controller.dart';
import '../models/marketer_lead_model.dart';
import 'active_store_visit_screen.dart';

enum _LeadsViewMode { map, list }

/// Self-serve "قاعدة المحلات" browser: shows the real, unclaimed stores
/// inside the marketer's own locked zone -- on a map by default, like the
/// zone-picker map, with a list view available too -- and lets them claim
/// one to start a visit immediately. Claiming is atomic on the backend, so
/// if another marketer in the same zone claims the store first, this screen
/// surfaces that as a clear notice instead of a silent failure.
class AvailableStoresScreen extends StatefulWidget {
  const AvailableStoresScreen({super.key});

  @override
  State<AvailableStoresScreen> createState() => _AvailableStoresScreenState();
}

class _AvailableStoresScreenState extends State<AvailableStoresScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const LatLng _defaultRiyadhCenter = LatLng(24.7136, 46.6753);

  _LeadsViewMode _viewMode = _LeadsViewMode.map;
  GoogleMapController? _mapController;
  MarketerLeadModel? _selectedLead;
  bool _didFitBounds = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<StoreVisitsController>().loadAvailableLeads();
      _maybeFitBounds();
    });
  }

  LatLng _leadLatLng(MarketerLeadModel lead) {
    if (lead.latitude != null && lead.longitude != null) {
      return LatLng(lead.latitude!, lead.longitude!);
    }
    return _defaultRiyadhCenter;
  }

  void _maybeFitBounds() {
    if (_didFitBounds || _mapController == null) return;
    final leads = Get.find<StoreVisitsController>().availableLeads;
    if (leads.isEmpty) return;
    _didFitBounds = true;

    double? minLat, maxLat, minLng, maxLng;
    for (final l in leads) {
      final pos = _leadLatLng(l);
      minLat = (minLat == null || pos.latitude < minLat) ? pos.latitude : minLat;
      maxLat = (maxLat == null || pos.latitude > maxLat) ? pos.latitude : maxLat;
      minLng = (minLng == null || pos.longitude < minLng) ? pos.longitude : minLng;
      maxLng = (maxLng == null || pos.longitude > maxLng) ? pos.longitude : maxLng;
    }
    if (minLat == null || maxLat == null || minLng == null || maxLng == null) return;

    Future.delayed(const Duration(milliseconds: 250), () {
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat!, minLng!), northeast: LatLng(maxLat!, maxLng!)),
        60,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : const Color(0xFFF8F9FA);
        final cardBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? IconlyLight.arrowRight2
                    : IconlyLight.arrowLeft2,
                color: darkText,
                size: 22,
              ),
            ),
            title: Text(
              'available_stores_in_zone'.tr,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w700, color: darkText),
            ),
            backgroundColor: cardBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            actions: [
              _buildViewToggle(cardBg: cardBg, darkText: darkText, subText: subText, borderColor: borderColor),
              IconButton(
                onPressed: () => Get.find<StoreVisitsController>().loadAvailableLeads(),
                icon: Icon(Icons.refresh_rounded, color: subText),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            top: false,
            child: GetBuilder<StoreVisitsController>(
              builder: (controller) {
                final leads = controller.availableLeads;

                if (controller.isLoadingLeads && leads.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: _primaryGreen));
                }
                if (leads.isEmpty) {
                  return RefreshIndicator(
                    color: _primaryGreen,
                    onRefresh: () => controller.loadAvailableLeads(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Text(
                            'no_available_stores'.tr,
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: subText),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFitBounds());

                return _viewMode == _LeadsViewMode.map
                    ? _buildMapView(
                        leads: leads,
                        controller: controller,
                        isDark: isDark,
                        cardBg: cardBg,
                        darkText: darkText,
                        subText: subText,
                        borderColor: borderColor,
                        themeCtrl: themeCtrl,
                      )
                    : _buildListView(
                        leads: leads,
                        controller: controller,
                        isDark: isDark,
                        cardBg: cardBg,
                        darkText: darkText,
                        subText: subText,
                        borderColor: borderColor,
                      );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggle({
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(IconlyBold.location, _LeadsViewMode.map, darkText, subText),
          _toggleBtn(Icons.view_list_rounded, _LeadsViewMode.list, darkText, subText),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, _LeadsViewMode mode, Color darkText, Color subText) {
    final isActive = _viewMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? _primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: isActive ? Colors.white : subText),
      ),
    );
  }

  Widget _buildMapView({
    required List<MarketerLeadModel> leads,
    required StoreVisitsController controller,
    required bool isDark,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
    required ThemeController themeCtrl,
  }) {
    final markers = <Marker>{
      for (final lead in leads)
        Marker(
          markerId: MarkerId('lead_${lead.id}'),
          position: _leadLatLng(lead),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _selectedLead?.id == lead.id ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          onTap: () => setState(() => _selectedLead = lead),
        ),
    };

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _leadLatLng(leads.first), zoom: 13),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          style: isDark ? themeCtrl.darkMap : themeCtrl.lightMap,
          onMapCreated: (c) {
            _mapController = c;
            _maybeFitBounds();
          },
          onTap: (_) => setState(() => _selectedLead = null),
        ),
        Positioned(
          top: 10,
          right: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Text(
              'available_stores_count'.trParams({'count': '${leads.length}'}),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: darkText),
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: _selectedLead != null ? 150 : 20,
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: IconButton(
              icon: Icon(Icons.my_location_rounded, color: darkText, size: 20),
              tooltip: 'my_current_location'.tr,
              onPressed: () async {
                try {
                  final pos = await Geolocator.getCurrentPosition(
                    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 8)),
                  );
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15));
                } catch (_) {}
              },
            ),
          ),
        ),
        if (_selectedLead != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildLeadDetailSheet(
              lead: _selectedLead!,
              controller: controller,
              isDark: isDark,
              cardBg: cardBg,
              darkText: darkText,
              subText: subText,
              borderColor: borderColor,
            ),
          ),
      ],
    );
  }

  Widget _buildLeadDetailSheet({
    required MarketerLeadModel lead,
    required StoreVisitsController controller,
    required bool isDark,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
  }) {
    final isClaiming = controller.claimingLeadId == lead.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: borderColor) : null,
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(IconlyBold.location, color: _primaryGreen, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lead.neighborhood?.isNotEmpty == true ? lead.neighborhood! : lead.address,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: isClaiming ? null : () => _onClaimPressed(lead, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isClaiming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(
                      'claim_store_action'.tr,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView({
    required List<MarketerLeadModel> leads,
    required StoreVisitsController controller,
    required bool isDark,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
  }) {
    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: () => controller.loadAvailableLeads(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'available_stores_count'.trParams({'count': '${leads.length}'}),
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: subText),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: leads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lead = leads[index];
                return _buildLeadCard(
                  lead: lead,
                  controller: controller,
                  cardBg: cardBg,
                  darkText: darkText,
                  subText: subText,
                  borderColor: borderColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard({
    required MarketerLeadModel lead,
    required StoreVisitsController controller,
    required Color cardBg,
    required Color darkText,
    required Color subText,
    required Color borderColor,
  }) {
    final isClaiming = controller.claimingLeadId == lead.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w700, color: darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(IconlyLight.location, size: 13, color: subText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lead.neighborhood?.isNotEmpty == true ? lead.neighborhood! : lead.address,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: subText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: isClaiming ? null : () => _onClaimPressed(lead, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isClaiming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(
                      'claim_store_action'.tr,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onClaimPressed(MarketerLeadModel lead, StoreVisitsController controller) async {
    if (!controller.canStartVisit(showWarning: true)) return;

    final visit = await controller.claimLead(lead);
    if (visit == null) {
      if (mounted) setState(() => _selectedLead = null);
      return;
    }

    final started = await controller.startVisit(visit);
    if (started && mounted) {
      Get.off(() => ActiveStoreVisitScreen(visit: visit));
    }
  }
}
