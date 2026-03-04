import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/modal/api_response.dart';
import 'package:my_app/modal/google_auth_response.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/sucessfull_authentication.dart';

class UserApiService {
  final ApiClient apiClient;

  UserApiService(this.apiClient);

  Future<ApiResponse<SucessfullAuthentication>> createUser(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/create",
        data,
      );
      final apiResponse = ApiResponse<SucessfullAuthentication>.fromJson(
        response,
        (json) =>
            SucessfullAuthentication.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse;
    } catch (e) {
      throw Exception("Create user failed: $e");
    }
  }

  Future<ApiResponse<SucessfullAuthentication>> loginUser(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/login",
        data,
      );
      final apiResponse = ApiResponse<SucessfullAuthentication>.fromJson(
        response,
        (json) =>
            SucessfullAuthentication.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse;
    } catch (e) {
      throw Exception("Create user failed: $e");
    }
  }

  Future<ApiResponse<GoogleAuthResponse>> googleAuth(data) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/google/auth",
        {"token": data},
      );
      final apiResponse = ApiResponse<GoogleAuthResponse>.fromJson(
        response,
        (json) => GoogleAuthResponse.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse;
    } catch (e) {
      throw Exception("Create user failed: $e");
    }
  }

  Future<ApiResponse<List<SearchItem>>> getUsers({
    required String search,
    required int page,
  }) async {
    try {
      final response = await apiClient.get(
        "${ApiConstants.baseUrl}${ApiConstants.users}?search=$search&page=$page",
      );
      final apiResponse = ApiResponse<List<SearchItem>>.fromJson(
        response,
        (json) =>
            (json as List).map((item) => SearchItem.fromJson(item)).toList(),
      );
      return apiResponse;
    } catch (e) {
      throw Exception("Create user failed: $e");
    }
  }

  Future<ApiResponse<SearchItem>> getMyProfile({required String token}) async {
    try {
      final response = await apiClient.get(
        "${ApiConstants.baseUrl}${ApiConstants.users}/me",
        token: token,
      );

      final apiResponse = ApiResponse<SearchItem>.fromJson(
        response,
        (json) => SearchItem.fromJson(json as Map<String, dynamic>),
      );
      print(apiResponse);
      return apiResponse;
    } catch (e) {
      throw Exception("Get profile failed: $e");
    }
  }
}
