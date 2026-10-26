import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/util/images.dart';
import '../controllers/employee_vacations_controller.dart';

/// Screen displaying the status and details of a leave request.
/// Faithfully matches Figma node 9480:85646 in node 8976:27114.
class EmployeeLeaveStatusScreen extends StatelessWidget {
  final MarketerLeaveModel leave;

  const EmployeeLeaveStatusScreen({
    super.key,
    required this.leave,
  });

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _lightGreenCircle = Color(0xFFDCFCE7);
  static const Color _dangerRed = Color(0xFFDC2626);
  static const Color _lightRedCircle = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final bg = isDark ? const Color(0xFF121418) : Colors.white;
        final appBarBg = isDark ? const Color(0xFF1C2028) : Colors.white;
        final darkText = isDark ? Colors.white : const Color(0xFF111B18);
        final subText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF555555);
        final cardBg = isDark ? const Color(0xFF1C2028) : const Color(0xFFF9FAFB);
        final borderColor = isDark ? const Color(0xFF2B3240) : const Color(0xFFEAECF0);
        final lineInactive = isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        final isApproved = leave.status == 'approved';
        final isRejected = leave.status == 'rejected';
        final isUnderReview = !isApproved && !isRejected;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? IconlyLight.arrowRight2
                    : IconlyLight.arrowLeft2,
                color: darkText,
                size: 22,
              ),
            ),
            title: Text(
              leave.typeLabel,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // ─── 1. Hero Illustration ────────────────────────────────────
                  if (isUnderReview)
                    Image.asset(
                      Images.leaveStatusHourglass,
                      width: 188,
                      height: 196,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildFallbackIllustration(
                        icon: Icons.hourglass_top_rounded,
                        color: _primaryGreen,
                        bgColor: isDark ? const Color(0xFF183B22) : _lightGreenCircle,
                      ),
                    )
                  else if (isApproved)
                    _buildFallbackIllustration(
                      icon: Icons.check_circle_rounded,
                      color: _primaryGreen,
                      bgColor: isDark ? const Color(0xFF183B22) : _lightGreenCircle,
                    )
                  else
                    _buildFallbackIllustration(
                      icon: Icons.cancel_rounded,
                      color: _dangerRed,
                      bgColor: isDark ? const Color(0xFF3B1818) : _lightRedCircle,
                    ),

                  const SizedBox(height: 24),

                  // ─── 2. Title & Description ──────────────────────────────────
                  Text(
                    isApproved
                        ? 'leave_approved_title'.tr
                        : isRejected
                            ? 'leave_rejected_title'.tr
                            : 'request_under_review_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isApproved
                          ? _primaryGreen
                          : isRejected
                              ? _dangerRed
                              : darkText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      isApproved
                          ? 'leave_approved_desc'.tr
                          : isRejected
                              ? (leave.rejectReason != null &&
                                      leave.rejectReason!.trim().isNotEmpty
                                  ? '${'rejection_reason_label'.tr} ${leave.rejectReason}'
                                  : 'leave_rejected_desc'.tr)
                              : 'request_under_review_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        height: 1.5,
                        color: subText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ─── 3. Three-Step Stepper (Figma 9480:92746) ────────────────
                  _buildStepper(
                    context: context,
                    isDark: isDark,
                    isApproved: isApproved,
                    isRejected: isRejected,
                    lineInactive: lineInactive,
                    darkText: darkText,
                    subText: subText,
                  ),

                  const SizedBox(height: 40),

                  // ─── 4. Leave Request Details Card ───────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'leave_details_title'.tr,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'start_date'.tr,
                          value: leave.startDate ?? '—',
                          darkText: darkText,
                          subText: subText,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          label: 'end_date'.tr,
                          value: leave.endDate ?? '—',
                          darkText: darkText,
                          subText: subText,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          label: 'duration'.tr,
                          value: '${leave.days} ${leave.days == 1 ? "day".tr : "days".tr}',
                          darkText: darkText,
                          subText: subText,
                        ),
                        if (leave.reason != null &&
                            leave.reason!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            label: 'notes_optional'.tr,
                            value: leave.reason!,
                            darkText: darkText,
                            subText: subText,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackIllustration({
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color, size: 70),
      ),
    );
  }

  Widget _buildStepper({
    required BuildContext context,
    required bool isDark,
    required bool isApproved,
    required bool isRejected,
    required Color lineInactive,
    required Color darkText,
    required Color subText,
  }) {
    final step3Color = isApproved
        ? _primaryGreen
        : isRejected
            ? _dangerRed
            : lineInactive;

    final step3TextColor = isApproved
        ? _primaryGreen
        : isRejected
            ? _dangerRed
            : subText;

    final step3Text = isApproved
        ? 'accepted_status'.tr
        : isRejected
            ? 'rejected_status'.tr
            : 'step_admin_decision'.tr;

    return Column(
      children: [
        // Circles and Lines Row
        Directionality(
          textDirection: Directionality.of(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step 1: تم استلام الطلب
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: _primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),

              // Connector Line 1
              Container(
                width: 48,
                height: 2,
                color: _primaryGreen,
              ),

              // Step 2: قيد المراجعة
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isApproved || isRejected)
                      ? _primaryGreen
                      : (isDark ? const Color(0xFF183B22) : _lightGreenCircle),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryGreen,
                    width: 2,
                  ),
                ),
                child: Icon(
                  (isApproved || isRejected) ? Icons.check : Icons.access_time_rounded,
                  color: (isApproved || isRejected) ? Colors.white : _primaryGreen,
                  size: 18,
                ),
              ),

              // Connector Line 2
              Container(
                width: 48,
                height: 2,
                color: isApproved
                    ? _primaryGreen
                    : isRejected
                        ? _dangerRed
                        : lineInactive,
              ),

              // Step 3: قرار الإدارة
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isApproved || isRejected)
                      ? step3Color
                      : (isDark ? const Color(0xFF2B3240) : const Color(0xFFF2F4F7)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApproved
                      ? Icons.check
                      : isRejected
                          ? Icons.close
                          : Icons.verified_outlined,
                  color: (isApproved || isRejected) ? Colors.white : subText,
                  size: 18,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Step Labels Row
        Directionality(
          textDirection: Directionality.of(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'step_request_received'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'step_under_review'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  step3Text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: step3TextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color darkText,
    required Color subText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            color: subText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
      ],
    );
  }
}
