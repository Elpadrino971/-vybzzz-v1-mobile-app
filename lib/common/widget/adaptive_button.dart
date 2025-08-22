import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isLoading;
  final bool isOutlined;
  final bool useGradient;
  final bool useAccentColor;
  final bool useSecondaryColor;
  final bool useContrastColor;
  final Color? customColor;
  final Color? customTextColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final IconData? icon;
  final bool iconFirst;
  final double iconSize;
  final double spacing;
  final bool enableShadow;
  final bool enableAnimation;
  final Duration animationDuration;

  const AdaptiveButton(
    this.text, {
    Key? key,
    this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.isOutlined = false,
    this.useGradient = false,
    this.useAccentColor = false,
    this.useSecondaryColor = false,
    this.useContrastColor = false,
    this.customColor,
    this.customTextColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.iconFirst = true,
    this.iconSize = 20.0,
    this.spacing = 8.0,
    this.enableShadow = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        final buttonColor = _getButtonColor(themeManager);
        final textColor = _getTextColor(themeManager);

        Widget buttonContent = _buildButtonContent(themeManager);

        if (isOutlined) {
          return _buildOutlinedButton(buttonColor, textColor, buttonContent);
        }

        if (useGradient) {
          return _buildGradientButton(themeManager, textColor, buttonContent);
        }

        return _buildFilledButton(buttonColor, textColor, buttonContent);
      },
    );
  }

  Widget _buildButtonContent(ThemeManager themeManager) {
    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(themeManager),
          ),
        ),
      );
    }

    if (icon != null) {
      final iconWidget = Icon(
        icon,
        size: iconSize,
        color: _getTextColor(themeManager),
      );

      final textWidget = Text(
        text,
        style: TextStyle(
          color: _getTextColor(themeManager),
          fontWeight: FontWeight.w600,
        ),
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: iconFirst 
          ? [iconWidget, SizedBox(width: spacing), textWidget]
          : [textWidget, SizedBox(width: spacing), iconWidget],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: _getTextColor(themeManager),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFilledButton(Color buttonColor, Color textColor, Widget content) {
    final button = ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        elevation: enableShadow ? 4 : 0,
        shadowColor: buttonColor.withOpacity(0.3),
      ),
      child: content,
    );

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        child: button,
      );
    }

    return button;
  }

  Widget _buildOutlinedButton(Color buttonColor, Color textColor, Widget content) {
    final button = OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(color: buttonColor, width: 2),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: content,
    );

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        child: button,
      );
    }

    return button;
  }

  Widget _buildGradientButton(ThemeManager themeManager, Color textColor, Widget content) {
    final button = Container(
      decoration: BoxDecoration(
        gradient: themeManager.getCurrentThemeGradient(),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: enableShadow ? [
          BoxShadow(
            color: themeManager.getCurrentThemeAccent().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child: content,
      ),
    );

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        child: button,
      );
    }

    return button;
  }

  Color _getButtonColor(ThemeManager themeManager) {
    if (customColor != null) {
      return customColor!;
    }

    if (useAccentColor) {
      return themeManager.getCurrentThemeAccent();
    }

    if (useSecondaryColor) {
      return themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.bgGrey;
    }

    if (useContrastColor) {
      return themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure;
    }

    return themeManager.getCurrentThemeAccent();
  }

  Color _getTextColor(ThemeManager themeManager) {
    if (customTextColor != null) {
      return customTextColor!;
    }

    if (useContrastColor) {
      return themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure;
    }

    return ColorRes.whitePure;
  }
}

class AdaptiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isLoading;
  final bool isOutlined;
  final bool useGradient;
  final bool useAccentColor;
  final bool useSecondaryColor;
  final bool useContrastColor;
  final Color? customColor;
  final Color? customIconColor;
  final double? size;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool enableShadow;
  final bool enableAnimation;
  final Duration animationDuration;
  final String? tooltip;

  const AdaptiveIconButton(
    this.icon, {
    Key? key,
    this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.isOutlined = false,
    this.useGradient = false,
    this.useAccentColor = false,
    this.useSecondaryColor = false,
    this.useContrastColor = false,
    this.customColor,
    this.customIconColor,
    this.size,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.enableShadow = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        final buttonColor = _getButtonColor(themeManager);
        final iconColor = _getIconColor(themeManager);

        Widget buttonContent = _buildButtonContent(iconColor);

        if (isOutlined) {
          return _buildOutlinedIconButton(buttonColor, iconColor, buttonContent);
        }

        if (useGradient) {
          return _buildGradientIconButton(themeManager, iconColor, buttonContent);
        }

        return _buildFilledIconButton(buttonColor, iconColor, buttonContent);
      },
    );
  }

  Widget _buildButtonContent(Color iconColor) {
    if (isLoading) {
      return SizedBox(
        width: iconSize ?? 20,
        height: iconSize ?? 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }

    return Icon(
      icon,
      size: iconSize ?? 20,
      color: iconColor,
    );
  }

  Widget _buildFilledIconButton(Color buttonColor, Color iconColor, Widget content) {
    final button = IconButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      icon: content,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: iconColor,
        padding: padding ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        elevation: enableShadow ? 4 : 0,
        shadowColor: buttonColor.withOpacity(0.3),
      ),
    );

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        child: button,
      );
    }

    return button;
  }

  Widget _buildOutlinedIconButton(Color buttonColor, Color iconColor, Widget content) {
    final button = IconButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      icon: content,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: iconColor,
        side: BorderSide(color: buttonColor, width: 2),
        padding: padding ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
    );

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        child: button,
      );
    }

    return button;
  }

  Widget _buildGradientIconButton(ThemeManager themeManager, Color iconColor, Widget content) {
    final button = Container(
      decoration: BoxDecoration(
        gradient: themeManager.getCurrentThemeGradient(),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: enableShadow ? [
          BoxShadow(
            color: themeManager.getCurrentThemeAccent().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        icon: content,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: iconColor,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
      ),
    );

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        child: button,
      );
    }

    return button;
  }

  Color _getButtonColor(ThemeManager themeManager) {
    if (customColor != null) {
      return customColor!;
    }

    if (useAccentColor) {
      return themeManager.getCurrentThemeAccent();
    }

    if (useSecondaryColor) {
      return themeManager.isDarkMode ? ColorRes.textDarkGrey : ColorRes.bgGrey;
    }

    if (useContrastColor) {
      return themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure;
    }

    return themeManager.getCurrentThemeAccent();
  }

  Color _getIconColor(ThemeManager themeManager) {
    if (customIconColor != null) {
      return customIconColor!;
    }

    if (useContrastColor) {
      return themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure;
    }

    return ColorRes.whitePure;
  }
}
