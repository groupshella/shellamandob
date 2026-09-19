import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../models/store_visit_model.dart';
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

  // Temporary micro-form state for active visit
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

  StorePipelineStep _selectedPipelineStep = StorePipelineStep.notMet;
  StorePipelineStep get selectedPipelineStep => _selectedPipelineStep;

  String? _selectedClosingReason;
  String? get selectedClosingReason => _selectedClosingReason;

  DateTime? _selectedFollowUpDate;
  DateTime? get selectedFollowUpDate => _selectedFollowUpDate;

  TimeOfDay? _selectedFollowUpTime;
  TimeOfDay? get selectedFollowUpTime => _selectedFollowUpTime;

  String? _frontImagePath;
  String? get frontImagePath => _frontImagePath;

  String? _insideImagePath;
  String? get insideImagePath => _insideImagePath;

  bool _isConfidentialReportExpanded = false;
  bool get isConfidentialReportExpanded => _isConfidentialReportExpanded;

  bool isLoading = false;

  String get zoneName => 'غرب الرياض';

  // Visits lists
  final List<StoreVisitModel> _allVisits = [];
  List<StoreVisitModel> get allVisits => _allVisits;

  @override
  void onInit() {
    super.onInit();
    loadVisits();
  }

  Future<void> loadVisits({bool notify = true}) async {
    isLoading = true;
    if (notify) update();
    try {
      if (Get.isRegistered<ApiClient>()) {
        final res = await Get.find<ApiClient>().getData(AppConstants.marketerVisitsUri);
        if (res.statusCode == 200 && res.body != null && res.body['data'] != null) {
          final list = res.body['data']['visits'];
          if (list is List && list.isNotEmpty) {
            _allVisits.clear();
            for (var item in list) {
              _allVisits.add(StoreVisitModel.fromJson(Map<String, dynamic>.from(item)));
            }
            isLoading = false;
            if (notify) update();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [StoreVisitsController] loadVisits error: $e');
    }
    if (_allVisits.isEmpty) {
      _initMockVisits();
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
    super.onClose();
  }

  void _initMockVisits() {
    _allVisits.addAll([
      const StoreVisitModel(
        id: 'VIS-101',
        storeName: 'مطاعم ومطابخ شواية الرياض',
        managerName: 'أبو فهد القحطاني',
        phone: '0501234567',
        openingsCount: 3,
        crNumber: '1010892341',
        address: 'حي الملقا - طريق أنس بن مالك',
        category: 'مطاعم ومأكولات',
        distanceKm: 0.3,
        timeSlot: '09:00 ص - 09:30 ص',
        visitStatus: StoreVisitStatus.completed,
        pipelineStep: StorePipelineStep.contractSigned,
        isQualifiedOutcome: true,
        durationMinutes: 24,
      ),
      const StoreVisitModel(
        id: 'VIS-102',
        storeName: 'أريج كافيه & روستري',
        managerName: 'م. راكان الشمري',
        phone: '0559876543',
        openingsCount: 2,
        crNumber: '1010774512',
        address: 'حي الياسمين - طريق الثمامة',
        category: 'كافيهات ومشروبات',
        distanceKm: 0.6,
        timeSlot: '09:45 ص - 10:15 ص',
        visitStatus: StoreVisitStatus.completed,
        pipelineStep: StorePipelineStep.negotiating,
        isQualifiedOutcome: true,
        durationMinutes: 28,
      ),
      const StoreVisitModel(
        id: 'VIS-103',
        storeName: 'أسواق زهرة الربيع للمواد الغذائية',
        managerName: 'عبدالرحمن العتيبي',
        phone: '0543322114',
        openingsCount: 4,
        crNumber: '1010654321',
        address: 'حي الصحافة - شارع العليا',
        category: 'سوبرماركت وتموينات',
        distanceKm: 1.1,
        timeSlot: '10:30 ص - 11:00 ص',
        visitStatus: StoreVisitStatus.followUp,
        pipelineStep: StorePipelineStep.gracePeriod,
        isQualifiedOutcome: true,
        durationMinutes: 19,
      ),
      const StoreVisitModel(
        id: 'VIS-104',
        storeName: 'حلويات وبقلاوة النخيل الذهبي',
        managerName: 'فراس المصري',
        phone: '0562211998',
        openingsCount: 1,
        crNumber: '1010334455',
        address: 'حي النرجس - طريق أبي بكر الصديق',
        category: 'حلويات ومخبوزات',
        distanceKm: 1.4,
        timeSlot: '11:15 ص - 11:45 ص',
        visitStatus: StoreVisitStatus.scheduled,
        pipelineStep: StorePipelineStep.notMet,
        isQualifiedOutcome: false,
      ),
      const StoreVisitModel(
        id: 'VIS-105',
        storeName: 'مكسرات ومحامص البن الأصيل',
        managerName: 'سعود الدوسري',
        phone: '0507788990',
        openingsCount: 1,
        crNumber: '1010998877',
        address: 'حي العارض - شارع ريحانة بنت زيد',
        category: 'محامص ومكسرات',
        distanceKm: 1.8,
        timeSlot: '12:00 م - 12:30 م',
        visitStatus: StoreVisitStatus.scheduled,
        pipelineStep: StorePipelineStep.notMet,
        isQualifiedOutcome: false,
      ),
      const StoreVisitModel(
        id: 'VIS-106',
        storeName: 'صيدلية النقاء الحديثة',
        managerName: 'د. خالد الزهراني',
        phone: '0531122334',
        openingsCount: 1,
        crNumber: '1010445566',
        address: 'حي حطين - طريق الأمير تركي الأول',
        category: 'صيدليات وعناية',
        distanceKm: 2.2,
        timeSlot: '12:45 م - 01:15 م',
        visitStatus: StoreVisitStatus.scheduled,
        pipelineStep: StorePipelineStep.notMet,
        isQualifiedOutcome: false,
      ),
      const StoreVisitModel(
        id: 'VIS-107',
        storeName: 'معرض الأناقة للأحذية والحقائب',
        managerName: 'يوسف الغامدي',
        phone: '0554433221',
        openingsCount: 2,
        crNumber: '1010223344',
        address: 'حي المروة - شارع الإمام مسلم',
        category: 'أزياء وملابس',
        distanceKm: 2.5,
        timeSlot: '01:30 م - 02:00 م',
        visitStatus: StoreVisitStatus.scheduled,
        pipelineStep: StorePipelineStep.notMet,
        isQualifiedOutcome: false,
      ),
      const StoreVisitModel(
        id: 'VIS-108',
        storeName: 'مخبز ومطاحن خيرات بلادي',
        managerName: 'عماد الشريف',
        phone: '0509988776',
        openingsCount: 1,
        crNumber: '1010112233',
        address: 'حي نمار - طريق ديراب',
        category: 'مخابز ومعجنات',
        distanceKm: 3.1,
        timeSlot: '02:15 م - 02:45 م',
        visitStatus: StoreVisitStatus.scheduled,
        pipelineStep: StorePipelineStep.notMet,
        isQualifiedOutcome: false,
      ),
    ]);
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
    obstaclesController.text = visit.obstaclesNotes ?? '';
    _selectedClosingReason = visit.closingReason;

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

  void setClosingReason(String? reason) {
    _selectedClosingReason = reason;
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
        update();
      }
    } catch (e) {
      debugPrint('Front photo capture error: $e');
    }
  }

  Future<void> captureInsideImage() async {
    registerActivity();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        _insideImagePath = photo.path;
        update();
      }
    } catch (e) {
      debugPrint('Inside photo capture error: $e');
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
  bool submitAndFinishVisit() {
    if (_activeVisit == null) return false;

    // Outcome logic: qualified if minimum conditions met
    final bool isQualified = (_selectedPipelineStep != StorePipelineStep.notMet &&
            _selectedPipelineStep != StorePipelineStep.rejected &&
            _selectedPipelineStep != StorePipelineStep.notQualified) &&
        (_frontImagePath != null || _insideImagePath != null);

    final bool isFollowUpNeeded = (_selectedPipelineStep == StorePipelineStep.gracePeriod ||
        _selectedPipelineStep == StorePipelineStep.negotiating ||
        _selectedPipelineStep == StorePipelineStep.interested ||
        _selectedFollowUpDate != null);

    final updated = _activeVisit!.copyWith(
      storeName: storeNameController.text.trim(),
      managerName: managerNameController.text.trim(),
      phone: phoneController.text.trim(),
      openingsCount: int.tryParse(openingsController.text.trim()) ?? 1,
      crNumber: crNumberController.text.trim(),
      pipelineStep: _selectedPipelineStep,
      visitStatus: isFollowUpNeeded ? StoreVisitStatus.followUp : StoreVisitStatus.completed,
      isQualifiedOutcome: isQualified,
      frontImagePath: _frontImagePath,
      insideImagePath: _insideImagePath,
      nextFollowUpDate: _selectedFollowUpDate,
      nextFollowUpCommitments: commitmentsController.text.trim(),
      obstaclesNotes: obstaclesController.text.trim(),
      closingReason: _selectedClosingReason,
      closingReasonOtherDetails: otherReasonController.text.trim(),
      confidentialNotes: confidentialNotesController.text.trim(),
      durationMinutes: (_elapsedVisitSeconds / 60).ceil(),
      completedAt: DateTime.now(),
    );

    // Update in all visits list
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

    // Call backend API in background
    try {
      if (Get.isRegistered<ApiClient>()) {
        Get.find<ApiClient>().postData(
          '${AppConstants.marketerVisitsUri}/$finishedVisitId/complete',
          {
            'store_name': updated.storeName,
            'manager_name': updated.managerName,
            'phone': updated.phone,
            'openings_count': updated.openingsCount,
            'cr_number': updated.crNumber,
            'pipeline_step': updated.pipelineStep.name,
            'obstacles_notes': updated.obstaclesNotes,
            'closing_reason': updated.closingReason,
            'closing_reason_other_details': updated.closingReasonOtherDetails,
            'confidential_notes': updated.confidentialNotes,
            'front_image': updated.frontImagePath,
            'inside_image': updated.insideImagePath,
            'is_qualified': updated.isQualifiedOutcome,
            if (updated.nextFollowUpDate != null)
              'next_follow_up_date': updated.nextFollowUpDate!.toIso8601String(),
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
