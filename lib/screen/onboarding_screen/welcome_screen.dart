import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/widget/text_button_custom.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';

/// Écran d'accueil VyBzzZ
///
/// Premier écran que voit l'utilisateur
/// Présente la plateforme et propose Login/Signup

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: const ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.vertical(
              top: SmoothRadius(cornerRadius: 0, cornerSmoothing: 1),
            ),
          ),
        ),
        child: Stack(
          children: [
            const ThemeBlurBg(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo/Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFD700), // Or
                                Color(0xFFFF8C00), // Orange doré
                              ],
                            ),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.all(
                                SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🎵',
                              style: TextStyle(fontSize: 60),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App Name
                        Text(
                          'VyBzzZ',
                          style: TextStyleCustom.unboundedBlack900(
                            fontSize: 48,
                            color: whitePure(context),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tagline
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'La première plateforme\nqui paie les artistes tous les lundis',
                            textAlign: TextAlign.center,
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 16,
                              color: whitePure(context).withValues(alpha: 0.8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // J+14 Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.all(
                                SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFFFD700),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Paiements J+14 🚀',
                            style: TextStyleCustom.outFitMedium500(
                              fontSize: 14,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Features
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Column(
                            children: [
                              _FeatureItem(
                                icon: '🎤',
                                text: 'Concerts live en HD',
                              ),
                              const SizedBox(height: 12),
                              _FeatureItem(
                                icon: '🎫',
                                text: '3 types de billets',
                              ),
                              const SizedBox(height: 12),
                              _FeatureItem(
                                icon: '📺',
                                text: 'Replays 7 jours',
                              ),
                              const SizedBox(height: 12),
                              _FeatureItem(
                                icon: '⚡',
                                text: 'Happy Hour chaque mercredi',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Sign Up Button
                        TextButtonCustom(
                          name: 'CRÉER UN COMPTE',
                          onTap: () {
                            Get.toNamed('/register');
                          },
                          backgroundColor: const Color(0xFFFFD700), // Or
                          textColor: Colors.black,
                        ),

                        const SizedBox(height: 12),

                        // Login Button
                        TextButtonCustom(
                          name: 'SE CONNECTER',
                          onTap: () {
                            Get.toNamed('/login');
                          },
                          backgroundColor: whitePure(context).withValues(alpha: 0.1),
                          textColor: whitePure(context),
                        ),

                        const SizedBox(height: 20),

                        // Terms
                        Text(
                          'En continuant, vous acceptez nos\nConditions d\'utilisation et Politique de confidentialité',
                          textAlign: TextAlign.center,
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 11,
                            color: whitePure(context).withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 15,
              color: whitePure(context).withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
