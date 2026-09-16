import 'package:sixam_mart/features/onboard/domain/models/onboarding_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/onboard/domain/service/onboard_service_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class OnBoardingController extends GetxController implements GetxService {
  final OnboardServiceInterface onboardServiceInterface;
  OnBoardingController({required this.onboardServiceInterface});

  List<OnBoardingModel> _onBoardingList = [];
  List<OnBoardingModel> get onBoardingList => _onBoardingList;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void changeSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  Future<void> getOnBoardingList() async {
    // 🎯 MARKETER: Use embedded onboarding pages tailored for coupon marketers
    // Avoids backend dependency on first launch — works offline too
    if (AppConstants.isMarketerApp) {
      _onBoardingList = _marketerOnboardingPages();
      update();
      return;
    }

    final Response<dynamic> response =
        await onboardServiceInterface.getOnBoardingList();
    if (response.statusCode == 200) {
      _onBoardingList = [];

      // 🛡️ Defensive handling: Support both JSON and Model objects
      final List<dynamic> data = response.body as List<dynamic>;
      _onBoardingList = data.map((e) {
        // If already OnBoardingModel, return directly
        if (e is OnBoardingModel) {
          return e;
        }
        // If JSON Map, convert using fromJson
        else if (e is Map<String, dynamic>) {
          return OnBoardingModel.fromJson(e);
        }
        // Invalid type - throw descriptive exception
        else {
          throw Exception("Invalid onboarding data type: ${e.runtimeType}. "
              "Expected OnBoardingModel or Map<String, dynamic>.");
        }
      }).toList();
    }
    update();
  }

  /// 🎯 Marketer-specific onboarding pages (embedded, no backend required)
  List<OnBoardingModel> _marketerOnboardingPages() => [
        OnBoardingModel(
          '',
          'onboard_marketer_title_1'.tr,
          'onboard_marketer_desc_1'.tr,
        ),
        OnBoardingModel(
          '',
          'onboard_marketer_title_2'.tr,
          'onboard_marketer_desc_2'.tr,
        ),
        OnBoardingModel(
          '',
          'onboard_marketer_title_3'.tr,
          'onboard_marketer_desc_3'.tr,
        ),
      ];
}
