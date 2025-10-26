import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/screen/artist_live_screen/artist_live_controller.dart';
import 'package:vybzzz/utilities/text_style_custom.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';

/// Écran de contrôle live pour l'artiste (broadcaster)
class ArtistLiveScreen extends StatelessWidget {
  const ArtistLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtistLiveController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview (en production, afficher HMSVideoView)
          _buildCameraPreview(controller, context),

          // Overlays
          SafeArea(
            child: Column(
              children: [
                // Top stats bar
                _buildTopStatsBar(controller, context),

                const Spacer(),

                // Recent messages preview
                _buildRecentMessages(controller, context),

                // Controls
                _buildControls(controller, context),
              ],
            ),
          ),

          // Loading overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(
    ArtistLiveController controller,
    BuildContext context,
  ) {
    return SizedBox.expand(
      child: Obx(() {
        // Placeholder pour la démo
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.videocam,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                if (!controller.isLiveActive.value)
                  const Text(
                    'Aperçu caméra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopStatsBar(
    ArtistLiveController controller,
    BuildContext context,
  ) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Close button
                GestureDetector(
                  onTap: () {
                    if (controller.isLiveActive.value) {
                      _showEndLiveDialog(controller);
                    } else {
                      Get.back();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // Live status
                if (controller.isLiveActive.value)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          return Text(
                            'LIVE ${controller.liveDuration.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                const Spacer(),

                // Viewer count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Obx(() {
                        return Text(
                          '${controller.viewerCount.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            // Stats cards
            if (controller.isLiveActive.value) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  // Tips received
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '💸',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            return Text(
                              '${controller.totalTipsReceived.value.toStringAsFixed(0)}€',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          const Text(
                            'Tips reçus',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Messages
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            return Text(
                              '${controller.messageCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          const Text(
                            'Messages',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildRecentMessages(
    ArtistLiveController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (!controller.isLiveActive.value ||
          controller.recentMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(15),
        decoration: ShapeDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 15, cornerSmoothing: 1),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages récents',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...controller.recentMessages.take(3).map((message) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${message.userName}: ${message.message}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildControls(
    ArtistLiveController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Obx(() {
            if (controller.isLiveActive.value) {
              // Controls pendant le live
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Toggle video
                  _buildControlButton(
                    icon: controller.isVideoMuted.value
                        ? Icons.videocam_off
                        : Icons.videocam,
                    label: 'Caméra',
                    onTap: controller.toggleVideo,
                  ),

                  // Toggle audio
                  _buildControlButton(
                    icon: controller.isAudioMuted.value
                        ? Icons.mic_off
                        : Icons.mic,
                    label: 'Micro',
                    onTap: controller.toggleAudio,
                  ),

                  // Switch camera
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    label: 'Flip',
                    onTap: controller.switchCamera,
                  ),

                  // End live
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Arrêter',
                    color: const Color(0xFFE50914),
                    onTap: () => _showEndLiveDialog(controller),
                  ),
                ],
              );
            } else {
              // Bouton pour démarrer le live
              return SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.startLive,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DÉMARRER LE LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color ?? Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showEndLiveDialog(ArtistLiveController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Terminer le live?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir terminer le concert? Le replay sera automatiquement disponible.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.endLive();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
            ),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}
