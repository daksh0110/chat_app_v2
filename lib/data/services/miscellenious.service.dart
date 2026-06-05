import 'package:flutter/material.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/modal/server_status_response.dart';

class MiscelleniousService {
  final ApiClient apiClient;

  MiscelleniousService(this.apiClient);

  Future<ServerStatusResponse> verifyServerConnection() async {
    debugPrint("verifyServerConnection CALLED");

    try {
      debugPrint(ApiConstants.backendUrl);
      final response = await apiClient.get(ApiConstants.backendUrl);
      debugPrint("DATA: $response");
      if (response is Map<String, dynamic>) {
        return ServerStatusResponse.fromJson(response);
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      debugPrint("verifyServerConnection ERROR: ${e.toString()}");
      throw Exception("server connection: $e");
    }
  }
}
