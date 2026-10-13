import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Poppins';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Helper text themes
  static TextTheme textTheme(Color textColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: display.copyWith(color: textColor),
      displayMedium: display.copyWith(fontSize: 28, color: textColor),
      headlineMedium: title.copyWith(color: textColor),
      titleLarge: title.copyWith(fontSize: 20, color: textColor),
      titleMedium: bodyBold.copyWith(fontSize: 16, color: textColor),
      bodyLarge: body.copyWith(fontSize: 16, color: textColor),
      bodyMedium: body.copyWith(color: textColor),
      bodySmall: caption.copyWith(color: secondaryColor),
      labelSmall: sectionLabel.copyWith(color: secondaryColor),
      labelLarge: button.copyWith(color: textColor),
    );
  }
}
