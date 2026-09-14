import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/support/domain/repositories/support_repository_interface.dart';
import 'package:sixam_mart/features/support/domain/services/support_service_interface.dart';

class SupportService implements SupportServiceInterface {
  final SupportRepositoryInterface supportRepositoryInterface;
  SupportService({required this.supportRepositoryInterface});

  @override
  Future<ResponseModel> submitSupportRequest(Map<String, String> data) async {
    return await supportRepositoryInterface.submitSupportRequest(data);
  }
}
