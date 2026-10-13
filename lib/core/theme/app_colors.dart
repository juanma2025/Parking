import 'package:flutter/material.dart';

class AppColors {
  // Brand & Warm Stitch Palette
  static const Color primary = Color(0xFFFBAB56); // Accent / Bottom Bar
  static const Color secondary = Color(0xFFFEC775); // Amber Card
  static const Color lightBackground = Color(0xFFFFF2E2); // Warm Cream
  static const Color darkCard = Color(0xFF222222); // Charcoal / Dark Card
  static const Color white = Color(0xFFFFFFFF);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF222222);
  static const Color darkSurface = Color(0xFF2E2E2E);
  static const Color darkText = Color(0xFFFFF2E2);
  static const Color darkSecondaryText = Color(0xFFA3A3A3);
  static const Color darkAccent = Color(0xFFFEC775);

  // Feedback Colors (messages / badges only)
  static const Color error = Color(0xFFE5604D);
  static const Color success = Color(0xFF5FBF7A);

  // Parking Space Status Colors
  static const Color spaceAvailable = Color(0xFFFEC775);
  static const Color spaceOccupied = Color(0xFF3A3A3A);
  static const Color spaceMaintenance = Color(0xFFE08244);
  static const Color spaceInactive = Color(0xFF757575);

  // Neutral text & border colors
  static const Color textPrimaryLight = Color(0xFF222222);
  static const Color textSecondaryLight = Color(0xFF756F68);
  static const Color borderLight = Color(0xFFEEDDCC);
}

class AppDimensions {
  static const double radiusCard = 28.0;
  static const double radiusField = 20.0;
  static const double radiusPill = 50.0;
  static const double radiusChip = 14.0;

  static const double buttonHeight = 54.0; // 52-56 high
  static const double screenMargin = 20.0;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;
}
