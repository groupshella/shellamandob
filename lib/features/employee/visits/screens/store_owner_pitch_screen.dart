import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/store_visit_model.dart';
import '../models/zone_store_demand_model.dart';
import 'contract_signing_screen.dart';

/// Owner Pitch Screen ("العرض التقديمي للمالك") — Figma 9975:9644:
/// - Full-screen green gradient including status bar (#0E5727) — NO white bar at top
/// - Non-scrolling single-viewport layout (Map expands cleanly to fit remaining height)
class StoreOwnerPitchScreen extends StatefulWidget {
  final ZoneStoreDemandModel store;

  const StoreOwnerPitchScreen({super.key, required this.store});

  @override
  State<StoreOwnerPitchScreen> createState() => _StoreOwnerPitchScreenState();
}

class _StoreOwnerPitchScreenState extends State<StoreOwnerPitchScreen> {
  static const SystemUiOverlayStyle _pitchOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Color(0xFF0E5727),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_pitchOverlayStyle);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final hasCoords = store.latitude != null && store.longitude != null;
    final storeLatLng = LatLng(
      store.latitude ?? 24.7136,
      store.longitude ?? 46.6753,
    );

    final heroCount = store.nearbyCustomers2km > 0
        ? store.nearbyCustomers2km
        : store.waitingCustomersCount;

    final lang = Get.locale?.languageCode ?? 'ar';
    final nowTimeText = DateFormat('hh:mm a', lang).format(DateTime.now());

    final Set<Circle> circles = {
      Circle(
        circleId: const CircleId('radius_2km'),
        center: storeLatLng,
        radius: 2000,
        fillColor: const Color(0xFF30913F).withValues(alpha: 0.14),
        strokeColor: const Color(0xFF30913F).withValues(alpha: 0.7),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('radius_1km'),
        center: storeLatLng,
        radius: 1000,
        fillColor: const Color(0xFF16A34A).withValues(alpha: 0.25),
        strokeColor: const Color(0xFF15803D),
        strokeWidth: 2,
      ),
    };

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('target_store'),
        position: storeLatLng,
        infoWindow: InfoWindow(title: store.storeName),
      ),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _pitchOverlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E5727),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.85, -1.0),
              end: Alignment(0.85, 1.0),
              stops: [0.08, 0.31, 0.53, 0.92],
              colors: [
                Color(0xFF0E5727),
                Color(0xFF1F7433),
                Color(0xFF30913F),
                Color(0xFF35AF50),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative translucent white rings (Figma 9975:9853 & 9975:9855)
              Positioned(
                left: -109,
                top: -109,
                child: IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 34.4,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -95,
                bottom: 90,
                child: IgnorePointer(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 34.4,
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Compact Header Row: Back Arrow + Centered Store Pill
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            onPressed: () => Get.back(),
                            icon: SvgPicture.asset(
                              'assets/image/figma_pitch_back.svg',
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                height: 38,
                                padding: const EdgeInsetsDirectional.only(
                                    start: 6, end: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.18),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/image/figma_pitch_shop.svg',
                                        width: 17,
                                        height: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'special_offer_for_prefix'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        store.storeName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 2. Kicker + Headline
                      Text(
                        'pitch_ready_demand_subtitle'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC8F7D0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'pitch_hero_headline'.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 3. Big Hero Number Row (60px Black + vertical divider + description)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '$heroCount',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 58,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 0.8,
                            height: 38,
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'pitch_neighborhood_customers_desc'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.35,
                                  ),
                                ),
                                if (store.waitingCustomersCount > 0)
                                  Text(
                                    '${'pitch_of_them_prefix'.tr} ${store.waitingCustomersCount} ${'pitch_registered_via_staff_suffix'.tr}',
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFC8F7D0),
                                      height: 1.3,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 4. Journey Subtitle
                      Text(
                        'pitch_journey_subtitle'.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.82),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 5. Two Glass Stat Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassMetricCard(
                              svgAsset: 'assets/image/figma_pitch_profile.svg',
                              value: '${store.waitingCustomersCount}',
                              label: 'waiting_customers_short'.tr,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGlassMetricCard(
                              svgAsset:
                                  'assets/image/figma_pitch_profile_2user.svg',
                              value: '${store.storeMarketersCount}',
                              label: 'store_marketers_short'.tr,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 6. Live Pulse Dot + Last Update + Disclaimer
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8BF39B),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8BF39B)
                                      .withValues(alpha: 0.25),
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${'last_updated_today_prefix'.tr}، $nowTimeText',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 9.5,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'pitch_disclaimer_note'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 8.5,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 7. Expanded Neighborhood Map (fills exact remaining space — ZERO scroll!)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'neighborhood_map_title'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildLegendPill(
                                          '1 ${'distance_km'.tr}: ${store.nearbyCustomers1km}'),
                                      const SizedBox(width: 6),
                                      _buildLegendPill(
                                          '2 ${'distance_km'.tr}: ${store.nearbyCustomers2km}'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: hasCoords
                                      ? GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: storeLatLng,
                                            zoom: 13.0,
                                          ),
                                          circles: circles,
                                          markers: markers,
                                          myLocationButtonEnabled: false,
                                          zoomControlsEnabled: false,
                                          mapToolbarEnabled: false,
                                        )
                                      : Container(
                                          color: Colors.white
                                              .withValues(alpha: 0.08),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'location_coordinates_unavailable'
                                                .tr,
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 8. White Primary CTA Button ("ابدأ التعاقد الآن")
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final visitForContract = StoreVisitModel(
                              id: (store.visitId ?? store.id).toString(),
                              storeId: store.storeId,
                              storeName: store.storeName,
                              managerName: store.managerName,
                              phone: store.phone,
                              crNumber: store.crNumber,
                              address: store.address,
                              latitude: store.latitude,
                              longitude: store.longitude,
                              category: '',
                              timeSlot: '',
                              pipelineStep: StorePipelineStep.contractSigned,
                              visitStatus: StoreVisitStatus.inProgress,
                            );
                            Get.to(() => ContractSigningScreen(
                                visit: visitForContract));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF237D2D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'start_contract_now_btn'.tr,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF237D2D),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMetricCard({
    required String svgAsset,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
