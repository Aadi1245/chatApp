import 'package:flutter/material.dart';

class AppTheme {
  // Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFFFF5722), // Orange
      scaffoldBackgroundColor: const Color(0xFFFF5722), // Orange background
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFF5722),
        elevation: 1,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // Comprehensive TextTheme with fixed font sizes
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        titleSmall: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        labelLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        labelSmall: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
      ),
      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF5722),
        foregroundColor: Colors.white,
      ),
      // Input decoration theme
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
    );
  }

  // Gradient for background
  static LinearGradient get backgroundGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF8A65), // Lighter orange
        Color(0xFFFF5722), // Primary orange
      ],
    );
  }
}
