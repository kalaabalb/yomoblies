import 'package:flutter/material.dart' show Color;

class AppColor {
  const AppColor._();

  // New elegant color scheme
  static const primaryBlue = Color(0xFF2D5A7E);
  static const secondaryBlue = Color(0xFF4A7BA6);
  static const accentTeal = Color(0xFF2A9D8F);
  static const lightTeal = Color(0xFF8ECAE6);

  static const darkGrey = Color(0xFF2B2D42);
  static const mediumGrey = Color(0xFF8D99AE);
  static const lightGrey = Color(0xFFEDF2F4);

  static const successGreen = Color(0xFF4CAF50);
  static const warningAmber = Color(0xFFFFB74D);
  static const errorRed = Color(0xFFEF5350);

  // Gradient colors
  static const gradientStart = Color(0xFF2D5A7E);
  static const gradientEnd = Color(0xFF4A7BA6);

  // Background colors
  static const scaffoldLight = Color(0xFFF8F9FA);
  static const scaffoldDark = Color(0xFF121212);

  // Card colors
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1E1E1E);

  // Keep the old names for backward compatibility
  static const darkOrange = Color(0xFF2D5A7E); // Same as primaryBlue
  static const lightOrange = Color(0xFF4A7BA6); // Same as secondaryBlue
}