import 'dart:ui' as ui show Gradient;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_res.dart';

class StyleRes {
  // THÈME CLAIR : Gradient doré
  static LinearGradient themeGradient = const LinearGradient(
    colors: [ColorRes.themeGradient1, ColorRes.themeGradient2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // THÈME SOMBRE : Gradient rouge Netflix
  static LinearGradient themeGradientDark = const LinearGradient(
    colors: [ColorRes.themeGradient1Dark, ColorRes.themeGradient2Dark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradient pour le mode sombre
  static LinearGradient getThemeGradient(bool isDarkMode) {
    return isDarkMode ? themeGradientDark : themeGradient;
  }

  static LinearGradient textDarkGreyGradient({double opacity = 1}) => LinearGradient(
        colors: [
          textDarkGrey(Get.context!).withValues(alpha: opacity),
          textDarkGrey(Get.context!).withValues(alpha: opacity)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient disabledGreyGradient({double opacity = 1}) => LinearGradient(
        colors: [
          ColorRes.disabledGrey.withValues(alpha: opacity),
          ColorRes.disabledGrey.withValues(alpha: opacity)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient textLightGreyGradient({double opacity = 1}) => LinearGradient(
        colors: [
          textLightGrey(Get.context!).withValues(alpha: opacity),
          textLightGrey(Get.context!).withValues(alpha: opacity)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // Gradient des vagues adaptatif
  static Shader wavesGradient(bool isDarkMode) {
    return ui.Gradient.linear(
      const Offset(70, 50),
      Offset(Get.width / 2, 0),
      isDarkMode 
        ? [ColorRes.themeGradient1Dark, ColorRes.themeGradient2Dark]
        : [ColorRes.themeGradient1, ColorRes.themeGradient2],
    );
  }
}
