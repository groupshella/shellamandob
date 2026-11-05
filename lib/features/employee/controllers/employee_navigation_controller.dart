import 'package:get/get.dart';
import '../visits/controllers/store_visits_controller.dart';
import 'monthly_earnings_controller.dart';

class EmployeeNavigationController extends GetxController implements GetxService {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      update();
      if (index == 2 && Get.isRegistered<StoreVisitsController>()) {
        Get.find<StoreVisitsController>().loadVisits();
      } else if (index == 3 && Get.isRegistered<MonthlyEarningsController>()) {
        Get.find<MonthlyEarningsController>().refreshCurrentMonth();
      }
    }
  }
}
