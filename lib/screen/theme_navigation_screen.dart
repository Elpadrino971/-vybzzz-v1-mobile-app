import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/widget/adaptive_button.dart';
import 'package:vybzzz/common/widget/adaptive_text.dart';
import 'package:vybzzz/common/widget/adaptive_theme_card.dart';
import 'package:vybzzz/common/widget/theme_switch_button.dart';
import 'package:vybzzz/routes/theme_routes.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class ThemeNavigationScreen extends StatelessWidget {
  const ThemeNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          backgroundColor: themeManager.getCurrentThemeColor(),
          appBar: AppBar(
            title: AdaptiveTextWithGradient(
              'Navigation des Thèmes VyBzzZ',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              useThemeGradient: true,
            ),
            backgroundColor: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.bgLightGrey,
            elevation: 0,
            actions: [
              ThemeSwitchButton(
                size: 40,
                showLabel: false,
                onThemeChanged: () {
                  Get.snackbar(
                    'Thème Changé',
                    themeManager.isDarkMode ? 'Mode Sombre activé' : 'Mode Clair activé',
                    backgroundColor: themeManager.getCurrentThemeAccent(),
                    colorText: ColorRes.whitePure,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(themeManager),
                const SizedBox(height: 24),
                _buildNavigationSection(),
                const SizedBox(height: 24),
                _buildQuickActionsSection(themeManager),
                const SizedBox(height: 24),
                _buildThemeInfoSection(themeManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveTextWithGradient(
            'Bienvenue dans le Système de Thèmes VyBzzZ',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            useThemeGradient: true,
          ),
          const SizedBox(height: 8),
          AdaptiveText(
            'Naviguez vers les différents écrans pour tester tous les composants adaptatifs',
            fontSize: 16,
            useSecondaryColor: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorRes.whitePure.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AdaptiveText(
                    themeManager.isDarkMode 
                      ? '🌙 Thème Sombre : Noir et Rouge Netflix'
                      : '🌞 Thème Clair : Blanc et Doré',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ThemeSwitchButtonWithAnimation(
                size: 60,
                showLabel: true,
                lightLabel: 'Clair',
                darkLabel: 'Sombre',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection() {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Navigation vers les Écrans de Test',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          // Écran de démonstration
          _buildNavigationCard(
            '🎨 Démonstration des Thèmes',
            'Testez les deux thèmes avec des exemples visuels',
            Icons.palette,
            () => ThemeRoutes.toThemeDemo(),
          ),
          
          const SizedBox(height: 12),
          
          // Écran d'accueil avec thèmes
          _buildNavigationCard(
            '🏠 Accueil avec Thèmes',
            'Interface complète utilisant tous les composants adaptatifs',
            Icons.home,
            () => ThemeRoutes.toHomeWithThemes(),
          ),
          
          const SizedBox(height: 12),
          
          // Écran de test complet
          _buildNavigationCard(
            '🧪 Test Complet des Composants',
            'Validation de tous les composants et fonctionnalités',
            Icons.science,
            () => ThemeRoutes.toCompleteTest(),
          ),
          
          const SizedBox(height: 12),
          
          // Écran de paramètres avancés
          _buildNavigationCard(
            '⚙️ Paramètres Avancés',
            'Configuration complète et gestion des préférences',
            Icons.settings,
            () => ThemeRoutes.toAdvancedSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(String title, String description, IconData icon, VoidCallback onTap) {
    return AdaptiveThemeCard(
      useShadow: true,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: Get.find<ThemeManager>().getCurrentThemeGradient(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ColorRes.whitePure,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                AdaptiveText(
                  description,
                  fontSize: 14,
                  useSecondaryColor: true,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Get.find<ThemeManager>().getCurrentThemeAccent(),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Actions Rapides',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useContrastColor: true,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  '🌞 Thème Clair',
                  onPressed: () => themeManager.setTheme(false),
                  useContrastColor: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdaptiveButton(
                  '🌙 Thème Sombre',
                  onPressed: () => themeManager.setTheme(true),
                  useContrastColor: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              'Basculer vers ${themeManager.isDarkMode ? 'Clair' : 'Sombre'}',
              onPressed: () => themeManager.toggleTheme(),
              useContrastColor: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeInfoSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Informations sur le Système',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Mode Actuel', 
            themeManager.isDarkMode ? 'Sombre' : 'Clair', 
            themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          _buildInfoRow('Couleur d\'Accent', 
            themeManager.isDarkMode ? 'Rouge Netflix' : 'Orange Doré', 
            Icons.color_lens),
          _buildInfoRow('Fond Principal', 
            themeManager.isDarkMode ? 'Noir Pur' : 'Blanc Cassé', 
            Icons.format_color_fill),
          _buildInfoRow('Gradient', 
            themeManager.isDarkMode ? 'Rouge Netflix' : 'Or et Orange', 
            Icons.gradient),
          _buildInfoRow('Composants', 
            '25+ composants adaptatifs', 
            Icons.widgets),
          _buildInfoRow('Préférences', 
            'Sauvegarde automatique', 
            Icons.save),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Get.find<ThemeManager>().getCurrentThemeAccent(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AdaptiveText(
              label,
              fontSize: 16,
            ),
          ),
          AdaptiveText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            useAccentColor: true,
          ),
        ],
      ),
    );
  }
}
