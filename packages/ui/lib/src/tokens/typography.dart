import 'package:flutter/material.dart';


abstract final class SbType {


  static const overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.2,
  );


  static const tabular = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  );


  static TextTheme textTheme({required Color ink, required Color muted}) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 62,
        height: 0.94,
        fontWeight: FontWeight.w400,
        letterSpacing: -3.2,
        color: ink,
      ),
      displayMedium: TextStyle(
        fontSize: 52,
        height: 0.96,
        fontWeight: FontWeight.w400,
        letterSpacing: -2.6,
        color: ink,
      ),
      displaySmall: TextStyle(
        fontSize: 42,
        height: 1,
        fontWeight: FontWeight.w400,
        letterSpacing: -2,
        color: ink,
      ),
      headlineLarge: TextStyle(
        fontSize: 36,
        height: 1.05,
        fontWeight: FontWeight.w500,
        letterSpacing: -1.6,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.08,
        fontWeight: FontWeight.w500,
        letterSpacing: -1.2,
        color: ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.7,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.35,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.42, color: muted),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: muted),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: ink,
      ),
      labelMedium: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: muted,
      ),
      labelSmall: overline.copyWith(color: muted),
    );
  }
}
