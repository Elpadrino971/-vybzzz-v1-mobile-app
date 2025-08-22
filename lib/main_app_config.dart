import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/theme_manager.dart';
import 'package:vybzzz/utilities/theme_res.dart';

class MainAppConfig {
  static void initializeApp() {
    // Initialiser le gestionnaire de thème
    Get.put(ThemeManager());
    
    // Configuration des routes et thèmes
    Get.config(
      defaultTransition: Transition.fadeIn,
      defaultDurationTransition: const Duration(milliseconds: 300),
    );
  }
  
  static MaterialApp createApp({
    required Widget home,
    required String title,
    List<GetPage>? routes,
    bool enableThemeSwitching = true,
  }) {
    return GetMaterialApp(
      title: title,
      home: home,
      routes: routes?.asMap().map((key, value) => MapEntry(value.name, value)),
      getPages: routes,
      theme: ThemeRes.lightTheme(Get.context!),
      darkTheme: ThemeRes.darkTheme(Get.context!),
      themeMode: enableThemeSwitching ? ThemeMode.system : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, child) {
        // Appliquer le thème personnalisé
        final themeManager = Get.find<ThemeManager>();
        return GetBuilder<ThemeManager>(
          builder: (controller) {
            return child!;
          },
        );
      },
    );
  }
  
  static void showThemeSwitcher() {
    Get.dialog(
      GetBuilder<ThemeManager>(
        builder: (themeManager) {
          return AlertDialog(
            title: Text(
              'Choisir le Thème',
              style: TextStyle(
                color: themeManager.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: themeManager.isDarkMode ? Colors.black : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.light_mode, color: Colors.orange),
                  title: const Text('Thème Clair'),
                  subtitle: const Text('Blanc et Doré'),
                  selected: !themeManager.isDarkMode,
                  onTap: () {
                    themeManager.setTheme(false);
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode, color: Colors.red),
                  title: const Text('Thème Sombre'),
                  subtitle: const Text('Noir et Rouge Netflix'),
                  selected: themeManager.isDarkMode,
                  onTap: () {
                    themeManager.setTheme(true);
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_auto, color: Colors.blue),
                  title: const Text('Thème Système'),
                  subtitle: const Text('Automatique'),
                  onTap: () {
                    themeManager._detectSystemTheme();
                    Get.back();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: themeManager.getCurrentThemeAccent(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
