import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/widget/adaptive_theme_card.dart';
import 'package:vybzzz/common/widget/theme_switch_button.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class HomeWithThemesScreen extends StatelessWidget {
  const HomeWithThemesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          backgroundColor: themeManager.getCurrentThemeColor(),
          appBar: AppBar(
            title: Text(
              'VyBzzZ - Accueil',
              style: TextStyle(
                color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.bgLightGrey,
            elevation: 0,
            actions: [
              ThemeSwitchButton(
                size: 40,
                showLabel: false,
                onThemeChanged: () {
                  // Optionnel : action après changement de thème
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
                _buildWelcomeSection(themeManager),
                const SizedBox(height: 24),
                _buildFeaturesGrid(themeManager),
                const SizedBox(height: 24),
                _buildThemeInfoSection(themeManager),
                const SizedBox(height: 24),
                _buildInteractiveDemo(themeManager),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Naviguer vers l'écran de démonstration
              Get.to(() => const ThemeDemoScreen());
            },
            backgroundColor: themeManager.getCurrentThemeAccent(),
            foregroundColor: ColorRes.whitePure,
            icon: const Icon(Icons.palette),
            label: const Text('Démo Thèmes'),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue sur VyBzzZ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorRes.whitePure,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Découvrez nos nouveaux thèmes élégants',
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorRes.whitePure.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ThemeSwitchButtonWithAnimation(
                size: 60,
                showLabel: true,
                lightLabel: 'Clair',
                darkLabel: 'Sombre',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColorRes.whitePure.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              themeManager.isDarkMode 
                ? '🌙 Thème Sombre : Noir et Rouge Netflix'
                : '🌞 Thème Clair : Blanc et Doré',
              style: const TextStyle(
                color: ColorRes.whitePure,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(ThemeManager themeManager) {
    final features = [
      {
        'icon': Icons.post_add,
        'title': 'Posts',
        'description': 'Partagez vos moments',
        'color': themeManager.getCurrentThemeAccent(),
      },
      {
        'icon': Icons.video_library,
        'title': 'Shorts',
        'description': 'Vidéos courtes tendance',
        'color': themeManager.getCurrentThemeAccent(),
      },
      {
        'icon': Icons.music_note,
        'title': 'Musique',
        'description': 'Découvrez de nouveaux sons',
        'color': themeManager.getCurrentThemeAccent(),
      },
      {
        'icon': Icons.live_tv,
        'title': 'Live',
        'description': 'Diffusions en direct',
        'color': themeManager.getCurrentThemeAccent(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonctionnalités',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return AdaptiveThemeCardWithAnimation(
              useShadow: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 48,
                    color: feature['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['title'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeManager.isDarkMode ? ColorRes.textLightGrey : ColorRes.textDarkGrey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeInfoSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations sur le Thème',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
            ),
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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Get.find<ThemeManager>().isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Get.find<ThemeManager>().getCurrentThemeAccent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveDemo(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Démonstration Interactive',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorRes.whitePure,
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
                      ? ColorRes.whitePure 
                      : ColorRes.whitePure.withOpacity(0.2),
                    foregroundColor: !themeManager.isDarkMode 
                      ? themeManager.getCurrentThemeAccent() 
                      : ColorRes.whitePure,
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
                      ? ColorRes.whitePure 
                      : ColorRes.whitePure.withOpacity(0.2),
                    foregroundColor: themeManager.isDarkMode 
                      ? themeManager.getCurrentThemeAccent() 
                      : ColorRes.whitePure,
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
            child: ElevatedButton(
              onPressed: () => themeManager.toggleTheme(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorRes.whitePure,
                foregroundColor: themeManager.getCurrentThemeAccent(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Basculer vers ${themeManager.isDarkMode ? 'Clair' : 'Sombre'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
