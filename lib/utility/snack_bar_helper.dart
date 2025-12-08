import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackBarHelper {
  static void showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  static void showErrorSnackBar(String message) {
    // Convert technical errors to user-friendly messages
    String userMessage = _convertToUserFriendly(message);

    Get.snackbar(
      'Error',
      userMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  static void showInfoSnackBar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  static void showProfileError(String error) {
    String userMessage = _convertProfileError(error);

    Get.snackbar(
      'Update Failed',
      userMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  static String _convertToUserFriendly(String error) {
    error = error.toLowerCase();

    if (error.contains('invalid name or password') ||
        error.contains('incorrect password')) {
      return 'Wrong username or password. Please try again.';
    }

    if (error.contains('already exists') ||
        error.contains('duplicate') ||
        error.contains('username is already taken')) {
      return 'This username is already taken. Please choose another one.';
    }

    if (error.contains('network error') ||
        error.contains('socket') ||
        error.contains('connection')) {
      return 'Cannot connect to server. Please check your internet connection.';
    }

    if (error.contains('timeout') || error.contains('timed out')) {
      return 'Request timeout. Please try again.';
    }

    if (error.contains('no response') ||
        error.contains('server not responding')) {
      return 'Server is not responding. Please try again later.';
    }

    if (error.contains('required')) {
      if (error.contains('name') && error.contains('password')) {
        return 'Both username and password are required.';
      } else if (error.contains('name')) {
        return 'Username is required.';
      } else if (error.contains('password')) {
        return 'Password is required.';
      }
    }

    // Return original message but cleaned up
    return error.replaceAll('Exception:', '').replaceAll('Error:', '').trim();
  }

  static String _convertProfileError(String error) {
    error = error.toLowerCase();

    if (error.contains('current password is incorrect') ||
        error.contains('wrong current password')) {
      return 'Your current password is incorrect. Please try again.';
    }

    if (error.contains('current password is required')) {
      return 'Please enter your current password to make changes.';
    }

    if (error.contains('name is required')) {
      return 'Username cannot be empty.';
    }

    if (error.contains('username is already taken') ||
        error.contains('name already exists')) {
      return 'This username is already taken. Please choose a different one.';
    }

    // Fall back to general error converter
    return _convertToUserFriendly(error);
  }
}
