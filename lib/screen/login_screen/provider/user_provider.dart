import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/email_verification_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/forgot_password_screen.dart';
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

    // Fix: Proper null checking
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

  Future<void> registerUser(String name, String email, String password) async {
    try {
      Map<String, dynamic> user = {
        "name": name.toLowerCase(),
        "email": email.toLowerCase(),
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

          // If email was provided, navigate to verification screen
          if (email.isNotEmpty) {
            Get.offAll(() => EmailVerificationScreen(
                  email: email,
                  onVerificationComplete: () async {
                    print(
                        '🟡 [REGISTER] onVerificationComplete callback executed');
                    // Try to login after verification
                    await loginUser(name, password);
                  },
                ));
          } else {
            // If no email, login directly
            await loginUser(name, password);
          }
        } else {
          // Handle specific error messages
          if (apiResponse.message.contains('already exists') == true) {
            throw Exception(
                'This email is already registered. Please use a different email or try logging in.');
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

// Update the loginUser method to trigger data loading after successful login
  Future<void> loginUser(String identifier, String password) async {
    try {
      // Clear any previous user data first
      clearAllUserData();

      Map<String, dynamic> loginData = {
        'password': password,
      };

      // Check if identifier is email
      if (identifier.contains('@')) {
        loginData['email'] = identifier.toLowerCase();
      } else {
        loginData['name'] = identifier.toLowerCase();
      }

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

          // Clear any existing data before saving new user
          clearAllUserData();

          await saveLoginInfo(user); // persist BEFORE navigating
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);

          // Navigate to home and trigger data loading
          Get.offAll(const HomeScreen());

          // Trigger data loading after navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // This will trigger data loading in HomeScreen
          });
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

  // Send email verification code
  Future<void> sendEmailVerification(String email) async {
    try {
      final response = await service.addItem(
        endpointUrl: 'verification/send-email-verification',
        itemData: {'email': email.toLowerCase()},
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Failed to send verification code');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Failed to send verification: $e');
      rethrow;
    }
  }

// Verify email with code
  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await service.addItem(
        endpointUrl: 'verification/verify-email',
        itemData: {
          'email': email.toLowerCase(),
          'code': code,
        },
      );

      if (response.isOk && response.body != null) {
        // Parse response manually to avoid null check issues
        if (response.body is Map<String, dynamic>) {
          final responseMap = response.body as Map<String, dynamic>;
          final success = responseMap['success'] as bool? ?? false;
          final message =
              responseMap['message'] as String? ?? 'Unknown response';

          if (success) {
            SnackBarHelper.showSuccessSnackBar(message);

            // Update user data if available
            if (responseMap['data'] != null) {
              final data = responseMap['data'] as Map<String, dynamic>;

              // Update the stored user info if needed
              final currentUser = getLoginUsr();
              if (currentUser != null && data['email'] == currentUser.email) {
                // Create updated user object
                final updatedUser = User(
                  sId: currentUser.sId,
                  name: currentUser.name,
                  email: currentUser.email,
                  phone: currentUser.phone,
                  password: currentUser.password,
                  emailVerified: data['emailVerified'] as bool? ?? true,
                  phoneVerified: currentUser.phoneVerified,
                  verificationCode: currentUser.verificationCode,
                  codeExpires: currentUser.codeExpires,
                  recoveryEmail: currentUser.recoveryEmail,
                  createdAt: currentUser.createdAt,
                  updatedAt: currentUser.updatedAt,
                  iV: currentUser.iV,
                );

                await saveLoginInfo(updatedUser);
              }
            }
          } else {
            throw Exception(message);
          }
        } else {
          throw Exception('Invalid server response');
        }
      } else {
        throw Exception('Verification failed: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Verification failed: $e');
      rethrow;
    }
  }

  // Forgot password - send reset code
  Future<void> sendPasswordResetCode(String email) async {
    try {
      final response = await service.addItem(
        endpointUrl: 'verification/forgot-password',
        itemData: {'email': email.toLowerCase()},
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          // Navigate to reset password screen
          Get.to(() => ForgotPasswordScreen(email: email));
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Failed to send reset code');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Failed to send reset code: $e');
      rethrow;
    }
  }

  // Reset password with code
  Future<void> resetPassword(
      String email, String code, String newPassword) async {
    try {
      final response = await service.addItem(
        endpointUrl: 'verification/reset-password',
        itemData: {
          'email': email.toLowerCase(),
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          Get.offAll(const LoginScreen());
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Password reset failed');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Password reset failed: $e');
      rethrow;
    }
  }

  // Update user profile with password verification
  Future<void> updateProfile({
    required String userId,
    required String name,
    String? email,
    required String currentPassword,
    String? newPassword,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'name': name,
        'currentPassword': currentPassword,
      };

      if (email != null && email.isNotEmpty) {
        updateData['email'] = email;
      }

      if (newPassword != null && newPassword.isNotEmpty) {
        updateData['newPassword'] = newPassword;
      }

      final response = await service.updateItem(
        endpointUrl: 'verification/update-profile',
        itemId: userId,
        itemData: updateData,
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);

          // Update stored user info if needed
          if (apiResponse.data != null) {
            await saveLoginInfo(User.fromJson(apiResponse.data));
          }

          notifyListeners();
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Profile update failed');
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

// In UserProvider, add this method
  void clearAllUserData() {
    // Clear user info
    box.remove(USER_INFO_BOX);

    // Clear favorites
    box.remove(FAVORITE_PRODUCT_BOX);

    // Clear cart
    var flutterCart = FlutterCart();
    flutterCart.clearCart();

    // Clear address
    box.remove(PHONE_KEY);
    box.remove(STREET_KEY);
    box.remove(CITY_KEY);
    box.remove(STATE_KEY);
    box.remove(POSTAL_CODE_KEY);
    box.remove(COUNTRY_KEY);

    // Clear profile image
    box.remove('profileImagePath');

    // Clear any other user-specific data

    notifyListeners();
  }

// Update the logOutUser method to use this
  void logOutUser() {
    clearAllUserData();
    Get.offAll(const LoginScreen());
    notifyListeners();
  }
}
