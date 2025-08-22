import 'package:flutter/material.dart';
import 'package:vybzzz/utilities/color_res.dart';

class GenerateColor {
  GenerateColor._();

  static final GenerateColor instance = GenerateColor._();

  // Add beautiful colors here for font
  List<Color> fontColor = [
    const Color(0xFF000000), // Black
    const Color(0xFF1A1A1A), // Very dark gray
    const Color(0xFF333333), // Dark gray
    const Color(0xFF4F4F4F), // Medium-dark gray
    const Color(0xFF666666), // Medium gray
    const Color(0xFF808080), // Neutral gray
    const Color(0xFFA6A6A6), // Light gray (for subtitles)
    const Color(0xFFFFFFFF), // White (for dark backgrounds)
    const Color(0xFFE50914), // Rouge Netflix
    const Color(0xFFB81D24), // Rouge foncé
    const Color(0xFFFFD700), // Or vif
    const Color(0xFFFFA500), // Orange doré
    const Color(0xFFFF8C00), // Orange foncé
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFC107), // Amber
    const Color(0xFFFFEB3B), // Yellow (use sparingly)
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFB71C1C), // Dark Red
  ];

  // Add beautiful gradient colors here
  static List<List<Color>> storyBgColor = [
    [ColorRes.themeGradient1, ColorRes.themeGradient2], // Theme Color - Doré
    [const Color(0xFFFF5F6D), const Color(0xFFFFC371)], // 1. Sunset Orange
    [const Color(0xFFE50914), const Color(0xFFB81D24)], // 2. Rouge Netflix
    [const Color(0xFFFFD700), const Color(0xFFFFA500)], // 3. Gradient Doré
    [const Color(0xFFF857A6), const Color(0xFFFF5858)], // 4. Neon Night
    [const Color(0xFF00F260), const Color(0xFF0575E6)], // 5. Soft Sky
    [const Color(0xFF89F7FE), const Color(0xFF66A6FF)], // 6. Sunset Glow
    [const Color(0xFFFF9966), const Color(0xFFFF5E62)], // 7. Royal Gold
    [const Color(0xFFFFD200), const Color(0xFFF7971E)], // 8. Indigo Twilight
    [const Color(0xFF654EA3), const Color(0xFFEAafc8)], // 9. Emerald Fade
  ];

  static LinearGradient generateGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  List<LinearGradient> gradientList =
      storyBgColor.map((colors) => generateGradient(colors)).toList();

// final Random _random = Random();

// Set<Color> generateUniqueRandomColors(int count) {
//   final Set<Color> colorSet = {};
//
//   while (colorSet.length < count) {
//     final color = Color.fromARGB(
//       255,
//       _random.nextInt(256),
//       _random.nextInt(256),
//       _random.nextInt(256),
//     );
//     colorSet.add(color); // Set automatically handles duplicates
//   }
//   return colorSet;
// }

  /// Generates a random color
// Color getRandomColor() {
//   return Color.fromARGB(
//     255,
//     _random.nextInt(256),
//     _random.nextInt(256),
//     _random.nextInt(256),
//   );
// }

  /// Generates a random linear gradient
// LinearGradient getRandomGradient() {
//   return LinearGradient(
//     colors: [getRandomColor(), getRandomColor()],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }

  /// Generates a list of random gradients
// List<LinearGradient> generateRandomGradients(int count) {
//   return List.generate(count, (_) => getRandomGradient());
// }
}
