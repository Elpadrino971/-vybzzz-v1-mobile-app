import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundImageWidget extends StatelessWidget {
  final String imagePath;
  final Widget child;
  final double? opacity;
  final BoxFit fit;

  const BackgroundImageWidget({
    Key? key,
    required this.imagePath,
    required this.child,
    this.opacity = 0.3,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Opacity(
            opacity: opacity!,
            child: imagePath.endsWith('.svg')
                ? SvgPicture.asset(
                    imagePath,
                    fit: fit,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.asset(
                    imagePath,
                    fit: fit,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}

// Widget spécialisé pour les arrière-plans de festival
class FestivalBackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const FestivalBackgroundWidget({
    Key? key,
    required this.child,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWidget(
      imagePath: 'assets/images/events/festival_vibes.svg',
      opacity: isDarkMode ? 0.2 : 0.4,
      child: child,
    );
  }
}

// Widget spécialisé pour les arrière-plans de concert
class ConcertBackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const ConcertBackgroundWidget({
    Key? key,
    required this.child,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWidget(
      imagePath: 'assets/images/backgrounds/concert_stage.svg',
      opacity: isDarkMode ? 0.15 : 0.25,
      child: child,
    );
  }
}

// Widget spécialisé pour les arrière-plans de DJ
class DJBackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const DJBackgroundWidget({
    Key? key,
    required this.child,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWidget(
      imagePath: 'assets/images/artists/dj_mixing.svg',
      opacity: isDarkMode ? 0.2 : 0.3,
      child: child,
    );
  }
}
