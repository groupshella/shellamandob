import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/support/domain/repositories/support_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class SupportRepository implements SupportRepositoryInterface {
  final ApiClient apiClient;
  SupportRepository({required this.apiClient});

  @override
  Future<ResponseModel> submitSupportRequest(Map<String, String> data) async {
    ResponseModel responseModel;
    final Response response = await apiClient.postData(AppConstants.supportSubmitUri, data, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, (response.body as Map<String, dynamic>)['message'] as String?);
    } else if (response.statusCode == 401) {
      responseModel = ResponseModel(false, 'Unauthenticated');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }
}
