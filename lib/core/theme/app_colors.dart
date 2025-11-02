import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // PRIMARY PASTEL COLORS
  // ==========================================

  // Soft pastels for different moods/sections
  static const Color primaryPastel = Color(0xFFC9AED9);      // Lavender
  static const Color secondaryPastel = Color(0xFFB5EAD7);    // Mint
  static const Color accentPastel = Color(0xFFFFC8DD);       // Pink
  static const Color warmPastel = Color(0xFFFFD9B3);         // Peach
  static const Color coolPastel = Color(0xFFA8D8EA);         // Sky

  // ==========================================
  // EXTENDED PASTEL PALETTE
  // ==========================================

  // Emotional state colors (pastels)
  static const Color happyPastel = Color(0xFFFFE5B4);        // Peach
  static const Color calmPastel = Color(0xFFB5EAD7);         // Mint
  static const Color anxiousPastel = Color(0xFFF0A6CA);      // Rose
  static const Color sadPastel = Color(0xFFBBCEFF);          // Periwinkle
  static const Color energyPastel = Color(0xFFFFF9C4);       // Pale Yellow
  static const Color stressPastel = Color(0xFFFFCDDC);       // Light Pink

  // ==========================================
  // NEUTRAL COLORS
  // ==========================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteBg = Color(0xFFFAF9F6);            // Off-white
  static const Color lightGrey = Color(0xFFF5F3F0);
  static const Color mediumGrey = Color(0xFFE8E3DF);
  static const Color darkGrey = Color(0xFF8B8680);
  static const Color charcoal = Color(0xFF4A4A4A);
  static const Color black = Color(0xFF1A1A1A);

  // ==========================================
  // SEMANTIC COLORS
  // ==========================================

  static const Color success = Color(0xFF90EE90);            // Light Green
  static const Color warning = Color(0xFFFFD166);            // Amber
  static const Color error = Color(0xFFFFB6B9);              // Light Red
  static const Color info = Color(0xFF87CEEB);               // Sky Blue

  // ==========================================
  // GRADIENT COLORS
  // ==========================================

  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6D5F0), Color(0xFFC9AED9)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4F7EE), Color(0xFFB5EAD7)],
  );

  static const LinearGradient peacePastelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D5F0), Color(0xFFD4F0E6)],
  );
}