import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';

class AdaptiveThemeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool useGradient;
  final bool useShadow;
  final VoidCallback? onTap;
  final Color? customBackgroundColor;
  final Gradient? customGradient;

  const AdaptiveThemeCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.useGradient = false,
    this.useShadow = true,
    this.onTap,
    this.customBackgroundColor,
    this.customGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        final cardDecoration = BoxDecoration(
          color: customBackgroundColor ?? 
                 (useGradient ? null : (themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure)),
          gradient: customGradient ?? 
                    (useGradient ? themeManager.getCurrentThemeGradient() : null),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: useShadow ? [
            BoxShadow(
              color: (themeManager.isDarkMode ? ColorRes.themeGradient1Dark : ColorRes.themeGradient1)
                  .withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
          border: Border.all(
            color: themeManager.isDarkMode 
                ? ColorRes.textDarkGrey.withOpacity(0.2)
                : ColorRes.bgGrey,
            width: 1,
          ),
        );

        Widget cardContent = Container(
          decoration: cardDecoration,
          padding: padding ?? const EdgeInsets.all(16),
          margin: margin,
          child: child,
        );

        if (onTap != null) {
          cardContent = GestureDetector(
            onTap: onTap,
            child: cardContent,
          );
        }

        return cardContent;
      },
    );
  }
}

class AdaptiveThemeCardWithAnimation extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool useGradient;
  final bool useShadow;
  final VoidCallback? onTap;
  final Color? customBackgroundColor;
  final Gradient? customGradient;
  final Duration animationDuration;

  const AdaptiveThemeCardWithAnimation({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.useGradient = false,
    this.useShadow = true,
    this.onTap,
    this.customBackgroundColor,
    this.customGradient,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AdaptiveThemeCardWithAnimation> createState() => _AdaptiveThemeCardWithAnimationState();
}

class _AdaptiveThemeCardWithAnimationState extends State<AdaptiveThemeCardWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        final cardDecoration = BoxDecoration(
          color: widget.customBackgroundColor ?? 
                 (widget.useGradient ? null : (themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.whitePure)),
          gradient: widget.customGradient ?? 
                    (widget.useGradient ? themeManager.getCurrentThemeGradient() : null),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          boxShadow: widget.useShadow ? [
            BoxShadow(
              color: (themeManager.isDarkMode ? ColorRes.themeGradient1Dark : ColorRes.themeGradient1)
                  .withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
          border: Border.all(
            color: themeManager.isDarkMode 
                ? ColorRes.textDarkGrey.withOpacity(0.2)
                : ColorRes.bgGrey,
            width: 1,
          ),
        );

        Widget cardContent = AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: cardDecoration,
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  margin: widget.margin,
                  child: widget.child,
                ),
              ),
            );
          },
        );

        if (widget.onTap != null) {
          cardContent = GestureDetector(
            onTap: _onTap,
            child: cardContent,
          );
        }

        return cardContent;
      },
    );
  }
}

class AdaptiveThemeCardList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? itemMargin;
  final double? itemElevation;
  final BorderRadius? itemBorderRadius;
  final bool useGradient;
  final bool useShadow;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? listPadding;

  const AdaptiveThemeCardList({
    Key? key,
    required this.children,
    this.itemPadding,
    this.itemMargin,
    this.itemElevation,
    this.itemBorderRadius,
    this.useGradient = false,
    this.useShadow = true,
    this.physics,
    this.shrinkWrap = false,
    this.listPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: listPadding ?? const EdgeInsets.all(16),
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return AdaptiveThemeCard(
          padding: itemPadding,
          margin: itemMargin,
          elevation: itemElevation,
          borderRadius: itemBorderRadius,
          useGradient: useGradient,
          useShadow: useShadow,
          child: children[index],
        );
      },
    );
  }
}
