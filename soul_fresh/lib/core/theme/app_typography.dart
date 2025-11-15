import 'package:flutter/material.dart';

class AppTypography {
  // ==========================================
  // FONT FAMILIES
  // ==========================================

  static const String primaryFont = 'Poppins'; // Modern, friendly
  static const String secondaryFont = 'OpenSans'; // Clean, readable

  // ==========================================
  // TEXT STYLES
  // ==========================================

  // Headlines
  static const TextStyle h1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body text
  static const TextStyle body1 = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.3,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
