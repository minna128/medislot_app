import 'package:flutter/material.dart';
import 'app_colors.dart';

// AppTheme defines the visual appearance of the entire app
// It has TWO themes — light and dark
// Flutter automatically switches between them based on the device setting
class AppTheme {
  // Private constructor — all themes are accessed as AppTheme.lightTheme or AppTheme.darkTheme
  AppTheme._();

  // LIGHT THEME — used when device is in light mode
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,          // Uses the latest Material Design 3 components
      brightness: Brightness.light, // Tells Flutter this is a light theme
      fontFamily: 'Poppins',        // All text uses Poppins font by default

      // ColorScheme defines the main colors used throughout the app in light mode
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,           // Main teal color for buttons and highlights
        onPrimary: AppColors.white,           // Text color on top of primary color
        secondary: AppColors.primaryLight,    // Secondary teal for accents
        surface: AppColors.lightSurface,      // White card backgrounds
        onSurface: AppColors.textPrimary,     // Dark text on white cards
        background: AppColors.lightBackground,// Very light teal main background
        onBackground: AppColors.textPrimary,  // Dark text on background
        error: AppColors.error,               // Red color for error messages
      ),

      scaffoldBackgroundColor: AppColors.lightBackground, // Main screen background color

      // AppBar styling — top navigation bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground, // Same as background — seamless look
        foregroundColor: AppColors.textPrimary,      // Dark text and icons
        elevation: 0,                                // No shadow under AppBar
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins', fontSize: 20,
          fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
      ),

      // Card styling — rounded corners, no shadow, light border
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),

      // Input field styling — used in login and register forms
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Normal border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        // Border when not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        // Border when user taps on the field
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        // Border when there is a validation error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
      ),

      // Elevated button styling — solid teal background buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52), // Full width, 52px height
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Outlined button styling — transparent background with teal border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // DARK THEME — used when device is in dark mode
  // Same structure as light theme but with dark colors from AppColors
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,  // Tells Flutter this is a dark theme
      fontFamily: 'Poppins',

      // ColorScheme for dark mode — uses dark navy backgrounds and lighter teal
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,        // Lighter teal works better on dark backgrounds
        onPrimary: AppColors.darkBackground,    // Dark text on light teal buttons
        secondary: AppColors.primary,           // Standard teal as secondary
        surface: AppColors.darkCard,            // Dark card backgrounds
        onSurface: AppColors.textLight,         // Light text on dark cards
        background: AppColors.darkBackground,   // Very dark navy main background
        onBackground: AppColors.textLight,      // Light text on dark background
        error: Color(0xFFEF9A9A),              // Lighter red for dark mode
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      // AppBar in dark mode — dark background with light text
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins', fontSize: 20,
          fontWeight: FontWeight.w600, color: AppColors.textLight,
        ),
      ),

      // Card in dark mode — dark card color with subtle teal border
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primaryLight.withOpacity(0.15)),
        ),
      ),

      // Input fields in dark mode — dark surface with dark border
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF243B55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF243B55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF90A4AE)),
      ),

      // Buttons look the same in dark mode — teal is readable on dark backgrounds
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Outlined button in dark mode uses lighter teal so it's visible
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}