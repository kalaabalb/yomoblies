import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get.dart';
import '../../../models/api_response.dart';
import '../../../models/user.dart';
import '../../../services/http_services.dart';
import '../login_screen.dart';
import 'package:get_storage/get_storage.dart';
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
        'name': username.toLowerCase(),
        'password': password,
      };

      final response = await service.addItem(
        endpointUrl: 'users/login',
        itemData: loginData,
      );

      if (response.isOk) {
        final ApiResponse<User> apiResponse = ApiResponse.fromJson(
          response.body,
          (json) => User.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success == true) {
          User? user = apiResponse.data;

          clearAllUserData();

          await saveLoginInfo(user);
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);

          Get.offAll(const HomeScreen());
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Login failed: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Login failed: $e');
      rethrow;
    }
  }

  Future<void> registerUser(
      String name, String dummyEmail, String password) async {
    try {
      Map<String, dynamic> user = {
        "name": name.toLowerCase(),
        "email": dummyEmail.toLowerCase(),
        "password": password,
      };

      final response = await service.addItem(
        endpointUrl: 'users/register',
        itemData: user,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);

          await loginUser(name, password);
        } else {
          if (apiResponse.message.contains('already exists') == true) {
            throw Exception(
                'This username is already taken. Please choose a different username.');
          } else {
            throw Exception(apiResponse.message ?? 'Registration failed');
          }
        }
      } else {
        throw Exception('Registration failed: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Registration failed: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String currentPassword,
    String? newPassword,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'name': name,
        'currentPassword': currentPassword,
      };

      if (newPassword != null && newPassword.isNotEmpty) {
        updateData['newPassword'] = newPassword;
      }

      final response = await service.updateItem(
        endpointUrl: 'users/update-profile',
        itemId: userId,
        itemData: updateData,
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);

          if (apiResponse.data != null) {
            final updatedUser = User.fromJson(apiResponse.data);
            await saveLoginInfo(updatedUser);

            Get.snackbar(
              'Success',
              'Profile updated successfully. Please login again with your new credentials.',
              duration: const Duration(seconds: 5),
            );

            Future.delayed(const Duration(seconds: 2), () {
              logOutUser();
            });
          }

          notifyListeners();
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Profile update failed: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Profile update failed: $e');
      rethrow;
    }
  }

  Future<void> saveLoginInfo(User? loginUser) async {
    if (loginUser == null) return;
    try {
      await box.write(USER_INFO_BOX, loginUser.toJson());
      notifyListeners();
    } catch (e) {}
  }

  void clearAllUserData() {
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
    box.remove('profile_image_path');

    try {} catch (e) {}

    notifyListeners();
  }

  void logOutUser() {
    try {
      final profileProvider = Get.find<ProfileProvider>();
      profileProvider.clearProfileData();
    } catch (e) {}

    clearAllUserData();
    Get.offAll(const LoginScreen());
    notifyListeners();
  }
}
