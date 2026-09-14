// ignore_for_file: constant_identifier_names

/// Environment Configuration for Indian Shella App
/// This file manages different environment configurations
///
/// Values can be injected at build time via --dart-define:
///   --dart-define=ENV=production
///   --dart-define=BASE_URL=https://shellafood.com
///   --dart-define=PUSHER_SCHEME=wss
///   --dart-define=PUSHER_HOST=shellafood.com
///   --dart-define=PUSHER_PORT=443
///   --dart-define=PUSHER_KEY=your_key
///
/// Available environments:
/// - development: Local dev server
/// - staging: Staging server
/// - production: Production server
/// - azure: Azure test server
library;

import 'package:flutter/foundation.dart';
import 'package:sixam_mart/common/utils/app_logger.dart';

enum Environment { development, staging, production, azure }

class EnvironmentConfig {
  static const String _rawEnv =
      String.fromEnvironment('ENV', defaultValue: 'development');

  static const String _rawBaseUrl = String.fromEnvironment('BASE_URL');

  static const String _rawPusherScheme =
      String.fromEnvironment('PUSHER_SCHEME');

  static const String _rawPusherHost = String.fromEnvironment('PUSHER_HOST');

  static const int _rawPusherPort =
      int.fromEnvironment('PUSHER_PORT', defaultValue: 0);

  static const String _rawPusherKey = String.fromEnvironment('PUSHER_KEY');

  static const String pusherAppId = String.fromEnvironment('PUSHER_APP_ID');

  static const String pusherCluster = String.fromEnvironment('PUSHER_CLUSTER');

  /// Resolved current environment based on ENV dart-define
  static Environment get currentEnvironment {
    switch (_rawEnv.toLowerCase()) {
      case 'development':
      case 'dev':
      case 'local':
        return Environment.development;
      case 'staging':
        return Environment.staging;
      case 'azure':
        return Environment.azure;
      case 'production':
      case 'prod':
      default:
        return Environment.production;
    }
  }

  // Environment-specific configurations
  static const Map<Environment, Map<String, String>> _configs = {
    Environment.development: {
      'baseUrl': String.fromEnvironment('DEV_BASE_URL',
          defaultValue: 'http://192.168.1.4:8000'),
      'webHostedUrl': String.fromEnvironment('DEV_BASE_URL',
          defaultValue: 'http://192.168.1.4:8000'),
      'description': 'Local LAN Dev (http://192.168.1.4:8000)',
    },
    Environment.staging: {
      'baseUrl': 'https://shellafood.com',
      'webHostedUrl': 'https://shellafood.com',
      'description': 'Staging Server',
    },
    Environment.production: {
      'baseUrl': 'https://shellafood.com',
      'webHostedUrl': 'https://shellafood.com',
      'description': 'Production Server',
    },
    Environment.azure: {
      'baseUrl': 'https://shellagroup.uaenorth.cloudapp.azure.com',
      'webHostedUrl': 'https://shellagroup.uaenorth.cloudapp.azure.com',
      'description': 'Azure (shellagroup)',
    },
  };

  /// Get current base URL based on environment or BASE_URL override
  static String get baseUrl {
    if (_rawBaseUrl.isNotEmpty) {
      return _rawBaseUrl;
    }
    return _configs[currentEnvironment]!['baseUrl']!;
  }

  /// Get current web hosted URL based on environment
  static String get webHostedUrl =>
      _configs[currentEnvironment]!['webHostedUrl']!;

  /// Get current environment description
  static String get description =>
      _configs[currentEnvironment]!['description']!;

  /// Check if current environment is development
  static bool get isDevelopment =>
      currentEnvironment == Environment.development;

  /// Check if current environment is staging
  static bool get isStaging => currentEnvironment == Environment.staging;

  /// Check if current environment is production
  static bool get isProduction => currentEnvironment == Environment.production;

  /// Get environment name as string
  static String get environmentName => currentEnvironment.name.toUpperCase();

  /// Pusher host
  static String get pusherHost {
    if (_rawPusherHost.isNotEmpty) {
      return _rawPusherHost;
    }
    try {
      final uri = Uri.parse(baseUrl);
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (_) {}
    return isProduction ? 'shellafood.com' : '127.0.0.1';
  }

  /// Pusher scheme (wss for production/https, ws for local dev)
  static String get pusherScheme {
    if (_rawPusherScheme.isNotEmpty) {
      return _rawPusherScheme;
    }
    try {
      final uri = Uri.parse(baseUrl);
      if (uri.scheme == 'https') {
        return 'wss';
      }
    } catch (_) {}
    return isProduction ? 'wss' : 'ws';
  }

  /// Pusher port (443 for wss, 6001 for local dev)
  static int get pusherPort {
    if (_rawPusherPort > 0) {
      return _rawPusherPort;
    }
    return pusherScheme == 'wss' ? 443 : 6001;
  }

  /// Pusher key (injected via PUSHER_KEY or fallback in dev only)
  static String get pusherKey {
    if (_rawPusherKey.isNotEmpty) {
      return _rawPusherKey;
    }
    if (isDevelopment) {
      return 'local';
    }
    return '';
  }

  /// Master switch for TLS certificate pinning.
  static const bool enableCertificatePinning = false;

  /// Check if secure HTTP client should be used
  static bool get useSecureHttpClient =>
      currentEnvironment == Environment.production;

  /// Print current environment configuration
  static void printConfig() {
    if (kDebugMode) {
      appLogger.info('🌐 Environment: $environmentName');
      appLogger.info('🔗 Base URL: $baseUrl');
      appLogger.info('🌐 Web URL: $webHostedUrl');
      appLogger.info('📝 Description: $description');
      appLogger.info('⚡ Pusher Host: $pusherHost');
      appLogger.info('⚡ Pusher Port: $pusherPort');
      appLogger.info('⚡ Pusher Scheme: $pusherScheme');
    }
  }
}
