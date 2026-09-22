import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_commissions_screen.dart';
import 'package:sixam_mart/features/marketer/widgets/marketer_header.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';
import 'package:sixam_mart/features/employee/screens/employee_profile_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketerDashboardScreen extends StatelessWidget {
  final bool isRoot;
  const MarketerDashboardScreen({super.key, this.isRoot = false});

  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                MarketerHeader(
                  title: isRoot
                      ? 'my_account_and_marketer'.tr
                      : 'voucher_marketer'.tr,
                  showBackButton: !isRoot,
                  trailing: GestureDetector(
                    onTap: () => Get.to(() => const EmployeeProfileScreen()),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F5F8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconlyLight.setting,
                        size: 20,
                        color: Color(0xFF111B18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GetBuilder<MarketerController>(
                    builder: (c) {
                      return RefreshIndicator(
                        color: _primaryGreen,
                        onRefresh: c.loadDashboard,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 0. Profile Summary Bar (when in root tab)
                              if (isRoot) ...[
                                _buildProfileSummaryBar(),
                                const SizedBox(height: 14),
                              ],

                              // 1. Hero Gradient Balance Card
                              _buildHeroBalanceCard(c),
                              const SizedBox(height: 16),

                              // 2. Personal QR Code Card
                              _buildQRCard(context, c),
                              const SizedBox(height: 16),

                              // 3. KPI Cards
                              _buildKPICards(c),
                              const SizedBox(height: 16),

                              // 4. Recent Commissions Card
                              _buildRecentCommissionsCard(c),
                              const SizedBox(height: 16),

                              // 5. Settings Quick Card
                              _buildSettingsQuickCard(),
                              const SizedBox(height: 70),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Floating Support Button (Matching Figma: Circular 56x56 at Bottom Left)
            Positioned(
              bottom: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x21000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.headset_mic_outlined,
                      color: _primaryGreen,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------- 1. Hero Balance Card (Figma Exact)
  Widget _buildHeroBalanceCard(MarketerController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.03, 0.03),
          end: Alignment(0.93, 1.00),
          colors: [
            Color(0xFFDFD3F5),
            Color(0xFFEBFEEB),
            Color(0xFFDFD3F5),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inner Glass Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.42),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.80, color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_balance'.tr,
                  style: const TextStyle(
                    color: _darkText,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SarCurrencyWidget(size: 28, color: _darkText),
                      const SizedBox(width: 8),
                      Text(
                        c.balance.toStringAsFixed(
                            c.balance.truncateToDouble() == c.balance ? 0 : 2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _primaryGreen,
                          fontSize: 36,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3 Mini Cards Row (In RTL: Bank Transfer Right, Pending Middle, Today's Left)
          Row(
            children: [
              // Card 1: Bank Transfer (Right)
              Expanded(
                child: Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: _primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x07000000),
                        blurRadius: 8.90,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'bank_transfer'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'bank_transfer_min_desc'.tr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Card 2: Pending Balance (Middle)
              Expanded(
                child: Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF6F5F8),
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0x1E555555)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x07000000),
                        blurRadius: 8.90,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'pending_balance'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _darkText,
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SarCurrencyWidget(size: 13, color: _darkText),
                          const SizedBox(width: 4),
                          Text(
                            c.pendingBalance.toStringAsFixed(0),
                            style: const TextStyle(
                              color: _darkText,
                              fontSize: 18,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.pendingBalance > 0
                            ? '${'remaining_days'.tr} ${c.pendingDays} ${'days'.tr}'
                            : 'no_pending_balance'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 9,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Card 3: Today's Customers (Left)
              Expanded(
                child: Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF6F5F8),
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0x1E555555)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x07000000),
                        blurRadius: 8.90,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'today_customers'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _darkText,
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c.todayReferred} ${'customer'.tr}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _darkText,
                          fontSize: 15,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------- 2. Personal QR Card (Figma Exact)
  Widget _buildQRCard(BuildContext context, MarketerController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'personal_qr_code'.tr,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 15,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'let_others_scan_and_join'.tr,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // Large QR Code with Styled Container
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.60, color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x190AB564),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: c.qrLink,
                version: QrVersions.auto,
                size: 150,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF111B18),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF111B18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Code & Social Action Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: ShapeDecoration(
              color: const Color(0xFFF0F4F8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Quick Share Buttons (Messenger, Telegram, WhatsApp, Copy)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Messenger — exact Figma gradient circle
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(
                            'fb-messenger://share?link=${Uri.encodeComponent(c.qrLink)}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          Share.share(c.shareText);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: SvgPicture.string(
                          '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
                            <defs>
                              <linearGradient id="mg" x1="50%" y1="100%" x2="50%" y2="0%">
                                <stop offset="0%" stop-color="#E01AFF"/>
                                <stop offset="50%" stop-color="#0078FF"/>
                                <stop offset="100%" stop-color="#00D3FF"/>
                              </linearGradient>
                            </defs>
                            <circle cx="16" cy="16" r="16" fill="url(#mg)"/>
                            <path d="M16 7C10.925 7 7 10.69 7 15.272c0 2.747 1.37 5.196 3.516 6.817V25l3.207-1.762a9.37 9.37 0 002.277.279c5.075 0 9-3.69 9-8.272C25 10.69 21.075 7 16 7zm.892 11.127l-2.294-2.44-4.474 2.44 4.924-5.23 2.35 2.44 4.418-2.44-4.924 5.23z" fill="white"/>
                          </svg>''',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Telegram — exact Figma blue circle
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(
                            'https://t.me/share/url?url=${Uri.encodeComponent(c.qrLink)}&text=${Uri.encodeComponent(c.shareText)}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          Share.share(c.shareText);
                        }
                      },
                      child: SvgPicture.string(
                        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
                          <circle cx="16" cy="16" r="16" fill="#29B6F6"/>
                          <path d="M22.93 10.25l-2.654 12.52c-.2.886-.72 1.107-1.46.688l-4.03-2.97-1.947 1.875c-.215.215-.395.395-.81.395l.29-4.106 7.47-6.746c.325-.29-.07-.45-.505-.16l-9.232 5.81-3.976-1.242c-.864-.27-.882-.864.18-1.28l15.53-5.986c.72-.26 1.348.16 1.144 1.202z" fill="white"/>
                        </svg>''',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // WhatsApp — exact Figma green circle
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(
                            'https://wa.me/?text=${Uri.encodeComponent(c.shareText)}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          Share.share(c.shareText);
                        }
                      },
                      child: SvgPicture.string(
                        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
                          <circle cx="16" cy="16" r="16" fill="#25D366"/>
                          <path d="M22.5 9.5A9.48 9.48 0 0016 7a9.5 9.5 0 00-8.232 14.233L7 25l3.867-.74A9.5 9.5 0 0022.5 9.5zM16 24.1a7.9 7.9 0 01-4.027-1.103l-.29-.172-2.294.44.447-2.237-.19-.298A7.9 7.9 0 1116 24.1zm4.33-5.917c-.237-.119-1.4-.69-1.617-.768-.217-.08-.374-.119-.532.119-.158.237-.61.768-.748.926-.137.158-.275.178-.513.059-.237-.119-1.002-.37-1.907-1.178-.705-.63-1.181-1.408-1.319-1.646-.138-.237-.015-.365.104-.483.107-.106.237-.276.356-.415.119-.138.158-.237.237-.394.08-.158.04-.296-.02-.415-.059-.119-.532-1.282-.729-1.755-.192-.46-.387-.398-.532-.405l-.453-.008a.87.87 0 00-.63.296c-.217.237-.828.81-.828 1.973 0 1.163.848 2.286.966 2.444.119.158 1.668 2.548 4.042 3.573.565.244 1.005.39 1.349.498.567.18 1.083.155 1.491.094.455-.068 1.4-.572 1.597-1.124.197-.552.197-1.025.138-1.124-.059-.098-.217-.158-.453-.276z" fill="white"/>
                        </svg>''',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Copy Button — light green rounded square
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: c.code));
                        Get.snackbar(
                          'success'.tr,
                          'code_copied_success'.tr,
                          backgroundColor: _primaryGreen,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEBFEEB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                                color: _primaryGreen.withValues(alpha: 0.3)),
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.string(
                            '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="none">
                              <rect x="7" y="7" width="9" height="10" rx="1.5" stroke="#30913F" stroke-width="1.5"/>
                              <path d="M13 7V5.5A1.5 1.5 0 0011.5 4h-7A1.5 1.5 0 003 5.5v8A1.5 1.5 0 004.5 15H7" stroke="#30913F" stroke-width="1.5"/>
                            </svg>''',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Code Text (Right in RTL)
                Text(
                  c.code,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------- 3. KPI Cards (Figma Exact)
  Widget _buildKPICards(MarketerController c) {
    return Column(
      children: [
        // KPI Card 1: Acquired Customers (Full Width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: ShapeDecoration(
            color: const Color(0xFFFAFFFA),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 0.80,
                color: Color(0x7030913F),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGrowthBadge('${c.kpiGrowthPct}%'),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: _primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Center(
                      child: Icon(IconlyLight.addUser,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'العملاء الدافعون (أتموا الشراء)',
                style: const TextStyle(
                  color: Color(0xFF6A7282),
                  fontSize: 15,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${c.payingCustomers} ${'customers'.tr}',
                style: const TextStyle(
                  color: Color(0xFF1E2939),
                  fontSize: 24,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Row with 2 Bottom KPI Cards — exact Figma layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card: إجمالي المسجلين بالكود (Right in RTL)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 0.80, color: Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badge + Icon Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Growth badge (green)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF0FDF4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.north_east,
                                  size: 12, color: Color(0xFF008236)),
                              const SizedBox(width: 2),
                              Text(
                                '${c.kpiGrowthPct}%',
                                style: const TextStyle(
                                  color: Color(0xFF008236),
                                  fontSize: 12,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Users icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Center(
                            child: Icon(IconlyLight.profile,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'إجمالي المسجلين',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${c.registeredCustomers} ${'customers'.tr}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF1E2939),
                        fontSize: 20,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Card: لم يدفعوا بعد (Left in RTL)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: const Color(0xFFFCFCFD),
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 0.80, color: Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badge + Icon Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pending badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFFBEB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  size: 12, color: Color(0xFFD97706)),
                              const SizedBox(width: 2),
                              Text(
                                '${c.hesitantCustomers}',
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 11,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Alert / Pending Icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF59E0B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Center(
                            child: Icon(IconlyLight.timeCircle,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لم يدفعوا بعد',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${c.hesitantCustomers} عميل',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF1E2939),
                        fontSize: 20,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrowthBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFFF0FDF4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_upward, size: 12, color: Color(0xFF008236)),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF008236),
              fontSize: 12,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------- 4. Recent Commissions Card (Figma Exact)
  Widget _buildRecentCommissionsCard(MarketerController c) {
    final txns = c.transactions;
    final recent = txns.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'recent_commissions'.tr,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const MarketerCommissionsScreen()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF6F5F8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'view_all'.tr,
                    style: const TextStyle(
                      color: _primaryGreen,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'no_commissions_yet'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 14, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, i) {
                final t = recent[i];
                final isPending = (t['status'] ?? '').toString() == 'pending' ||
                    (t['status'] ?? '').toString() == 'معلّقة';
                final amount = t['reward'] ?? t['amount'] ?? 1;

                return Row(
                  children: [
                    // Coin Icon Box (Figma: 40x40 with rounded 12)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        color: isPending
                            ? const Color(0xFFFEF3DC)
                            : const Color(0xFFE6F9F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          IconlyLight.paper,
                          size: 20,
                          color: isPending
                              ? const Color(0xFFEC9C17)
                              : _primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (t['title'] ?? 'عمولة انضمام عميل جديدة')
                                .toString(),
                            style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 13,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (t['time'] ?? t['date'] ?? 'اليوم، 2:30 م')
                                .toString(),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPending
                                ? 'معلّقة – متبقي 3 أيام'
                                : 'تم تسجيل بنجاح',
                            style: TextStyle(
                              color: isPending
                                  ? const Color(0xFFEC9C17)
                                  : _primaryGreen,
                              fontSize: 11,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount with SAR currency
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+$amount ',
                          style: TextStyle(
                            color: isPending
                                ? const Color(0xFFEC9C17)
                                : _primaryGreen,
                            fontSize: 15,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SarCurrencyWidget(
                          size: 14,
                          color: isPending
                              ? const Color(0xFFEC9C17)
                              : _primaryGreen,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryBar() {
    return GetBuilder<ProfileController>(
      builder: (profileCtrl) {
        final userInfo = profileCtrl.userInfoModel;
        final name = userInfo != null
            ? '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim()
            : 'certified_marketer'.tr;
        final phone = userInfo?.phone ?? '';
        final imageUrl = userInfo?.imageFullUrl ?? '';

        return InkWell(
          onTap: () => Get.to(() => const EmployeeProfileScreen()),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: imageUrl.isNotEmpty
                      ? CustomImage(
                          image: imageUrl,
                          height: 44,
                          width: 44,
                          placeholder: Images.guestIcon,
                        )
                      : Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: _primaryGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            IconlyBold.profile,
                            size: 22,
                            color: _primaryGreen,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'shella_agent'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone.isNotEmpty ? phone : 'certified_marketer'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(IconlyLight.setting,
                          size: 16, color: _primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        'settings'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsQuickCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'app_and_account_settings'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'app_and_account_settings_desc'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const EmployeeProfileScreen()),
            icon: const Icon(IconlyLight.setting, size: 18),
            label: Text(
              'open_settings'.tr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primaryGreen,
              elevation: 0,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
