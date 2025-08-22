import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/widget/adaptive_button.dart';
import 'package:vybzzz/common/widget/adaptive_text.dart';
import 'package:vybzzz/common/widget/adaptive_theme_card.dart';
import 'package:vybzzz/common/widget/theme_switch_button.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class CompleteThemeTestScreen extends StatelessWidget {
  const CompleteThemeTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          backgroundColor: themeManager.getCurrentThemeColor(),
          appBar: AppBar(
            title: AdaptiveText(
              'Test Complet des Thèmes',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              useContrastColor: true,
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
                _buildTextComponentsSection(themeManager),
                const SizedBox(height: 24),
                _buildButtonComponentsSection(themeManager),
                const SizedBox(height: 24),
                _buildCardComponentsSection(themeManager),
                const SizedBox(height: 24),
                _buildInteractiveComponentsSection(themeManager),
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
            'Composants Adaptatifs VyBzzZ',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            useThemeGradient: true,
          ),
          const SizedBox(height: 8),
          AdaptiveText(
            'Test complet de tous les nouveaux composants qui s\'adaptent automatiquement au thème',
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

  Widget _buildTextComponentsSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Composants de Texte',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          // Texte normal
          AdaptiveText(
            'Ceci est un texte normal qui s\'adapte au thème',
            fontSize: 16,
          ),
          const SizedBox(height: 8),
          
          // Texte avec couleur d'accent
          AdaptiveText(
            'Ceci est un texte avec la couleur d\'accent du thème',
            fontSize: 16,
            useAccentColor: true,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          
          // Texte secondaire
          AdaptiveText(
            'Ceci est un texte secondaire avec une couleur plus subtile',
            fontSize: 14,
            useSecondaryColor: true,
          ),
          const SizedBox(height: 16),
          
          // Texte avec icône
          AdaptiveTextWithIcon(
            'Texte avec icône',
            icon: Icons.star,
            useAccentColor: true,
          ),
          const SizedBox(height: 8),
          
          // Texte avec gradient
          AdaptiveTextWithGradient(
            'Texte avec gradient du thème',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            useThemeGradient: true,
          ),
          const SizedBox(height: 16),
          
          // Texte animé
          AdaptiveTextWithAnimation(
            'Ce texte apparaît avec une animation',
            fontSize: 16,
            useAccentColor: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonComponentsSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Composants de Boutons',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          // Boutons normaux
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  'Bouton Principal',
                  useAccentColor: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdaptiveButton(
                  'Bouton Secondaire',
                  useSecondaryColor: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Bouton avec gradient
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              'Bouton avec Gradient',
              useGradient: true,
            ),
          ),
          const SizedBox(height: 12),
          
          // Bouton avec contour
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              'Bouton avec Contour',
              isOutlined: true,
              useAccentColor: true,
            ),
          ),
          const SizedBox(height: 12),
          
          // Bouton avec icône
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              'Bouton avec Icône',
              icon: Icons.favorite,
              useAccentColor: true,
            ),
          ),
          const SizedBox(height: 16),
          
          // Boutons d'icônes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AdaptiveIconButton(
                Icons.home,
                useAccentColor: true,
                tooltip: 'Accueil',
              ),
              AdaptiveIconButton(
                Icons.search,
                useGradient: true,
                tooltip: 'Rechercher',
              ),
              AdaptiveIconButton(
                Icons.settings,
                isOutlined: true,
                useAccentColor: true,
                tooltip: 'Paramètres',
              ),
              AdaptiveIconButton(
                Icons.favorite,
                useSecondaryColor: true,
                tooltip: 'Favoris',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardComponentsSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Composants de Cartes',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          // Carte simple
          AdaptiveThemeCard(
            child: AdaptiveText(
              'Carte simple avec contenu',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          
          // Carte avec gradient
          AdaptiveThemeCard(
            useGradient: true,
            child: AdaptiveText(
              'Carte avec gradient du thème',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Carte avec animation
          AdaptiveThemeCardWithAnimation(
            child: AdaptiveText(
              'Carte avec animation d\'apparition',
              fontSize: 16,
              useAccentColor: true,
            ),
          ),
          const SizedBox(height: 16),
          
          // Liste de cartes
          AdaptiveThemeCardList(
            children: [
              AdaptiveText('Élément 1 de la liste'),
              AdaptiveText('Élément 2 de la liste'),
              AdaptiveText('Élément 3 de la liste'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveComponentsSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Composants Interactifs',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useContrastColor: true,
          ),
          const SizedBox(height: 16),
          
          // Contrôles de thème
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
          
          // Basculement automatique
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              'Basculer vers ${themeManager.isDarkMode ? 'Clair' : 'Sombre'}',
              onPressed: () => themeManager.toggleTheme(),
              useContrastColor: true,
            ),
          ),
          const SizedBox(height: 16),
          
          // Switch de thème
          Row(
            children: [
              AdaptiveText(
                'Mode Sombre',
                fontSize: 16,
                useContrastColor: true,
              ),
              const Spacer(),
              Switch(
                value: themeManager.isDarkMode,
                onChanged: (value) => themeManager.setTheme(value),
                activeColor: themeManager.getCurrentThemeAccent(),
              ),
            ],
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
            'Informations sur le Thème',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          _buildThemeInfoRow('Mode Actuel', 
            themeManager.isDarkMode ? 'Sombre' : 'Clair', 
            themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          _buildThemeInfoRow('Couleur d\'Accent', 
            themeManager.isDarkMode ? 'Rouge Netflix' : 'Orange Doré', 
            Icons.color_lens),
          _buildThemeInfoRow('Fond Principal', 
            themeManager.isDarkMode ? 'Noir Pur' : 'Blanc Cassé', 
            Icons.format_color_fill),
          _buildThemeInfoRow('Gradient', 
            themeManager.isDarkMode ? 'Rouge Netflix' : 'Or et Orange', 
            Icons.gradient),
          _buildThemeInfoRow('Animation', 
            'Activée', 
            Icons.animation),
          _buildThemeInfoRow('Performance', 
            'Optimisée', 
            Icons.speed),
        ],
      ),
    );
  }

  Widget _buildThemeInfoRow(String label, String value, IconData icon) {
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
