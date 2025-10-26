import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/enum/user_type_enum.dart';
import 'package:vybzzz/common/widget/text_button_custom.dart';
import 'package:vybzzz/common/widget/theme_blur_bg.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:vybzzz/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';

/// Écran de sélection du type d'utilisateur VyBzzZ
///
/// Permet à l'utilisateur de choisir parmi les 5 types:
/// - Fan
/// - Artiste
/// - Apporteur d'Affaire
/// - Responsable Régional
/// - Propriétaire de Salle

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  UserType? selectedType;

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
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          'BIENVENUE SUR',
                          style: TextStyleCustom.unboundedBlack900(
                            fontSize: 16,
                            color: whitePure(context).withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'VyBzzZ',
                          style: TextStyleCustom.unboundedBlack900(
                            fontSize: 40,
                            color: whitePure(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choisissez votre profil',
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 18,
                            color: whitePure(context).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User Types Grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: UserType.values.map((type) {
                          return _UserTypeCard(
                            userType: type,
                            isSelected: selectedType == type,
                            onTap: () {
                              setState(() {
                                selectedType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextButtonCustom(
                          name: 'CONTINUER',
                          onTap: selectedType != null
                              ? () {
                                  // Navigation vers l'écran de profil
                                  Get.toNamed('/profile-setup',
                                      arguments: {'userType': selectedType});
                                }
                              : null,
                          backgroundColor: selectedType != null
                              ? const Color(0xFFFFD700) // Or
                              : Colors.grey,
                          textColor: Colors.black,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Vous pourrez modifier votre type de compte plus tard',
                          textAlign: TextAlign.center,
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 12,
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

class _UserTypeCard extends StatelessWidget {
  final UserType userType;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.userType,
    required this.isSelected,
    required this.onTap,
  });

  Color _getCardColor(BuildContext context) {
    if (isSelected) {
      return const Color(0xFFFFD700).withValues(alpha: 0.2); // Or clair
    }
    return whitePure(context).withValues(alpha: 0.05);
  }

  Color _getBorderColor(BuildContext context) {
    if (isSelected) {
      return const Color(0xFFFFD700); // Or
    }
    return whitePure(context).withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: ShapeDecoration(
          color: _getCardColor(context),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            ),
            side: BorderSide(
              color: _getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: ShapeDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                      : whitePure(context).withValues(alpha: 0.1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                      SmoothRadius(cornerRadius: 15, cornerSmoothing: 1),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userType.displayName,
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 18,
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : whitePure(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userType.description,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 13,
                        color: whitePure(context).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Check Icon
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji() {
    switch (userType) {
      case UserType.fan:
        return '🎵';
      case UserType.artist:
        return '🎤';
      case UserType.businessBringer:
        return '🤝';
      case UserType.regionalManager:
        return '📊';
      case UserType.venueOwner:
        return '🏟️';
    }
  }
}
