import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData lightAppTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.primaryBlue,
    scaffoldBackgroundColor: AppColor.scaffoldLight,
    cardColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColor.darkOrange,
      unselectedItemColor: Colors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColor.primaryBlue,
      secondary: AppColor.secondaryBlue,
      surface: Colors.white,
      background: AppColor.scaffoldLight,
      onSurface: Colors.black,
      onBackground: Colors.black,
    ),
    textTheme: const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),

      // Body styles
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: AppColor.primaryBlue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColor.primaryBlue,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.primaryBlue,
        side: const BorderSide(color: AppColor.primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColor.primaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      subtitleTextStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      iconColor: Colors.grey[700],
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[100]!,
      selectedColor: AppColor.primaryBlue,
      secondarySelectedColor: AppColor.primaryBlue,
      labelStyle: const TextStyle(color: Colors.black),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData darkAppTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColor.secondaryBlue,
    scaffoldBackgroundColor: AppColor.scaffoldDark,
    cardColor: AppColor.cardDark,
    dialogBackgroundColor: AppColor.cardDark,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColor.cardDark,
      selectedItemColor: AppColor.lightOrange,
      unselectedItemColor: Colors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.scaffoldDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColor.secondaryBlue,
      secondary: AppColor.accentTeal,
      surface: AppColor.cardDark,
      background: AppColor.scaffoldDark,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    textTheme: const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),

      // Body styles
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: AppColor.secondaryBlue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColor.lightTeal,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.lightTeal,
        side: const BorderSide(color: AppColor.lightTeal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColor.secondaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    cardTheme: CardThemeData(
      color: AppColor.cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColor.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      subtitleTextStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      iconColor: Colors.grey[400],
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[700],
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[800]!,
      selectedColor: AppColor.secondaryBlue,
      secondarySelectedColor: AppColor.secondaryBlue,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}