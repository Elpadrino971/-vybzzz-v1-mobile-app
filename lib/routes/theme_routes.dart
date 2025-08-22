import 'package:get/get.dart';
import 'package:vybzzz/screen/theme_demo_screen.dart';
import 'package:vybzzz/screen/home_with_themes_screen.dart';
import 'package:vybzzz/screen/complete_theme_test_screen.dart';
import 'package:vybzzz/screen/advanced_theme_settings_screen.dart';
import 'package:vybzzz/screen/theme_navigation_screen.dart';

class ThemeRoutes {
  static const String themeDemo = '/theme-demo';
  static const String homeWithThemes = '/home-themes';
  static const String completeTest = '/complete-test';
  static const String advancedSettings = '/advanced-settings';
  static const String themeNavigation = '/theme-navigation';

  static List<GetPage> getPages() {
    return [
      GetPage(
        name: themeDemo,
        page: () => const ThemeDemoScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: homeWithThemes,
        page: () => const HomeWithThemesScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: completeTest,
        page: () => const CompleteThemeTestScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: advancedSettings,
        page: () => const AdvancedThemeSettingsScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: themeNavigation,
        page: () => const ThemeNavigationScreen(),
        transition: Transition.fadeIn,
      ),
    ];
  }

  // Méthodes de navigation
  static void toThemeDemo() => Get.toNamed(themeDemo);
  static void toHomeWithThemes() => Get.toNamed(homeWithThemes);
  static void toCompleteTest() => Get.toNamed(completeTest);
  static void toAdvancedSettings() => Get.toNamed(advancedSettings);
  static void toThemeNavigation() => Get.toNamed(themeNavigation);
}
