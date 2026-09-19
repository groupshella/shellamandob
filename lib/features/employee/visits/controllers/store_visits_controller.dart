import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  // Inactivity tracking (10-minute threshold)
  int _inactivitySeconds = 0;
  int get inactivitySeconds => _inactivitySeconds;
  static const int inactivityThresholdSeconds = 600; // 10 minutes

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

  // Visits lists
  final List<StoreVisitModel> _allVisits = [];
  List<StoreVisitModel> get allVisits => _allVisits;

  @override
  void onInit() {
    super.onInit();
    _initMockVisits();
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
        category: 'عطارة ومحامص',
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
        phone: '0534455667',
        openingsCount: 2,
        crNumber: '1010445566',
        address: 'حي حطين - طريق الأمير تركي الأول',
        category: 'صيدليات وعناية',
        distanceKm: 2.2,
        timeSlot: '01:00 م - 01:30 م',
        visitStatus: StoreVisitStatus.scheduled,
        pipelineStep: StorePipelineStep.notMet,
        isQualifiedOutcome: false,
      ),
    ]);
  }

  // Filtered lists
  List<StoreVisitModel> get filteredVisits {
    switch (_selectedFilterIndex) {
      case 1:
        return _allVisits.where((v) => v.visitStatus == StoreVisitStatus.scheduled || v.visitStatus == StoreVisitStatus.inProgress).toList();
      case 2:
        return _allVisits.where((v) => v.visitStatus == StoreVisitStatus.completed).toList();
      case 3:
        return _allVisits.where((v) => v.visitStatus == StoreVisitStatus.followUp).toList();
      default:
        return _allVisits;
    }
  }

  int get completedVisitsCount => _allVisits.where((v) => v.visitStatus == StoreVisitStatus.completed).length;
  int get qualifiedVisitsCount => _allVisits.where((v) => v.isQualifiedOutcome).length;
  int get followUpVisitsCount => _allVisits.where((v) => v.visitStatus == StoreVisitStatus.followUp).length;
  double get dailyProgressPercentage => (qualifiedVisitsCount / dailyTargetVisits).clamp(0.0, 1.0);

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    update();
  }

  void toggleConfidentialReport() {
    _isConfidentialReportExpanded = !_isConfidentialReportExpanded;
    update();
  }

  // Start a store visit
  void startVisit(StoreVisitModel visit) {
    _activeVisit = visit.copyWith(
      visitStatus: StoreVisitStatus.inProgress,
      startedAt: DateTime.now(),
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

    _elapsedVisitSeconds = 0;
    _inactivitySeconds = 0;

    _startVisitTimer();
    update();
  }

  void _startVisitTimer() {
    _visitTimer?.cancel();
    _visitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedVisitSeconds++;
      _inactivitySeconds++;

      // Trigger anti-fraud inactivity warnings if inactive for >= 10 minutes
      if (_inactivitySeconds == inactivityThresholdSeconds) {
        if (Get.isRegistered<AntiFraudAlertsController>()) {
          Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert1);
        }
      } else if (_inactivitySeconds == inactivityThresholdSeconds + 180) { // +3 min
        if (Get.isRegistered<AntiFraudAlertsController>()) {
          Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert2);
        }
      } else if (_inactivitySeconds == inactivityThresholdSeconds + 360) { // +6 min
        if (Get.isRegistered<AntiFraudAlertsController>()) {
          Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.alert3);
        }
      } else if (_inactivitySeconds >= inactivityThresholdSeconds + 540) { // +9 min -> critical
        if (Get.isRegistered<AntiFraudAlertsController>()) {
          Get.find<AntiFraudAlertsController>().triggerAlert(AlertLevel.criticalAlert4);
        }
      }

      update();
    });
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
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (file != null) {
        if (isFrontImage) {
          _frontImagePath = file.path;
        } else {
          _insideImagePath = file.path;
        }
        registerActivity();
        update();
      }
    } catch (e) {
      debugPrint('Error capturing store photo: $e');
    }
  }

  // Save digital signature
  void setContractSignature(String path) {
    if (_activeVisit != null) {
      _activeVisit = _activeVisit!.copyWith(
        contractSignaturePath: path,
        pipelineStep: StorePipelineStep.contractSigned,
      );
      _selectedPipelineStep = StorePipelineStep.contractSigned;
      update();
    }
  }

  // Finish visit logic with qualification evaluation
  bool submitAndFinishVisit() {
    if (_activeVisit == null) return false;

    // Outcome logic: qualified if minimum conditions met
    // (Presented, Interested, Grace Period, Negotiating, or Contract Signed + at least one photo captured)
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

    _visitTimer?.cancel();
    _activeVisit = null;
    update();

    // Update main shift metrics if controller exists
    if (Get.isRegistered<EmployeeShiftController>()) {
      Get.find<EmployeeShiftController>().recordVisitCompleted(isQualified);
    }

    return true;
  }
}
