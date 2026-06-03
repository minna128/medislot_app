import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // MediSlot brand colors (matches Laravel website)
  static const Color primary        = Color(0xFF0D9488); // teal
  static const Color primaryDark    = Color(0xFF0F766E); // teal hover
  static const Color primaryLight   = Color(0xFF2DD4BF); // teal light
  static const Color accent         = Color(0xFF1E3A8A); // navy blue button

  // Backgrounds
  static const Color darkBackground = Color(0xFF050A1E); // hero dark navy
  static const Color darkSurface    = Color(0xFF0F172A); // card surface
  static const Color darkCard       = Color(0xFF1E293B); // elevated card

  // Light mode
  static const Color lightBackground = Color(0xFFF0FDFA); // teal tint
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightBorder     = Color(0xFFCCFBF1); // teal border

  // Text
  static const Color textPrimary    = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF546E7A);
  static const Color textHint       = Color(0xFF90A4AE);
  static const Color textLight      = Color(0xFFE8F0FE);

  // Semantic
  static const Color success        = Color(0xFF2E7D32);
  static const Color error          = Color(0xFFC62828);
  static const Color warning        = Color(0xFFE65100);
  static const Color white          = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFE0E0E0);
}
