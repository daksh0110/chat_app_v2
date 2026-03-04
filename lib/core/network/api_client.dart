import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> get(String url, {String? token}) async {
    final response = await http.get(
      Uri.parse(url),
      headers: token != null
          ? {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            }
          : {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }
}
