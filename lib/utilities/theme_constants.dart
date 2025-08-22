import 'package:flutter/material.dart';

class ThemeConstants {
  // Couleurs du thème clair
  static const Color lightPrimary = Color(0xFFFFD700);      // Or vif
  static const Color lightSecondary = Color(0xFFFFA500);    // Orange doré
  static const Color lightAccent = Color(0xFFFF8C00);       // Orange foncé
  static const Color lightBackground = Color(0xFFF5F5F5);   // Blanc cassé
  static const Color lightSurface = Color(0xFFFFFFFF);      // Blanc pur
  static const Color lightText = Color(0xFF000000);         // Noir
  static const Color lightTextSecondary = Color(0xFF454545); // Gris foncé
  static const Color lightBorder = Color(0xFFF0F0F0);       // Gris clair

  // Couleurs du thème sombre
  static const Color darkPrimary = Color(0xFFE50914);       // Rouge Netflix
  static const Color darkSecondary = Color(0xFFB81D24);     // Rouge foncé
  static const Color darkAccent = Color(0xFFE50914);        // Rouge Netflix
  static const Color darkBackground = Color(0xFF000000);    // Noir pur
  static const Color darkSurface = Color(0xFF1A1A1A);      // Noir cassé
  static const Color darkText = Color(0xFFFFFFFF);          // Blanc
  static const Color darkTextSecondary = Color(0xFF8B8B8B); // Gris clair
  static const Color darkBorder = Color(0xFF333333);        // Gris foncé

  // Couleurs communes
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);           // Vert
  static const Color warning = Color(0xFFFFC107);           // Jaune
  static const Color error = Color(0xFFE50914);             // Rouge Netflix
  static const Color info = Color(0xFF2196F3);              // Bleu

  // Gradients prédéfinis
  static const List<Color> lightGradient = [lightPrimary, lightSecondary];
  static const List<Color> darkGradient = [darkPrimary, darkSecondary];
  static const List<Color> successGradient = [success, Color(0xFF45A049)];
  static const List<Color> warningGradient = [warning, Color(0xFFFF9800)];
  static const List<Color> errorGradient = [error, Color(0xFFB81D24)];

  // Ombres
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkShadow = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Rayons de bordure
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Espacements
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Tailles d'icônes
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;

  // Durées d'animation
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Courbes d'animation
  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveFast = Curves.easeOut;
  static const Curve animationCurveSlow = Curves.easeInOutCubic;

  // Opacités
  static const double opacityLow = 0.1;
  static const double opacityMedium = 0.5;
  static const double opacityHigh = 0.8;
  static const double opacityFull = 1.0;

  // Méthodes utilitaires
  static Color getPrimaryColor(bool isDark) => isDark ? darkPrimary : lightPrimary;
  static Color getSecondaryColor(bool isDark) => isDark ? darkSecondary : lightSecondary;
  static Color getAccentColor(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color getBackgroundColor(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color getSurfaceColor(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getTextColor(bool isDark) => isDark ? darkText : lightText;
  static Color getTextSecondaryColor(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getBorderColor(bool isDark) => isDark ? darkBorder : lightBorder;

  static List<Color> getGradient(bool isDark) => isDark ? darkGradient : lightGradient;
  static List<BoxShadow> getShadow(bool isDark) => isDark ? darkShadow : lightShadow;

  // Méthodes de contraste
  static Color getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? black : white;
  }

  static bool isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }

  // Méthodes de couleur adaptative
  static Color adaptiveColor({
    required Color lightColor,
    required Color darkColor,
    required bool isDark,
  }) {
    return isDark ? darkColor : lightColor;
  }

  static Color adaptiveColorWithOpacity({
    required Color lightColor,
    required Color darkColor,
    required bool isDark,
    required double opacity,
  }) {
    final color = isDark ? darkColor : lightColor;
    return color.withOpacity(opacity);
  }
}
