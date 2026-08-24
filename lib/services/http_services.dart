import 'dart:async';
import 'dart:io';
import 'package:get/get_connect.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../utility/constants.dart';

class HttpService {
  final String baseUrl = MAIN_URL;
  final int timeoutSeconds = 30;
  final GetStorage _storage = GetStorage();

  Map<String, String> _buildHeaders({bool includeJson = false}) {
    final headers = <String, String>{
      if (includeJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _storage.read('auth_token');
    if (token is String && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      final response = await GetConnect(
        timeout: Duration(seconds: timeoutSeconds),
      ).get(
        '$baseUrl/$endpointUrl',
        headers: _buildHeaders(),
      );

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
        headers: _buildHeaders(includeJson: true),
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
      final requestPath = itemId.isEmpty
          ? '$baseUrl/$endpointUrl'
          : '$baseUrl/$endpointUrl/$itemId';

      final response = await GetConnect(
        timeout: const Duration(seconds: 30),
      ).put(
        requestPath,
        itemData,
        headers: _buildHeaders(includeJson: true),
      );

      if (response.statusCode == null) {
        throw SocketException(
            'No response from server. Check if server is running and IP is correct.');
      }

      if (response.statusCode! >= 400) {
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
      rethrow;
    } on SocketException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) async {
    try {
      final requestPath = itemId.isEmpty
          ? '$baseUrl/$endpointUrl'
          : '$baseUrl/$endpointUrl/$itemId';
      final response = await GetConnect(
        timeout: Duration(seconds: timeoutSeconds),
      ).delete(
        requestPath,
        headers: _buildHeaders(),
      );

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

    if (response.statusCode == 401) {
      final storage = GetStorage();
      storage.remove('auth_token');
      storage.remove(USER_INFO_BOX);
      return response;
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
