import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/widget/adaptive_button.dart';
import 'package:vybzzz/common/widget/adaptive_text.dart';
import 'package:vybzzz/common/widget/adaptive_theme_card.dart';
import 'package:vybzzz/common/widget/advanced_theme_selector.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';
import 'package:vybzzz/utilities/theme_preferences.dart';

class AdvancedThemeSettingsScreen extends StatefulWidget {
  const AdvancedThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedThemeSettingsScreen> createState() => _AdvancedThemeSettingsScreenState();
}

class _AdvancedThemeSettingsScreenState extends State<AdvancedThemeSettingsScreen> {
  bool _autoThemeEnabled = true;
  bool _showAnimations = true;
  bool _showShadows = true;
  bool _useGradients = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final autoTheme = await ThemePreferences.getAutoThemeEnabled();
      setState(() {
        _autoThemeEnabled = autoTheme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAutoTheme(bool value) async {
    try {
      await ThemePreferences.setAutoThemeEnabled(value);
      setState(() {
        _autoThemeEnabled = value;
      });
      
      Get.snackbar(
        'Paramètre Mis à Jour',
        'Thème automatique ${value ? 'activé' : 'désactivé'}',
        backgroundColor: Get.find<ThemeManager>().getCurrentThemeAccent(),
        colorText: ColorRes.whitePure,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le paramètre',
        backgroundColor: Colors.red,
        colorText: ColorRes.whitePure,
      );
    }
  }

  Future<void> _resetAllSettings() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Réinitialiser les Paramètres'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser tous les paramètres de thème ? '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: ColorRes.whitePure,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ThemePreferences.resetThemePreferences();
        await _loadSettings();
        
        Get.snackbar(
          'Paramètres Réinitialisés',
          'Tous les paramètres ont été remis à zéro',
          backgroundColor: Get.find<ThemeManager>().getCurrentThemeAccent(),
          colorText: ColorRes.whitePure,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de réinitialiser les paramètres',
          backgroundColor: Colors.red,
          colorText: ColorRes.whitePure,
        );
      }
    }
  }

  Future<void> _exportSettings() async {
    try {
      final settings = await ThemePreferences.exportThemePreferences();
      
      Get.snackbar(
        'Paramètres Exportés',
        'Vos préférences ont été exportées avec succès',
        backgroundColor: Get.find<ThemeManager>().getCurrentThemeAccent(),
        colorText: ColorRes.whitePure,
        duration: const Duration(seconds: 2),
      );
      
      // Ici vous pourriez implémenter la logique d'export
      print('Paramètres exportés: $settings');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les paramètres',
        backgroundColor: Colors.red,
        colorText: ColorRes.whitePure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          backgroundColor: themeManager.getCurrentThemeColor(),
          appBar: AppBar(
            title: AdaptiveText(
              'Paramètres de Thème',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              useContrastColor: true,
            ),
            backgroundColor: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.bgLightGrey,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: _showHelpDialog,
                tooltip: 'Aide',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentThemeSection(themeManager),
                      const SizedBox(height: 24),
                      _buildThemeSelectionSection(),
                      const SizedBox(height: 24),
                      _buildAdvancedOptionsSection(themeManager),
                      const SizedBox(height: 24),
                      _buildActionsSection(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCurrentThemeSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveTextWithGradient(
            'Thème Actuel',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            useThemeGradient: true,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: themeManager.getCurrentThemeGradient(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: ColorRes.whitePure,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdaptiveText(
                      themeManager.isDarkMode 
                        ? 'Thème Sombre : Noir et Rouge Netflix'
                        : 'Thème Clair : Blanc et Doré',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      useContrastColor: true,
                    ),
                    const SizedBox(height: 4),
                    AdaptiveText(
                      'Mode ${_autoThemeEnabled ? 'automatique' : 'manuel'}',
                      fontSize: 14,
                      useSecondaryColor: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sélecteur rapide
          QuickThemeSelector(
            showLabels: true,
            size: 50,
            onThemeChanged: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelectionSection() {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Sélection du Thème',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          AdvancedThemeSelector(
            showTitle: false,
            showDescription: true,
            showPreview: true,
            showAutoOption: true,
            onThemeChanged: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsSection(ThemeManager themeManager) {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Options Avancées',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          // Thème automatique
          SwitchListTile(
            title: AdaptiveText(
              'Thème Automatique',
              fontSize: 16,
            ),
            subtitle: AdaptiveText(
              'Suivre automatiquement le thème du système',
              fontSize: 14,
              useSecondaryColor: true,
            ),
            value: _autoThemeEnabled,
            onChanged: _updateAutoTheme,
            activeColor: themeManager.getCurrentThemeAccent(),
            secondary: Icon(
              Icons.brightness_auto,
              color: themeManager.getCurrentThemeAccent(),
            ),
          ),
          
          const Divider(),
          
          // Animations
          SwitchListTile(
            title: AdaptiveText(
              'Animations',
              fontSize: 16,
            ),
            subtitle: AdaptiveText(
              'Activer les animations de transition',
              fontSize: 14,
              useSecondaryColor: true,
            ),
            value: _showAnimations,
            onChanged: (value) {
              setState(() {
                _showAnimations = value;
              });
            },
            activeColor: themeManager.getCurrentThemeAccent(),
            secondary: Icon(
              Icons.animation,
              color: themeManager.getCurrentThemeAccent(),
            ),
          ),
          
          const Divider(),
          
          // Ombres
          SwitchListTile(
            title: AdaptiveText(
              'Ombres',
              fontSize: 16,
            ),
            subtitle: AdaptiveText(
              'Afficher les ombres et effets de profondeur',
              fontSize: 14,
              useSecondaryColor: true,
            ),
            value: _showShadows,
            onChanged: (value) {
              setState(() {
                _showShadows = value;
              });
            },
            activeColor: themeManager.getCurrentThemeAccent(),
            secondary: Icon(
              Icons.dark_mode,
              color: themeManager.getCurrentThemeAccent(),
            ),
          ),
          
          const Divider(),
          
          // Gradients
          SwitchListTile(
            title: AdaptiveText(
              'Gradients',
              fontSize: 16,
            ),
            subtitle: AdaptiveText(
              'Utiliser les gradients de couleur',
              fontSize: 14,
              useSecondaryColor: true,
            ),
            value: _useGradients,
            onChanged: (value) {
              setState(() {
                _useGradients = value;
              });
            },
            activeColor: themeManager.getCurrentThemeAccent(),
            secondary: Icon(
              Icons.gradient,
              color: themeManager.getCurrentThemeAccent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return AdaptiveThemeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Actions',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            useAccentColor: true,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  'Exporter Paramètres',
                  icon: Icons.download,
                  useAccentColor: true,
                  onPressed: _exportSettings,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdaptiveButton(
                  'Réinitialiser',
                  icon: Icons.refresh,
                  useSecondaryColor: true,
                  onPressed: _resetAllSettings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Aide - Paramètres de Thème'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thème Automatique :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Active le suivi automatique du thème système'),
              SizedBox(height: 8),
              
              Text(
                'Animations :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Contrôle les animations de transition entre thèmes'),
              SizedBox(height: 8),
              
              Text(
                'Ombres :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Active les effets d\'ombre pour la profondeur'),
              SizedBox(height: 8),
              
              Text(
                'Gradients :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Utilise les dégradés de couleur du thème'),
              SizedBox(height: 16),
              
              Text(
                'Note :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Les changements sont appliqués immédiatement.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
