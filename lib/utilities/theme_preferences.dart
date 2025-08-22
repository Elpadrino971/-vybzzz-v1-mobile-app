import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _themeKey = 'theme_mode';
  static const String _autoThemeKey = 'auto_theme_enabled';
  static const String _lastThemeKey = 'last_theme';
  
  // Valeurs possibles pour le thème
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';
  static const String _systemTheme = 'system';

  /// Sauvegarder le mode de thème
  static Future<bool> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_themeKey, themeMode);
  }

  /// Récupérer le mode de thème sauvegardé
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? _systemTheme;
  }

  /// Sauvegarder l'état d'activation du thème automatique
  static Future<bool> setAutoThemeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_autoThemeKey, enabled);
  }

  /// Récupérer l'état d'activation du thème automatique
  static Future<bool> getAutoThemeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoThemeKey) ?? true;
  }

  /// Sauvegarder le dernier thème choisi manuellement
  static Future<bool> setLastTheme(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_lastThemeKey, themeMode);
  }

  /// Récupérer le dernier thème choisi manuellement
  static Future<String> getLastTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastThemeKey) ?? _lightTheme;
  }

  /// Convertir le mode de thème en booléen
  static bool isDarkMode(String themeMode) {
    switch (themeMode) {
      case _darkTheme:
        return true;
      case _lightTheme:
        return false;
      case _systemTheme:
      default:
        return false; // Par défaut, thème clair
    }
  }

  /// Convertir le mode de thème en string lisible
  static String getThemeModeDisplayName(String themeMode) {
    switch (themeMode) {
      case _darkTheme:
        return 'Sombre';
      case _lightTheme:
        return 'Clair';
      case _systemTheme:
        return 'Système';
      default:
        return 'Système';
    }
  }

  /// Obtenir l'icône correspondant au mode de thème
  static String getThemeModeIcon(String themeMode) {
    switch (themeMode) {
      case _darkTheme:
        return '🌙';
      case _lightTheme:
        return '🌞';
      case _systemTheme:
        return '⚙️';
      default:
        return '⚙️';
    }
  }

  /// Vérifier si le thème est en mode système
  static bool isSystemTheme(String themeMode) {
    return themeMode == _systemTheme;
  }

  /// Vérifier si le thème est en mode manuel
  static bool isManualTheme(String themeMode) {
    return themeMode == _lightTheme || themeMode == _darkTheme;
  }

  /// Obtenir tous les modes de thème disponibles
  static List<Map<String, dynamic>> getAvailableThemeModes() {
    return [
      {
        'value': _lightTheme,
        'displayName': 'Clair',
        'icon': '🌞',
        'description': 'Thème clair avec couleurs dorées',
      },
      {
        'value': _darkTheme,
        'displayName': 'Sombre',
        'icon': '🌙',
        'description': 'Thème sombre avec couleurs rouges Netflix',
      },
      {
        'value': _systemTheme,
        'displayName': 'Système',
        'icon': '⚙️',
        'description': 'Suivre automatiquement le thème du système',
      },
    ];
  }

  /// Réinitialiser toutes les préférences de thème
  static Future<bool> resetThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_autoThemeKey);
    await prefs.remove(_lastThemeKey);
    return true;
  }

  /// Exporter les préférences de thème
  static Future<Map<String, dynamic>> exportThemePreferences() async {
    return {
      'themeMode': await getThemeMode(),
      'autoThemeEnabled': await getAutoThemeEnabled(),
      'lastTheme': await getLastTheme(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Importer les préférences de thème
  static Future<bool> importThemePreferences(Map<String, dynamic> data) async {
    try {
      if (data['themeMode'] != null) {
        await setThemeMode(data['themeMode']);
      }
      if (data['autoThemeEnabled'] != null) {
        await setAutoThemeEnabled(data['autoThemeEnabled']);
      }
      if (data['lastTheme'] != null) {
        await setLastTheme(data['lastTheme']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
