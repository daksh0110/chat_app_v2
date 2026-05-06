import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/modal/api_response.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';

class ChatApiService {
  final ApiClient apiClient;

  ChatApiService(this.apiClient);

  Future<ApiResponse<CreateGroupResponse>> getChat({
    required String token,
    required String chatId,
  }) async {
    try {
      final response = await apiClient.get(
        "${ApiConstants.baseUrl}${ApiConstants.chats}/chat/${chatId}",
        token: token,
      );

      return ApiResponse<CreateGroupResponse>.fromJson(
        response,
        (json) =>
            CreateGroupResponse.fromJson((json as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      throw Exception("Get chats failed: $e");
    }
  }
}
