import 'dart:async';
import 'dart:io';
import 'package:get/get_connect.dart';
import 'package:get/get.dart';

import '../utility/constants.dart';

class HttpService {
  final String baseUrl = MAIN_URL;
  final int timeoutSeconds = 30;

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      final response = await GetConnect(
        timeout: Duration(seconds: timeoutSeconds),
      ).get('$baseUrl/$endpointUrl');

      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    required dynamic itemData,
  }) async {
    try {
      final response = await GetConnect(
        timeout: Duration(seconds: timeoutSeconds),
      ).post(
        '$baseUrl/$endpointUrl',
        itemData,
        headers: {'Content-Type': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    required dynamic itemData,
  }) async {
    try {
      print('🔄 Making update request to: $baseUrl/$endpointUrl/$itemId');

      final response = await GetConnect(
        timeout: const Duration(seconds: 30),
        allowAutoSignedCert: true,
      ).put(
        '$baseUrl/$endpointUrl/$itemId',
        itemData,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📥 Update response status: ${response.statusCode}');

      if (response.statusCode == null) {
        print('❌ No response from server');
        throw SocketException(
            'No response from server. Check if server is running and IP is correct.');
      }

      if (response.statusCode! >= 400) {
        print('❌ Server error: ${response.statusCode} - ${response.body}');

        // Try to get error message from response
        String errorMsg = 'Server error: ${response.statusCode}';
        if (response.body is Map) {
          final body = response.body as Map<String, dynamic>;
          if (body.containsKey('message')) {
            errorMsg = body['message'].toString();
          }
        }

        throw HttpException(errorMsg);
      }

      return response;
    } on TimeoutException catch (e) {
      print('⏰ Request timeout: $e');
      rethrow;
    } on SocketException catch (e) {
      print('🌐 Network error: $e');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error in updateItem: $e');
      rethrow;
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) async {
    try {
      final response = await GetConnect(
        timeout: Duration(seconds: timeoutSeconds),
      ).delete('$baseUrl/$endpointUrl/$itemId');

      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  Response _handleResponse(Response response) {
    if (response.statusCode == null) {
      throw SocketException(
          'No response from server. Check if server is running.');
    }

    if (response.statusCode! >= 400) {
      // Try to extract error message from response body
      String errorMsg = 'Server error: ${response.statusCode}';

      if (response.body is Map) {
        final body = response.body as Map<String, dynamic>;
        if (body.containsKey('message')) {
          errorMsg = body['message'].toString();
        }
      }

      throw HttpException(errorMsg,
          uri: Uri.parse(response.request?.url.toString() ?? ''));
    }

    return response;
  }

  Response _handleException(dynamic e) {
    String errorMessage;

    if (e is SocketException) {
      errorMessage =
          'Network error: Cannot connect to server. Check your internet connection.';
    } else if (e is HttpException) {
      errorMessage = e.message;
    } else if (e is TimeoutException) {
      errorMessage = 'Request timeout. Please try again.';
    } else {
      errorMessage = 'Network error: $e';
    }

    return Response(
      statusCode: 500,
      statusText: errorMessage,
      body: {
        'success': false,
        'message': errorMessage,
      },
    );
  }
}
