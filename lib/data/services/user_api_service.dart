import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/modal/api_response.dart';
import 'package:my_app/modal/google_auth_response.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/modal/send_email_verification_otp.dart';
import 'package:my_app/modal/send_otp_response.dart';
import 'package:my_app/modal/succesfull_authentication_after_verification.dart';
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
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        "${ApiConstants.baseUrl}${ApiConstants.users}?search=$search&page=$page",
        token: token,
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
      return apiResponse;
    } catch (e) {
      throw Exception("Get profile failed: $e");
    }
  }

  Future<ApiResponse<SearchItem>> getUserById(String userId) async {
    try {
      final response = await apiClient.get(
        "${ApiConstants.baseUrl}${ApiConstants.users}/$userId",
      );

      return ApiResponse<SearchItem>.fromJson(
        response,
        (json) => SearchItem.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception("Get user by id failed: $e");
    }
  }

  Future<ApiResponse<SendOtpResponse>> sendOtp({required String email}) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/send-otp",
        {"email": email},
      );
      final apiResponse = ApiResponse<SendOtpResponse>.fromJson(
        response,
        (json) => SendOtpResponse.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse;
    } catch (e) {
      throw Exception("Send Otp Failed");
    }
  }

  Future<ApiResponse<void>> verifyOtp({
    required String resetToken,
    required String otp,
  }) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/verify-otp",
        {"reset_token": resetToken, "otp": otp},
      );
      final apiResponse = ApiResponse<void>.fromJson(response, (_) => {});

      return apiResponse;
    } catch (e) {
      throw Exception("Send Otp Failed");
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String resetToken,
    required String newpassword,
  }) async {
    try {
      final response = await apiClient.patch(
        "${ApiConstants.baseUrl}${ApiConstants.users}/change-password",
        {"reset_token": resetToken, "new_password": newpassword},
      );
      final apiResponse = ApiResponse<void>.fromJson(response, (_) => {});

      return apiResponse;
    } catch (e) {
      throw Exception("Send Otp Failed");
    }
  }

  Future<ApiResponse<SuccesfullAuthenticationAfterVerification>>
  verifyEmailVerificationOtp({
    required String verificationToken,
    required String otp,
  }) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/verify-email-otp",
        {"verification_token": verificationToken, "otp": otp},
      );
      final apiResponse =
          ApiResponse<SuccesfullAuthenticationAfterVerification>.fromJson(
            response,
            (json) => SuccesfullAuthenticationAfterVerification.fromJson(
              json as Map<String, dynamic>,
            ),
          );

      return apiResponse;
    } catch (e) {
      throw Exception("Create user failed: $e");
    }
  }

  Future<ApiResponse<SendEmailVerificationOtp>> sendEmailVerificationOtp({
    required String email,
  }) async {
    try {
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.users}/send-email-verification-otp",
        {"email": email},
      );
      final apiResponse = ApiResponse<SendEmailVerificationOtp>.fromJson(
        response,
        (json) =>
            SendEmailVerificationOtp.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse;
    } catch (e) {
      throw Exception("Send Otp Failed");
    }
  }

  Future<ApiResponse<void>> updateProfile({
    required String token,
    String? bio,
    String? profilePicPath,
  }) async {
    try {
      final response = await apiClient.patch(
        "${ApiConstants.baseUrl}${ApiConstants.users}/update-profile",
        {
          if (bio != null) "bio": bio,
          if (profilePicPath != null) "profile_picture": profilePicPath,
          "token": token,
        },
      );
      final apiResponse = ApiResponse<void>.fromJson(response, (_) => {});

      return apiResponse;
    } catch (e) {
      throw Exception("Update profile failed: $e");
    }
  }
}
