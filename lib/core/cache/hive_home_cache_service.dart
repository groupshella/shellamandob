import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight caching service for ETags, zones, and app configuration.
/// Stripped of deleted customer store/cart/item/banner dependencies.
class HiveHomeCacheService {
  static final HiveHomeCacheService _instance = HiveHomeCacheService._internal();
  factory HiveHomeCacheService() => _instance;
  HiveHomeCacheService._internal();

  static const String _appConfigBox = 'app_config';
  static const String _zoneDataBox = 'zone_data';
  static const String _lastSelectedModuleKey = 'last_selected_module_id';
  static const String _lastKnownZoneKey = 'last_known_zone';

  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_appConfigBox)) {
        await Hive.openBox<String>(_appConfigBox);
      }
      if (!Hive.isBoxOpen(_zoneDataBox)) {
        await Hive.openBox<String>(_zoneDataBox);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ HiveHomeCacheService init error: $e');
    }
  }

  // --- ETag caching ---
  Future<String?> getEtag(String key) async {
    try {
      final box = Hive.isBoxOpen(_appConfigBox)
          ? Hive.box<String>(_appConfigBox)
          : await Hive.openBox<String>(_appConfigBox);
      return box.get('etag_$key');
    } catch (_) {
      return null;
    }
  }

  Future<void> saveEtag(String key, String etag) async {
    try {
      final box = Hive.isBoxOpen(_appConfigBox)
          ? Hive.box<String>(_appConfigBox)
          : await Hive.openBox<String>(_appConfigBox);
      await box.put('etag_$key', etag);
    } catch (_) {}
  }

  // --- Module caching ---
  static Future<int?> getLastSelectedModuleId() async {
    try {
      final box = Hive.isBoxOpen(_appConfigBox)
          ? Hive.box<String>(_appConfigBox)
          : await Hive.openBox<String>(_appConfigBox);
      final val = box.get(_lastSelectedModuleKey);
      return val != null ? int.tryParse(val) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLastSelectedModuleId(int id) async {
    try {
      final box = Hive.isBoxOpen(_appConfigBox)
          ? Hive.box<String>(_appConfigBox)
          : await Hive.openBox<String>(_appConfigBox);
      await box.put(_lastSelectedModuleKey, id.toString());
    } catch (_) {}
  }

  // --- Zone caching ---
  Future<Map<String, dynamic>?> loadLastKnownZone() async {
    try {
      final box = Hive.isBoxOpen(_zoneDataBox)
          ? Hive.box<String>(_zoneDataBox)
          : await Hive.openBox<String>(_zoneDataBox);
      final raw = box.get(_lastKnownZoneKey);
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveLastKnownZone(dynamic zoneData) async {
    try {
      final box = Hive.isBoxOpen(_zoneDataBox)
          ? Hive.box<String>(_zoneDataBox)
          : await Hive.openBox<String>(_zoneDataBox);
      final jsonStr = zoneData is String ? zoneData : jsonEncode(zoneData);
      await box.put(_lastKnownZoneKey, jsonStr);
    } catch (_) {}
  }

  Future<void> saveZoneData(String key, dynamic zoneData) async {
    try {
      final box = Hive.isBoxOpen(_zoneDataBox)
          ? Hive.box<String>(_zoneDataBox)
          : await Hive.openBox<String>(_zoneDataBox);
      final jsonStr = zoneData is String ? zoneData : jsonEncode(zoneData);
      await box.put(key, jsonStr);
    } catch (_) {}
  }

  Future<dynamic> loadHomeUnifiedData(int moduleId) async => null;
  Future<void> saveHomeUnifiedData(int moduleId, dynamic data) async {}
  Future<void> savePromotionalContent(dynamic content, {int? moduleId}) async {}

  Future<void> clearAllCache() async {
    try {
      if (Hive.isBoxOpen(_appConfigBox)) {
        await Hive.box<String>(_appConfigBox).clear();
      }
      if (Hive.isBoxOpen(_zoneDataBox)) {
        await Hive.box<String>(_zoneDataBox).clear();
      }
    } catch (_) {}
  }
}
