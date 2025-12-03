import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorHandler {
  static String getUserFriendlyError(dynamic error) {
    if (error is String) {
      // HTTP Status Code based errors
      if (error.contains('401') || error.contains('Invalid name or password')) {
        return 'The username or password you entered is incorrect.';
      }

      if (error.contains('400') ||
          error.contains('User with this name already exists')) {
        return 'This username is already taken. Please choose another one.';
      }

      if (error.contains('404')) {
        return 'Service temporarily unavailable. Please try again later.';
      }

      if (error.contains('500')) {
        return 'Server error. Please try again in a moment.';
      }

      // Network and connection errors
      if (error.contains('IOException') ||
          error.contains('SocketException') ||
          error.contains('Network is unreachable') ||
          error.contains('Failed host lookup') ||
          error.contains('Connection refused')) {
        return 'Please check your internet connection and try again.';
      }

      if (error.contains('Timeout') || error.contains('timed out')) {
        return 'Request took too long. Please try again.';
      }

      // Remove technical details from error messages
      return _removeTechnicalDetails(error);
    }

    return 'Something went wrong. Please try again.';
  }

  static String _removeTechnicalDetails(String error) {
    // Remove common technical prefixes
    final technicalPrefixes = [
      'Exception:',
      'Error:',
      'Failed to',
      'Unable to',
    ];

    String cleanedError = error;
    for (final prefix in technicalPrefixes) {
      if (cleanedError.contains(prefix)) {
        cleanedError = cleanedError.split(prefix).last.trim();
      }
    }

    // Capitalize first letter
    if (cleanedError.isNotEmpty) {
      cleanedError = cleanedError[0].toUpperCase() + cleanedError.substring(1);
    }

    return cleanedError;
  }

  static void handleError(
    dynamic error, {
    BuildContext? context,
    bool showToUser = true,
  }) {
    final friendlyError = getUserFriendlyError(error);

    if (showToUser && _shouldShowToUser(error)) {
      _showErrorSnackBar(friendlyError);
    }
  }

  static bool _shouldShowToUser(dynamic error) {
    if (error is String) {
      // Don't show these technical errors to users
      final technicalErrors = [
        'getItems',
        'addItem',
        'updateItem',
        'deleteItem',
        'Response',
        'statusCode',
        'DioError',
        'HttpException',
      ];

      return !technicalErrors.any((techError) => error.contains(techError));
    }
    return true;
  }

  static void _showErrorSnackBar(String message) {
    Get.rawSnackbar(
      message: message,
      backgroundColor: Colors.red[800]!,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      snackPosition: SnackPosition.BOTTOM,
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // Specific error handlers for common operations
  static void handleNetworkError(
    dynamic error, {
    String operation = 'perform this action',
  }) {
    final friendlyError = getUserFriendlyError(error);
    final message = friendlyError.contains('internet')
        ? friendlyError
        : 'Unable to $operation. Please check your connection.';

    _showErrorSnackBar(message);
  }

  static void handleDataLoadError(dynamic error, {String dataType = 'data'}) {
    final friendlyError = getUserFriendlyError(error);
    final message = friendlyError.contains('internet')
        ? friendlyError
        : 'Failed to load $dataType. Please try again.';

    _showErrorSnackBar(message);
  }
}
