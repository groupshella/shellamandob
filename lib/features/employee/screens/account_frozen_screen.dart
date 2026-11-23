import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/controllers/theme_controller.dart';
import '../../chat/screens/chat_screen.dart';
import '../controllers/employee_shift_controller.dart';
import '../services/marketer_shift_service.dart';
import '../../marketer/controllers/marketer_controller.dart';
import '../../marketer/screens/marketer_screen.dart';

/// Account Temporarily Frozen Screen ("تم تجميد حسابك مؤقتًا") matching Figma (9937:87455):
/// - AppBar refresh action with loading state (no background timer)
/// - Auto-rechecks status on return from ChatScreen and on app resume
/// - Automatically navigates back to EmployeeMainScreen once unfrozen
class AccountFrozenScreen extends StatefulWidget {
  final String? freezeReason;

  const AccountFrozenScreen({super.key, this.freezeReason});

  @override
  State<AccountFrozenScreen> createState() => _AccountFrozenScreenState();
}

class _AccountFrozenScreenState extends State<AccountFrozenScreen>
    with WidgetsBindingObserver {
  static const Color _primaryGreen = Color(0xFF30913F);

  bool _isChecking = false;
  String? _latestReason;

  @override
  void initState() {
    super.initState();
    _latestReason = widget.freezeReason;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccountStatus();
    }
  }

  Future<void> _checkAccountStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final service = Get.isRegistered<MarketerShiftService>()
          ? Get.find<MarketerShiftService>()
          : Get.put(MarketerShiftService(apiClient: Get.find()));

      final res = await service.getCurrentShift();
      if (!mounted) return;

      if (res.statusCode == 200 && res.body is Map && res.body['data'] is Map) {
        final data = Map<String, dynamic>.from(res.body['data'] as Map);
        final isFrozen = data['account_frozen'] == true;
        if (!isFrozen) {
          if (Get.isRegistered<MarketerController>()) {
            await Get.find<MarketerController>().loadDashboard(notify: true);
          }
          if (Get.isRegistered<EmployeeShiftController>()) {
            Get.find<EmployeeShiftController>().loadCurrentShift(notify: true);
          }
          Get.offAll(() => const MarketerScreen());
          return;
        }
        final reason = data['freeze_reason']?.toString();
        if (reason != null && reason.trim().isNotEmpty) {
          setState(() => _latestReason = reason.trim());
        }
      }
    } catch (e) {
      debugPrint('❌ [AccountFrozenScreen] status check error: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final cardBg =
            isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);

        final effectiveReason =
            (_latestReason != null && _latestReason!.trim().isNotEmpty)
                ? _latestReason!.trim()
                : 'account_frozen_default_reason'.tr;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _isChecking
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: _primaryGreen,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _checkAccountStatus,
                          tooltip: 'refresh'.tr,
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: darkText,
                            size: 24,
                          ),
                        ),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: RefreshIndicator(
                color: _primaryGreen,
                onRefresh: _checkAccountStatus,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(flex: 2),
                              // Figma Illustration (image 97 — 243x248)
                              Center(
                                child: Image.asset(
                                  'assets/image/figma_account_frozen.png',
                                  width: 243,
                                  height: 248,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'account_frozen_title'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'account_frozen_subtitle'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: darkText,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Reason Card ("سبب الإيقاف" — Figma 9937:87465)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'suspension_reason_label'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: darkText,
                                          height: 1.6,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        effectiveReason,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.6,
                                          color: darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(flex: 3),
                              // Bottom Green CTA ("التواصل مع الإدارة" — Figma 9937:87468)
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await Get.to(() => const ChatScreen());
                                    if (mounted) {
                                      _checkAccountStatus();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryGreen,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'contact_admin_btn'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
