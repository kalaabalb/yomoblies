import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> checkServerConnection(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Server connection failed: $e');
      return false;
    }
  }
}
