import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineVisitItem {
  final String clientUuid;
  final String? visitId; // if completing an existing scheduled visit
  final String storeName;
  final String? managerName;
  final String? decisionMakerName;
  final String? decisionMakerPhone;
  final String? decisionMakerBestTime;
  final String? interviewedPersonRole;
  final String? phone;
  final String? address;
  final String? category;
  final double? latitude;
  final double? longitude;
  final String pipelineStep;
  final String? interestStatus;
  final String? selectedPromo;
  final String visitStatus;
  final bool isQualified;
  final int openingsCount;
  final String? crNumber;
  final String? frontImagePath; // local file path
  final String? insideImagePath; // local file path
  final String? contractSignaturePath; // local file path
  final String? nextFollowUpDate;
  final String? nextFollowUpCommitments;
  final String? obstaclesNotes;
  final String? closingReason;
  final String? closingReasonOtherDetails;
  final String? confidentialNotes;
  final int durationMinutes;
  final bool isExtended;
  final int extendedMinutes;
  final DateTime offlineCreatedAt;
  final List<Map<String, dynamic>> branches;
  final String syncStatus; // 'pending' | 'syncing' | 'failed' | 'synced'
  final String? lastError;

  OfflineVisitItem({
    required this.clientUuid,
    this.visitId,
    required this.storeName,
    this.managerName,
    this.decisionMakerName,
    this.decisionMakerPhone,
    this.decisionMakerBestTime,
    this.interviewedPersonRole,
    this.phone,
    this.address,
    this.category,
    this.latitude,
    this.longitude,
    required this.pipelineStep,
    this.interestStatus,
    this.selectedPromo,
    this.visitStatus = 'completed',
    this.isQualified = false,
    this.openingsCount = 1,
    this.crNumber,
    this.frontImagePath,
    this.insideImagePath,
    this.contractSignaturePath,
    this.nextFollowUpDate,
    this.nextFollowUpCommitments,
    this.obstaclesNotes,
    this.closingReason,
    this.closingReasonOtherDetails,
    this.confidentialNotes,
    this.durationMinutes = 15,
    this.isExtended = false,
    this.extendedMinutes = 0,
    required this.offlineCreatedAt,
    this.branches = const [],
    this.syncStatus = 'pending',
    this.lastError,
  });

  Map<String, dynamic> toJson() => {
    'client_uuid': clientUuid,
    'visit_id': visitId,
    'store_name': storeName,
    'manager_name': managerName,
    'decision_maker_name': decisionMakerName,
    'decision_maker_phone': decisionMakerPhone,
    'decision_maker_best_time': decisionMakerBestTime,
    'interviewed_person_role': interviewedPersonRole,
    'phone': phone,
    'address': address,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'pipeline_step': pipelineStep,
    'interest_status': interestStatus,
    'selected_promo': selectedPromo,
    'visit_status': visitStatus,
    'is_qualified': isQualified,
    'openings_count': openingsCount,
    'cr_number': crNumber,
    'front_image_path': frontImagePath,
    'inside_image_path': insideImagePath,
    'contract_signature_path': contractSignaturePath,
    'next_follow_up_date': nextFollowUpDate,
    'next_follow_up_commitments': nextFollowUpCommitments,
    'obstacles_notes': obstaclesNotes,
    'closing_reason': closingReason,
    'closing_reason_other_details': closingReasonOtherDetails,
    'confidential_notes': confidentialNotes,
    'duration_minutes': durationMinutes,
    'is_extended': isExtended,
    'extended_minutes': extendedMinutes,
    'offline_created_at': offlineCreatedAt.toIso8601String(),
    'branches': branches,
    'sync_status': syncStatus,
    'last_error': lastError,
  };

  factory OfflineVisitItem.fromJson(Map<String, dynamic> json) => OfflineVisitItem(
    clientUuid: json['client_uuid'] ?? '',
    visitId: json['visit_id']?.toString(),
    storeName: json['store_name'] ?? '',
    managerName: json['manager_name'],
    decisionMakerName: json['decision_maker_name'],
    decisionMakerPhone: json['decision_maker_phone'],
    decisionMakerBestTime: json['decision_maker_best_time'],
    interviewedPersonRole: json['interviewed_person_role'],
    phone: json['phone'],
    address: json['address'],
    category: json['category'],
    latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    pipelineStep: json['pipeline_step'] ?? 'interested',
    interestStatus: json['interest_status'],
    selectedPromo: json['selected_promo'],
    visitStatus: json['visit_status'] ?? 'completed',
    isQualified: json['is_qualified'] == true || json['is_qualified'] == 1,
    openingsCount: json['openings_count'] ?? 1,
    crNumber: json['cr_number'],
    frontImagePath: json['front_image_path'],
    insideImagePath: json['inside_image_path'],
    contractSignaturePath: json['contract_signature_path'],
    nextFollowUpDate: json['next_follow_up_date'],
    nextFollowUpCommitments: json['next_follow_up_commitments'],
    obstaclesNotes: json['obstacles_notes'],
    closingReason: json['closing_reason'],
    closingReasonOtherDetails: json['closing_reason_other_details'],
    confidentialNotes: json['confidential_notes'],
    durationMinutes: json['duration_minutes'] ?? 15,
    isExtended: json['is_extended'] == true || json['is_extended'] == 1,
    extendedMinutes: json['extended_minutes'] ?? 0,
    offlineCreatedAt: json['offline_created_at'] != null
        ? DateTime.parse(json['offline_created_at'])
        : DateTime.now(),
    branches: (json['branches'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
    syncStatus: json['sync_status'] ?? 'pending',
    lastError: json['last_error'],
  );

  OfflineVisitItem copyWith({
    String? syncStatus,
    String? lastError,
  }) {
    return OfflineVisitItem(
      clientUuid: clientUuid,
      visitId: visitId,
      storeName: storeName,
      managerName: managerName,
      decisionMakerName: decisionMakerName,
      decisionMakerPhone: decisionMakerPhone,
      decisionMakerBestTime: decisionMakerBestTime,
      interviewedPersonRole: interviewedPersonRole,
      phone: phone,
      address: address,
      category: category,
      latitude: latitude,
      longitude: longitude,
      pipelineStep: pipelineStep,
      interestStatus: interestStatus,
      selectedPromo: selectedPromo,
      visitStatus: visitStatus,
      isQualified: isQualified,
      openingsCount: openingsCount,
      crNumber: crNumber,
      frontImagePath: frontImagePath,
      insideImagePath: insideImagePath,
      contractSignaturePath: contractSignaturePath,
      nextFollowUpDate: nextFollowUpDate,
      nextFollowUpCommitments: nextFollowUpCommitments,
      obstaclesNotes: obstaclesNotes,
      closingReason: closingReason,
      closingReasonOtherDetails: closingReasonOtherDetails,
      confidentialNotes: confidentialNotes,
      durationMinutes: durationMinutes,
      isExtended: isExtended,
      extendedMinutes: extendedMinutes,
      offlineCreatedAt: offlineCreatedAt,
      branches: branches,
      syncStatus: syncStatus ?? this.syncStatus,
      lastError: lastError ?? this.lastError,
    );
  }
}

class OfflineVisitStorageService {
  static const String _storageKey = 'offline_pending_visits_v1';

  static Future<List<OfflineVisitItem>> getPendingVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];

      final List decoded = jsonDecode(raw);
      return decoded.map((e) => OfflineVisitItem.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('❌ [OfflineVisitStorageService] getPendingVisits error: $e');
      return [];
    }
  }

  static Future<void> saveVisit(OfflineVisitItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getPendingVisits();

      // Replace if existing with same clientUuid, else append
      final index = currentList.indexWhere((e) => e.clientUuid == item.clientUuid);
      if (index >= 0) {
        currentList[index] = item;
      } else {
        currentList.add(item);
      }

      final jsonStr = jsonEncode(currentList.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
      debugPrint('💾 [OfflineVisitStorageService] Visit saved locally: ${item.clientUuid} (${item.storeName})');
    } catch (e) {
      debugPrint('❌ [OfflineVisitStorageService] saveVisit error: $e');
    }
  }

  static Future<void> removeVisit(String clientUuid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getPendingVisits();
      currentList.removeWhere((e) => e.clientUuid == clientUuid);

      final jsonStr = jsonEncode(currentList.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
      debugPrint('🗑️ [OfflineVisitStorageService] Visit removed after sync: $clientUuid');
    } catch (e) {
      debugPrint('❌ [OfflineVisitStorageService] removeVisit error: $e');
    }
  }

  static Future<void> updateVisitStatus(String clientUuid, String status, {String? error}) async {
    try {
      final currentList = await getPendingVisits();
      final index = currentList.indexWhere((e) => e.clientUuid == clientUuid);
      if (index >= 0) {
        currentList[index] = currentList[index].copyWith(syncStatus: status, lastError: error);
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = jsonEncode(currentList.map((e) => e.toJson()).toList());
        await prefs.setString(_storageKey, jsonStr);
      }
    } catch (e) {
      debugPrint('❌ [OfflineVisitStorageService] updateVisitStatus error: $e');
    }
  }

  static Future<int> getPendingCount() async {
    final list = await getPendingVisits();
    return list.where((e) => e.syncStatus != 'synced').length;
  }
}
