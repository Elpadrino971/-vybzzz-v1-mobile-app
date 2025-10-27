import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/service/vybzzz/stripe_service.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:vybzzz/common/widget/text_button_custom.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';

/// Écran d'onboarding Stripe Connect pour les artistes
class StripeOnboardingScreen extends StatefulWidget {
  const StripeOnboardingScreen({super.key});

  @override
  State<StripeOnboardingScreen> createState() => _StripeOnboardingScreenState();
}

class _StripeOnboardingScreenState extends State<StripeOnboardingScreen> {
  final StripeService _stripeService = StripeService();
  final AuthController _authController = Get.find<AuthController>();

  bool isLoading = false;
  bool isOnboarded = false;
  String? connectAccountId;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final user = _authController.currentUser.value;
    if (user == null) return;

    setState(() => isLoading = true);

    final completed = await _stripeService.isOnboardingCompleted(user.id!);

    setState(() {
      isOnboarded = completed;
      isLoading = false;
    });
  }

  Future<void> _startOnboarding() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      setState(() => isLoading = true);

      // 1. Créer le compte Connect
      connectAccountId = await _stripeService.createConnectAccount(
        userId: user.id!,
        email: user.userEmail ?? '',
        fullname: user.fullname ?? '',
        country: 'FR',
      );

      // 2. Générer le lien d'onboarding
      final onboardingUrl = await _stripeService.createAccountLink(
        connectAccountId: connectAccountId!,
        returnUrl: 'vybzzz://stripe/return',
        refreshUrl: 'vybzzz://stripe/refresh',
      );

      // 3. Ouvrir le lien dans le navigateur
      final uri = Uri.parse(onboardingUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      setState(() => isLoading = false);

      // 4. Afficher un message
      Get.snackbar(
        'Onboarding Stripe',
        'Complétez votre profil Stripe pour recevoir les paiements',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Erreur', 'Erreur lors de la création du compte Stripe');
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      setState(() => isLoading = true);

      await _stripeService.completeOnboarding(user.id!);

      setState(() {
        isOnboarded = true;
        isLoading = false;
      });

      Get.snackbar(
        'Succès!',
        'Votre compte Stripe est maintenant configuré',
        duration: const Duration(seconds: 3),
      );

      // Retourner au dashboard
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Erreur', 'Erreur lors de la completion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: whitePure(context).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: whitePure(context),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Configuration Stripe',
                        style: TextStyleCustom.outFitMedium500(
                          fontSize: 20,
                          color: whitePure(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                          ),
                        )
                      : _buildContent(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isOnboarded) {
      return _buildOnboardedView(context);
    } else {
      return _buildOnboardingView(context);
    }
  }

  Widget _buildOnboardingView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.account_balance,
                size: 60,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Text(
            'Configurez vos paiements',
            style: TextStyleCustom.outFitMedium500(
              fontSize: 24,
              color: whitePure(context),
            ),
          ),

          const SizedBox(height: 15),

          // Description
          Text(
            'Pour recevoir les paiements de vos concerts, vous devez configurer votre compte Stripe Connect.',
            textAlign: TextAlign.center,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 16,
              color: whitePure(context).withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 40),

          // Features
          _buildFeatureItem(
            context,
            icon: Icons.schedule,
            title: 'Paiements J+14',
            description: 'Recevez vos gains tous les lundis, 14 jours après le concert',
          ),

          const SizedBox(height: 20),

          _buildFeatureItem(
            context,
            icon: Icons.security,
            title: 'Sécurisé',
            description: 'Stripe est utilisé par des millions d\'entreprises dans le monde',
          ),

          const SizedBox(height: 20),

          _buildFeatureItem(
            context,
            icon: Icons.trending_up,
            title: 'Jusqu\'à 70%',
            description: 'Gardez jusqu\'à 70% de vos revenus selon votre tier',
          ),

          const SizedBox(height: 40),

          // CTA Button
          TextButtonCustom(
            name: 'CONFIGURER MAINTENANT',
            onTap: _startOnboarding,
            backgroundColor: const Color(0xFFFFD700),
            textColor: Colors.black,
          ),

          const SizedBox(height: 15),

          Text(
            'Moins de 5 minutes',
            style: TextStyleCustom.outFitRegular400(
              fontSize: 14,
              color: whitePure(context).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Compte configuré!',
              style: TextStyleCustom.outFitMedium500(
                fontSize: 24,
                color: whitePure(context),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Votre compte Stripe est prêt à recevoir les paiements.',
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 16,
                color: whitePure(context).withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 40),

            TextButtonCustom(
              name: 'RETOUR AU DASHBOARD',
              onTap: () => Get.back(),
              backgroundColor: const Color(0xFFFFD700),
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: whitePure(context).withValues(alpha: 0.05),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 16,
                    color: whitePure(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 14,
                    color: whitePure(context).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
