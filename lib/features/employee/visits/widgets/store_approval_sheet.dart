import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/store_visits_controller.dart';
import '../models/store_visit_model.dart';

/// Gate shown before a fresh visit starts: the marketer photographs the
/// store's signboard and confirms their GPS location to "approve" the
/// store, then starts the visit. Resuming an already-started visit skips
/// this entirely (the server only requires it on a fresh start too).
///
/// Returns the confirmed [LatLng] on success, or null if the marketer
/// cancelled / the gate failed.
Future<LatLng?> runStoreApprovalFlow(
  BuildContext context,
  StoreVisitsController controller,
  StoreVisitModel visit,
) async {
  if (visit.startedAt != null) {
    // Resuming an in-progress visit -- nothing to approve again.
    final pos = await controller.captureStoreApprovalLocation();
    return pos == null ? null : LatLng(pos.latitude, pos.longitude);
  }

  controller.clearStoreApprovalPhoto();

  return showModalBottomSheet<LatLng?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _StoreApprovalSheetBody(controller: controller),
  );
}

class _StoreApprovalSheetBody extends StatefulWidget {
  final StoreVisitsController controller;
  const _StoreApprovalSheetBody({required this.controller});

  @override
  State<_StoreApprovalSheetBody> createState() => _StoreApprovalSheetBodyState();
}

class _StoreApprovalSheetBodyState extends State<_StoreApprovalSheetBody> {
  Position? _position;
  bool _capturingLocation = false;

  Future<void> _handleCapturePhoto({bool fromGallery = false}) async {
    await widget.controller.captureStoreApprovalPhoto(fromGallery: fromGallery);
    setState(() {});
  }

  Future<void> _handleConfirmLocation() async {
    setState(() => _capturingLocation = true);
    final pos = await widget.controller.captureStoreApprovalLocation();
    setState(() {
      _position = pos;
      _capturingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoPath = widget.controller.storeApprovalPhotoPath;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    const primaryGreen = Color(0xFF30913F);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'approve_store_title'.tr,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'approve_store_hint'.tr,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Step 1: signboard photo
            GestureDetector(
              onTap: _handleCapturePhoto,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: photoPath != null ? primaryGreen : theme.dividerColor,
                    width: photoPath != null ? 2 : 1,
                  ),
                  image: photoPath != null
                      ? DecorationImage(
                          image: ResizeImage(FileImage(File(photoPath)), width: 480),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconlyLight.camera, color: theme.hintColor, size: 32),
                          const SizedBox(height: 8),
                          Text('capture_signboard_photo'.tr, style: theme.textTheme.bodyMedium),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => _handleCapturePhoto(fromGallery: true),
                icon: Icon(IconlyLight.image, size: 18, color: theme.hintColor),
                label: Text(
                  'choose_from_gallery'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.hintColor),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Step 2: confirm location
            OutlinedButton.icon(
              onPressed: photoPath == null || _capturingLocation ? null : _handleConfirmLocation,
              icon: _capturingLocation
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_position != null ? Icons.check_circle : IconlyLight.location, color: _position != null ? primaryGreen : null),
              label: Text(_position != null ? 'location_confirmed'.tr : 'confirm_current_location'.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: _position != null ? primaryGreen : theme.dividerColor),
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (photoPath != null && _position != null)
                    ? () => Navigator.pop(context, LatLng(_position!.latitude, _position!.longitude))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: primaryGreen.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'approve_store_and_start_visit'.tr,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
