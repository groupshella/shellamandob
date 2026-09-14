import 'package:sixam_mart/common/models/response_model.dart';

abstract class SupportServiceInterface {
  Future<ResponseModel> submitSupportRequest(Map<String, String> data);
}
