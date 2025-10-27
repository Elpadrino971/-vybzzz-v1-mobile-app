import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/routes/vybzzz_routes.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';

/// Splash screen animé avec effet interactif de particules
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particlesController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  final List<Particle> _particles = [];
  final List<Snowflake> _snowflakes = [];
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Particles animation
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60fps
      vsync: this,
    )..repeat();

    _particlesController.addListener(_updateParticles);

    // Initialize snowflakes
    for (int i = 0; i < 50; i++) {
      _snowflakes.add(Snowflake(
        position: Offset(
          math.Random().nextDouble() * Get.width,
          math.Random().nextDouble() * Get.height,
        ),
      ));
    }

    // Start animations
    _logoController.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        VyBzzZRoutes.toWelcome();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    setState(() {
      // Update existing particles
      _particles.removeWhere((p) => p.isDead);
      for (var particle in _particles) {
        particle.update();
      }

      // Update snowflakes
      for (var snowflake in _snowflakes) {
        snowflake.update();
        // Reset snowflake if it goes off screen
        if (snowflake.position.dy > Get.height) {
          snowflake.position = Offset(
            math.Random().nextDouble() * Get.width,
            -20,
          );
        }
      }

      // Add new particles at touch position
      if (_touchPosition != null && _particles.length < 100) {
        _particles.add(Particle(position: _touchPosition!));
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _touchPosition = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _touchPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTapDown: (details) {
          setState(() {
            _touchPosition = details.localPosition;
            // Create burst of particles on tap
            for (int i = 0; i < 10; i++) {
              _particles.add(Particle(position: details.localPosition));
            }
          });
        },
        child: Container(
          width: Get.width,
          height: Get.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF000000),
                Color(0xFF1A1A1A),
                Color(0xFF000000),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Snowflakes (background)
              CustomPaint(
                size: Size(Get.width, Get.height),
                painter: SnowflakesPainter(snowflakes: _snowflakes),
              ),

              // Interactive particles
              CustomPaint(
                size: Size(Get.width, Get.height),
                painter: ParticlesPainter(particles: _particles),
              ),

              // Logo & Text
              Center(
                child: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Container(
                              width: 150,
                              height: 150,
                              decoration: ShapeDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFF8C00),
                                    Color(0xFFFFD700),
                                  ],
                                ),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius.all(
                                    SmoothRadius(
                                      cornerRadius: 40,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Musical note
                                    const Text(
                                      '🎵',
                                      style: TextStyle(fontSize: 80),
                                    ),
                                    // Santa hat on top
                                    Positioned(
                                      top: -10,
                                      right: 15,
                                      child: Transform.rotate(
                                        angle: 0.3,
                                        child: const Text(
                                          '🎅',
                                          style: TextStyle(fontSize: 40),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // App name
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFF8C00),
                                  Color(0xFFFFD700),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'VyBzzZ',
                                style: TextStyleCustom.unboundedBlack900(
                                  fontSize: 56,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Tagline
                            Text(
                              'La première plateforme J+14',
                              style: TextStyleCustom.outFitRegular400(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Loading indicator
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFFFD700)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Hint text
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Touchez l\'écran pour créer de la magie ✨🎄❄️',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Particle class for animation
class Particle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle({required this.position})
      : velocity = Offset(
          (math.Random().nextDouble() - 0.5) * 4,
          (math.Random().nextDouble() - 0.5) * 4 - 2, // Bias upward
        ),
        life = 1.0,
        maxLife = math.Random().nextDouble() * 60 + 30,
        color = [
          const Color(0xFFFFD700), // Gold
          const Color(0xFFFF0000), // Red
          const Color(0xFF00FF00), // Green
          const Color(0xFFFFFFFF), // White
          const Color(0xFFFF6B6B), // Light Red
        ][math.Random().nextInt(5)],
        size = math.Random().nextDouble() * 6 + 2;

  void update() {
    position += velocity;
    velocity *= 0.98; // Friction
    life -= 1;
  }

  bool get isDead => life <= 0;

  double get opacity => (life / maxLife).clamp(0.0, 1.0);
}

/// Custom painter for particles
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;

  ParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        particle.position,
        particle.size * 1.5,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}

/// Snowflake class for Christmas effect
class Snowflake {
  Offset position;
  double speed;
  double size;
  double swingAmplitude;
  double swingSpeed;
  double swingOffset;

  Snowflake({required this.position})
      : speed = math.Random().nextDouble() * 1 + 0.5,
        size = math.Random().nextDouble() * 4 + 2,
        swingAmplitude = math.Random().nextDouble() * 30 + 10,
        swingSpeed = math.Random().nextDouble() * 0.05 + 0.02,
        swingOffset = math.Random().nextDouble() * math.pi * 2;

  void update() {
    // Move down
    position = Offset(
      position.dx + math.sin(position.dy * swingSpeed + swingOffset) * 0.5,
      position.dy + speed,
    );
  }
}

/// Custom painter for snowflakes
class SnowflakesPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowflakesPainter({required this.snowflakes});

  @override
  void paint(Canvas canvas, Size size) {
    for (var snowflake in snowflakes) {
      // Draw snowflake as white circle with glow
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        snowflake.position,
        snowflake.size,
        paint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        snowflake.position,
        snowflake.size * 1.5,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SnowflakesPainter oldDelegate) => true;
}
