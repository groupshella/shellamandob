import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class MarketerShiftService {
  final ApiClient apiClient;

  MarketerShiftService({required this.apiClient});

  /// 1) Zone Lock & Geofencing
  /// GET /api/v1/customer/marketer/zones
  Future<Response> getZones() async {
    try {
      return await apiClient.getData(
        AppConstants.marketerZonesUri,
        useEtag: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] getZones error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// POST /api/v1/customer/marketer/zone/lock
  Future<Response> lockZone({
    required int zoneId,
    required double lat,
    required double lng,
  }) async {
    try {
      return await apiClient.postData(
        AppConstants.marketerZoneLockUri,
        {
          'zone_id': zoneId,
          'lat': lat,
          'lng': lng,
        },
        handleError: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] lockZone error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// POST /api/v1/customer/marketer/zone/change-request
  Future<Response> requestZoneChange({
    required int requestedZoneId,
    String? reason,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'requested_zone_id': requestedZoneId,
      };
      if (reason != null && reason.trim().isNotEmpty) {
        body['reason'] = reason.trim();
      }
      return await apiClient.postData(
        AppConstants.marketerZoneChangeRequestUri,
        body,
        handleError: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] requestZoneChange error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// GET /api/v1/customer/marketer/zone/change-request/status
  Future<Response> getZoneChangeRequestStatus() async {
    try {
      return await apiClient.getData(
        AppConstants.marketerZoneChangeRequestStatusUri,
        useEtag: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] getZoneChangeRequestStatus error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// 2) Dashboard & Shift Controls
  /// POST /api/v1/customer/marketer/shift/start
  Future<Response> startShift({
    required double lat,
    required double lng,
    XFile? selfie,
  }) async {
    try {
      final Map<String, String> body = {
        'lat': lat.toString(),
        'lng': lng.toString(),
      };

      if (selfie != null) {
        return await apiClient.postMultipartData(
          AppConstants.marketerShiftStartUri,
          body,
          [MultipartBody('selfie', selfie)],
          handleError: false,
        );
      } else {
        return await apiClient.postData(
          AppConstants.marketerShiftStartUri,
          {
            'lat': lat,
            'lng': lng,
          },
          handleError: false,
        );
      }
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] startShift error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// POST /api/v1/customer/marketer/shift/break
  Future<Response> startBreak() async {
    try {
      return await apiClient.postData(
        AppConstants.marketerShiftBreakUri,
        {},
        handleError: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] startBreak error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// POST /api/v1/customer/marketer/shift/resume
  Future<Response> resumeShift() async {
    try {
      return await apiClient.postData(
        AppConstants.marketerShiftResumeUri,
        {},
        handleError: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] resumeShift error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// POST /api/v1/customer/marketer/shift/end
  Future<Response> endShift({
    required double lat,
    required double lng,
  }) async {
    try {
      return await apiClient.postData(
        AppConstants.marketerShiftEndUri,
        {
          'lat': lat,
          'lng': lng,
        },
        handleError: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] endShift error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// GET /api/v1/customer/marketer/shift/current
  Future<Response> getCurrentShift() async {
    try {
      return await apiClient.getData(
        AppConstants.marketerShiftCurrentUri,
        useEtag: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] getCurrentShift error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  /// GET /api/v1/customer/marketer/shift/history
  Future<Response> getShiftHistory() async {
    try {
      return await apiClient.getData(
        AppConstants.marketerShiftHistoryUri,
        useEtag: false,
      );
    } catch (e) {
      debugPrint('❌ [MarketerShiftService] getShiftHistory error: $e');
      return Response(statusCode: 500, statusText: e.toString());
    }
  }
}
