import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:vybzzz/common/service/vybzzz/live_streaming_service.dart';
import 'package:vybzzz/common/service/vybzzz/live_chat_service.dart';
import 'package:vybzzz/common/service/vybzzz/tip_service.dart';
import 'package:vybzzz/common/service/vybzzz/vybz_coin_service.dart';
import 'package:vybzzz/model/chat_model/live_chat_message_model.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/model/vybz_coin_model/vybz_coin_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Contrôleur pour l'écran de concert live
class LiveConcertController extends GetxController {
  final LiveStreamingService _streamingService = LiveStreamingService();
  final LiveChatService _chatService = LiveChatService();
  final TipService _tipService = TipService();
  final VybzCoinService _coinService = VybzCoinService();
  final AuthController _authController = Get.find<AuthController>();

  // Event (initialized from Get.arguments)
  late VyBzzZEvent event;

  // 100MS SDK
  late HMSSDK hmsSDK;
  final Rx<HMSPeer?> localPeer = Rx<HMSPeer?>(null);
  final RxList<HMSPeer> remotePeers = <HMSPeer>[].obs;
  final Rx<HMSTrack?> videoTrack = Rx<HMSTrack?>(null);
  final RxBool isVideoMuted = true.obs;

  // État
  final RxBool isLoading = true.obs;
  final RxBool isConnected = false.obs;
  final RxString errorMessage = ''.obs;

  // Chat
  final RxList<LiveChatMessage> messages = <LiveChatMessage>[].obs;
  final TextEditingController chatController = TextEditingController();
  final RxBool isChatVisible = true.obs;

  // Stats
  final RxInt viewerCount = 0.obs;
  final RxInt totalTips = 0.obs; // En Vybz maintenant
  final RxInt totalLikes = 0.obs;

  // User balance
  final RxInt userBalance = 0.obs;

  // UI State
  final RxBool isFullscreen = false.obs;
  final RxList<LikeAnimation> activeHearts = <LikeAnimation>[].obs;

  // Brightness control
  final RxDouble brightness = 0.5.obs;
  final RxBool showBrightnessIndicator = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize event from Get.arguments
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args.containsKey('event') && args['event'] is VyBzzZEvent) {
        event = args['event'] as VyBzzZEvent;
      } else {
        throw Exception('Event parameter is required for LiveConcertScreen');
      }
    } else {
      throw Exception('Arguments are required for LiveConcertScreen');
    }

    _initializeHMS();
    _listenToChat();
    _listenToViewerCount();
    _loadUserBalance();
    _initBrightness();
  }

  // ============================================
  // BRIGHTNESS
  // ============================================

  Future<void> _initBrightness() async {
    try {
      // Récupérer la luminosité actuelle du système
      // final currentBrightness = await ScreenBrightness().current;
      // brightness.value = currentBrightness;
      brightness.value = 0.5; // Valeur par défaut
    } catch (e) {
      Loggers.error('Erreur init brightness: $e');
    }
  }

  Future<void> setBrightness(double value) async {
    try {
      // Limiter entre 0 et 1
      final newBrightness = value.clamp(0.0, 1.0);
      brightness.value = newBrightness;

      // Appliquer au système
      // await ScreenBrightness().setScreenBrightness(newBrightness);

      // Afficher l'indicateur
      showBrightnessIndicator.value = true;

      // Masquer après 1 seconde
      Future.delayed(const Duration(seconds: 1), () {
        showBrightnessIndicator.value = false;
      });
    } catch (e) {
      Loggers.error('Erreur set brightness: $e');
    }
  }

  void handleVerticalDragUpdate(DragUpdateDetails details, double screenHeight) {
    // Swipe vers le haut = augmenter luminosité
    // Swipe vers le bas = diminuer luminosité
    final delta = -details.delta.dy / screenHeight;
    final newBrightness = brightness.value + delta;
    setBrightness(newBrightness);
  }

  // ============================================
  // USER BALANCE
  // ============================================

  Future<void> _loadUserBalance() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final balance = await _coinService.getUserBalance(user.id!);
      userBalance.value = balance;

      // Stream du solde en temps réel
      _coinService.streamUserBalance(user.id!).listen((balance) {
        userBalance.value = balance;
      });
    } catch (e) {
      Loggers.error('Erreur load balance: $e');
    }
  }

  @override
  void onClose() {
    _leaveRoom();
    chatController.dispose();
    super.onClose();
  }

  // ============================================
  // 100MS INITIALIZATION
  // ============================================

  Future<void> _initializeHMS() async {
    try {
      isLoading.value = true;

      // Initialiser le SDK 100MS
      hmsSDK = HMSSDK();
      await hmsSDK.build();

      // Joindre la room
      await _joinRoom();

      isLoading.value = false;
    } catch (e) {
      Loggers.error('Erreur init HMS: $e');
      errorMessage.value = 'Erreur de connexion au live';
      isLoading.value = false;
    }
  }

  Future<void> _joinRoom() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Générer le token d'authentification
      final roomInfo = await _streamingService.getRoomInfo(event.id!);
      if (roomInfo == null) {
        throw Exception('Room introuvable');
      }

      final token = await _streamingService.generateAuthToken(
        roomId: roomInfo['room_id'],
        userId: user.id ?? 0,
        userName: user.fullname ?? 'Anonyme',
        isBroadcaster: false, // Spectateur
      );

      // Configuration HMS
      final config = HMSConfig(
        authToken: token,
        userName: user.fullname ?? 'Anonyme',
      );

      // Joindre la room
      await hmsSDK.join(config: config);

      // Incrémenter le compteur de viewers
      await _streamingService.incrementViewerCount(event.id!);

      // Message système
      await _chatService.sendSystemMessage(
        eventId: event.id!,
        message: '${user.fullname} a rejoint le live 👋',
      );

      isConnected.value = true;
      Loggers.success('Connecté au live!');
    } catch (e) {
      Loggers.error('Erreur join room: $e');
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  Future<void> _leaveRoom() async {
    try {
      await hmsSDK.leave();

      // Décrémenter le compteur
      await _streamingService.decrementViewerCount(event.id!);

      isConnected.value = false;
    } catch (e) {
      Loggers.error('Erreur leave room: $e');
    }
  }

  // ============================================
  // CHAT
  // ============================================

  void _listenToChat() {
    _chatService.streamMessages(event.id!).listen((newMessages) {
      messages.value = newMessages;
    });
  }

  Future<void> sendMessage() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final message = chatController.text.trim();
      if (message.isEmpty) return;

      await _chatService.sendChatMessage(
        eventId: event.id!,
        userId: user.id ?? 0,
        userName: user.fullname ?? 'Anonyme',
        userPhoto: user.profilePhoto,
        message: message,
      );

      chatController.clear();
    } catch (e) {
      Loggers.error('Erreur send message: $e');
      Get.snackbar('Erreur', 'Impossible d\'envoyer le message');
    }
  }

  void toggleChat() {
    isChatVisible.value = !isChatVisible.value;
  }

  // ============================================
  // TIPS
  // ============================================

  Future<void> sendTip(int vybzAmount) async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      // Vérifier le solde
      if (userBalance.value < vybzAmount) {
        Get.snackbar(
          'Solde insuffisant',
          'Vous avez besoin de $vybzAmount Vybz (vous avez ${userBalance.value})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Dépenser les Vybz
      final success = await _coinService.spendVybz(
        userId: user.id!,
        amount: vybzAmount,
        purpose: 'tip_live',
        description: 'Tip pour ${event.artistName}',
      );

      if (!success) {
        throw Exception('Impossible de dépenser les Vybz');
      }

      // Créer le tip dans Firestore (convertir en euros pour l'artiste)
      final amountEur = VybzCoin.vybzToEur(vybzAmount);
      await _tipService.createTip(
        fromUserId: user.id ?? 0,
        fromUserName: user.fullname ?? 'Anonyme',
        fromUserPhoto: user.profilePhoto,
        toArtistId: event.artistId ?? 0,
        toArtistName: event.artistName ?? 'Artiste',
        toArtistPhoto: event.artistPhoto,
        eventId: event.id!,
        eventTitle: event.title ?? 'Concert Live',
        amount: amountEur,
        message: '$vybzAmount Vybz',
      );

      // Envoyer le message de tip dans le chat
      await _chatService.sendTipMessage(
        eventId: event.id!,
        userId: user.id ?? 0,
        userName: user.fullname ?? 'Anonyme',
        userPhoto: user.profilePhoto,
        tipAmount: amountEur, // Afficher en euros dans le chat
      );

      // Mettre à jour le total local
      totalTips.value += vybzAmount;

      // Déterminer l'animation tier
      final tier = VybzAnimationTier.fromAmount(vybzAmount);

      Get.snackbar(
        '${tier.icon} Tip envoyé!',
        'Merci pour votre soutien de $vybzAmount Vybz (${amountEur.toStringAsFixed(2)}€)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFFFD700),
        colorText: Colors.black,
      );
    } catch (e) {
      Loggers.error('Erreur send tip: $e');
      Get.snackbar('Erreur', 'Impossible d\'envoyer le tip');
    }
  }

  void showTipModal() {
    Get.bottomSheet(
      _TipBottomSheet(
        onTipSent: sendTip,
        userBalance: userBalance.value,
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  // ============================================
  // STATS
  // ============================================

  void _listenToViewerCount() {
    _streamingService.streamViewerCount(event.id!).listen((count) {
      viewerCount.value = count;
    });
  }

  // ============================================
  // LIKES / REACTIONS
  // ============================================

  Future<void> sendLike() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      // Incrémenter le compteur local
      totalLikes.value++;

      // Ajouter l'animation de coeur
      activeHearts.add(LikeAnimation());

      // Supprimer après l'animation (3 secondes)
      Future.delayed(const Duration(seconds: 3), () {
        if (activeHearts.isNotEmpty) {
          activeHearts.removeAt(0);
        }
      });

      // Envoyer à Firestore pour synchroniser avec les autres viewers
      await _chatService.sendSystemMessage(
        eventId: event.id!,
        message: '${user.fullname} a aimé ❤️',
      );
    } catch (e) {
      Loggers.error('Erreur send like: $e');
    }
  }

  // ============================================
  // PARTAGE
  // ============================================

  Future<void> shareEvent() async {
    try {
      // Import share_plus package nécessaire
      // await Share.share(
      //   'Rejoins-moi sur le live de ${event.artistName}!\n\n'
      //   '${event.title}\n'
      //   'Sur VyBzzZ - L\'app des concerts live 🎵\n\n'
      //   'Télécharge VyBzzZ: https://vybzzz.com/download',
      //   subject: 'Concert live: ${event.title}',
      // );

      Get.snackbar(
        'Partage',
        'Fonctionnalité de partage disponible prochainement!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Loggers.error('Erreur share: $e');
    }
  }

  // ============================================
  // FULLSCREEN
  // ============================================

  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;

    // Masquer le chat en mode fullscreen
    if (isFullscreen.value) {
      isChatVisible.value = false;
    }
  }

  // ============================================
  // CASTING (Chromecast / AirPlay)
  // ============================================

  Future<void> startCasting() async {
    try {
      // Import flutter_cast package nécessaire
      // CastDevices disponibles via flutter_cast

      Get.snackbar(
        'Casting',
        'Recherche d\'appareils disponibles...\n'
        'Chromecast et AirPlay seront bientôt disponibles!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Loggers.error('Erreur casting: $e');
    }
  }
}

/// Classe pour gérer les animations de likes (coeurs qui montent)
class LikeAnimation {
  final String id;
  final double left;
  final double rotation;
  final Duration duration;

  LikeAnimation()
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        left = 50 + (DateTime.now().millisecondsSinceEpoch % 30).toDouble(),
        rotation = (DateTime.now().millisecondsSinceEpoch % 100 - 50) / 100,
        duration = Duration(milliseconds: 2000 + (DateTime.now().millisecondsSinceEpoch % 1000));
}

/// Modal pour envoyer un tip
class _TipBottomSheet extends StatelessWidget {
  final Function(int) onTipSent;
  final int userBalance;

  const _TipBottomSheet({
    required this.onTipSent,
    required this.userBalance,
  });

  @override
  Widget build(BuildContext context) {
    final tipAmounts = QuickTipAmount.defaults;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                '💸 Envoyer un tip',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Soutenez l\'artiste pendant le live!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 10),

              // User balance
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Votre solde: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                    Text(
                      '$userBalance Vybz',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      ' (≈ ${VybzCoin.vybzToEur(userBalance).toStringAsFixed(2)}€)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tip amounts grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: tipAmounts.map((tipAmount) {
                  final canAfford = userBalance >= tipAmount.vybz;

                  return GestureDetector(
                    onTap: canAfford
                        ? () {
                            Get.back();
                            onTipSent(tipAmount.vybz);
                          }
                        : null,
                    child: Opacity(
                      opacity: canAfford ? 1.0 : 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tipAmount.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tipAmount.vybz}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              'Vybz',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${tipAmount.euros.toStringAsFixed(1)}€',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
