import 'package:flutter/material.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/font_res.dart';

class ThemeRes {
  /// Theme light mode - Blanc et Doré

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: ColorRes.whitePure,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: ColorRes.whitePure),
      appBarTheme: const AppBarTheme(backgroundColor: ColorRes.bgLightGrey),
      fontFamily: FontRes.outFitRegular400,
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: ColorRes.whitePure),
      sliderTheme: const SliderThemeData(
          trackHeight: 2.5,
          trackShape: RectangularSliderTrackShape(),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
          overlayColor: Colors.transparent),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColorRes.blackPure),
        titleMedium: TextStyle(color: ColorRes.textDarkGrey),
        titleSmall: TextStyle(color: ColorRes.textLightGrey),
        labelSmall: TextStyle(color: ColorRes.themeAccentSolid),
        labelLarge: TextStyle(color: ColorRes.disabledGrey),
      ),
      textSelectionTheme:
          const TextSelectionThemeData(selectionColor: ColorRes.themeAccentSolid),
      cardTheme: const CardThemeData(color: ColorRes.whitePure),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: ColorRes.themeAccentSolid,
      dividerColor: ColorRes.bgGrey,
      cardColor: ColorRes.bgMediumGrey,
      primaryColorDark: ColorRes.blackPure,
      canvasColor: ColorRes.themeColor,
      useMaterial3: false,
    );
  }

  /// Theme dark mode - Noir et Rouge (Style Netflix)

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: ColorRes.themeColorDark,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: ColorRes.themeColorDark),
      appBarTheme: const AppBarTheme(backgroundColor: ColorRes.blackPure),
      fontFamily: FontRes.outFitRegular400,
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: ColorRes.blackPure),
      sliderTheme: const SliderThemeData(
          trackHeight: 2.5,
          trackShape: RectangularSliderTrackShape(),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
          overlayColor: Colors.transparent),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColorRes.whitePure),
        titleMedium: TextStyle(color: ColorRes.whitePure),
        titleSmall: TextStyle(color: ColorRes.textLightGrey),
        labelSmall: TextStyle(color: ColorRes.themeAccentSolidDark),
        labelLarge: TextStyle(color: ColorRes.disabledGrey),
      ),
      textSelectionTheme:
          const TextSelectionThemeData(selectionColor: ColorRes.themeAccentSolidDark),
      cardTheme: const CardThemeData(color: ColorRes.blackPure),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: ColorRes.themeAccentSolidDark,
      dividerColor: ColorRes.textDarkGrey,
      cardColor: ColorRes.textDarkGrey,
      primaryColorDark: ColorRes.whitePure,
      canvasColor: ColorRes.themeColorDark,
      useMaterial3: false,
    );
  }
}

Color whitePure(BuildContext context) {
  return Theme.of(context).textTheme.titleLarge?.color ?? ColorRes.whitePure;
}

Color textDarkGrey(BuildContext context) {
  return Theme.of(context).textTheme.titleMedium?.color ??
      ColorRes.textDarkGrey;
}

Color textLightGrey(BuildContext context) {
  return Theme.of(context).textTheme.titleSmall?.color ??
      ColorRes.textLightGrey;
}

Color bgGrey(BuildContext context) {
  return Theme.of(context).dividerColor;
}

Color themeAccentSolid(BuildContext context) {
  return Theme.of(context).textTheme.labelSmall?.color ??
      ColorRes.themeAccentSolid;
}

Color disableGrey(BuildContext context) {
  return Theme.of(context).textTheme.labelLarge?.color ?? ColorRes.disabledGrey;
}

Color scaffoldBackgroundColor(BuildContext context) {
  return Theme.of(context).scaffoldBackgroundColor;
}

Color blueFollow(BuildContext context) {
  return Theme.of(context).cardTheme.color ?? ColorRes.blueFollow;
}

Color bgMediumGrey(BuildContext context) {
  return Theme.of(context).cardColor;
}

Color blackPure(BuildContext context) {
  return Theme.of(context).primaryColorDark;
}

Color bgLightGrey(BuildContext context) {
  return Theme.of(context).appBarTheme.backgroundColor ?? ColorRes.bgLightGrey;
}

Color themeColor(BuildContext context) {
  return Theme.of(context).canvasColor;
}
