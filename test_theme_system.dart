import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/theme_manager.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_res.dart';

/// Script de test simple pour valider le système de thèmes
/// Ce fichier peut être exécuté pour tester les composants de base

void main() {
  runApp(const ThemeTestApp());
}

class ThemeTestApp extends StatelessWidget {
  const ThemeTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Test Système de Thèmes VyBzzZ',
      themeMode: ThemeMode.system,
      darkTheme: ThemeRes.darkTheme(context),
      theme: ThemeRes.lightTheme(context),
      home: const ThemeTestHome(),
    );
  }
}

class ThemeTestHome extends StatelessWidget {
  const ThemeTestHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialiser le ThemeManager
    Get.put(ThemeManager());
    
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          backgroundColor: themeManager.getCurrentThemeColor(),
          appBar: AppBar(
            title: Text(
              'Test Thèmes VyBzzZ',
              style: TextStyle(
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            backgroundColor: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.bgLightGrey,
            actions: [
              IconButton(
                icon: Icon(
                  themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: themeManager.getCurrentThemeAccent(),
                ),
                onPressed: () => themeManager.toggleTheme(),
                tooltip: 'Basculer le thème',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(themeManager),
                const SizedBox(height: 16),
                _buildThemeInfoCard(themeManager),
                const SizedBox(height: 16),
                _buildColorPaletteCard(themeManager),
                const SizedBox(height: 16),
                _buildTestButtonsCard(themeManager),
                const SizedBox(height: 16),
                _buildNavigationCard(themeManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ThemeManager themeManager) {
    return Card(
      elevation: 4,
      color: themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.whitePure,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: themeManager.getCurrentThemeGradient(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '🎉 Système de Thèmes VyBzzZ',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorRes.whitePure,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Test de validation du système de thèmes',
              style: const TextStyle(
                fontSize: 16,
                color: ColorRes.whitePure,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeInfoCard(ThemeManager themeManager) {
    return Card(
      elevation: 2,
      color: themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Informations du Thème',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.getCurrentThemeAccent(),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Mode Actuel', 
              themeManager.isDarkMode ? '🌙 Sombre' : '🌞 Clair'),
            _buildInfoRow('Couleur d\'Accent', 
              themeManager.isDarkMode ? 'Rouge Netflix' : 'Orange Doré'),
            _buildInfoRow('Fond Principal', 
              themeManager.isDarkMode ? 'Noir Pur' : 'Blanc Cassé'),
            _buildInfoRow('Gradient', 
              themeManager.isDarkMode ? 'Rouge Netflix' : 'Or et Orange'),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPaletteCard(ThemeManager themeManager) {
    return Card(
      elevation: 2,
      color: themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎨 Palette de Couleurs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.getCurrentThemeAccent(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorSwatch('Accent', themeManager.getCurrentThemeAccent()),
                _buildColorSwatch('Gradient 1', themeManager.getCurrentThemeGradient().colors[0]),
                _buildColorSwatch('Gradient 2', themeManager.getCurrentThemeGradient().colors[1]),
                _buildColorSwatch('Fond', themeManager.getCurrentThemeColor()),
                _buildColorSwatch('Texte', themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtonsCard(ThemeManager themeManager) {
    return Card(
      elevation: 2,
      color: themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔘 Boutons de Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.getCurrentThemeAccent(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => themeManager.setTheme(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeManager.getCurrentThemeAccent(),
                      foregroundColor: ColorRes.whitePure,
                    ),
                    child: const Text('🌞 Thème Clair'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => themeManager.setTheme(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeManager.getCurrentThemeAccent(),
                      foregroundColor: ColorRes.whitePure,
                    ),
                    child: const Text('🌙 Thème Sombre'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => themeManager.toggleTheme(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeManager.getCurrentThemeAccent(),
                  foregroundColor: ColorRes.whitePure,
                ),
                child: Text('Basculer vers ${themeManager.isDarkMode ? 'Clair' : 'Sombre'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(ThemeManager themeManager) {
    return Card(
      elevation: 2,
      color: themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧭 Navigation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.getCurrentThemeAccent(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ceci est un test de base du système de thèmes.',
              style: TextStyle(
                fontSize: 16,
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour tester tous les composants, lancez l\'application principale et naviguez vers l\'écran de navigation des thèmes.',
              style: TextStyle(
                fontSize: 14,
                color: themeManager.isDarkMode ? ColorRes.textLightGrey : ColorRes.textDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
