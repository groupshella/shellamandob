import 'package:sixam_mart/common/models/response_model.dart';

abstract class SupportRepositoryInterface {
  Future<ResponseModel> submitSupportRequest(Map<String, String> data);
}
