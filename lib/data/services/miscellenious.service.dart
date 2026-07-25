import 'package:flutter/material.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/modal/server_status_response.dart';

class MiscelleniousService {
  final ApiClient apiClient;

  MiscelleniousService(this.apiClient);

  Future<ServerStatusResponse> verifyServerConnection() async {

    try {
      final response = await apiClient.get(ApiConstants.backendUrl);
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
