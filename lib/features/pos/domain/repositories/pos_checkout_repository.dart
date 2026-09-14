import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class PosCheckoutRepository {
  final ApiClient apiClient;

  PosCheckoutRepository({required this.apiClient});

  Future<Response> resolveCheckout(String token) async {
    return await apiClient.getData('${AppConstants.posCheckoutUri}$token');
  }

  Future<Response> claimCheckout(String token) async {
    return await apiClient.postData('${AppConstants.posCheckoutUri}$token/claim', {});
  }

  Future<Response> initiatePayment(String token, Map<String, dynamic> body) async {
    return await apiClient.postData('${AppConstants.posCheckoutUri}$token/payment', body);
  }
}

