import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/style_res.dart';
import 'package:vybzzz/utilities/theme_res.dart';

class ThemeManager extends GetxController {
  static ThemeManager get instance => Get.find();
  
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  @override
  void onInit() {
    super.onInit();
    // Détecter automatiquement le thème système
    detectSystemTheme();
  }
  
  void detectSystemTheme() {
    final brightness = Get.mediaQuery.platformBrightness;
    _isDarkMode.value = brightness == Brightness.dark;
  }
  
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(_isDarkMode.value ? ThemeRes.darkTheme(Get.context!) : ThemeRes.lightTheme(Get.context!));
  }
  
  void setTheme(bool isDark) {
    _isDarkMode.value = isDark;
    Get.changeTheme(_isDarkMode.value ? ThemeRes.darkTheme(Get.context!) : ThemeRes.lightTheme(Get.context!));
  }
  
  // Obtenir le gradient approprié selon le thème
  LinearGradient getCurrentThemeGradient() {
    return StyleRes.getThemeGradient(_isDarkMode.value);
  }
  
  // Obtenir la couleur d'accent appropriée selon le thème
  Color getCurrentThemeAccent() {
    return _isDarkMode.value ? ColorRes.themeAccentSolidDark : ColorRes.themeAccentSolid;
  }
  
  // Obtenir la couleur de thème appropriée selon le thème
  Color getCurrentThemeColor() {
    return _isDarkMode.value ? ColorRes.themeColorDark : ColorRes.themeColor;
  }
  
  // Obtenir le gradient des vagues approprié selon le thème
  Shader getCurrentWavesGradient() {
    return StyleRes.wavesGradient(_isDarkMode.value);
  }
  
  // Obtenir le thème actuel
  ThemeData getCurrentTheme() {
    return _isDarkMode.value ? ThemeRes.darkTheme(Get.context!) : ThemeRes.lightTheme(Get.context!);
  }
}
