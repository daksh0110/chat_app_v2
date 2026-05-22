import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/modal/api_response.dart';
import 'package:my_app/modal/upload_responses/presigned_url_response.dart';
import 'package:my_app/modal/upload_responses/upload_response.dart';

class UploadService {
  final ApiClient apiClient;

  UploadService(this.apiClient);

  Future<ApiResponse<UploadResponse>> uploadFileToAmazon({
    required XFile image,
    required String entityType,
    required String assetType,
    String? entityId,
  }) async {
    try {
      final mimeType = image.mimeType ?? 'image/png';

      final presignedUrlResponse = await getPresignedUrl(
        entityType: entityType,
        assetType: assetType,
        contentType: mimeType,
        entityId: entityId,
      );

      if (!presignedUrlResponse.success || presignedUrlResponse.data == null) {
        throw Exception(presignedUrlResponse.message);
      }

      final bytes = await image.readAsBytes();
      await uploadToSignedUrl(bytes, presignedUrlResponse.data!.url, mimeType);

      final uploadResponse = UploadResponse(
        url: presignedUrlResponse.data!.url,
        entityType: entityType,
        assetType: assetType,
        entityId: entityId,
      );

      return ApiResponse<UploadResponse>(
        success: true,
        message: 'File uploaded successfully',
        data: uploadResponse,
      );
    } catch (e) {
      throw Exception('Upload file to Amazon failed: $e');
    }
  }

  Future<ApiResponse<PresignedUrlResponse>> getPresignedUrl({
    required String entityType,
    required String assetType,
    required String contentType,
    String? entityId,
  }) async {
    try {
      final token = await FlutterSecureStorage().read(key: "accessToken");
      final body = {
        'entity_type': entityType,
        'asset_type': assetType,
        'content_type': contentType,
        if (entityId != null) 'entity_id': entityId,
      };

      final response = await apiClient.post(
        "${ApiConstants.baseUrl}${ApiConstants.uploadEndpoint}",
        body,
        token: token,
      );
      debugPrint("url ${ApiConstants.baseUrl}${ApiConstants.uploadEndpoint}");

      final apiResponse = ApiResponse<PresignedUrlResponse>.fromJson(
        response,
        (json) => PresignedUrlResponse.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse;
    } catch (e) {
      throw Exception('Get presigned URL failed: $e');
    }
  }

  Future<int> uploadToSignedUrl(
    Uint8List fileBytes,
    String uploadUrl,
    String contentType,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType},
        body: fileBytes,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Signed upload failed: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
      return response.statusCode;
    } catch (e) {
      throw Exception('Upload to signed URL failed: $e');
    }
  }

  Future<ApiResponse<String>> getDownloadUrl(String key) async {
    try {
      final token = await const FlutterSecureStorage().read(key: "accessToken");
      final response = await apiClient.get(
        "${ApiConstants.baseUrl}${ApiConstants.uploadEndpoint}/get-url?key=$key",
        token: token,
      );

      final apiResponse = ApiResponse<String>.fromJson(
        response,
        (json) => (json as Map<String, dynamic>)['url'] as String,
      );

      return apiResponse;
    } catch (e) {
      throw Exception('Get download URL failed: $e');
    }
  }
}
