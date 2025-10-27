import 'package:flutter/material.dart';

/// Thème VyBzzZ - Couleurs et constantes de style
class VyBzzZTheme {
  // Couleurs principales VyBzzZ (Or et Orange)
  static const Color primary = Color(0xFFFFD700); // Or
  static const Color secondary = Color(0xFFFF8C00); // Orange

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backgrounds
  static const Color background = Color(0xFF000000); // Noir
  static const Color cardBackground = Color(0xFF1A1A1A); // Gris très foncé

  // Texte
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanc
  static const Color textSecondary = Color(0xFF8B8B8B); // Gris
  static const Color textDisabled = Color(0xFF454545); // Gris foncé

  // Status colors
  static const Color success = Color(0xFF34D948); // Vert
  static const Color error = Color(0xFFE50914); // Rouge
  static const Color warning = Color(0xFFFFA500); // Orange
  static const Color info = Color(0xFF3E8BFF); // Bleu

  // Live streaming colors
  static const Color liveRed = Color(0xFFE50914); // Rouge "EN DIRECT"
  static const Color likeRed = Color(0xFFFF0000); // Rouge coeur

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Shadow
  static BoxShadow get primaryShadow => BoxShadow(
    color: primary.withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(0, 10),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 10,
    offset: const Offset(0, 5),
  );
}
