import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppBorderRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xlarge = 20;
  static const double xxlarge = 24;
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color.fromARGB(8, 0, 0, 0),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color.fromARGB(12, 0, 0, 0),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow elevated = BoxShadow(
    color: Color.fromARGB(16, 0, 0, 0),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}
