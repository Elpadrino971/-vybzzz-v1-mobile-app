import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/widget/adaptive_button.dart';
import 'package:vybzzz/common/widget/adaptive_text.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';
import 'package:vybzzz/utilities/theme_preferences.dart';

class AdvancedThemeSelector extends StatefulWidget {
  final bool showTitle;
  final String? title;
  final bool showDescription;
  final bool showPreview;
  final bool showAutoOption;
  final VoidCallback? onThemeChanged;
  final double? width;
  final double? height;

  const AdvancedThemeSelector({
    Key? key,
    this.showTitle = true,
    this.title,
    this.showDescription = true,
    this.showPreview = true,
    this.showAutoOption = true,
    this.onThemeChanged,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<AdvancedThemeSelector> createState() => _AdvancedThemeSelectorState();
}

class _AdvancedThemeSelectorState extends State<AdvancedThemeSelector> {
  String _currentThemeMode = 'system';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentThemeMode();
  }

  Future<void> _loadCurrentThemeMode() async {
    final themeMode = await ThemePreferences.getThemeMode();
    setState(() {
      _currentThemeMode = themeMode;
      _isLoading = false;
    });
  }

  Future<void> _setThemeMode(String themeMode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ThemePreferences.setThemeMode(themeMode);
      
      if (themeMode != 'system') {
        await ThemePreferences.setLastTheme(themeMode);
      }

      setState(() {
        _currentThemeMode = themeMode;
        _isLoading = false;
      });

      // Appliquer le thème
      final themeManager = Get.find<ThemeManager>();
      if (themeMode == 'system') {
        themeManager.detectSystemTheme();
      } else {
        themeManager.setTheme(ThemePreferences.isDarkMode(themeMode));
      }

      widget.onThemeChanged?.call();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Erreur',
        'Impossible de changer le thème',
        backgroundColor: Colors.red,
        colorText: ColorRes.whitePure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            AdaptiveText(
              widget.title ?? 'Sélection du Thème',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              useAccentColor: true,
            ),
            const SizedBox(height: 16),
          ],
          
          // Options de thème
          ...ThemePreferences.getAvailableThemeModes()
              .where((mode) => widget.showAutoOption || mode['value'] != 'system')
              .map((mode) => _buildThemeOption(mode))
              .toList(),
          
          if (widget.showPreview) ...[
            const SizedBox(height: 24),
            _buildThemePreview(),
          ],
          
          if (widget.showDescription) ...[
            const SizedBox(height: 16),
            _buildThemeDescription(),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeOption(Map<String, dynamic> mode) {
    final isSelected = _currentThemeMode == mode['value'];
    final isSystemMode = mode['value'] == 'system';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _setThemeMode(mode['value']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
              ? Get.find<ThemeManager>().getCurrentThemeAccent().withOpacity(0.1)
              : Colors.transparent,
            border: Border.all(
              color: isSelected 
                ? Get.find<ThemeManager>().getCurrentThemeAccent()
                : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Get.find<ThemeManager>().getCurrentThemeAccent()
                    : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    mode['icon'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdaptiveText(
                      mode['displayName'],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    if (widget.showDescription) ...[
                      const SizedBox(height: 4),
                      AdaptiveText(
                        mode['description'],
                        fontSize: 14,
                        useSecondaryColor: true,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Indicateur de sélection
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Get.find<ThemeManager>().getCurrentThemeAccent(),
                  size: 24,
                ),
              
              // Indicateur système
              if (isSystemMode && _currentThemeMode == 'system')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Get.find<ThemeManager>().getCurrentThemeAccent(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AdaptiveText(
                    'Actif',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    useContrastColor: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview() {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeManager.getCurrentThemeColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveText(
                'Aperçu du Thème',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                useAccentColor: true,
              ),
              const SizedBox(height: 12),
              
              // Barre de navigation simulée
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: themeManager.getCurrentThemeGradient(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: AdaptiveText(
                    'Barre de Navigation',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    useContrastColor: true,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Bouton simulé
              SizedBox(
                width: double.infinity,
                child: AdaptiveButton(
                  'Bouton d\'Exemple',
                  useAccentColor: true,
                  onPressed: () {},
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Texte simulé
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: themeManager.getCurrentThemeAccent(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AdaptiveText(
                      'Ceci est un exemple de texte avec le thème actuel',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Get.find<ThemeManager>().getCurrentThemeAccent(),
                size: 20,
              ),
              const SizedBox(width: 8),
              AdaptiveText(
                'Informations sur les Thèmes',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                useAccentColor: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          AdaptiveText(
            '• Le thème clair utilise des couleurs dorées et blanches pour un style élégant',
            fontSize: 14,
            useSecondaryColor: true,
          ),
          const SizedBox(height: 4),
          AdaptiveText(
            '• Le thème sombre utilise des couleurs noires et rouges Netflix pour un style moderne',
            fontSize: 14,
            useSecondaryColor: true,
          ),
          const SizedBox(height: 4),
          AdaptiveText(
            '• Le mode système suit automatiquement les préférences de votre appareil',
            fontSize: 14,
            useSecondaryColor: true,
          ),
        ],
      ),
    );
  }
}

class QuickThemeSelector extends StatelessWidget {
  final bool showLabels;
  final double size;
  final VoidCallback? onThemeChanged;

  const QuickThemeSelector({
    Key? key,
    this.showLabels = false,
    this.size = 48,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thème clair
            _buildThemeButton(
              themeManager,
              false,
              Icons.light_mode,
              'Clair',
              showLabels,
            ),
            
            const SizedBox(width: 8),
            
            // Thème sombre
            _buildThemeButton(
              themeManager,
              true,
              Icons.dark_mode,
              'Sombre',
              showLabels,
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeButton(
    ThemeManager themeManager,
    bool isDark,
    IconData icon,
    String label,
    bool showLabel,
  ) {
    final isActive = themeManager.isDarkMode == isDark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            themeManager.setTheme(isDark);
            onThemeChanged?.call();
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isActive 
                ? themeManager.getCurrentThemeAccent()
                : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                  ? themeManager.getCurrentThemeAccent()
                  : Colors.grey.withOpacity(0.3),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive 
                ? ColorRes.whitePure
                : Colors.grey,
              size: size * 0.5,
            ),
          ),
        ),
        
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive 
                ? Get.find<ThemeManager>().getCurrentThemeAccent()
                : Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
