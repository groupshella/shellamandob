import 'package:get/get.dart';

class EmployeeNavigationController extends GetxController implements GetxService {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      update();
    }
  }
}
