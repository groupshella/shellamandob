import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/support/domain/services/support_service_interface.dart';

class SupportController extends GetxController implements GetxService {
  final SupportServiceInterface supportServiceInterface;
  SupportController({required this.supportServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<ResponseModel> submitSupportRequest(Map<String, String> data) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await supportServiceInterface.submitSupportRequest(data);
    _isLoading = false;
    update();
    return responseModel;
  }
}
