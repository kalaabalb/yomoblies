import 'dart:async';

import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/page_wrapper.dart';
import '../../shared/widgets/buttons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordScreen({super.key, required this.email});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    try {
      setState(() {});

      await context.userProvider.sendPasswordResetCode(widget.email);
      _startCooldown();
    } catch (e) {
      // Error handled by provider
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      SnackBarHelper.showErrorSnackBar('Please enter a valid 6-digit code');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      SnackBarHelper.showErrorSnackBar('Please enter new password');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      SnackBarHelper.showErrorSnackBar('Passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      SnackBarHelper.showErrorSnackBar(
          'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.userProvider.resetPassword(
        widget.email,
        _codeController.text,
        _newPasswordController.text,
      );
    } catch (e) {
      // Error handled by provider
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: PageWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: AppColor.darkOrange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the code sent to ${widget.email}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _codeController,
                    labelText: 'Enter 6-digit code',
                    inputType: TextInputType.number,
                    maxLength: 6,
                    showCounter: true,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter verification code'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _newPasswordController,
                    labelText: 'New Password',
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter new password' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm New Password',
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Please confirm password' : null,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Reset Password',
                    onPressed: _isLoading ? null : _resetPassword,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: _resendCooldown > 0 ? null : _resendCode,
                        child: Text(
                          _resendCooldown > 0
                              ? 'Resend in $_resendCooldown s'
                              : 'Resend Code',
                          style: TextStyle(
                            color: _resendCooldown > 0
                                ? Colors.grey
                                : AppColor.darkOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    text: 'Back to Login',
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  SizedBox(
                    height:
                        MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
