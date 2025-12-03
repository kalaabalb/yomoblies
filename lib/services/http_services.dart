import 'package:get/get_connect.dart';
import 'package:get/get.dart';

import '../utility/constants.dart';

class HttpService {
  final String baseUrl = MAIN_URL;

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      final response = await GetConnect(
        timeout: const Duration(seconds: 10),
      ).get('$baseUrl/$endpointUrl');

      if (response.statusCode == null) {
        throw Exception(
          'Network error: No response from server. Check if server is running and IP address is correct.',
        );
      }

      if (response.statusCode! >= 400) {
        throw Exception('Server error: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      return Response(
        statusCode: 500,
        statusText: e.toString(),
        body: {'success': false, 'message': 'Network error: $e'},
      );
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    required dynamic itemData,
  }) async {
    try {
      final response =
          await GetConnect(timeout: const Duration(seconds: 10)).post(
        '$baseUrl/$endpointUrl',
        itemData,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == null) {
        throw Exception(
          'Network error: No response from server. Check if server is running and IP address is correct.',
        );
      }

      return response;
    } catch (e) {
      return Response(
        statusCode: 500,
        statusText: e.toString(),
        body: {'success': false, 'message': 'Network error: $e'},
      );
    }
  }

  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    required dynamic itemData,
  }) async {
    try {
      final response =
          await GetConnect(timeout: const Duration(seconds: 10)).put(
        '$baseUrl/$endpointUrl/$itemId',
        itemData,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == null) {
        throw Exception('Network error: No response from server');
      }

      return response;
    } catch (e) {
      return Response(
        statusCode: 500,
        statusText: e.toString(),
        body: {'success': false, 'message': 'Network error: $e'},
      );
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) async {
    try {
      final response = await GetConnect(
        timeout: const Duration(seconds: 10),
      ).delete('$baseUrl/$endpointUrl/$itemId');

      if (response.statusCode == null) {
        throw Exception('Network error: No response from server');
      }

      return response;
    } catch (e) {
      return Response(
        statusCode: 500,
        statusText: e.toString(),
        body: {'success': false, 'message': 'Network error: $e'},
      );
    }
  }
}
