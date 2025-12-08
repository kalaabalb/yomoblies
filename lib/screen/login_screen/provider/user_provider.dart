import 'dart:async';
import 'dart:io';
import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/api_response.dart';
import '../../../models/user.dart';
import '../../../services/http_services.dart';
import '../login_screen.dart';
import '../../../utility/constants.dart';

class UserProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  UserProvider();

  User? getLoginUsr() {
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);

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
          User user = User.fromJson(data as Map<String, dynamic>);

          clearAllUserData();
          await saveLoginInfo(user);

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

  Future<void> registerUser(
      String name, String dummyEmail, String password) async {
    try {
      Map<String, dynamic> user = {
        "name": name.toLowerCase().trim(),
        "email": dummyEmail.toLowerCase(),
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
        endpointUrl: 'users',
        itemId: userId,
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
            await saveLoginInfo(updatedUser);

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

  Future<void> saveLoginInfo(User? loginUser) async {
    if (loginUser == null) return;
    try {
      await box.write(USER_INFO_BOX, loginUser.toJson());
      notifyListeners();
    } catch (e) {
      print('Error saving login info: $e');
    }
  }

  void clearAllUserData() {
    try {
      box.remove(USER_INFO_BOX);

      box.remove(FAVORITE_PRODUCT_BOX);

      var flutterCart = FlutterCart();
      flutterCart.clearCart();

      box.remove(PHONE_KEY);
      box.remove(STREET_KEY);
      box.remove(CITY_KEY);
      box.remove(STATE_KEY);
      box.remove(POSTAL_CODE_KEY);
      box.remove(COUNTRY_KEY);

      box.remove('profileImagePath');

      notifyListeners();
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  void logOutUser() {
    try {
      try {
        final profileProvider = Get.find<ProfileProvider>();
        profileProvider.clearProfileData();
      } catch (e) {}

      clearAllUserData();
      Get.offAll(const LoginScreen());
      SnackBarHelper.showInfoSnackBar('Logged out successfully');
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      Get.offAll(const LoginScreen());
    }
  }
}
