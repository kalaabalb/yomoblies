import 'dart:async';

import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/screen/login_screen/login_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _storage = GetStorage();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  final List<OnboardingPage> _onboardingPages = [
    OnboardingPage(
      image: 'assets/images/onboarding1.svg',
      title: 'Discover Amazing Products',
      description:
          'Explore thousands of high-quality products from trusted brands and sellers worldwide.',
      color: AppColor.primaryBlue,
      icon: Icons.shopping_bag_rounded,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding2.svg',
      title: 'Easy & Secure Shopping',
      description:
          'Shop with confidence using our secure payment system and fast delivery options.',
      color: Colors.purple,
      icon: Icons.credit_card_rounded,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding3.svg',
      title: 'Fast Delivery',
      description:
          'Get your products delivered quickly right to your doorstep with real-time tracking.',
      color: Colors.orange,
      icon: Icons.local_shipping_rounded,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding4.svg',
      title: 'Start Shopping Now!',
      description:
          'Join millions of happy customers and enjoy the best shopping experience.',
      color: Colors.green,
      icon: Icons.shopping_cart_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        final nextPage = (_currentPage + 1) % _onboardingPages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _completeOnboarding() {
    _autoAdvanceTimer?.cancel();
    _storage.write('onboarding_completed', true);

    // Check if user is already logged in
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.getLoginUsr() != null;

    if (isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _manualNext() {
    _autoAdvanceTimer?.cancel();

    final nextPage = (_currentPage + 1) % _onboardingPages.length;
    if (nextPage == 0) {
      _completeOnboarding();
    } else {
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _onboardingPages[_currentPage].color,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    onboardingPage: _onboardingPages[index],
                    pageNumber: index + 1,
                    totalPages: _onboardingPages.length,
                  );
                },
              ),
            ),

            // Bottom section with dots and buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Next/Get Started button
                  PrimaryButton(
                    text: _currentPage == _onboardingPages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _manualNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage onboardingPage;
  final int pageNumber;
  final int totalPages;

  const OnboardingPageWidget({
    super.key,
    required this.onboardingPage,
    required this.pageNumber,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Image with fallback to icon
          _buildImageOrIcon(),

          const SizedBox(height: 50),

          // Title
          Text(
            onboardingPage.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            onboardingPage.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Page number indicator
          Text(
            '$pageNumber/$totalPages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOrIcon() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          onboardingPage.image,
          width: 200,
          height: 200,
          color: Colors.white.withOpacity(0.9),
          placeholderBuilder: (BuildContext context) {
            // Fallback to icon if SVG fails to load
            return Icon(onboardingPage.icon, size: 80, color: Colors.white);
          },
        ),
      ),
    );
  }
}
