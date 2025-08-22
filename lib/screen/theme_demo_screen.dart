import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/style_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Démonstration des Thèmes',
              style: TextStyle(
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            backgroundColor: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.bgLightGrey,
            actions: [
              IconButton(
                icon: Icon(
                  themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
                ),
                onPressed: () => themeManager.toggleTheme(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThemeInfo(themeManager),
                const SizedBox(height: 24),
                _buildColorPalette(themeManager),
                const SizedBox(height: 24),
                _buildGradientExamples(themeManager),
                const SizedBox(height: 24),
                _buildInteractiveElements(themeManager),
                const SizedBox(height: 24),
                _buildThemeToggle(themeManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeInfo(ThemeManager themeManager) {
    return Card(
      color: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thème Actuel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: themeManager.getCurrentThemeGradient(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                themeManager.isDarkMode ? '🌙 Thème Sombre' : '🌞 Thème Clair',
                style: const TextStyle(
                  color: ColorRes.whitePure,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              themeManager.isDarkMode 
                ? 'Style Netflix : Noir et Rouge'
                : 'Style Élégant : Blanc et Doré',
              style: TextStyle(
                fontSize: 16,
                color: themeManager.isDarkMode ? ColorRes.textLightGrey : ColorRes.textDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette(ThemeManager themeManager) {
    return Card(
      color: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Palette de Couleurs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorSwatch('Gradient 1', themeManager.isDarkMode ? ColorRes.themeGradient1Dark : ColorRes.themeGradient1),
                _buildColorSwatch('Gradient 2', themeManager.isDarkMode ? ColorRes.themeGradient2Dark : ColorRes.themeGradient2),
                _buildColorSwatch('Accent', themeManager.getCurrentThemeAccent()),
                _buildColorSwatch('Fond', themeManager.getCurrentThemeColor()),
                _buildColorSwatch('Texte', themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
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

  Widget _buildGradientExamples(ThemeManager themeManager) {
    return Card(
      color: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exemples de Gradients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: themeManager.getCurrentThemeGradient(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Gradient Principal',
                  style: const TextStyle(
                    color: ColorRes.whitePure,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: StyleRes.themeGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Gradient Clair (Doré)',
                  style: const TextStyle(
                    color: ColorRes.whitePure,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: StyleRes.themeGradientDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Gradient Sombre (Rouge Netflix)',
                  style: const TextStyle(
                    color: ColorRes.whitePure,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveElements(ThemeManager themeManager) {
    return Card(
      color: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Éléments Interactifs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: themeManager.getCurrentThemeAccent(),
                foregroundColor: ColorRes.whitePure,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Bouton Principal'),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                gradient: themeManager.getCurrentThemeGradient(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: ColorRes.whitePure,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Bouton Gradient'),
              ),
            ),
            const SizedBox(height: 12),
            Switch(
              value: themeManager.isDarkMode,
              onChanged: (value) => themeManager.setTheme(value),
              activeColor: themeManager.getCurrentThemeAccent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeManager themeManager) {
    return Card(
      color: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contrôle du Thème',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => themeManager.setTheme(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !themeManager.isDarkMode 
                        ? themeManager.getCurrentThemeAccent() 
                        : Colors.grey.shade300,
                      foregroundColor: !themeManager.isDarkMode 
                        ? ColorRes.whitePure 
                        : ColorRes.blackPure,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('🌞 Thème Clair'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => themeManager.setTheme(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeManager.isDarkMode 
                        ? themeManager.getCurrentThemeAccent() 
                        : Colors.grey.shade300,
                      foregroundColor: themeManager.isDarkMode 
                        ? ColorRes.whitePure 
                        : ColorRes.blackPure,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('🌙 Thème Sombre'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: themeManager.getCurrentThemeGradient(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => themeManager.toggleTheme(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: ColorRes.whitePure,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Basculer vers ${themeManager.isDarkMode ? 'Clair' : 'Sombre'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
