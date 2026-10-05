import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/environment_config.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';

/// Centralized Mock Network Dispatcher for Offline Demo / Test Builds.
/// Intercepts network calls before reaching the wire when [EnvironmentConfig.useMockMode] is true.
class MockNetworkDispatcher {
  /// Check if mock mode is currently enabled
  static bool get isEnabled => EnvironmentConfig.useMockMode;

  /// Simulated network latency (milliseconds) to test shimmers & loaders realistically
  static const int simulatedDelayMs = 300;

  // In-memory store for dynamic demo state (persists during the session)
  static String _mockNafathCode = '54';
  static DateTime? _mockNafathInitiatedAt;

  static final List<Map<String, dynamic>> _mockMerchantPromos = [
    {
      'id': 1,
      'title_ar': 'باقة التأسيس الماسي للشركاء الجدد',
      'title_en': 'Diamond Foundation Package for New Partners',
      'code': 'GROWTH-DIAMOND-2026',
      'discount_type': 'percent',
      'discount_value': 50.0,
      'min_order_amount': 0.0,
      'badge': 'الأكثر طلباً',
      'description_ar': 'خصم 50% على عمولة شلة لأول 3 أشهر + دعم فني مخصص وتسويق مجاني للمتجر.',
      'description_en': '50% off commission for 3 months with dedicated marketing support.',
      'is_active': true,
      'valid_until': '2026-12-31',
    },
    {
      'id': 2,
      'title_ar': 'باقة التوصيل المجاني للعملاء',
      'title_en': 'Free Delivery for Customers Package',
      'code': 'FREE-DELIVERY-100',
      'discount_type': 'fixed',
      'discount_value': 100.0,
      'min_order_amount': 50.0,
      'badge': 'باقة سريعة',
      'description_ar': 'تغطية كاملة لرسوم التوصيل لأول 100 طلب من المتجر لتحفيز المبيعات الفورية.',
      'description_en': 'Full coverage for delivery fees on first 100 orders.',
      'is_active': true,
      'valid_until': '2026-11-30',
    },
    {
      'id': 3,
      'title_ar': 'باقة قطاع التموينات والبقالة الذهبية',
      'title_en': 'Grocery Sector Golden Package',
      'code': 'GROCERY-PRO-2026',
      'discount_type': 'percent',
      'discount_value': 30.0,
      'min_order_amount': 20.0,
      'badge': 'موصى به للبقالات',
      'description_ar': 'عمولة مخفضة 30% مع ربط أجهزة الكاشير ونظام قيدها للدفع الآجل مجاناً.',
      'description_en': '30% reduced commission with free POS and Qidha integration.',
      'is_active': true,
      'valid_until': '2026-12-31',
    },
  ];

  static final List<Map<String, dynamic>> _mockVisits = [
    {
      'id': 'VST-201',
      'store_name': 'تموينات أضواء الجزيرة',
      'manager_name': 'أبو فيصل الشمري',
      'phone': '+966551122334',
      'interest_status': 'مهتم جدًا',
      'openings_count': 3,
      'cr_number': '1010982341',
      'address': 'طريق الأمير محمد بن عبد العزيز، العليا',
      'category': 'بقالة وتموينات',
      'distance_km': 0.3,
      'latitude': 24.7118,
      'longitude': 46.6744,
      'time_slot': '09:00 ص - 09:30 ص',
      'pipeline_step': 'contractSigned',
      'visit_status': 'completed',
      'is_qualified': 1,
      'front_image': null,
      'inside_image': null,
      'closing_reason': 'تم توقيع العقد فوراً',
    },
    {
      'id': 'VST-202',
      'store_name': 'سوبرماركت النجمة الذهبية',
      'manager_name': 'خالد العتيبي',
      'phone': '+966554433221',
      'interest_status': 'طلب مهلة',
      'openings_count': 2,
      'cr_number': '1010776543',
      'address': 'حي الملقا، طريق أنس بن مالك',
      'category': 'سوبرماركت',
      'distance_km': 0.8,
      'latitude': 24.8105,
      'longitude': 46.6215,
      'time_slot': '10:00 ص - 10:30 ص',
      'pipeline_step': 'negotiating',
      'visit_status': 'followUp',
      'is_qualified': 1,
      'next_follow_up_date': '2026-10-02T10:00:00Z',
      'next_follow_up_commitments': 'مراجعة الأسعار ونسب العمولة مع المالك',
    },
    {
      'id': 'VST-203',
      'store_name': 'مخبز وحلويات الريف',
      'manager_name': 'سعيد العمري',
      'phone': '+966556677889',
      'interest_status': 'مهتم',
      'openings_count': 1,
      'cr_number': '1010665544',
      'address': 'حي طويق، شارع بلال بن رباح',
      'category': 'حلويات ومخابز',
      'distance_km': 1.2,
      'latitude': 24.5833,
      'longitude': 46.5412,
      'time_slot': '11:00 ص - 11:30 ص',
      'pipeline_step': 'interested',
      'visit_status': 'scheduled',
      'is_qualified': 0,
    },
    {
      'id': 'VST-204',
      'store_name': 'ملحمة الطازج الحديثة',
      'manager_name': 'عمر القحطاني',
      'phone': '+966558899001',
      'interest_status': 'تم تقديم شلة',
      'openings_count': 1,
      'cr_number': '1010554433',
      'address': 'حي نمار، طريق ديراب',
      'category': 'لحوم ودواجن',
      'distance_km': 2.1,
      'latitude': 24.5422,
      'longitude': 46.6110,
      'time_slot': '12:00 م - 12:30 م',
      'pipeline_step': 'presented',
      'visit_status': 'scheduled',
      'is_qualified': 0,
    },
    {
      'id': 'VST-205',
      'store_name': 'صيدلية العناية القصوى',
      'manager_name': 'د. أحمد رضوان',
      'phone': '+966550011223',
      'interest_status': 'غير مؤهل',
      'openings_count': 1,
      'cr_number': '1010443322',
      'address': 'حي النموذجية، شارع المعذر',
      'category': 'صيدليات',
      'distance_km': 3.5,
      'latitude': 24.6543,
      'longitude': 46.6872,
      'time_slot': '01:00 م - 01:30 م',
      'pipeline_step': 'notQualified',
      'visit_status': 'completed',
      'is_qualified': 0,
      'closing_reason': 'غير مؤهل',
    },
  ];

  static final Map<String, dynamic> _mockShiftState = {
    'status': 'active',
    'shift_id': 101,
    'zone_id': 1,
    'zone_name': 'غرب الرياض (طويق ونمار)',
    'started_at': '2026-09-28T08:30:00Z',
    'start_time_text': '08:30 ص',
    'worked_seconds': 9300,
    'worked_time_text': '02:35 ساعة',
    'overtime_seconds': 1200,
    'overtime_text': '00:20 ساعة',
    'approved_leave_seconds': 1800,
    'approved_leave_text': '00:30 ساعة',
    'target_visits': 16,
    'completed_visits': 12,
  };

  static final List<Map<String, dynamic>> _mockRecommendationsList = [
    {
      'id': '1',
      'supervisor_name': 'اسم المشرف',
      'supervisor_role': 'مسمى الوظيفة',
      'supervisor_avatar': 'assets/image/supervisor_avatar.png',
      'title': 'توصيات خاصة بالمبيعات',
      'content': 'حاول توضيح آلية عمل شلة ومزاياها قبل الانتقال للتعاقد.\nفي حالة التفاوض، سجل ملاحظات التاجر وحدد موعد متابعة واضح.',
      'is_read': false,
      'date_group': 'اليوم',
      'is_today': true,
      'time_text': '03:30 م',
      'created_at': '2026-10-03T15:30:00Z',
      'is_expanded': true,
    },
    {
      'id': '2',
      'supervisor_name': 'اسم المشرف',
      'supervisor_role': 'مسمى الوظيفة',
      'supervisor_avatar': 'assets/image/supervisor_avatar.png',
      'title': 'توجيهات يومية',
      'content': 'التركيز اليوم على المتاجر ذات النشاط الغذائي وتقديم عروض الباقات السنوية لشلة مع التوضيح الفوري لمزايا سرعة التحصيل.',
      'is_read': true,
      'date_group': 'اليوم',
      'is_today': true,
      'time_text': '03:30 م',
      'created_at': '2026-10-03T15:30:00Z',
      'is_expanded': false,
    },
    {
      'id': '3',
      'supervisor_name': 'اسم المشرف',
      'supervisor_role': 'مسمى الوظيفة',
      'supervisor_avatar': 'assets/image/supervisor_avatar.png',
      'title': 'توصيات لتحسين الأداء',
      'content': 'حاول توضيح آلية عمل شلة ومزاياها قبل الانتقال للتعاقد.\nفي حالة التفاوض، سجل ملاحظات التاجر وحدد موعد متابعة واضح.',
      'is_read': true,
      'date_group': 'الأربعاء 26 ,فبراير , 2026',
      'is_today': false,
      'time_text': '03:30 م',
      'created_at': '2026-02-26T15:30:00Z',
      'is_expanded': false,
    },
    {
      'id': '4',
      'supervisor_name': 'اسم المشرف',
      'supervisor_role': 'مسمى الوظيفة',
      'supervisor_avatar': 'assets/image/supervisor_avatar.png',
      'title': 'توصية خاصة بالمبيعات',
      'content': 'متابعة العملاء الذين أبدوا اهتماماً خلال الأسبوع الماضي وإعادة التواصل معهم قبل نهاية الشهر لإتمام التعاقد.',
      'is_read': true,
      'date_group': 'الأربعاء 26 ,فبراير , 2026',
      'is_today': false,
      'time_text': '03:30 م',
      'created_at': '2026-02-26T15:30:00Z',
      'is_expanded': false,
    },
    {
      'id': '5',
      'supervisor_name': 'اسم المشرف',
      'supervisor_role': 'مسمى الوظيفة',
      'supervisor_avatar': 'assets/image/supervisor_avatar.png',
      'title': 'توصية خاصة بالمبيعات',
      'content': 'التأكد من اكتمال مستندات السجل التجاري والهوية قبل رفع طلب انضمام المتجر لتقليص مدة الموافقة.',
      'is_read': true,
      'date_group': 'الأربعاء 26 ,فبراير , 2026',
      'is_today': false,
      'time_text': '03:30 م',
      'created_at': '2026-02-26T15:30:00Z',
      'is_expanded': false,
    },
  ];

  /// Dispatches any incoming request (GET, POST, PUT, DELETE) to the appropriate mock handler.
  static Future<Response<dynamic>?> dispatch(
    String method,
    String uri, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    if (!isEnabled) return null;

    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }

    if (kDebugMode) {
      debugPrint('⚡ [MockNetworkDispatcher] $method -> $uri');
    }

    final normalizedUri = uri.split('?').first;

    switch (method.toUpperCase()) {
      case 'GET':
        return _handleGet(normalizedUri, uri, query);
      case 'POST':
        return _handlePost(normalizedUri, uri, body);
      case 'PUT':
        return _handlePut(normalizedUri, uri, body);
      case 'DELETE':
        return _handleDelete(normalizedUri, uri);
      default:
        return Response(statusCode: 200, body: {'status': 'success', 'message': 'Mock OK'});
    }
  }

  // ==========================================
  // GET HANDLERS
  // ==========================================
  static Response<dynamic>? _handleGet(
    String path,
    String fullUri,
    Map<String, dynamic>? query,
  ) {
    // 1. Config & App Init (Splash)
    if (path.contains(AppConstants.configUri)) {
      return Response(statusCode: 200, body: _mockConfigPayload);
    }
    if (path.contains(AppConstants.appInitUri)) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {
          'config': _mockConfigPayload,
          'modules': _mockModulesList,
          'zones': _mockZonesList,
        },
      });
    }
    if (path.contains(AppConstants.landingPageUri)) {
      return Response(statusCode: 200, body: {'status': 'success', 'data': {}});
    }
    if (path.contains(AppConstants.bannerUri)) {
      return Response(statusCode: 200, body: {'banners': [], 'campaigns': []});
    }

    // 2. Customer Profile
    if (path.contains(AppConstants.customerInfoUri) || path.contains('/api/v1/customer/info')) {
      return Response(statusCode: 200, body: _mockUserInfoPayload);
    }

    // 3. Marketer Dashboard
    if (path.contains(AppConstants.marketerDashboardUri) || path.contains('/customer/marketer/dashboard')) {
      return Response(statusCode: 200, body: _mockDashboardPayload);
    }

    // 4. Marketer Zones & Geofencing
    if (path.contains(AppConstants.marketerZonesUri) || path.contains('/customer/marketer/zones')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {
          'locked_zone_id': 1,
          'locked_at': '2026-09-28 08:00:00',
          'zones': _mockZonesList,
        },
      });
    }
    if (path.contains(AppConstants.marketerZoneChangeRequestStatusUri)) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {'has_pending_request': false},
      });
    }

    // 5. Shift Status & History
    if (path.contains(AppConstants.marketerShiftCurrentUri) || path.contains('/customer/marketer/shift/current')) {
      final unreadRecs = _mockRecommendationsList.where((r) => r['is_read'] == false).length;
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {
          'status': _mockShiftState['status'],
          'employee': {'name': 'أحمد محمد'},
          'shift': _mockShiftState,
          'warnings': {
            'count': 2,
            'items': [
              {
                'id': '1',
                'title': 'تأخير في تسليم تقرير الزيارة',
                'date': '10 سبتمبر',
                'reason': 'تأخر تسليم التقرير عن الموعد المحدد',
              },
              {
                'id': '2',
                'title': 'مغادرة منطقة العمل بدون إذن',
                'date': '8 سبتمبر',
                'reason': 'التواجد خارج النطاق الجغرافي المحدد للوردية',
              },
            ],
          },
          'recommendations': {
            'count': _mockRecommendationsList.length,
            'unread_count': unreadRecs,
          },
          'visits_summary': {
            'total': 3,
            'completed': 1,
            'upcoming': 4,
            'needs_follow_up': 2,
            'next_visit': {
              'store_name': 'متجر الفرسان',
              'address': 'حي العليا، الرياض',
              'distance_km': 1.2,
              'time_slot': '09:00 ص',
            },
          },
        },
      });
    }

    // 5.1 Supervisor Recommendations List
    if (path.contains(AppConstants.marketerRecommendationsUri) || path.contains('/customer/marketer/recommendations')) {
      final unread = _mockRecommendationsList.where((r) => r['is_read'] == false).length;
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {
          'total': _mockRecommendationsList.length,
          'unread': unread,
          'recommendations': _mockRecommendationsList,
        },
      });
    }
    if (path.contains(AppConstants.marketerShiftHistoryUri)) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {
          'shifts': [
            {
              'id': 100,
              'date': '2026-09-27',
              'worked_seconds': 28800,
              'visits_count': 15,
              'status': 'completed',
            },
            {
              'id': 99,
              'date': '2026-09-26',
              'worked_seconds': 27000,
              'visits_count': 14,
              'status': 'completed',
            },
          ]
        },
      });
    }

    // 6. Store Visits List
    if (path.contains(AppConstants.marketerVisitsUri) || path.contains('/customer/marketer/visits')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': {
          'visits': _mockVisits,
          'total': _mockVisits.length,
          'target': 16,
          'completed': _mockVisits.where((v) => v['visit_status'] == 'completed').length,
        },
      });
    }

    // 7. Productivity & Reports
    if (path.contains(AppConstants.marketerProductivityUri) || path.contains('/customer/marketer/productivity')) {
      return Response(statusCode: 200, body: _mockProductivityPayload);
    }

    // 8. Notifications
    if (path.contains(AppConstants.notificationUri) || path.contains('/customer/notifications')) {
      return Response(statusCode: 200, body: [
        {
          'id': 1,
          'data': {
            'title': 'مكافأة إنجاز الهدف اليومي',
            'description': 'تمت إضافة 100 ر.س لرصيدك لتحقيقك 12 زيارة ناجحة اليوم!',
            'image': '',
            'type': 'reward',
          },
          'created_at': '2026-09-28T14:00:00Z',
        },
        {
          'id': 2,
          'data': {
            'title': 'تحديث نطاق العمل',
            'description': 'تم تخصيص قطاع غرب الرياض لنطاق جولاتك الميدانية.',
            'image': '',
            'type': 'zone',
          },
          'created_at': '2026-09-28T08:00:00Z',
        }
      ]);
    }

    // 9. Addresses / Zones check
    if (path.contains('/address/list') ||
        path.contains('/api/v2/address/list') ||
        path.contains('/customer/address/list') ||
        path.contains(AppConstants.addressListUri) ||
        path.contains(AppConstants.addressListV2Uri)) {
      final mockAddresses = [
        {
          'id': 1,
          'address_type': 'work',
          'contact_person_number': '+966501234567',
          'address': 'الرياض، المملكة العربية السعودية',
          'latitude': '24.7136',
          'longitude': '46.6753',
          'zone_id': 1,
          'zone_ids': [1],
          'city': 'الرياض',
          'region': 'الرياض',
          'street_name': 'طريق الملك فهد',
          'address_label': 'work',
        }
      ];
      return Response(statusCode: 200, body: {
        'status': 'success',
        'success': true,
        'addresses': mockAddresses,
        'zone_ids': [1],
      });
    }
    // 10. Merchant Promos Library
    if (path.contains('/customer/marketer/promos') && !path.contains('/activate')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': _mockMerchantPromos,
      });
    }

    // 10.1 Nafath Check Status (GET)
    if (path.contains('/nafath/checkStatus') || path.contains('/nafath/check-status')) {
      final elapsed = _mockNafathInitiatedAt != null
          ? DateTime.now().difference(_mockNafathInitiatedAt!).inSeconds
          : 10;
      final isApproved = elapsed >= 6;
      return Response(statusCode: 200, body: {
        'status': isApproved ? 'approved' : 'pending',
        'national_id': query?['national_id'] ?? '1010982341',
        'code': _mockNafathCode,
        'random': _mockNafathCode,
        'is_approved': isApproved,
        'can_proceed': isApproved,
        'full_name_ar': 'عبدالله بن سعد الدوسري (تاجر معتمد)',
      });
    }

    // 11. Instant Reward Settings
    if (path.contains('/customer/marketer/reward-settings')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'contract_signing_reward': 50.0,
        'qaidha_activation_reward': 30.0,
        'today_earnings': 240.0,
        'today_contracts_count': 3,
        'today_qaidha_count': 3,
      });
    }

    // 12. Supervisor Recommendations
    if (path.contains('/customer/marketer/recommendations')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': [
          {
            'id': 1,
            'title': 'التركيز على قطاع التموينات ومحلات البقالة',
            'content': 'نلاحظ إقبالاً كبيراً على باقة التوصيل في قطاع البقالة، ركز جهود اليوم على المتاجر ذات 2 فتحات أو أكثر.',
            'supervisor_name': 'م. فهد القرني (مشرف النمو الميداني)',
            'priority': 'high',
            'created_at': '2026-10-03T09:00:00Z',
            'is_read': false,
          },
          {
            'id': 2,
            'title': 'تفعيل عرض التأسيس الماسي للشركاء الجدد',
            'content': 'احرص على عرض خصم 50% على عمولة شلة عند توقيع العقد لزيادة نسبة الإغلاق الفوري.',
            'supervisor_name': 'م. فهد القرني (مشرف النمو الميداني)',
            'priority': 'normal',
            'created_at': '2026-10-02T11:30:00Z',
            'is_read': true,
          },
        ]
      });
    }

    // 13. Marketer Leaves
    if (path.contains('/customer/marketer/leaves')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'data': [
          {
            'id': 1,
            'leave_type': 'إجازة اعتيادية',
            'start_date': '2026-10-10',
            'end_date': '2026-10-12',
            'reason': 'ظرف عائلي خاص',
            'status': 'approved',
            'status_note': 'معتمد من إدارة العمليات الميدانية',
          }
        ]
      });
    }

    // Default Fallback for unmatched GET requests in mock mode
    return Response(statusCode: 200, body: {'status': 'success', 'data': []});
  }

  // ==========================================
  // POST HANDLERS
  // ==========================================
  static Response<dynamic>? _handlePost(String path, String fullUri, dynamic body) {
    // 1. Auth: Login & Send OTP (Compatible with both v1 and v2 auth)
    if (path.contains(AppConstants.loginUri) ||
        path.contains(AppConstants.sendOtpV2Uri) ||
        path.contains('/auth/send-otp') ||
        path.contains('/auth/customer-login')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'success': true,
        'otp_sent': true,
        'otp_required': true,
        'cooldown_seconds': 60,
        'expires_in_seconds': 600,
        'phone': body is Map ? body['phone']?.toString() : null,
        'message': 'تم إرسال رمز التحقق بنجاح إلى هاتفك (الكود: 1234)',
      });
    }

    // 2. Auth: Verify OTP / Sign Up (Returns successful user & token)
    if (path.contains(AppConstants.verifyLoginOtpUri) ||
        path.contains(AppConstants.verifyOtpV2Uri) ||
        path.contains(AppConstants.registerUri) ||
        path.contains(AppConstants.registerV2Uri) ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/verify-login-otp')) {
      // Pre-save address so location guards in AddressHelper don't block navigation
      try {
        AddressHelper.saveUserAddressInSharedPref(
          AddressModel(
            id: 1,
            addressType: 'work',
            contactPersonNumber: '+966501234567',
            address: 'الرياض، المملكة العربية السعودية',
            latitude: '24.7136',
            longitude: '46.6753',
            zoneId: 1,
            zoneIds: [1],
          ),
        );
      } catch (_) {}

      return Response(statusCode: 200, body: {
        'status': 'success',
        'success': true,
        'is_existed': true,
        'token': 'mock_marketer_token_shella_2026',
        'is_phone_verified': 1,
        'is_email_verified': 1,
        'is_personal_info': 1,
        'login_type': 'phone',
        'message': 'تم تسجيل الدخول بنجاح',
        'is_exist_user': {
          'id': 1001,
          'name': 'أحمد المسوق الميداني',
          'image': '',
        },
        'user': {
          'id': 1001,
          'f_name': 'أحمد',
          'l_name': 'المسوق الميداني',
          'phone': '+966501234567',
          'email': 'marketer@shella.com',
        },
      });
    }

    // 3. Zone Lock
    if (path.contains(AppConstants.marketerZoneLockUri)) {
      final int zId = (body is Map && body['zone_id'] != null)
          ? int.tryParse(body['zone_id'].toString()) ?? 1
          : 1;
      _mockShiftState['zone_id'] = zId;
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم قفل النطاق الجغرافي للمنطقة بنجاح',
      });
    }

    // 4. Zone Change Request
    if (path.contains(AppConstants.marketerZoneChangeRequestUri)) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم إرسال طلب تغيير المنطقة إلى المشرف بنجاح',
      });
    }

    // 5. Shift Operations (Start, Break, Resume, End)
    if (path.contains(AppConstants.marketerShiftStartUri)) {
      _mockShiftState['status'] = 'active';
      _mockShiftState['started_at'] = DateTime.now().toIso8601String();
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم بدء الشفت وتسجيل الحضور الميداني بنجاح',
        'data': _mockShiftState,
      });
    }
    if (path.contains(AppConstants.marketerShiftBreakUri)) {
      _mockShiftState['status'] = 'on_break';
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم تسجيل بداية فترة الاستراحة',
      });
    }
    if (path.contains(AppConstants.marketerShiftResumeUri)) {
      _mockShiftState['status'] = 'active';
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم استئناف الشفت ومواصلة الزيارات',
      });
    }
    if (path.contains(AppConstants.marketerShiftEndUri)) {
      _mockShiftState['status'] = 'not_started';
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم إنهاء الشفت وإغلاق دوام اليوم بنجاح',
      });
    }

    // 5.1 Recommendations mark as read
    if (path.contains('/customer/marketer/recommendations') && path.contains('/read')) {
      final segments = path.split('/');
      final readIndex = segments.indexOf('read');
      if (readIndex > 0) {
        final id = segments[readIndex - 1];
        for (var rec in _mockRecommendationsList) {
          if (rec['id'] == id) {
            rec['is_read'] = true;
          }
        }
      }
      return Response(statusCode: 200, body: {'status': 'success', 'message': 'تم تحديث حالة القراءة بنجاح'});
    }

    // 6. Store Visits: Create or Complete Visit
    if (path.contains('/customer/marketer/visits') || path.contains(AppConstants.marketerVisitsUri)) {
      if (path.contains('/start')) {
        return Response(statusCode: 200, body: {'status': 'success', 'message': 'تم بدء مؤقت الزيارة'});
      }
      if (path.contains('/alert')) {
        return Response(statusCode: 200, body: {'status': 'success', 'message': 'تم تسجيل الإنذار'});
      }
      if (path.contains('/complete') || path.contains('/store')) {
        // Dynamic addition/update to in-memory state
        if (body is Map) {
          final String newId = 'VST-${DateTime.now().millisecondsSinceEpoch % 10000}';
          final newVisit = {
            'id': newId,
            'store_name': body['store_name']?.toString() ?? 'متجر جديد تجريبي',
            'manager_name': body['manager_name']?.toString() ?? 'المدير المسؤول',
            'phone': body['phone']?.toString() ?? '+966500000000',
            'interest_status': body['interest_status']?.toString() ?? 'مهتم',
            'openings_count': int.tryParse('${body['openings_count']}') ?? 1,
            'cr_number': body['cr_number']?.toString() ?? '',
            'address': 'حي طويق، الرياض',
            'category': 'عام',
            'distance_km': 0.5,
            'time_slot': '12:00 م',
            'pipeline_step': body['pipeline_step']?.toString() ?? 'interested',
            'visit_status': 'completed',
            'is_qualified': 1,
          };
          _mockVisits.insert(0, newVisit);
        }
        return Response(statusCode: 200, body: {
          'status': 'success',
          'message': 'تم حفظ بيانات الزيارة وإتمامها بنجاح',
        });
      }
    }

    // 7. Marketer Apply
    if (path.contains(AppConstants.marketerApplyUri) || path.contains('/customer/marketer/apply')) {
      _mockDashboardPayload['data']['marketer_status'] = 'pending';
      _mockDashboardPayload['data']['applied_at'] = DateTime.now().toIso8601String();
      if (body is Map) {
        if (body['profession'] != null) _mockDashboardPayload['data']['profession'] = body['profession'];
        if (body['document_type'] != null) _mockDashboardPayload['data']['document_type'] = body['document_type'];
      }
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم استلام طلب انضمامك كمسوق بنجاح، وستتم مراجعته',
        'token': 'mock_marketer_token_shella_2026',
        'data': _mockDashboardPayload['data'],
      });
    }

    // 8. Update Profile
    if (path.contains(AppConstants.updateProfileUri)) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم تحديث البيانات الشخصية بنجاح',
      });
    }

    // 10. Verify Commercial Register
    if (path.contains('/customer/marketer/verify-cr')) {
      final cr = body is Map ? body['cr_number']?.toString() : null;
      return Response(statusCode: 200, body: {
        'status': 'success',
        'is_valid': true,
        'cr_number': cr ?? '1010892741',
        'store_name': 'مؤسسة أضواء التجارة للتجزئة',
        'is_registered_before': false,
        'message': 'السجل التجاري سليم ونشط وغير مسجل مسبقاً في شلة.',
      });
    }

    // 11. Activate Merchant Promo
    if (path.contains('/customer/marketer/promos/activate')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم تفعيل العرض الترويجي للمتجر بنجاح وتوثيقه في النظام.',
      });
    }

    // 12. Marketer Leaves Submit
    if (path.contains('/customer/marketer/leaves')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم رفع طلب الإجازة بنجاح إلى المشرف الميداني.',
      });
    }

    // 14. Nafath Initiate
    if (path.contains('/nafath/initiate')) {
      final randCode = (10 + (DateTime.now().millisecondsSinceEpoch % 90)).toString();
      _mockNafathCode = randCode;
      _mockNafathInitiatedAt = DateTime.now();
      return Response(statusCode: 200, body: {
        'status': 'sent',
        'request_id': 'mock-nafath-${DateTime.now().millisecondsSinceEpoch}',
        'code': randCode,
        'random': randCode,
        'message': 'تم إرسال طلب التوثيق عبر نفاذ بنجاح (وضع العرض التجريبي)',
        'data': {
          'status': 'pending',
          'random': randCode,
          'code': randCode,
        },
        'external_response': [
          {
            'error': 'Success',
            'random': randCode,
            'message': 'Mock Nafath initiated',
          }
        ],
      });
    }

    // 15. Nafath Sign
    if (path.contains('/nafath/sign')) {
      return Response(statusCode: 200, body: {
        'status': 'success',
        'message': 'تم توقيع العقد واعتماده بنجاح',
      });
    }

    // 16. Nafath Retry
    if (path.contains('/nafath/retry')) {
      final randCode = (10 + (DateTime.now().millisecondsSinceEpoch % 90)).toString();
      _mockNafathCode = randCode;
      _mockNafathInitiatedAt = DateTime.now();
      return Response(statusCode: 200, body: {
        'status': 'sent',
        'code': randCode,
        'random': randCode,
        'message': 'تمت إعادة محاولة إرسال الرمز بنجاح',
      });
    }

    // 17. Nafath Check Status (POST fallback)
    if (path.contains('/nafath/checkStatus') || path.contains('/nafath/check-status')) {
      final elapsed = _mockNafathInitiatedAt != null
          ? DateTime.now().difference(_mockNafathInitiatedAt!).inSeconds
          : 10;
      final isApproved = elapsed >= 6;
      return Response(statusCode: 200, body: {
        'status': isApproved ? 'approved' : 'pending',
        'code': _mockNafathCode,
        'random': _mockNafathCode,
        'is_approved': isApproved,
        'can_proceed': isApproved,
        'full_name_ar': 'عبدالله بن سعد الدوسري (تاجر معتمد)',
      });
    }

    // Default POST success
    return Response(statusCode: 200, body: {'status': 'success', 'message': 'تم تنفيذ العملية بنجاح'});
  }

  // ==========================================
  // PUT & DELETE HANDLERS
  // ==========================================
  static Response<dynamic>? _handlePut(String path, String fullUri, dynamic body) {
    return Response(statusCode: 200, body: {'status': 'success', 'message': 'تم التعديل بنجاح'});
  }

  static Response<dynamic>? _handleDelete(String path, String fullUri) {
    return Response(statusCode: 200, body: {'status': 'success', 'message': 'تم الحذف بنجاح'});
  }

  // ==========================================
  // MOCK PAYLOADS
  // ==========================================
  static final Map<String, dynamic> _mockConfigPayload = {
    'business_name': 'شلة مندوب',
    'logo_full_url': '',
    'address': 'الرياض، المملكة العربية السعودية',
    'phone': '+966501234567',
    'email': 'support@shella.com',
    'country': 'SA',
    'currency_symbol': 'ر.س',
    'currency_symbol_direction': 'right',
    'app_minimum_version_android': 1.0,
    'app_url_android': '',
    'app_minimum_version_ios': 1.0,
    'app_url_ios': '',
    'customer_verification': false,
    'schedule_order': false,
    'order_delivery_verification': false,
    'cash_on_delivery': true,
    'digital_payment': true,
    'demo': false,
    'maintenance_mode': false,
    'order_confirmation_model': 'deliveryman',
    'show_dm_earning': false,
    'canceled_by_deliveryman': false,
    'timeformat': '12',
    'language': [
      {'key': 'ar', 'value': 'العربية'},
      {'key': 'en', 'value': 'English'}
    ],
    'toggle_veg_non_veg': false,
    'toggle_dm_registration': false,
    'toggle_store_registration': false,
    'digit_after_decimal_point': 2,
    'active_payment_method_list': [],
    'default_location': {
      'lat': '24.7136',
      'lng': '46.6753',
    },
    'module': {
      'id': 1,
      'module_name': 'مندوب شلة',
      'module_type': 'marketer',
      'theme_id': 1,
      'status': 1,
      'stores_count': 50,
    },
  };

  static final List<Map<String, dynamic>> _mockModulesList = [
    {
      'id': 1,
      'module_name': 'مندوب شلة',
      'module_type': 'marketer',
      'thumbnail': '',
      'status': 1,
      'stores_count': 50,
    }
  ];

  static final List<Map<String, dynamic>> _mockZonesList = [
    {
      'id': 1,
      'name': 'غرب الرياض (طويق ونمار)',
      'planned_visits': 16,
      'is_locked': true,
      'latitude': 24.7136,
      'longitude': 46.6753,
      'radius_meters': 3000.0,
    },
    {
      'id': 2,
      'name': 'شمال الرياض (الملقا وحطين)',
      'planned_visits': 14,
      'is_locked': false,
      'latitude': 24.8000,
      'longitude': 46.6200,
      'radius_meters': 4000.0,
    },
    {
      'id': 3,
      'name': 'وسط الرياض (العليا والسليمانية)',
      'planned_visits': 18,
      'is_locked': false,
      'latitude': 24.6900,
      'longitude': 46.6850,
      'radius_meters': 2500.0,
    }
  ];

  static final Map<String, dynamic> _mockUserInfoPayload = {
    'id': 1001,
    'f_name': 'أحمد',
    'l_name': 'المسوق الميداني',
    'email': 'marketer@shella.com',
    'phone': '+966501234567',
    'image_full_url': '',
    'wallet_balance': 1850.0,
    'loyalty_point': 320,
    'ref_code': 'SHELLA-M77',
    'is_phone_verified': 1,
    'is_email_verified': 1,
    'order_count': 42,
    'created_at': '2026-01-15T00:00:00Z',
  };

  static final Map<String, dynamic> _mockDashboardPayload = {
    'status': 'success',
    'data': {
      'marketer_status': 'approved',
      'code': 'SHELLA-M77',
      'balance': 1850.0,
      'pending_balance': 450.0,
      'pending_days': 3,
      'min_transfer_amount': 200.0,
      'commission_rate': 1.5,
      'today_referred': 5,
      'acquired_customers': 48,
      'registered_customers': 62,
      'paying_customers': 38,
      'total_scans': 142,
      'hesitant_customers': 14,
      'kpi_growth_pct': 18,
      'applied_at': '2026-08-15T10:00:00.000Z',
      'qr_link': 'https://shellafood.com/join?ref=SHELLA-M77',
      'app_deep_link': 'shella://join?ref=SHELLA-M77',
      'share_text': 'حمّل تطبيق شلة واستخدم كودي SHELLA-M77 واحصل على خصم فوري ومكافأة!',
      'funnel': {
        'scans': 142,
        'registered': 62,
        'paying': 38,
      },
      'transactions': [
        {
          'id': 'TX-901',
          'type': 'commission',
          'amount': 150.0,
          'title': 'عمولة متجر تموينات الأمل',
          'date': '2026-09-27 14:30',
        },
        {
          'id': 'TX-902',
          'type': 'payout',
          'amount': 500.0,
          'title': 'سحب رصيد لحساب بنك الراجحي',
          'date': '2026-09-25 11:15',
        },
        {
          'id': 'TX-903',
          'type': 'commission',
          'amount': 200.0,
          'title': 'عمولة مطعم برجر ستيشن',
          'date': '2026-09-24 18:40',
        },
      ],
    },
  };

  static final Map<String, dynamic> _mockProductivityPayload = {
    'status': 'success',
    'data': {
      'type': 'daily',
      'date': '2026-09-28',
      'dateFormatted': 'اليوم ، 28 سبتمبر 2026',
      'kpis': {
        'successfulVisits': 12,
        'successfulVisitsText': '12 زيارة',
        'workHours': '7س 40د',
        'workSeconds': 27600,
        'warningsCount': 1,
        'warningsText': '1 إنذار',
        'signedContracts': 3,
        'signedContractsText': '3 اتفاقيات',
      },
      'dailyTarget': {
        'target': 16,
        'achieved': 12,
        'targetText': '16 / 12',
        'remaining': 4,
        'percentage': 75,
        'subtitle': 'متبقي 4 زيارات — 75%',
      },
    },
  };
}
