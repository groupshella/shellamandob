import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_dashboard_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_intro_screen.dart';
import 'package:sixam_mart/features/marketer/screens/marketer_pending_screen.dart';

/// In-app "Coupon Marketer" entry screen.
/// Dynamically renders:
///   none / rejected -> MarketerIntroScreen (Figma 8433:84426)
///   pending         -> MarketerPendingScreen (Figma 6321:65096)
///   approved        -> MarketerDashboardScreen (Figma 8436:85415)
class MarketerScreen extends StatefulWidget {
  const MarketerScreen({super.key});

  @override
  State<MarketerScreen> createState() => _MarketerScreenState();
}

class _MarketerScreenState extends State<MarketerScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<MarketerController>().loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketerController>(
      builder: (controller) {
        if (controller.isLoading && controller.data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            ),
          );
        }

        switch (controller.status) {
          case 'approved':
            return const MarketerDashboardScreen();
          case 'pending':
            return const MarketerPendingScreen();
          case 'none':
          case 'rejected':
          default:
            return const MarketerIntroScreen();
        }
      },
    );
  }
}
