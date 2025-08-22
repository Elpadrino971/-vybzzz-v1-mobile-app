import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/utilities/color_res.dart';
import 'package:vybzzz/utilities/theme_manager.dart';
import 'package:vybzzz/utilities/theme_res.dart';

void main() {
  runApp(const VyBzzZWebApp());
}

class VyBzzZWebApp extends StatelessWidget {
  const VyBzzZWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VyBzzZ Web',
      theme: ThemeRes.lightTheme(context),
      darkTheme: ThemeRes.darkTheme(context),
      home: const VyBzzZWebHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VyBzzZWebHome extends StatelessWidget {
  const VyBzzZWebHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (themeManager) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('VyBzzZ Web'),
            backgroundColor: themeManager.isDarkMode ? ColorRes.blackPure : ColorRes.bgLightGrey,
            foregroundColor: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
            actions: [
              IconButton(
                icon: Icon(
                  themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: themeManager.isDarkMode ? ColorRes.whitePure : ColorRes.blackPure,
                ),
                onPressed: () => themeManager.toggleTheme(),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeManager.getCurrentThemeGradient(),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flutter_dash,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'VyBzzZ Web',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Application web en cours de développement',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
