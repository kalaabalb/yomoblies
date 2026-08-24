import 'dart:async';
import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/user.dart';
import '../../../services/http_services.dart';
import '../login_screen.dart';
import '../../../utility/constants.dart';

class UserProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  UserProvider();

  User? getLoginUsr() {
    final token = box.read('auth_token');
    if (token == null || token.toString().isEmpty) {
      return null;
    }

    Map<String, dynamic>? userJson = box.read(userInfoBox);

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      User? userLogged = User.fromJson(userJson);
      return userLogged;
    } catch (e) {
      return null;
    }
  }

  Future<void> loginUser(String username, String password) async {
    try {
      clearAllUserData();

      Map<String, dynamic> loginData = {
        'name': username.toLowerCase().trim(),
        'password': password,
      };

      final response = await service.addItem(
        endpointUrl: 'users/login',
        itemData: loginData,
      );

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Login successful';
        final data = responseBody['data'];

        if (success && data != null) {
          final loginData = data as Map<String, dynamic>;
          final token = loginData['token']?.toString();
          final userJson = loginData['user'] is Map<String, dynamic>
              ? loginData['user'] as Map<String, dynamic>
              : loginData;
          User user = User.fromJson(userJson);

          if (token == null || token.isEmpty) {
            throw Exception('Authentication token missing from login response.');
          }

          clearAllUserData();
          await saveLoginInfo(user, token: token);

          SnackBarHelper.showSuccessSnackBar('Welcome back, ${user.name}!');
          Get.offAll(const HomeScreen());
        } else {
          throw Exception(message);
        }
      } else {
        if (response.statusCode == 401) {
          throw Exception('Invalid name or password.');
        } else if (response.statusCode == 404) {
          throw Exception('User not found.');
        } else {
          throw Exception('Login failed: ${response.statusText}');
        }
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  Future<void> registerUser(String name, String email, String password) async {
    try {
      Map<String, dynamic> user = {
        "name": name.toLowerCase().trim(),
        "email": email.toLowerCase().trim(),
        "password": password,
      };

      final response = await service.addItem(
        endpointUrl: 'users/register',
        itemData: user,
      );

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Registration successful';

        if (success) {
          SnackBarHelper.showSuccessSnackBar('Account created successfully!');

          await loginUser(name, password);
        } else {
          throw Exception(message);
        }
      } else {
        if (response.statusCode == 400) {
          throw Exception('Registration failed. Please check your details.');
        } else {
          throw Exception('Registration failed: ${response.statusText}');
        }
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  // Forgot password - send reset code to email
  Future<void> forgotPassword(String email) async {
    try {
      Map<String, dynamic> data = {
        'email': email.toLowerCase().trim(),
      };

      final response = await service.addItem(
        endpointUrl: 'verification/forgot-password',
        itemData: data,
      );

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Reset code sent';

        if (success) {
          SnackBarHelper.showSuccessSnackBar(message);
        } else {
          throw Exception(message);
        }
      } else {
        if (response.statusCode == 404) {
          throw Exception('No verified account found with this email.');
        } else {
          throw Exception('Failed to send reset code: ${response.statusText}');
        }
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  // Reset password with code
  Future<void> resetPassword(
      String email, String code, String newPassword) async {
    try {
      Map<String, dynamic> data = {
        'email': email.toLowerCase().trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      };

      final response = await service.addItem(
        endpointUrl: 'verification/reset-password',
        itemData: data,
      );

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Password reset successful';

        if (success) {
          SnackBarHelper.showSuccessSnackBar(message);
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Failed to reset password: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String currentPassword,
    String? newPassword,
  }) async {
    bool isLoadingDialogShown = false;

    try {
      if (name.isEmpty) {
        SnackBarHelper.showProfileError('Username cannot be empty');
        return;
      }

      if (currentPassword.isEmpty) {
        SnackBarHelper.showProfileError('Current password is required');
        return;
      }

      if (Get.isDialogOpen == false) {
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );
        isLoadingDialogShown = true;
      }

      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'currentPassword': currentPassword,
      };

      if (newPassword != null && newPassword.isNotEmpty) {
        if (newPassword.length < 4) {
          _closeLoadingDialog(isLoadingDialogShown);
          SnackBarHelper.showProfileError(
              'New password must be at least 4 characters');
          return;
        }
        updateData['password'] = newPassword;
      }

      final response = await service.updateItem(
        endpointUrl: 'users/profile',
        itemId: '',
        itemData: updateData,
      );

      _closeLoadingDialog(isLoadingDialogShown);

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Profile updated';

        if (success) {
          final data = responseBody['data'];

          if (data != null && data is Map<String, dynamic>) {
            final updatedUser = User.fromJson(data);
            final storedToken = box.read('auth_token')?.toString();
            await saveLoginInfo(updatedUser, token: storedToken);

            notifyListeners();

            SnackBarHelper.showSuccessSnackBar('Profile updated successfully!');

            if (newPassword != null && newPassword.isNotEmpty) {
              Get.snackbar(
                'Password Changed',
                'Password updated successfully. Please login again.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );

              Future.delayed(const Duration(seconds: 2), () {
                logOutUser();
              });
            }
          }
        } else {
          SnackBarHelper.showProfileError(message);
        }
      } else {
        SnackBarHelper.showProfileError(
            'Update failed: ${response.statusText}');
      }
    } catch (e) {
      _closeLoadingDialog(isLoadingDialogShown);
      print('❌ Profile update error: $e');
      SnackBarHelper.showProfileError('An error occurred');
    }
  }

  void _closeLoadingDialog(bool wasShown) {
    if (wasShown && Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<void> saveLoginInfo(User? loginUser, {String? token}) async {
    if (loginUser == null) return;
    try {
      await box.write(userInfoBox, loginUser.toJson());
      if (token != null && token.isNotEmpty) {
        await box.write('auth_token', token);
      }
      notifyListeners();
    } catch (e) {
      print('Error saving login info: $e');
    }
  }

  void clearAllUserData() {
    try {
      box.remove('auth_token');
      box.remove(userInfoBox);

      box.remove(favoriteProductBox);

      var flutterCart = FlutterCart();
      flutterCart.clearCart();

      box.remove(phoneKey);
      box.remove(streetKey);
      box.remove(cityKey);
      box.remove(stateKey);
      box.remove(postalCodeKey);
      box.remove(countryKey);

      box.remove('profileImagePath');

      notifyListeners();
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  void logOutUser() {
    try {
      if (Get.isRegistered<ProfileProvider>()) {
        final profileProvider = Get.find<ProfileProvider>();
        profileProvider.clearProfileData();
      }

      clearAllUserData();
      Get.offAll(const LoginScreen());
      SnackBarHelper.showInfoSnackBar('Logged out successfully');
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      Get.offAll(const LoginScreen());
    }
  }

  Future<void> restoreSession() async {
    final token = box.read('auth_token');
    final userJson = box.read(userInfoBox);

    if (token == null || token.toString().isEmpty || userJson == null) {
      clearAllUserData();
      return;
    }

    try {
      final response = await service.getItems(endpointUrl: 'users/profile');
      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final data = responseBody['data'];

        if (data is Map<String, dynamic>) {
          await saveLoginInfo(User.fromJson(data), token: token.toString());
          return;
        }
      }
    } catch (e) {
      clearAllUserData();
      return;
    }

    clearAllUserData();
  }
}
