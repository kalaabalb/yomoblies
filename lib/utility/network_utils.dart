import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<bool> checkServerConnection(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('🔴 Server connection failed: $e');
      return false;
    }
  }
}