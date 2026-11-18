import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../models/store_visit_model.dart';
import '../models/marketer_lead_model.dart';
import '../models/store_contact_model.dart';
import '../models/merchant_promo_model.dart';
import '../models/not_closing_reason.dart';
import '../domain/models/contract_activation_model.dart';
import '../../controllers/employee_shift_controller.dart';
import '../../models/employee_shift_model.dart';
import '../../alerts/controllers/anti_fraud_alerts_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class StoreVisitsController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Daily target constants
  static const int dailyTargetVisits = 16;
  static const int baseMaxVisitMinutes = 30;
  static const int autoExtensionMinutes = 30;

  int _extensionMinutes = 0;
  int get extensionMinutes => _extensionMinutes;

  bool _isAutoExtended = false;
  bool get isAutoExtended => _isAutoExtended;

  int get maxVisitMinutes => baseMaxVisitMinutes + _extensionMinutes;

  // Active filter tab: 0 = الكل, 1 = مجدول, 2 = مكتمل, 3 = متابعة
  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  // Active visit state
  StoreVisitModel? _activeVisit;
  StoreVisitModel? get activeVisit => _activeVisit;

  Timer? _visitTimer;
  int _elapsedVisitSeconds = 0;
  int get elapsedVisitSeconds => _elapsedVisitSeconds;
  int get remainingVisitSeconds => (maxVisitMinutes * 60) - _elapsedVisitSeconds;
  int get remainingMinutes => ((maxVisitMinutes * 60 - _elapsedVisitSeconds) / 60).clamp(0, maxVisitMinutes).ceil();
  double get progressPercent => (_elapsedVisitSeconds / (maxVisitMinutes * 60)).clamp(0.0, 1.0);

  // Inactivity tracking (10-minute threshold)
  int _inactivitySeconds = 0;
  int get inactivitySeconds => _inactivitySeconds;
  static const int inactivityThresholdSeconds = 600; // 10 minutes

  // Inactivity Alert logs matching Figma
  final List<Map<String, dynamic>> _alertHistory = [];
  List<Map<String, dynamic>> get alertHistory => _alertHistory;

  bool isAlertsLogExpanded = false;
  void toggleAlertsLog() {
    isAlertsLogExpanded = !isAlertsLogExpanded;
    update();
  }

  void addAlertLog({required String title, required String time, required int level}) {
    _alertHistory.add({
      'title': title,
      'time': time,
      'level': level,
    });
    update();
  }

  // Form state for active visit
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController openingsController = TextEditingController(text: '1');
  final TextEditingController crNumberController = TextEditingController();
  final TextEditingController nextAppointmentController = TextEditingController();
  final TextEditingController commitmentsController = TextEditingController();
  final TextEditingController obstaclesController = TextEditingController();
  final TextEditingController otherReasonController = TextEditingController();
  final TextEditingController confidentialNotesController = TextEditingController();

  // R02: Decision Maker fields ('العامل موجود والمالك غائب')
  final TextEditingController decisionMakerNameController = TextEditingController();
  final TextEditingController decisionMakerPhoneController = TextEditingController();
  String? _selectedDecisionMakerBestTime;
  String? get selectedDecisionMakerBestTime => _selectedDecisionMakerBestTime;
  String? _selectedInterviewedPersonRole;
  String? get selectedInterviewedPersonRole => _selectedInterviewedPersonRole;

  void setDecisionMakerBestTime(String? time) {
    _selectedDecisionMakerBestTime = time;
    registerActivity();
    update();
  }

  void setInterviewedPersonRole(String? role) {
    _selectedInterviewedPersonRole = role;
    registerActivity();
    update();
  }

  // Dynamic conditional controllers
  final TextEditingController reasonNotMetController = TextEditingController();
  final TextEditingController reasonRejectedController = TextEditingController();
  final TextEditingController reasonDisqualifiedController = TextEditingController();
  final TextEditingController confidentialTitleController = TextEditingController();

  StorePipelineStep _selectedPipelineStep = StorePipelineStep.notMet;
  StorePipelineStep get selectedPipelineStep => _selectedPipelineStep;

  String _selectedInterestStatus = 'very_interested';
  String get selectedInterestStatus => _selectedInterestStatus;

  void setInterestStatus(String status) {
    _selectedInterestStatus = status;
    registerActivity();
    update();
  }

  NotClosingReason? _selectedNotClosingReason;
  NotClosingReason? get selectedNotClosingReason => _selectedNotClosingReason;

  void setSelectedNotClosingReason(NotClosingReason reason) {
    _selectedNotClosingReason = reason;
    _selectedClosingReason = reason.key;
    _selectedObstacle = reason.label;
    if (reason == NotClosingReason.other) {
      obstaclesController.text = otherReasonController.text;
    } else {
      obstaclesController.text = reason.label;
    }
    registerActivity();
    update();
  }

  static const List<String> predefinedObstacles = [
    'يحتاج وقت للتفكير',
    'طلب عرض مختلف',
    'بانتظار موافقة المالك',
    'يحتاج تفاصيل إضافية',
    'غير متأكد من الخدمة',
    'مشغول حالياً',
    'المحل مغلق',
    'المحل غير موجود',
    'سبب آخر',
  ];

  String? _selectedObstacle;
  String? get selectedObstacle => _selectedObstacle;

  void setSelectedObstacle(String? obstacle) {
    _selectedObstacle = obstacle;
    if (obstacle != null) {
      final matched = NotClosingReason.fromKey(obstacle);
      _selectedNotClosingReason = matched;
      _selectedClosingReason = matched.key;
      if (matched == NotClosingReason.other || obstacle == 'سبب آخر') {
        obstaclesController.text = otherReasonController.text;
      } else {
        obstaclesController.text = matched.label;
      }
    } else {
      _selectedNotClosingReason = null;
      _selectedClosingReason = null;
      obstaclesController.clear();
    }
    registerActivity();
    update();
  }

  void setOtherReason(String text) {
    otherReasonController.text = text;
    if (_selectedNotClosingReason == NotClosingReason.other || _selectedObstacle == 'سبب آخر') {
      obstaclesController.text = text;
    }
    registerActivity();
    update();
  }

  String? _selectedClosingReason;
  String? get selectedClosingReason => _selectedClosingReason;

  void setClosingReason(String? reason) {
    if (reason == null) {
      _selectedClosingReason = null;
      _selectedNotClosingReason = null;
    } else {
      final matched = NotClosingReason.fromKey(reason);
      _selectedNotClosingReason = matched;
      _selectedClosingReason = matched.key;
    }
    registerActivity();
    update();
  }

  DateTime? _selectedFollowUpDate;
  DateTime? get selectedFollowUpDate => _selectedFollowUpDate;

  TimeOfDay? _selectedFollowUpTime;
  TimeOfDay? get selectedFollowUpTime => _selectedFollowUpTime;

  String? _frontImagePath;
  String? get frontImagePath => _frontImagePath;

  DateTime? _frontPhotoCapturedTime;
  DateTime? get frontPhotoCapturedTime => _frontPhotoCapturedTime;

  String? _insideImagePath;
  String? get insideImagePath => _insideImagePath;

  DateTime? _insidePhotoCapturedTime;
  DateTime? get insidePhotoCapturedTime => _insidePhotoCapturedTime;

  bool _isConfidentialReportExpanded = false;
  bool get isConfidentialReportExpanded => _isConfidentialReportExpanded;

  bool isLoading = false;

  String get zoneName => 'غرب الرياض';

  // Visits lists (Real database data only)
  final List<StoreVisitModel> _allVisits = [];
  List<StoreVisitModel> get allVisits => _allVisits;

  // Visits assigned via a generated "مسار" (route_id + route_sequence) are
  // grouped together and ordered by their intended visiting sequence, so the
  // marketer walks the route in the geographically-sensible order the admin
  // generated -- instead of the default server (id) order, which can jumble
  // route stops with unrelated manually-scheduled visits.
  List<StoreVisitModel> get sortedVisits {
    final routed = _allVisits.where((v) => v.routeId != null).toList()
      ..sort((a, b) {
        final routeCompare = a.routeId!.compareTo(b.routeId!);
        if (routeCompare != 0) return routeCompare;
        return (a.routeSequence ?? 0).compareTo(b.routeSequence ?? 0);
      });
    final unrouted = _allVisits.where((v) => v.routeId == null).toList();
    return [...routed, ...unrouted];
  }

  // Straight-line distance between two consecutive route stops, for display
  // only (the real driving route is shown on the full map screen).
  double? distanceFromPreviousStopKm(StoreVisitModel visit, List<StoreVisitModel> displayList) {
    if (visit.routeId == null || visit.latitude == null || visit.longitude == null) return null;
    final index = displayList.indexWhere((v) => v.id == visit.id);
    if (index <= 0) return null;
    final previous = displayList[index - 1];
    if (previous.routeId != visit.routeId || previous.latitude == null || previous.longitude == null) return null;

    final meters = Geolocator.distanceBetween(
      previous.latitude!,
      previous.longitude!,
      visit.latitude!,
      visit.longitude!,
    );
    return meters / 1000.0;
  }

  // Commercial Register Verification State
  bool isVerifyingCr = false;
  Map<String, dynamic>? crVerificationResult;

  void clearCrVerification() {
    crVerificationResult = null;
    isVerifyingCr = false;
    update();
  }

  Future<bool> verifyCommercialRegister(String crNumber) async {
    final cleanCr = crNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanCr.length != 10) {
      crVerificationResult = {
        'is_valid': false,
        'is_already_registered': false,
        'message': 'رقم السجل التجاري يجب أن يتكون من 10 أرقام صحيحة',
      };
      update();
      return false;
    }

    isVerifyingCr = true;
    crVerificationResult = null;
    update();

    try {
      if (Get.isRegistered<ApiClient>()) {
        final response = await Get.find<ApiClient>().postData(
          '/api/v1/customer/marketer/verify-cr',
          {'cr_number': cleanCr},
        );
        if (response.statusCode == 200 && response.body != null) {
          crVerificationResult = Map<String, dynamic>.from(response.body);
          if (crVerificationResult?['is_already_registered'] == true) {
            crVerificationResult!['is_valid'] = false;
            showCustomSnackBar(
              crVerificationResult!['message'] ?? 'السجل التجاري مسجل بالفعل لمتجر آخر',
              isError: true,
              showDuration: 4,
            );
            return false;
          } else {
            showCustomSnackBar(
              crVerificationResult!['message'] ?? 'السجل التجاري صالح ومتحقق منه وجاهز للربط',
              isError: false,
              showDuration: 2,
            );
            return true;
          }
        } else {
          final msg = response.body?['message'] ?? 'السجل التجاري مسجل مسبقاً أو غير صالح';
          crVerificationResult = {
            'is_valid': false,
            'is_already_registered': response.body?['is_already_registered'] ?? true,
            'message': msg,
          };
          showCustomSnackBar(msg.toString(), isError: true, showDuration: 4);
          return false;
        }
      } else {
        crVerificationResult = {
          'is_valid': true,
          'is_already_registered': false,
          'message': 'السجل التجاري صالح ومتحقق منه وجاهز للربط',
        };
        return true;
      }
    } catch (e) {
      crVerificationResult = {
        'is_valid': false,
        'is_already_registered': false,
        'message': 'تعذر التحقق من السجل التجاري في الوقت الحالي',
      };
      showCustomSnackBar('cr_verification_failed_try_later'.tr, isError: true);
      return false;
    } finally {
      isVerifyingCr = false;
      update();
    }
  }

  // Standardized Enum for Not Closing Reason
  NotClosingReason _selectedReasonEnum = NotClosingReason.needsTime;
  NotClosingReason get selectedReasonEnum => _selectedReasonEnum;

  void setSelectedReasonEnum(NotClosingReason reason) {
    _selectedReasonEnum = reason;
    _selectedClosingReason = reason.key;
    registerActivity();
    update();
  }

  // Merchant Promo Library State
  List<MerchantPromoModel> merchantPromos = [];
  bool isLoadingPromos = false;
  final Set<int> activatedPromoIds = {};

  Future<void> loadMerchantPromos({bool reload = false}) async {
    if (!reload && merchantPromos.isNotEmpty) return;
    isLoadingPromos = true;
    update();

    try {
      if (Get.isRegistered<ApiClient>()) {
        final response = await Get.find<ApiClient>().getData(
          '/api/v1/customer/marketer/promos',
          useEtag: false,
          headers: {'X-No-ETag': '1', 'Cache-Control': 'no-cache'},
        );
        if (response.statusCode == 200 && response.body != null) {
          final data = response.body['data'];
          if (data is List) {
            merchantPromos = data.map((item) => MerchantPromoModel.fromJson(item)).toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load merchant promos from backend: $e');
    } finally {
      isLoadingPromos = false;
      update();
    }
  }

  Future<bool> activatePromoForStore({required int promoId, int? storeId, String? visitId}) async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        await Get.find<ApiClient>().postData('/api/v1/customer/marketer/promos/activate', {
          'promo_id': promoId,
          'store_id': storeId,
          'visit_id': visitId,
        });
      }
      activatedPromoIds.add(promoId);
      recordQaidhaActivatedReward();
      update();
      return true;
    } catch (_) {
      activatedPromoIds.add(promoId);
      recordQaidhaActivatedReward();
      update();
      return true;
    }
  }

  // Instant Reward Tracker State
  double contractSigningReward = 50.0;
  double qaidhaActivationReward = 30.0;
  double todayEarnings = 0.0;
  int todayContractsCount = 0;
  int todayQaidhaCount = 0;

  Future<void> loadRewardSettings() async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final response = await Get.find<ApiClient>().getData('/api/v1/customer/marketer/reward-settings');
        if (response.statusCode == 200 && response.body != null) {
          final body = response.body;
          contractSigningReward = (body['contract_signing_reward'] != null)
              ? double.tryParse(body['contract_signing_reward'].toString()) ?? 50.0
              : 50.0;
          qaidhaActivationReward = (body['qaidha_activation_reward'] != null)
              ? double.tryParse(body['qaidha_activation_reward'].toString()) ?? 30.0
              : 30.0;
          todayEarnings = (body['today_earnings'] != null)
              ? double.tryParse(body['today_earnings'].toString()) ?? 0.0
              : 0.0;
          todayContractsCount = (body['today_contracts_count'] != null)
              ? int.tryParse(body['today_contracts_count'].toString()) ?? 0
              : 0;
          todayQaidhaCount = (body['today_qaidha_count'] != null)
              ? int.tryParse(body['today_qaidha_count'].toString()) ?? 0
              : 0;
          update();
        }
      }
    } catch (_) {}
  }

  void recordContractSignedReward() {
    todayContractsCount++;
    todayEarnings += contractSigningReward;
    update();
  }

  void recordQaidhaActivatedReward() {
    todayQaidhaCount++;
    todayEarnings += qaidhaActivationReward;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadVisits();
    loadRewardSettings();
    loadMerchantPromos();
  }

  Future<void> loadVisits({bool notify = true}) async {
    isLoading = true;
    if (notify) update();
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData(
          AppConstants.marketerVisitsUri,
          useEtag: false,
          headers: {'X-No-ETag': '1', 'Cache-Control': 'no-cache'},
        );
        debugPrint('🔍 [StoreVisitsController] loadVisits status: ${res.statusCode}, hasBody: ${res.body != null}');
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          final list = res.body['data']['visits'];
          _allVisits.clear();
          if (list is List && list.isNotEmpty) {
            for (var item in list) {
              _allVisits.add(StoreVisitModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
          debugPrint('✅ [StoreVisitsController] Loaded ${_allVisits.length} visits successfully');
          isLoading = false;
          if (notify) update();
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadVisits error: $e');
    }
    isLoading = false;
    if (notify) update();
  }

  // Shared store pool for the marketer's own locked zone (قاعدة المحلات).
  List<MarketerLeadModel> availableLeads = [];
  bool isLoadingLeads = false;
  int? claimingLeadId;

  Future<void> loadAvailableLeads() async {
    isLoadingLeads = true;
    update();
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData(
          AppConstants.marketerLeadsUri,
          useEtag: false,
          headers: {'X-No-ETag': '1', 'Cache-Control': 'no-cache'},
        );
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          final list = res.body['data']['leads'];
          availableLeads = (list is List)
              ? list.map((item) => MarketerLeadModel.fromJson(Map<String, dynamic>.from(item))).toList()
              : [];
        } else {
          final msg = res.body?['message']?.toString();
          if (msg != null && msg.isNotEmpty) {
            showCustomSnackBar(msg, isError: true);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadAvailableLeads error: $e');
    } finally {
      isLoadingLeads = false;
      update();
    }
  }

  // Claims a shared-pool store for this marketer and opens today's visit for
  // it. If another marketer claimed it a moment earlier, the backend's
  // conditional update returns 409 and we surface that as a clear notice
  // instead of silently failing, then refresh the list so it drops out.
  Future<StoreVisitModel?> claimLead(MarketerLeadModel lead) async {
    claimingLeadId = lead.id;
    update();
    try {
      if (!Get.isRegistered<ApiClient>()) return null;

      final res = await Get.find<ApiClient>().postData(
        '${AppConstants.marketerLeadsUri}/${lead.id}/claim',
        {},
      );

      if (res.statusCode == 200 && res.body != null && res.body['data']?['visit'] != null) {
        final visit = StoreVisitModel.fromJson(Map<String, dynamic>.from(res.body['data']['visit']));
        final index = _allVisits.indexWhere((v) => v.id == visit.id);
        if (index != -1) {
          _allVisits[index] = visit;
        } else {
          _allVisits.add(visit);
        }
        availableLeads.removeWhere((l) => l.id == lead.id);
        showCustomSnackBar('store_claimed_success'.tr, isError: false);
        return visit;
      }

      if (res.statusCode == 409) {
        final msg = res.body?['message']?.toString() ?? 'store_already_claimed'.tr;
        showCustomSnackBar(msg, isError: true, showDuration: 4);
        availableLeads.removeWhere((l) => l.id == lead.id);
        return null;
      }

      final errorMsg = res.body?['message']?.toString() ?? 'store_already_claimed'.tr;
      showCustomSnackBar(errorMsg, isError: true, showDuration: 4);
      return null;
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] claimLead error: $e');
      showCustomSnackBar('server_connection_failed'.tr, isError: true);
      return null;
    } finally {
      claimingLeadId = null;
      update();
    }
  }

  @override
  void onClose() {
    _visitTimer?.cancel();
    storeNameController.dispose();
    managerNameController.dispose();
    phoneController.dispose();
    openingsController.dispose();
    crNumberController.dispose();
    nextAppointmentController.dispose();
    commitmentsController.dispose();
    obstaclesController.dispose();
    otherReasonController.dispose();
    confidentialNotesController.dispose();
    reasonNotMetController.dispose();
    reasonRejectedController.dispose();
    reasonDisqualifiedController.dispose();
    confidentialTitleController.dispose();
    super.onClose();
  }

  void selectFilterTab(int index) {
    _selectedFilterIndex = index;
    update();
  }

  List<StoreVisitModel> get filteredVisits {
    switch (_selectedFilterIndex) {
      case 1:
        return _allVisits.where((v) => v.visitStatus == StoreVisitStatus.scheduled).toList();
      case 2:
        return _allVisits.where((v) => v.visitStatus == StoreVisitStatus.completed).toList();
      case 3:
        return _allVisits.where((v) => v.visitStatus == StoreVisitStatus.followUp).toList();
      case 0:
      default:
        return _allVisits;
    }
  }

  int get scheduledCount => _allVisits.where((v) => v.visitStatus == StoreVisitStatus.scheduled).length;
  int get completedCount => _allVisits.where((v) => v.visitStatus == StoreVisitStatus.completed).length;
  int get followUpCount => _allVisits.where((v) => v.visitStatus == StoreVisitStatus.followUp).length;
  int get inProgressCount => _allVisits.where((v) => v.visitStatus == StoreVisitStatus.inProgress).length;

  int get completedVisitsCount => completedCount;
  int get qualifiedVisitsCount => _allVisits.where((v) => v.isQualifiedOutcome).length;
  int get followUpVisitsCount => followUpCount;
  int get scheduledVisitsCount => scheduledCount;
  int get totalVisitsCount => _allVisits.length;
  double get dailyProgressPercentage => (qualifiedVisitsCount / dailyTargetVisits).clamp(0.0, 1.0);

  void setFilterIndex(int index) {
    setFilterIndexTab(index);
  }

  void setFilterIndexTab(int index) {
    _selectedFilterIndex = index;
    update();
  }

  // Validation check before starting any visit
  /// Another visit that is currently in progress, if any.
  StoreVisitModel? openVisitOtherThan(String visitId) {
    if (_activeVisit != null &&
        _activeVisit!.id != visitId &&
        _activeVisit!.visitStatus == StoreVisitStatus.inProgress) {
      return _activeVisit;
    }
    for (final v in _allVisits) {
      if (v.id != visitId && v.visitStatus == StoreVisitStatus.inProgress) return v;
    }
    return null;
  }

  bool canStartVisit({bool showWarning = true}) {
    if (Get.isRegistered<EmployeeShiftController>()) {
      final shiftCtrl = Get.find<EmployeeShiftController>();
      if (shiftCtrl.status != ShiftStatus.active) {
        if (showWarning) {
          showCustomSnackBar(
            'يرجى تسجيل الحضور وبدء الدوام الرسمي أولاً من الشاشة الرئيسية لبدء الزيارات الميدانية.',
            isError: true,
            showDuration: 4,
          );
        }
        return false;
      }
    }
    return true;
  }

  /// Signboard photo captured to approve the store before the visit itself
  /// starts (distinct from [_frontImagePath], which the finish-visit flow
  /// reuses for its own storefront photo field).
  String? _storeApprovalPhotoPath;
  String? get storeApprovalPhotoPath => _storeApprovalPhotoPath;

  Future<void> captureStoreApprovalPhoto({bool fromGallery = false}) async {
    registerActivity();
    try {
      final XFile? photo = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        _storeApprovalPhotoPath = photo.path;
        update();
      }
    } catch (e) {
      debugPrint('Store approval photo capture error: $e');
      if (!fromGallery) {
        debugPrint('Falling back to gallery...');
        try {
          final XFile? photo = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
            maxWidth: 1600,
            maxHeight: 1600,
          );
          if (photo != null) {
            _storeApprovalPhotoPath = photo.path;
            update();
          }
        } catch (e2) {
          debugPrint('Gallery fallback error: $e2');
        }
      }
    }
  }

  void clearStoreApprovalPhoto() {
    _storeApprovalPhotoPath = null;
    update();
  }

  /// Current GPS fix used to approve the store, separate from the
  /// background location-ping stream the shift already runs.
  Future<Position?> captureStoreApprovalLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        showCustomSnackBar('location_permission_required_for_this_action'.tr, isError: true, showDuration: 4);
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
    } catch (e) {
      debugPrint('Store approval location error: $e');
      showCustomSnackBar('تعذر تحديد موقعك الحالي. يرجى تفعيل خدمة الموقع والمحاولة مرة أخرى.', isError: true, showDuration: 4);
      return null;
    }
  }

  // Start a store visit with exception handling & null safety guards.
  // isFreshStart visits must first be "approved" with a signboard photo
  // (storeApprovalPhotoPath) and a GPS fix (approvalPosition) -- the server
  // rejects a fresh start without both, so the caller must capture these via
  // captureStoreApprovalPhoto()/captureStoreApprovalLocation() first.
  Future<bool> startVisit(StoreVisitModel visit, {LatLng? approvalPosition}) async {
    if (!canStartVisit(showWarning: true)) {
      return false;
    }

    // One open visit at a time: resuming the same visit is fine, opening a
    // second one while another is still in progress is not (the backend
    // enforces this too and returns VISIT_ALREADY_OPEN).
    final StoreVisitModel? otherOpenVisit = openVisitOtherThan(visit.id);
    if (otherOpenVisit != null) {
      showCustomSnackBar(
        'visit_already_open_close_first'.trParams({'store': otherOpenVisit.storeName}),
        isError: true,
        showDuration: 4,
      );
      return false;
    }

    final isFreshStart = visit.startedAt == null;
    if (isFreshStart && (_storeApprovalPhotoPath == null || approvalPosition == null)) {
      showCustomSnackBar(
        'يجب تصوير لوحة المحل وتأكيد الموقع لاعتماده قبل بدء الزيارة.',
        isError: true,
        showDuration: 4,
      );
      return false;
    }

    try {
      final now = DateTime.now();
      final startedAt = visit.startedAt ?? now;

      _activeVisit = visit.copyWith(
        visitStatus: StoreVisitStatus.inProgress,
        startedAt: startedAt,
      );

      // Populate controllers safely
      storeNameController.text = visit.storeName;
      managerNameController.text = visit.managerName;
      phoneController.text = visit.phone;
      openingsController.text = visit.openingsCount.toString();
      crNumberController.text = visit.crNumber;
      _selectedPipelineStep = visit.pipelineStep;
      _frontImagePath = visit.frontImagePath;
      _insideImagePath = visit.insideImagePath;
      final initialObstacle = visit.obstaclesNotes;
      if (initialObstacle != null && initialObstacle.isNotEmpty) {
        if (predefinedObstacles.contains(initialObstacle)) {
          _selectedObstacle = initialObstacle;
          otherReasonController.clear();
        } else {
          _selectedObstacle = 'سبب آخر';
          otherReasonController.text = initialObstacle;
        }
        obstaclesController.text = initialObstacle;
      } else {
        _selectedObstacle = null;
        otherReasonController.clear();
        obstaclesController.clear();
      }
      _selectedClosingReason = visit.closingReason;
      reasonNotMetController.clear();
      reasonRejectedController.clear();
      reasonDisqualifiedController.clear();
      confidentialTitleController.clear();
      _selectedInterestStatus = 'interested';
      _frontPhotoCapturedTime = visit.frontImagePath != null ? DateTime.now() : null;
      _insidePhotoCapturedTime = visit.insideImagePath != null ? DateTime.now() : null;

      _isAutoExtended = visit.isExtended;
      _extensionMinutes = visit.extendedMinutes;

      final diff = now.difference(startedAt).inSeconds;
      _elapsedVisitSeconds = diff.clamp(0, maxVisitMinutes * 60);
      _inactivitySeconds = 0;

      // Update in all visits list immediately
      final index = _allVisits.indexWhere((v) => v.id == visit.id);
      if (index != -1) {
        _allVisits[index] = _activeVisit!;
      }

      _startVisitTimer();
      update();

      // Call backend API with safety check
      if (Get.isRegistered<ApiClient>()) {
        final res = isFreshStart
            ? await Get.find<ApiClient>().postMultipartData(
                '${AppConstants.marketerVisitsUri}/${visit.id}/start',
                {
                  'latitude': approvalPosition!.latitude.toString(),
                  'longitude': approvalPosition.longitude.toString(),
                },
                [MultipartBody('front_image', XFile(_storeApprovalPhotoPath!))],
              )
            : await Get.find<ApiClient>().postData(
                '${AppConstants.marketerVisitsUri}/${visit.id}/start',
                {},
              );
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          _storeApprovalPhotoPath = null;
          final visitData = res.body['data']['visit'];
          if (visitData != null && visitData['started_at'] != null) {
            final serverStartedAt = DateTime.tryParse(visitData['started_at'].toString());
            if (serverStartedAt != null && _activeVisit != null) {
              _activeVisit = _activeVisit!.copyWith(startedAt: serverStartedAt);
              final sDiff = DateTime.now().difference(serverStartedAt).inSeconds;
              _elapsedVisitSeconds = sDiff.clamp(0, maxVisitMinutes * 60);
              update();
            }
          }
          showCustomSnackBar(
            'تم بدء الزيارة بنجاح وتفعيل العداد والموقع',
            isError: false,
            showDuration: 2,
          );
          return true;
        } else {
          // Server error / rejection (e.g. shift not active)
          final errorMsg = res.body?['message'] ?? 'يجب تسجيل الحضور وبدء الدوام الرسمي أولاً قبل بدء أي زيارة ميدانية.';
          _visitTimer?.cancel();
          _activeVisit = null;
          // The visit was optimistically marked in progress above; undo that
          // so a rejected start (e.g. VISIT_ALREADY_OPEN) doesn't leave a
          // phantom open visit in the list.
          final rejectedIndex = _allVisits.indexWhere((v) => v.id == visit.id);
          if (rejectedIndex != -1) {
            _allVisits[rejectedIndex] = visit;
          }
          update();
          showCustomSnackBar(errorMsg.toString(), isError: true, showDuration: 4);
          return false;
        }
      }

      showCustomSnackBar(
        'تم بدء الزيارة بنجاح وتفعيل العداد والموقع',
        isError: false,
        showDuration: 2,
      );
      return true;
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] startVisit api error: $e');
      _visitTimer?.cancel();
      _activeVisit = null;
      update();
      showCustomSnackBar(
        'حدث خطأ غير متوقع أثناء بدء الزيارة. يرجى التأكد من تسجيل الدوام والمحاولة مرة أخرى.',
        isError: true,
        showDuration: 4,
      );
      return false;
    }
  }

  /// New field-discovery flow: the marketer types the store name and sets
  /// their own location (no pre-loaded candidate list), photographs the
  /// signboard, and the visit is created already started in one call. See
  /// AddFieldVisitScreen for the entry point.
  Future<StoreVisitModel?> createAndStartVisit({
    required String storeName,
    required LatLng position,
    String? address,
  }) async {
    if (!canStartVisit(showWarning: true)) return null;
    if (_storeApprovalPhotoPath == null) {
      showCustomSnackBar('يجب تصوير لوحة المحل لاعتماده قبل بدء الزيارة.', isError: true, showDuration: 4);
      return null;
    }

    try {
      final res = await Get.find<ApiClient>().postMultipartData(
        '${AppConstants.marketerVisitsUri}/store',
        {
          'store_name': storeName,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
          if (address != null && address.isNotEmpty) 'address': address,
        },
        [MultipartBody('front_image', XFile(_storeApprovalPhotoPath!))],
      );

      if (res.statusCode == 200 && res.body != null && res.body['data'] != null && res.body['data']['visit'] != null) {
        _storeApprovalPhotoPath = null;
        final visit = StoreVisitModel.fromJson(res.body['data']['visit']);
        _activeVisit = visit;
        _allVisits.add(visit);
        _elapsedVisitSeconds = 0;
        _inactivitySeconds = 0;
        storeNameController.text = visit.storeName;
        managerNameController.clear();
        phoneController.clear();
        openingsController.text = '1';
        crNumberController.clear();
        _selectedPipelineStep = visit.pipelineStep;
        _frontImagePath = visit.frontImagePath;
        _insideImagePath = null;
        _selectedObstacle = null;
        otherReasonController.clear();
        obstaclesController.clear();
        _selectedClosingReason = null;
        reasonNotMetController.clear();
        reasonRejectedController.clear();
        reasonDisqualifiedController.clear();
        confidentialTitleController.clear();
        _selectedInterestStatus = 'interested';
        _frontPhotoCapturedTime = DateTime.now();
        _insidePhotoCapturedTime = null;
        _isAutoExtended = false;
        _extensionMinutes = 0;
        _startVisitTimer();
        update();
        showCustomSnackBar('تم اعتماد المحل وبدء الزيارة بنجاح', isError: false, showDuration: 2);
        return visit;
      }

      final errorMsg = res.body?['message'] ?? 'تعذر اعتماد المحل، يرجى المحاولة مرة أخرى.';
      showCustomSnackBar(errorMsg.toString(), isError: true, showDuration: 4);
      return null;
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] createAndStartVisit error: $e');
      showCustomSnackBar('حدث خطأ غير متوقع أثناء اعتماد المحل. يرجى المحاولة مرة أخرى.', isError: true, showDuration: 4);
      return null;
    }
  }

  // Nearby candidate businesses list -- fetched for potential future use
  // (e.g. the admin-assigned-area suggestion flow); not currently wired
  // into any screen, since the marketer picks/types the store themselves
  // via AddFieldVisitScreen. See that screen for the actual entry point.
  List<Map<String, dynamic>> _nearbyLeads = [];
  List<Map<String, dynamic>> get nearbyLeads => _nearbyLeads;

  bool _isLoadingLeads = false;
  bool get isLoadingNearbyLeads => _isLoadingLeads;

  // The chain anchor: once the rep picks a store to visit, every following
  // suggestion is measured from THAT store instead of live GPS, so the
  // route walks naturally from one nearby place to the next rather than
  // jumping back to wherever the rep is physically standing. Resets to
  // live GPS at the start of a fresh day/shift (controller is recreated).
  double? _chainLat;
  double? _chainLng;

  /// Resolves the point to measure "nearby" from: the last visited store
  /// once one exists in this session, otherwise the rep's live GPS.
  Future<({double lat, double lng})?> _resolveReferencePoint() async {
    if (_chainLat != null && _chainLng != null) {
      return (lat: _chainLat!, lng: _chainLng!);
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(const Duration(seconds: 10));
    return (lat: position.latitude, lng: position.longitude);
  }

  Future<void> loadNearbyLeads({int limit = 15}) async {
    _isLoadingLeads = true;
    update();
    try {
      final point = await _resolveReferencePoint();
      if (point == null) {
        _nearbyLeads = [];
        return;
      }

      if (!Get.isRegistered<ApiClient>()) return;
      final res = await Get.find<ApiClient>().getData(
        '/api/v1/customer/marketer/leads/nearby'
            '?latitude=${point.lat}&longitude=${point.lng}&limit=$limit',
        useEtag: false,
      );
      if (res.statusCode == 200 && res.body != null) {
        final leads = res.body['data']?['leads'];
        if (leads is List) {
          _nearbyLeads = leads.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadNearbyLeads error: $e');
    } finally {
      _isLoadingLeads = false;
      update();
    }
  }

  // Manual picker: neighborhood -> store list (step 1 then step 2).
  List<Map<String, dynamic>> _neighborhoods = [];
  List<Map<String, dynamic>> get neighborhoods => _neighborhoods;
  bool _isLoadingNeighborhoods = false;
  bool get isLoadingNeighborhoods => _isLoadingNeighborhoods;

  Future<void> loadNeighborhoods() async {
    _isLoadingNeighborhoods = true;
    update();
    try {
      if (!Get.isRegistered<ApiClient>()) return;
      final res = await Get.find<ApiClient>().getData(
        '/api/v1/customer/marketer/leads/neighborhoods',
        useEtag: false,
      );
      if (res.statusCode == 200 && res.body != null) {
        final list = res.body['data']?['neighborhoods'];
        if (list is List) {
          _neighborhoods = list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadNeighborhoods error: $e');
    } finally {
      _isLoadingNeighborhoods = false;
      update();
    }
  }

  List<Map<String, dynamic>> _neighborhoodLeads = [];
  List<Map<String, dynamic>> get neighborhoodLeads => _neighborhoodLeads;
  bool _isLoadingNeighborhoodLeads = false;
  bool get isLoadingNeighborhoodLeads => _isLoadingNeighborhoodLeads;

  /// Every business in [neighborhood] -- available AND already-claimed, so
  /// the rep can see "someone already visited this one" instead of it just
  /// vanishing. Sorted by distance when location is available.
  Future<void> loadLeadsForNeighborhood(String neighborhood) async {
    _isLoadingNeighborhoodLeads = true;
    update();
    try {
      String query = 'neighborhood=${Uri.encodeQueryComponent(neighborhood)}';
      try {
        final point = await _resolveReferencePoint();
        if (point != null) {
          query += '&latitude=${point.lat}&longitude=${point.lng}';
        }
      } catch (_) {
        // Location unavailable -- list still loads, just unsorted.
      }

      if (!Get.isRegistered<ApiClient>()) return;
      final res = await Get.find<ApiClient>().getData(
        '/api/v1/customer/marketer/leads/by-neighborhood?$query',
        useEtag: false,
      );
      if (res.statusCode == 200 && res.body != null) {
        final list = res.body['data']?['leads'];
        if (list is List) {
          _neighborhoodLeads = list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadLeadsForNeighborhood error: $e');
    } finally {
      _isLoadingNeighborhoodLeads = false;
      update();
    }
  }

  /// Looks up the nearest not-yet-claimed candidate business from the
  /// pre-loaded area leads list. Returns null if location isn't available,
  /// the request fails, or there's nothing nearby to suggest.
  Future<Map<String, dynamic>?> fetchNearestLead() async {
    try {
      final point = await _resolveReferencePoint();
      if (point == null) return null;

      if (!Get.isRegistered<ApiClient>()) return null;
      final res = await Get.find<ApiClient>().getData(
        '/api/v1/customer/marketer/leads/nearby'
            '?latitude=${point.lat}&longitude=${point.lng}',
        useEtag: false,
      );
      if (res.statusCode == 200 && res.body != null) {
        final leads = res.body['data']?['leads'];
        if (leads is List && leads.isNotEmpty) {
          return Map<String, dynamic>.from(leads.first);
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] fetchNearestLead error: $e');
    }
    return null;
  }

  /// Creates a visit record from a suggested lead, then starts it exactly
  /// like any other visit (same timer/prefill/API flow as [startVisit]).
  Future<bool> startVisitFromLead(Map<String, dynamic> lead) async {
    try {
      if (!Get.isRegistered<ApiClient>()) return false;
      final res = await Get.find<ApiClient>().postData(
        '${AppConstants.marketerVisitsUri}/store',
        {
          'lead_id': lead['id'],
          'store_name': lead['name'],
          'address': lead['address'],
          'latitude': lead['latitude'],
          'longitude': lead['longitude'],
          'visit_status': 'scheduled',
        },
      );
      if (res.statusCode != 200 || res.body == null || res.body['data']?['id'] == null) {
        final msg = res.body?['message']?.toString() ?? 'تعذّر إنشاء الزيارة، حاول مرة أخرى';
        showCustomSnackBar(msg, isError: true);
        return false;
      }
      final newVisit = StoreVisitModel(
        id: res.body['data']['id'].toString(),
        storeName: lead['name']?.toString() ?? '',
        managerName: '',
        phone: '',
        address: lead['address']?.toString() ?? '',
        latitude: (lead['latitude'] as num?)?.toDouble(),
        longitude: (lead['longitude'] as num?)?.toDouble(),
        category: '',
        distanceKm: (lead['distance_km'] as num?)?.toDouble() ?? 0,
        timeSlot: '',
      );
      _allVisits.add(newVisit);
      _nearbyLeads.removeWhere((l) => l['id'] == lead['id']);

      // Chain the next suggestions off THIS store instead of live GPS, then
      // refresh the list in the background so it's ready by the time the
      // rep finishes this visit and comes back for the next one.
      if (newVisit.latitude != null && newVisit.longitude != null) {
        _chainLat = newVisit.latitude;
        _chainLng = newVisit.longitude;
        unawaited(loadNearbyLeads());
      }

      update();
      return startVisit(newVisit);
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] startVisitFromLead error: $e');
      return false;
    }
  }

  // Resume an existing in-progress visit
  void resumeVisit(StoreVisitModel visit) {
    _activeVisit = visit.copyWith(visitStatus: StoreVisitStatus.inProgress);
    storeNameController.text = visit.storeName;
    managerNameController.text = visit.managerName;
    phoneController.text = visit.phone;
    openingsController.text = visit.openingsCount.toString();
    crNumberController.text = visit.crNumber;
    decisionMakerNameController.text = visit.decisionMakerName ?? '';
    decisionMakerPhoneController.text = visit.decisionMakerPhone ?? '';
    _selectedDecisionMakerBestTime = visit.decisionMakerBestTime;
    _selectedInterviewedPersonRole = visit.interviewedPersonRole;
    _selectedPipelineStep = visit.pipelineStep;
    _frontImagePath = visit.frontImagePath;
    _insideImagePath = visit.insideImagePath;
    final resumeObstacle = visit.obstaclesNotes;
    if (resumeObstacle != null && resumeObstacle.isNotEmpty) {
      if (predefinedObstacles.contains(resumeObstacle)) {
        _selectedObstacle = resumeObstacle;
        otherReasonController.clear();
      } else {
        _selectedObstacle = 'سبب آخر';
        otherReasonController.text = resumeObstacle;
      }
      obstaclesController.text = resumeObstacle;
    } else {
      _selectedObstacle = null;
      otherReasonController.clear();
      obstaclesController.clear();
    }
    _selectedClosingReason = visit.closingReason;
    if (visit.interestStatus != null && visit.interestStatus!.isNotEmpty) {
      _selectedInterestStatus = visit.interestStatus!;
    }
    _selectedFollowUpDate = visit.nextFollowUpDate;
    commitmentsController.text = visit.nextFollowUpCommitments ?? '';

    _isAutoExtended = visit.isExtended ||
        visit.extendedMinutes > 0 ||
        visit.pipelineStep == StorePipelineStep.negotiating ||
        visit.pipelineStep == StorePipelineStep.contractSigned;
    _extensionMinutes = visit.extendedMinutes > 0 ? visit.extendedMinutes : (_isAutoExtended ? autoExtensionMinutes : 0);

    final now = DateTime.now();
    final startedAt = visit.startedAt ?? now;
    final diff = now.difference(startedAt).inSeconds;
    _elapsedVisitSeconds = diff.clamp(0, maxVisitMinutes * 60);
    _inactivitySeconds = 0;

    final index = _allVisits.indexWhere((v) => v.id == visit.id);
    if (index != -1) {
      _allVisits[index] = _activeVisit!;
    }

    _startVisitTimer();
    update();
  }

  void _startVisitTimer() {
    _visitTimer?.cancel();
    _visitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedVisitSeconds++;
      _inactivitySeconds++;

      // Trigger anti-fraud inactivity warnings if inactive for >= 10 minutes (bypassed in test/local mode)
      if (!AntiFraudAlertsController.disableInactivityAlertsInTest) {
        if (_inactivitySeconds == inactivityThresholdSeconds) {
          addAlertLog(
            title: 'first_warning'.tr,
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 1,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert1);
          }
          _syncAlertToBackend(1, 'تنبيه أول', 'يبدو أنك لم تتحرك نحو المتجر المستهدف');
        } else if (_inactivitySeconds == inactivityThresholdSeconds + 180) { // +3 min
          addAlertLog(
            title: 'second_warning'.tr,
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 2,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert2);
          }
          _syncAlertToBackend(2, 'تنبيه ثاني', 'لم يتم رصد تقدم كافٍ نحو المتجر');
        } else if (_inactivitySeconds == inactivityThresholdSeconds + 360) { // +6 min
          addAlertLog(
            title: 'third_warning'.tr,
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 3,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert3);
          }
          _syncAlertToBackend(3, 'تنبيه ثالث', 'تم تسجيل عدم نشاط مستمر أثناء الجولة');
        } else if (_inactivitySeconds >= inactivityThresholdSeconds + 540) { // +9 min -> critical
          addAlertLog(
            title: 'critical_warning'.tr,
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 4,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.criticalAlert4);
          }
          _syncAlertToBackend(4, 'تنبيه حرج', 'تم احتساب هذا الوقت خارج الدوام');
        }
      }

      update();
    });
  }

  void _syncAlertToBackend(int level, String title, String reason) async {
    if (_activeVisit == null) return;
    try {
      if (Get.isRegistered<ApiClient>()) {
        await Get.find<ApiClient>().postData(
          '${AppConstants.marketerVisitsUri}/${_activeVisit!.id}/alert',
          {'level': level, 'title': title, 'reason': reason},
        );
      }
    } catch (_) {}
  }

  // Reset inactivity counter whenever representative interacts with the form or moves
  void registerActivity() {
    _inactivitySeconds = 0;
    update();
  }

  String get formattedVisitTime {
    final minutes = (_elapsedVisitSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedVisitSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedRemainingTime {
    final rem = remainingVisitSeconds > 0 ? remainingVisitSeconds : 0;
    final minutes = (rem ~/ 60).toString().padLeft(2, '0');
    final seconds = (rem % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setPipelineStep(StorePipelineStep step) {
    _selectedPipelineStep = step;
    registerActivity();

    final isEligibleForAutoExtension = (step == StorePipelineStep.negotiating || step == StorePipelineStep.contractSigned);
    if (isEligibleForAutoExtension && !_isAutoExtended) {
      _applyAutoVisitExtension(step);
    } else {
      update();
    }
  }

  void _applyAutoVisitExtension(StorePipelineStep step) {
    if (_isAutoExtended) return;
    _isAutoExtended = true;
    _extensionMinutes = autoExtensionMinutes;

    if (_activeVisit != null) {
      _activeVisit = _activeVisit!.copyWith(
        isExtended: true,
        extendedMinutes: _extensionMinutes,
        pipelineStep: step,
      );
      final index = _allVisits.indexWhere((v) => v.id == _activeVisit!.id);
      if (index != -1) {
        _allVisits[index] = _activeVisit!;
      }

      _syncExtensionToBackend(step);
    }

    final message = step == StorePipelineStep.contractSigned
        ? 'auto_visit_extended_contract'.tr
        : 'auto_visit_extended_negotiation'.tr;

    Get.showSnackbar(GetSnackBar(
      message: message,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF163E20),
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      icon: const Icon(Icons.timer_outlined, color: Color(0xFF30913F)),
      shouldIconPulse: true,
    ));

    update();
  }

  void _syncExtensionToBackend(StorePipelineStep step) async {
    if (_activeVisit == null) return;
    try {
      if (Get.isRegistered<ApiClient>()) {
        await Get.find<ApiClient>().postData(
          '${AppConstants.marketerVisitsUri}/${_activeVisit!.id}/extend',
          {
            'extended_minutes': autoExtensionMinutes,
            'reason': step.name,
            'pipeline_step': step.apiValue,
          },
        );
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] syncExtension error: $e');
    }
  }

  void setFollowUpDate(DateTime date) {
    _selectedFollowUpDate = date;
    registerActivity();
    update();
  }

  void setFollowUpTime(TimeOfDay time) {
    _selectedFollowUpTime = time;
    registerActivity();
    update();
  }

  // Anti-spoofing live camera capture (strictly camera, no gallery)
  Future<void> captureStorePhoto({required bool isFrontImage}) async {
    if (isFrontImage) {
      await captureFrontImage();
    } else {
      await captureInsideImage();
    }
  }

  Future<void> captureFrontImage() async {
    registerActivity();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        _frontImagePath = photo.path;
        _frontPhotoCapturedTime = DateTime.now();
        update();
      }
    } catch (e) {
      debugPrint('Front photo capture camera error: $e. Falling back to gallery...');
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
        );
        if (photo != null) {
          _frontImagePath = photo.path;
          _frontPhotoCapturedTime = DateTime.now();
          update();
        }
      } catch (e2) {
        debugPrint('Gallery fallback error: $e2');
      }
    }
  }

  Future<void> captureInsideImage() async {
    registerActivity();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
        preferredCameraDevice: CameraDevice.front,
      );
      if (photo != null) {
        _insideImagePath = photo.path;
        _insidePhotoCapturedTime = DateTime.now();
        update();
      }
    } catch (e) {
      debugPrint('Inside photo capture camera error: $e. Falling back to gallery...');
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
        );
        if (photo != null) {
          _insideImagePath = photo.path;
          _insidePhotoCapturedTime = DateTime.now();
          update();
        }
      } catch (e2) {
        debugPrint('Gallery fallback error: $e2');
      }
    }
  }

  void toggleConfidentialReport() {
    _isConfidentialReportExpanded = !_isConfidentialReportExpanded;
    update();
  }

  // Save digital signature
  void setContractSignature(String path) {
    applyContractSignature(path);
  }

  void applyContractSignature(String path) {
    if (_activeVisit != null) {
      _activeVisit = _activeVisit!.copyWith(
        contractSignaturePath: path,
        pipelineStep: StorePipelineStep.contractSigned,
      );
      _selectedPipelineStep = StorePipelineStep.contractSigned;
      update();
    }
  }

  // Finish visit logic with qualification evaluation & backend API sync
  Future<bool> submitAndFinishVisit({
    StoreVisitModel? targetVisit,
    bool isNafathVerified = false,
    String? nafathNationalId,
    String? nafathRequestId,
  }) async {
    final baseVisit = targetVisit ?? _activeVisit;
    if (baseVisit == null) return false;

    final bool isContractStep = (_selectedPipelineStep == StorePipelineStep.contractSigned ||
        baseVisit.pipelineStep == StorePipelineStep.contractSigned);

    // A contract visit is ONLY officially completed when Nafath verification is confirmed successful!
    final bool isContractOfficiallyCompleted = isContractStep && isNafathVerified;

    final bool isDisqualifiedOrRejected = (_selectedPipelineStep == StorePipelineStep.rejected ||
        _selectedPipelineStep == StorePipelineStep.notQualified);

    final bool isFollowUpNeeded = !isContractOfficiallyCompleted &&
        !isDisqualifiedOrRejected &&
        (_selectedPipelineStep == StorePipelineStep.gracePeriod ||
            _selectedPipelineStep == StorePipelineStep.negotiating ||
            _selectedPipelineStep == StorePipelineStep.interested ||
            _selectedFollowUpDate != null);

    // Outcome logic: qualified if contract signed and nafath verified, or minimum conditions met
    final bool isQualified = isContractOfficiallyCompleted ||
        (!isContractStep &&
            (_selectedPipelineStep != StorePipelineStep.notMet &&
                _selectedPipelineStep != StorePipelineStep.rejected &&
                _selectedPipelineStep != StorePipelineStep.notQualified) &&
            (_frontImagePath != null || _insideImagePath != null || baseVisit.frontImagePath != null));

    // Status: if it's a contract step but Nafath is NOT yet verified, it MUST stay inProgress (pending verification)!
    final StoreVisitStatus finalVisitStatus = isFollowUpNeeded
        ? StoreVisitStatus.followUp
        : (isContractStep && !isNafathVerified
            ? StoreVisitStatus.inProgress
            : StoreVisitStatus.completed);

    String? effectiveClosingReason = _selectedClosingReason ?? baseVisit.closingReason;
    String effectiveOtherDetails = otherReasonController.text.trim().isNotEmpty
        ? otherReasonController.text.trim()
        : (baseVisit.closingReasonOtherDetails ?? '');
    if (_selectedPipelineStep == StorePipelineStep.notMet) {
      effectiveClosingReason = 'لم تتم المقابلة';
      effectiveOtherDetails = reasonNotMetController.text.trim();
    } else if (_selectedPipelineStep == StorePipelineStep.rejected) {
      effectiveClosingReason = 'رفض';
      effectiveOtherDetails = reasonRejectedController.text.trim();
    } else if (_selectedPipelineStep == StorePipelineStep.notQualified) {
      effectiveClosingReason = 'غير مؤهل';
      effectiveOtherDetails = reasonDisqualifiedController.text.trim();
    }

    String fullConfidentialNotes = confidentialNotesController.text.trim();
    if (confidentialTitleController.text.trim().isNotEmpty) {
      fullConfidentialNotes = '[${confidentialTitleController.text.trim()}] $fullConfidentialNotes';
    }
    if (fullConfidentialNotes.isEmpty && baseVisit.confidentialNotes != null) {
      fullConfidentialNotes = baseVisit.confidentialNotes!;
    }

    final effectiveStoreName = storeNameController.text.trim().isNotEmpty
        ? storeNameController.text.trim()
        : baseVisit.storeName;
    final effectiveManagerName = managerNameController.text.trim().isNotEmpty
        ? managerNameController.text.trim()
        : baseVisit.managerName;
    final effectivePhone = phoneController.text.trim().isNotEmpty
        ? phoneController.text.trim()
        : baseVisit.phone;
    final effectiveOpenings = int.tryParse(openingsController.text.trim()) ?? baseVisit.openingsCount;
    final effectiveCrNumber = crNumberController.text.trim().isNotEmpty
        ? crNumberController.text.trim()
        : baseVisit.crNumber;

    final updated = baseVisit.copyWith(
      storeName: effectiveStoreName,
      managerName: effectiveManagerName,
      phone: effectivePhone,
      openingsCount: effectiveOpenings,
      crNumber: effectiveCrNumber,
      decisionMakerName: decisionMakerNameController.text.trim().isNotEmpty ? decisionMakerNameController.text.trim() : baseVisit.decisionMakerName,
      decisionMakerPhone: decisionMakerPhoneController.text.trim().isNotEmpty ? decisionMakerPhoneController.text.trim() : baseVisit.decisionMakerPhone,
      decisionMakerBestTime: _selectedDecisionMakerBestTime ?? baseVisit.decisionMakerBestTime,
      interviewedPersonRole: _selectedInterviewedPersonRole ?? baseVisit.interviewedPersonRole,
      pipelineStep: _selectedPipelineStep != StorePipelineStep.notMet ? _selectedPipelineStep : baseVisit.pipelineStep,
      visitStatus: finalVisitStatus,
      isQualifiedOutcome: isQualified,
      frontImagePath: _frontImagePath ?? baseVisit.frontImagePath,
      insideImagePath: _insideImagePath ?? baseVisit.insideImagePath,
      nextFollowUpDate: isFollowUpNeeded
          ? (_selectedFollowUpDate ?? baseVisit.nextFollowUpDate)
          : null,
      nextFollowUpCommitments: isFollowUpNeeded
          ? (commitmentsController.text.trim().isNotEmpty
              ? commitmentsController.text.trim()
              : baseVisit.nextFollowUpCommitments)
          : null,
      obstaclesNotes: obstaclesController.text.trim().isNotEmpty
          ? obstaclesController.text.trim()
          : baseVisit.obstaclesNotes,
      closingReason: effectiveClosingReason,
      closingReasonOtherDetails: effectiveOtherDetails,
      confidentialNotes: fullConfidentialNotes,
      durationMinutes: _elapsedVisitSeconds > 0 ? (_elapsedVisitSeconds / 60).ceil() : baseVisit.durationMinutes,
      completedAt: DateTime.now(),
    );

    // Update in all visits list immediately
    final index = _allVisits.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _allVisits[index] = updated;
    } else {
      _allVisits.add(updated);
    }

    final finishedVisitId = updated.id;
    _visitTimer?.cancel();
    _activeVisit = null;
    update();

    // Call backend API and await
    try {
      if (Get.isRegistered<ApiClient>()) {
        // Multipart: _frontImagePath/_insideImagePath are also used by the UI
        // to show an "already captured" thumbnail, so they get populated
        // from the server's *relative storage path* (e.g. "marketer/visits/x.jpg")
        // whenever a visit is created/resumed/started -- not just on a fresh
        // local capture via captureFrontImage()/captureInsideImage(). Only a
        // path that actually exists on this device is a real local file safe
        // to wrap in XFile() and re-upload; a server path isn't, and wrapping
        // it throws (readAsBytes() on a nonexistent file), which used to be
        // silently swallowed and still reported as success to the caller.
        final List<MultipartBody> multipart = [
          if (_frontImagePath != null && _frontImagePath!.isNotEmpty && File(_frontImagePath!).existsSync())
            MultipartBody('front_image', XFile(_frontImagePath!)),
          if (_insideImagePath != null && _insideImagePath!.isNotEmpty && File(_insideImagePath!).existsSync())
            MultipartBody('inside_image', XFile(_insideImagePath!)),
        ];

        final res = await Get.find<ApiClient>().postMultipartData(
          '${AppConstants.marketerVisitsUri}/$finishedVisitId/complete',
          {
            'store_name': updated.storeName,
            'manager_name': updated.managerName,
            'phone': updated.phone,
            'openings_count': updated.openingsCount.toString(),
            'cr_number': updated.crNumber,
            'decision_maker_name': updated.decisionMakerName ?? '',
            'decision_maker_phone': updated.decisionMakerPhone ?? '',
            'decision_maker_best_time': updated.decisionMakerBestTime ?? '',
            'interviewed_person_role': updated.interviewedPersonRole ?? '',
            'pipeline_step': updated.pipelineStep.apiValue,
            'visit_status': updated.visitStatus == StoreVisitStatus.followUp
                ? 'follow_up'
                : (updated.visitStatus == StoreVisitStatus.inProgress ? 'in_progress' : 'completed'),
            'obstacles_notes': updated.obstaclesNotes ?? '',
            'closing_reason': updated.closingReason ?? '',
            'closing_reason_other_details': updated.closingReasonOtherDetails ?? '',
            'confidential_notes': updated.confidentialNotes ?? '',
            // PHP's (bool) cast treats any non-empty string (including "false")
            // as true, so booleans must travel as "1"/"0" over multipart, not
            // "true"/"false" -- that only holds for real JSON requests.
            'is_qualified': updated.isQualifiedOutcome ? '1' : '0',
            'is_extended': updated.isExtended ? '1' : '0',
            'extended_minutes': updated.extendedMinutes.toString(),
            if (isFollowUpNeeded && updated.nextFollowUpDate != null)
              'next_follow_up_date': updated.nextFollowUpDate!.toIso8601String(),
            if (isFollowUpNeeded)
              'next_follow_up_commitments': updated.nextFollowUpCommitments ?? '',
            // Proof of the merchant's Nafath approval -- the backend refuses to
            // mark a contract as signed without a matching approved request.
            if (nafathNationalId != null && nafathNationalId.isNotEmpty)
              'nafath_national_id': nafathNationalId,
            if (nafathRequestId != null && nafathRequestId.isNotEmpty)
              'nafath_request_id': nafathRequestId,
          },
          multipart,
        );

        if (res.statusCode == 200) {
          showCustomSnackBar(
            'تم توثيق وإنهاء الزيارة بنجاح ومزامنتها مع الإدارة',
            isError: false,
            showDuration: 2,
          );
        } else {
          final errorMsg = res.body?['message'] ?? 'حدث خطأ أثناء توثيق الزيارة في الخادم';
          showCustomSnackBar(errorMsg.toString(), isError: true, showDuration: 4);
          return false;
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] completeVisit api error: $e');
      showCustomSnackBar('server_connection_failed_saved_locally'.tr, isError: true);
      return false;
    }

    // Update main shift metrics only if visit is truly completed
    if (finalVisitStatus == StoreVisitStatus.completed && Get.isRegistered<EmployeeShiftController>()) {
      Get.find<EmployeeShiftController>().recordVisitCompleted(isQualified);
    }

    return true;
  }

  // =========================================================================
  // Contract Activation State & Methods (R01)
  // =========================================================================
  ContractActivationModel? currentActivation;
  bool isActivationLoading = false;
  List<ContractActivationModel> inActivationContracts = [];

  Future<void> loadContractActivation(int storeId, {String? contractNumber}) async {
    isActivationLoading = true;
    update();
    try {
      if (Get.isRegistered<ApiClient>()) {
        final query = contractNumber != null ? '?contract_number=$contractNumber' : '';
        final res = await Get.find<ApiClient>().getData('${AppConstants.contractActivationUri}/$storeId/activation$query');
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          currentActivation = ContractActivationModel.fromJson(Map<String, dynamic>.from(res.body['data']));
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadContractActivation error: $e');
    } finally {
      isActivationLoading = false;
      update();
    }
  }

  Future<bool> updateContractActivationItem(int storeId, String key, String status, {dynamic value, XFile? photoFile}) async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        Response res;
        if (photoFile != null) {
          List<MultipartBody> multipart = [
            MultipartBody('photo', photoFile),
          ];
          res = await Get.find<ApiClient>().postMultipartData(
            '${AppConstants.contractActivationUri}/$storeId/activation/item',
            {'key': key, 'status': status, if (value != null) 'value': value.toString()},
            multipart,
          );
        } else {
          res = await Get.find<ApiClient>().postData(
            '${AppConstants.contractActivationUri}/$storeId/activation/item',
            {'key': key, 'status': status, if (value != null) 'value': value},
          );
        }

        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          currentActivation = ContractActivationModel.fromJson(Map<String, dynamic>.from(res.body['data']));
          update();
          showCustomSnackBar('checklist_item_updated_success'.tr, isError: false);
          return true;
        } else {
          final msg = res.body?['message'] ?? 'checklist_item_updated_failed'.tr;
          showCustomSnackBar(msg.toString(), isError: true);
          return false;
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] updateContractActivationItem error: $e');
      showCustomSnackBar('server_connection_failed'.tr, isError: true);
    }
    return false;
  }

  Future<bool> reportContractActivationIssue(int storeId, String notes) async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().postData(
          '${AppConstants.contractActivationUri}/$storeId/activation/report-issue',
          {'notes': notes},
        );
        if (res.statusCode == 200) {
          showCustomSnackBar('issue_reported_success'.tr, isError: false);
          return true;
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] reportContractActivationIssue error: $e');
    }
    return false;
  }

  Future<void> loadInActivationContracts() async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData('${AppConstants.contractActivationUri}/in-activation');
        if (res.statusCode == 200 && res.body != null && res.body['data'] is List) {
          inActivationContracts = (res.body['data'] as List)
              .map((i) => ContractActivationModel.fromJson(Map<String, dynamic>.from(i)))
              .toList();
          update();
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadInActivationContracts error: $e');
    }
  }

  // Dynamic Commercial Contract Legal Clauses
  List<Map<String, dynamic>> dynamicContractClauses = [];
  bool isLoadingContractClauses = false;


  // [R03] Store Contacts Registry & WhatsApp Consent
  List<StoreContactModel> storeContacts = [];
  bool isLoadingContacts = false;

  Future<void> loadStoreContacts(int storeId) async {
    try {
      isLoadingContacts = true;
      update();
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData('/api/v1/customer/marketer/stores/$storeId/contacts');
        if (res.statusCode == 200 && res.body != null && res.body['data'] is List) {
          storeContacts = (res.body['data'] as List)
              .map((c) => StoreContactModel.fromJson(Map<String, dynamic>.from(c)))
              .toList();
          update();
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadStoreContacts error: $e');
    } finally {
      isLoadingContacts = false;
      update();
    }
  }

  Future<bool> addStoreContact({
    required int storeId,
    required String name,
    required String role,
    required String phone,
    String? nationality,
    String preferredLanguage = 'ar',
    bool whatsappConsent = true,
    int? marketerVisitId,
    String? notes,
  }) async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final body = {
          'name': name,
          'role': role,
          'phone': phone,
          if (nationality != null) 'nationality': nationality,
          'preferred_language': preferredLanguage,
          'whatsapp_consent': whatsappConsent,
          if (marketerVisitId != null) 'marketer_visit_id': marketerVisitId,
          if (notes != null) 'notes': notes,
        };
        final res = await Get.find<ApiClient>().postData('/api/v1/customer/marketer/stores/$storeId/contacts', body);
        if (res.statusCode == 200 || res.statusCode == 201) {
          if (res.body != null && res.body['data'] != null) {
            final newContact = StoreContactModel.fromJson(Map<String, dynamic>.from(res.body['data']));
            storeContacts.insert(0, newContact);
          } else {
            // Local fallback
            storeContacts.insert(0, StoreContactModel(
              storeId: storeId,
              name: name,
              role: role,
              phone: phone,
              nationality: nationality,
              preferredLanguage: preferredLanguage,
              whatsappConsent: whatsappConsent,
              consentAt: whatsappConsent ? DateTime.now() : null,
              notes: notes,
            ));
          }
          update();
          showCustomSnackBar('contact_added_success'.tr, isError: false);
          return true;
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] addStoreContact error: $e');
    }
    // Optimistic fallback for offline/local continuity
    storeContacts.insert(0, StoreContactModel(
      storeId: storeId,
      name: name,
      role: role,
      phone: phone,
      nationality: nationality,
      preferredLanguage: preferredLanguage,
      whatsappConsent: whatsappConsent,
      consentAt: whatsappConsent ? DateTime.now() : null,
      notes: notes,
    ));
    update();
    showCustomSnackBar('contact_added_success'.tr, isError: false);
    return true;
  }

  Future<bool> deleteStoreContact(int contactId) async {
    try {
      storeContacts.removeWhere((c) => c.id == contactId);
      update();
      if (Get.isRegistered<ApiClient>()) {
        await Get.find<ApiClient>().deleteData('/api/v1/customer/marketer/contacts/$contactId');
      }
      showCustomSnackBar('contact_deleted_success'.tr, isError: false);
      return true;
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] deleteStoreContact error: $e');
    }
    return false;
  }

  Future<void> loadContractTemplateClauses() async {
    try {
      isLoadingContractClauses = true;
      update();
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData('${AppConstants.contractActivationUri}/template-clauses');
        if (res.statusCode == 200 && res.body != null && res.body['data'] is List) {
          dynamicContractClauses = (res.body['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .where((c) => c['is_active'] != false)
              .toList();
          update();
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadContractTemplateClauses error: $e');
    } finally {
      isLoadingContractClauses = false;
      update();
    }
  }
}
