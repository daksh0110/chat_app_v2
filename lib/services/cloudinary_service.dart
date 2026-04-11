import 'dart:io';

import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static final String cloudName = dotenv.env['CLOUDINARY_NAME'] ?? '';
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  static final Cloudinary _cloudinary = Cloudinary.fromStringUrl(
    'cloudinary://$apiKey:$apiSecret@$cloudName',
  );

  static Future<String> uploadImage(XFile image) async {
    try {
      final File file = File(image.path);

      final response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams(type: "image"),
      );

      if (response == null || response.data == null) {
        throw Exception('Upload failed: Empty response');
      }

      final secureUrl = response.data!.secureUrl;

      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Upload failed: No image URL returned');
      }

      return secureUrl;
    } catch (e) {
      throw Exception('Cloudinary upload error: $e');
    }
  }
}
