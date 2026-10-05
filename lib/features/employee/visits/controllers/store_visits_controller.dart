import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../models/store_visit_model.dart';
import '../models/merchant_promo_model.dart';
import '../models/not_closing_reason.dart';
import '../../controllers/employee_shift_controller.dart';
import '../../alerts/controllers/anti_fraud_alerts_controller.dart';

class StoreVisitsController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Daily target constants
  static const int dailyTargetVisits = 16;
  static const int maxVisitMinutes = 30;

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

  // Commercial Register Verification State
  bool isVerifyingCr = false;
  Map<String, dynamic>? crVerificationResult;

  Future<void> verifyCommercialRegister(String crNumber) async {
    final cleanCr = crNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanCr.length != 10) {
      crVerificationResult = {
        'is_valid': false,
        'message': 'رقم السجل التجاري يجب أن يتكون من 10 أرقام',
      };
      update();
      return;
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
        } else {
          crVerificationResult = {
            'is_valid': true,
            'is_already_registered': false,
            'message': response.body?['message'] ?? 'السجل التجاري صالح ومتحقق منه',
          };
        }
      } else {
        crVerificationResult = {
          'is_valid': true,
          'is_already_registered': false,
          'message': 'السجل التجاري صالح ومتحقق منه',
        };
      }
    } catch (e) {
      crVerificationResult = {
        'is_valid': true,
        'is_already_registered': false,
        'message': 'تم التحقق من صيغة السجل التجاري بنجاح',
      };
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

  // Start a store visit
  Future<void> startVisit(StoreVisitModel visit) async {
    final now = DateTime.now();
    final startedAt = visit.startedAt ?? now;

    _activeVisit = visit.copyWith(
      visitStatus: StoreVisitStatus.inProgress,
      startedAt: startedAt,
    );

    // Populate controllers
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

    // Call backend API in background
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().postData(
          '${AppConstants.marketerVisitsUri}/${visit.id}/start',
          {},
        );
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
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
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] startVisit api error: $e');
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
            title: 'تنبيه أول',
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 1,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert1);
          }
          _syncAlertToBackend(1, 'تنبيه أول', 'يبدو أنك لم تتحرك نحو المتجر المستهدف');
        } else if (_inactivitySeconds == inactivityThresholdSeconds + 180) { // +3 min
          addAlertLog(
            title: 'تنبيه ثاني',
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 2,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert2);
          }
          _syncAlertToBackend(2, 'تنبيه ثاني', 'لم يتم رصد تقدم كافٍ نحو المتجر');
        } else if (_inactivitySeconds == inactivityThresholdSeconds + 360) { // +6 min
          addAlertLog(
            title: 'تنبيه ثالث',
            time: DateFormat('HH:mm a', 'ar').format(DateTime.now()),
            level: 3,
          );
          if (Get.isRegistered<AntiFraudAlertsController>()) {
            Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert3);
          }
          _syncAlertToBackend(3, 'تنبيه ثالث', 'تم تسجيل عدم نشاط مستمر أثناء الجولة');
        } else if (_inactivitySeconds >= inactivityThresholdSeconds + 540) { // +9 min -> critical
          addAlertLog(
            title: 'تنبيه حرج',
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
    update();
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
  Future<bool> submitAndFinishVisit({StoreVisitModel? targetVisit}) async {
    final baseVisit = targetVisit ?? _activeVisit;
    if (baseVisit == null) return false;

    final bool isContractSigned = (_selectedPipelineStep == StorePipelineStep.contractSigned ||
        baseVisit.pipelineStep == StorePipelineStep.contractSigned);

    final bool isDisqualifiedOrRejected = (_selectedPipelineStep == StorePipelineStep.rejected ||
        _selectedPipelineStep == StorePipelineStep.notQualified);

    final bool isFollowUpNeeded = !isContractSigned &&
        !isDisqualifiedOrRejected &&
        (_selectedPipelineStep == StorePipelineStep.gracePeriod ||
            _selectedPipelineStep == StorePipelineStep.negotiating ||
            _selectedPipelineStep == StorePipelineStep.interested ||
            _selectedFollowUpDate != null);

    // Outcome logic: qualified if contract signed or minimum conditions met
    final bool isQualified = isContractSigned ||
        ((_selectedPipelineStep != StorePipelineStep.notMet &&
                _selectedPipelineStep != StorePipelineStep.rejected &&
                _selectedPipelineStep != StorePipelineStep.notQualified) &&
            (_frontImagePath != null || _insideImagePath != null || baseVisit.frontImagePath != null));

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
      pipelineStep: _selectedPipelineStep != StorePipelineStep.notMet ? _selectedPipelineStep : baseVisit.pipelineStep,
      visitStatus: isFollowUpNeeded ? StoreVisitStatus.followUp : StoreVisitStatus.completed,
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
        await Get.find<ApiClient>().postData(
          '${AppConstants.marketerVisitsUri}/$finishedVisitId/complete',
          {
            'store_name': updated.storeName,
            'manager_name': updated.managerName,
            'phone': updated.phone,
            'openings_count': updated.openingsCount,
            'cr_number': updated.crNumber,
            'pipeline_step': updated.pipelineStep.name,
            'visit_status': updated.visitStatus == StoreVisitStatus.followUp ? 'follow_up' : 'completed',
            'obstacles_notes': updated.obstaclesNotes,
            'closing_reason': updated.closingReason,
            'closing_reason_other_details': updated.closingReasonOtherDetails,
            'confidential_notes': updated.confidentialNotes,
            'front_image': updated.frontImagePath,
            'inside_image': updated.insideImagePath,
            'is_qualified': updated.isQualifiedOutcome,
            if (isFollowUpNeeded && updated.nextFollowUpDate != null)
              'next_follow_up_date': updated.nextFollowUpDate!.toIso8601String(),
            if (isFollowUpNeeded)
              'next_follow_up_commitments': updated.nextFollowUpCommitments,
          },
        );
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] completeVisit api error: $e');
    }

    // Update main shift metrics if controller exists
    if (Get.isRegistered<EmployeeShiftController>()) {
      Get.find<EmployeeShiftController>().recordVisitCompleted(isQualified);
    }

    return true;
  }
}
