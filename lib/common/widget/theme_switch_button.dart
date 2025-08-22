import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class ThemeSwitchButton extends StatelessWidget {
  final double size;
  final bool showLabel;
  final String? lightLabel;
  final String? darkLabel;
  final VoidCallback? onThemeChanged;

  const ThemeSwitchButton({
    Key? key,
    this.size = 48,
    this.showLabel = false,
    this.lightLabel,
    this.darkLabel,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                themeManager.toggleTheme();
                onThemeChanged?.call();
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: themeManager.getCurrentThemeGradient(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeManager.getCurrentThemeAccent().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: ColorRes.whitePure,
                  size: size * 0.5,
                ),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 8),
              Text(
                themeManager.isDarkMode 
                  ? (darkLabel ?? 'Thème Sombre')
                  : (lightLabel ?? 'Thème Clair'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class ThemeSwitchButtonWithAnimation extends StatefulWidget {
  final double size;
  final bool showLabel;
  final String? lightLabel;
  final String? darkLabel;
  final VoidCallback? onThemeChanged;

  const ThemeSwitchButtonWithAnimation({
    Key? key,
    this.size = 48,
    this.showLabel = false,
    this.lightLabel,
    this.darkLabel,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  State<ThemeSwitchButtonWithAnimation> createState() => _ThemeSwitchButtonWithAnimationState();
}

class _ThemeSwitchButtonWithAnimationState extends State<ThemeSwitchButtonWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    final themeManager = Get.find<ThemeManager>();
    themeManager.toggleTheme();
    widget.onThemeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: GestureDetector(
                      onTap: _onTap,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          gradient: themeManager.getCurrentThemeGradient(),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: themeManager.getCurrentThemeAccent().withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: ColorRes.whitePure,
                          size: widget.size * 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  themeManager.isDarkMode 
                    ? (widget.darkLabel ?? 'Thème Sombre')
                    : (widget.lightLabel ?? 'Thème Clair'),
                  key: ValueKey(themeManager.isDarkMode),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
