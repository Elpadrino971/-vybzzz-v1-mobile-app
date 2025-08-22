import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? customColor;
  final bool useAccentColor;
  final bool useSecondaryColor;
  final bool useContrastColor;
  final double? opacity;

  const AdaptiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.fontSize,
    this.fontWeight,
    this.customColor,
    this.useAccentColor = false,
    this.useSecondaryColor = false,
    this.useContrastColor = false,
    this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        Color textColor = _getTextColor(themeManager);
        
        if (opacity != null) {
          textColor = textColor.withOpacity(opacity!);
        }

        final finalStyle = (style ?? const TextStyle()).copyWith(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );

        return Text(
          text,
          style: finalStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
        );
      },
    );
  }

  Color _getTextColor(ThemeManager themeManager) {
    if (customColor != null) {
      return customColor!;
    }

    if (useAccentColor) {
      return themeManager.getCurrentThemeAccent();
    }

    if (useSecondaryColor) {
      return themeManager.isDarkMode ? ColorRes.textLightGrey : ColorRes.textDarkGrey;
    }

    if (useContrastColor) {
      return themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure;
    }

    // Couleur par défaut selon le thème
    return themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure;
  }
}

class AdaptiveTextWithAnimation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? customColor;
  final bool useAccentColor;
  final bool useSecondaryColor;
  final bool useContrastColor;
  final double? opacity;
  final Duration animationDuration;
  final Curve animationCurve;

  const AdaptiveTextWithAnimation(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.fontSize,
    this.fontWeight,
    this.customColor,
    this.useAccentColor = false,
    this.useSecondaryColor = false,
    this.useContrastColor = false,
    this.opacity,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AdaptiveTextWithAnimation> createState() => _AdaptiveTextWithAnimationState();
}

class _AdaptiveTextWithAnimationState extends State<AdaptiveTextWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        Color textColor = _getTextColor(themeManager);
        
        if (widget.opacity != null) {
          textColor = textColor.withOpacity(widget.opacity!);
        }

        final finalStyle = (widget.style ?? const TextStyle()).copyWith(
          color: textColor,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
        );

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Text(
                  widget.text,
                  style: finalStyle,
                  textAlign: widget.textAlign,
                  maxLines: widget.maxLines,
                  overflow: widget.overflow,
                  softWrap: widget.softWrap,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getTextColor(ThemeManager themeManager) {
    if (widget.customColor != null) {
      return widget.customColor!;
    }

    if (widget.useAccentColor) {
      return themeManager.getCurrentThemeAccent();
    }

    if (widget.useSecondaryColor) {
      return themeManager.isDarkMode ? ColorRes.textLightGrey : ColorRes.textDarkGrey;
    }

    if (widget.useContrastColor) {
      return themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure;
    }

    return themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure;
  }
}

class AdaptiveTextWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final double spacing;
  final MainAxisAlignment alignment;
  final bool iconFirst;
  final bool useAccentColor;
  final bool useSecondaryColor;

  const AdaptiveTextWithIcon(
    this.text, {
    Key? key,
    required this.icon,
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.spacing = 8.0,
    this.alignment = MainAxisAlignment.start,
    this.iconFirst = true,
    this.useAccentColor = false,
    this.useSecondaryColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        final finalIconColor = iconColor ?? 
          (useAccentColor 
            ? themeManager.getCurrentThemeAccent() 
            : (useSecondaryColor 
              ? (themeManager.isDarkMode ? ColorRes.textLightGrey : ColorRes.textDarkGrey)
              : (themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure)
            )
          );

        final finalTextStyle = textStyle ?? TextStyle(
          color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
        );

        final iconWidget = Icon(
          icon,
          color: finalIconColor,
          size: iconSize ?? 20.0,
        );

        final textWidget = Text(
          text,
          style: finalTextStyle,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignment,
          children: iconFirst 
            ? [iconWidget, SizedBox(width: spacing), textWidget]
            : [textWidget, SizedBox(width: spacing), iconWidget],
        );
      },
    );
  }
}

class AdaptiveTextWithGradient extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool useThemeGradient;
  final List<Color>? customGradient;

  const AdaptiveTextWithGradient(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.fontSize,
    this.fontWeight,
    this.useThemeGradient = true,
    this.customGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        final gradient = customGradient ?? 
          (useThemeGradient ? themeManager.getCurrentThemeGradient().colors : null);

        if (gradient == null) {
          return AdaptiveText(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
            fontSize: fontSize,
            fontWeight: fontWeight,
          );
        }

        final finalStyle = (style ?? const TextStyle()).copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
        );

        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            text,
            style: finalStyle.copyWith(color: Colors.white),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
          ),
        );
      },
    );
  }
}
