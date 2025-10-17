import 'package:flutter/material.dart';

/// Defines the brand colors for Henkel's Gliss Mirror app.
/// These colors are approved by Henkel's brand guidelines.
class AppColors {
  // Primary Brand Colors
  static const henkelRed = Color(0xFFE1000F);
  static const deepViolet = Color(0xFF871984);
  static const freshBlue = Color(0xFF318096);
  static const warmGrey = Color(0xFFDED7D6);
  static const pureWhite = Color(0xFFFFFFFF);
  static const darkBlue = Color(0xFF28325A);
  static const softBlue = Color(0xFFBBD0DA);

  // Semantic Colors
  static const error = henkelRed;
  static const success = Color(0xFF34A853);
  static const warning = Color(0xFFFBAB17);
  static const info = freshBlue;

  // Text Colors Light Theme
  static const textPrimaryLight = darkBlue;
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textTertiaryLight = Color(0xFF9CA3AF);

  // Text Colors Dark Theme
  static const textPrimaryDark = pureWhite;
  static const textSecondaryDark = Color(0xFFE5E7EB);
  static const textTertiaryDark = Color(0xFFD1D5DB);

  // Background Colors Light Theme
  static const backgroundPrimaryLight = pureWhite;
  static const backgroundSecondaryLight = warmGrey;
  static const backgroundTertiaryLight = softBlue;

  // Background Colors Dark Theme
  static const backgroundPrimaryDark = darkBlue;
  static const backgroundSecondaryDark = Color(0xFF1F2937);
  static const backgroundTertiaryDark = Color(0xFF374151);

  // Overlay Colors
  static const overlayLight = Color(0x0A000000);
  static const overlayDark = Color(0x0AFFFFFF);
}
