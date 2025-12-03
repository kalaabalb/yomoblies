import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/page_wrapper.dart';
import '../../shared/widgets/buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    if (_identifierController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar(
        context.dataProvider.translate('error'),
        context.dataProvider.translate('please_fill_all_fields'),
      );
      return;
    }

    if (!_isLogin) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar(
          context.dataProvider.translate('error'),
          context.dataProvider.translate('passwords_dont_match'),
        );
        return;
      }
      if (_passwordController.text.length < 6) {
        Get.snackbar(
          context.dataProvider.translate('error'),
          'Password must be at least 6 characters',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await context.userProvider.loginUser(
          _identifierController.text,
          _passwordController.text,
        );
      } else {
        await context.userProvider.registerUser(
          _identifierController.text,
          _emailController.text,
          _passwordController.text,
        );
      }
    } catch (e) {
      // Error handled by provider
    }

    setState(() => _isLoading = false);
  }

  void _forgotPassword() {
    if (_identifierController.text.isEmpty &&
        !_identifierController.text.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter your email to reset password',
      );
      return;
    }

    // Use identifier if it's an email, otherwise show dialog for email input
    if (_identifierController.text.contains('@')) {
      context.userProvider.sendPasswordResetCode(_identifierController.text);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Please enter your email address to reset your password:'),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                inputType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  Get.back();
                  context.userProvider
                      .sendPasswordResetCode(_emailController.text);
                }
              },
              child: const Text('Send Code'),
            ),
          ],
        ),
      );
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
                  Image.asset('assets/images/logo.png', height: 100),
                  const SizedBox(height: 40),
                  Text(
                    _isLogin
                        ? context.dataProvider.translate('login')
                        : context.dataProvider.translate('register'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkOrange,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _identifierController,
                    labelText: _isLogin ? 'Username or Email' : 'Username',
                    validator: (value) => value!.isEmpty
                        ? _isLogin
                            ? 'Enter username or email'
                            : 'Enter username'
                        : null,
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email (Optional)',
                      inputType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isNotEmpty && !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: context.dataProvider.translate('password'),
                    validator: (value) => value!.isEmpty
                        ? context.dataProvider.translate('enter_password')
                        : null,
                    obscureText: true,
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText:
                          context.dataProvider.translate('confirm_password'),
                      validator: (value) => value!.isEmpty
                          ? context.dataProvider.translate('confirm_password')
                          : null,
                      obscureText: true,
                    ),
                  ],
                  if (_isLogin) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppColor.darkOrange),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: _isLogin
                        ? context.dataProvider.translate('login')
                        : context.dataProvider.translate('register'),
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    text: _isLogin
                        ? context.dataProvider.translate('dont_have_account')
                        : context.dataProvider
                            .translate('already_have_account'),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Clear fields when switching modes
                        if (_isLogin) {
                          _emailController.clear();
                          _confirmPasswordController.clear();
                        }
                      });
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
