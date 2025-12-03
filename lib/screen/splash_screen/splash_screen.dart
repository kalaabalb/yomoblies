import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../../screen/home_screen.dart';
import '../../screen/login_screen/login_screen.dart';
import '../login_screen/provider/user_provider.dart';
import '../onboarding_screen/onboarding_screen.dart';
import '../../shared/widgets/loading_states.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initializeApp() async {
    // Wait for data to load
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if user is already logged in
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.getLoginUsr() != null;
    final onboardingCompleted = _storage.read('onboarding_completed') ?? false;

    print('🟡 [SPLASH] onboardingCompleted: $onboardingCompleted');
    print('🟡 [SPLASH] isLoggedIn: $isLoggedIn');

    if (!mounted) return;

    if (!onboardingCompleted) {
      // First time - show onboarding
      print('🟡 [SPLASH] Navigating to OnboardingScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (!isLoggedIn) {
      // User completed onboarding but not logged in
      print('🟡 [SPLASH] Navigating to LoginScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // User is already logged in - go directly to home
      print('🟡 [SPLASH] Navigating to HomeScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            const SizedBox(height: 20),
            const LoadingIndicator(message: 'Loading...'),
          ],
        ),
      ),
    );
  }
}
