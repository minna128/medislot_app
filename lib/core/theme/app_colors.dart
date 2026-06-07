import 'package:flutter/material.dart';

// AppColors defines all the colors used throughout the app
// All colors match the Laravel website design for consistency
// Using a central color file means we only need to change a color in one place
// to update it everywhere in the app
class AppColors {
  // Private constructor — prevents creating instances, all colors are static
  AppColors._();

  // PRIMARY BRAND COLORS — the main teal color used for buttons, headers, highlights
  // These match exactly the teal colors used on the Laravel MediSlot website
  static const Color primary        = Color(0xFF0D9488); // Main teal — used for buttons and banners
  static const Color primaryDark    = Color(0xFF0F766E); // Darker teal — used for gradient end color
  static const Color primaryLight   = Color(0xFF2DD4BF); // Lighter teal — used on dark backgrounds
  static const Color accent         = Color(0xFF1E3A8A); // Navy blue — used for secondary buttons

  // DARK MODE BACKGROUND COLORS
  // Used when the device is in dark mode (ThemeMode.system)
  static const Color darkBackground = Color(0xFF050A1E); // Very dark navy — main background
  static const Color darkSurface    = Color(0xFF0F172A); // Slightly lighter — card backgrounds
  static const Color darkCard       = Color(0xFF1E293B); // Even lighter — elevated cards

  // LIGHT MODE BACKGROUND COLORS
  // Used when the device is in light mode
  static const Color lightBackground = Color(0xFFF0FDFA); // Very light teal tint — main background
  static const Color lightSurface    = Color(0xFFFFFFFF); // Pure white — card backgrounds
  static const Color lightBorder     = Color(0xFFCCFBF1); // Light teal — card borders

  // TEXT COLORS — different shades for different levels of importance
  static const Color textPrimary    = Color(0xFF0F172A); // Dark — main text
  static const Color textSecondary  = Color(0xFF546E7A); // Grey — secondary text
  static const Color textHint       = Color(0xFF90A4AE); // Light grey — placeholder text
  static const Color textLight      = Color(0xFFE8F0FE); // Almost white — text on dark backgrounds

  // SEMANTIC COLORS — used to show status/meaning
  static const Color success        = Color(0xFF2E7D32); // Green — completed appointments
  static const Color error          = Color(0xFFC62828); // Red — cancelled appointments, errors
  static const Color warning        = Color(0xFFE65100); // Orange — warnings
  static const Color white          = Color(0xFFFFFFFF); // Pure white
  static const Color divider        = Color(0xFFE0E0E0); // Light grey — divider lines
}