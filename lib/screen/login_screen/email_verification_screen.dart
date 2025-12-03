import 'dart:async';

import 'package:e_commerce_flutter/screen/login_screen/login_screen.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/page_wrapper.dart';
import '../../shared/widgets/buttons.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerificationComplete;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.onVerificationComplete,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60; // 60 seconds cooldown
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

  Future<void> _sendVerificationCode() async {
    try {
      setState(() {});

      await context.userProvider.sendEmailVerification(widget.email);

      if (mounted) {
        SnackBarHelper.showSuccessSnackBar(
            'Verification code sent to ${widget.email}');
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showErrorSnackBar('Failed to send code: $e');
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      SnackBarHelper.showErrorSnackBar('Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(
          '🟡 [UI] Calling verifyEmail with: ${widget.email}, ${_codeController.text}');
      await context.userProvider
          .verifyEmail(widget.email, _codeController.text);

      print(
          '🟡 [UI] Email verification completed successfully, calling onVerificationComplete');

      // Show success message
      SnackBarHelper.showSuccessSnackBar('Email verified successfully!');

      // Call the completion callback
      widget.onVerificationComplete();
    } catch (e) {
      // Error is already handled by the provider, just don't navigate
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resendCode() {
    if (_resendCooldown > 0) return;

    _sendVerificationCode();
    _startCooldown();
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
                    Icons.verified_user_outlined,
                    size: 80,
                    color: AppColor.darkOrange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We sent a verification code to',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkOrange,
                    ),
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
                  PrimaryButton(
                    text: 'Verify Email',
                    onPressed: _isLoading ? null : _verifyCode,
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
                    text: 'Change Email',
                    onPressed: () {
                      Get.offAll(const LoginScreen());
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
