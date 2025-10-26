import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:vybzzz/common/service/vybzzz/live_streaming_service.dart';
import 'package:vybzzz/common/service/vybzzz/live_chat_service.dart';
import 'package:vybzzz/common/service/vybzzz/tip_service.dart';
import 'package:vybzzz/model/chat_model/live_chat_message_model.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Contrôleur pour l'écran de concert live
class LiveConcertController extends GetxController {
  final LiveStreamingService _streamingService = LiveStreamingService();
  final LiveChatService _chatService = LiveChatService();
  final TipService _tipService = TipService();
  final AuthController _authController = Get.find<AuthController>();

  // Event
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
  final RxDouble totalTips = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeHMS();
    _listenToChat();
    _listenToViewerCount();
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

  Future<void> sendTip(double amount) async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      // Créer le tip dans Firestore
      await _tipService.createTip(
        eventId: event.id!,
        fromUserId: user.id ?? 0,
        toUserId: event.artistId ?? 0,
        amount: amount,
        message: null,
      );

      // Envoyer le message de tip dans le chat
      await _chatService.sendTipMessage(
        eventId: event.id!,
        userId: user.id ?? 0,
        userName: user.fullname ?? 'Anonyme',
        userPhoto: user.profilePhoto,
        tipAmount: amount,
      );

      // Mettre à jour le total local
      totalTips.value += amount;

      Get.snackbar(
        'Tip envoyé!',
        'Merci pour votre soutien de ${amount.toStringAsFixed(2)}€',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Loggers.error('Erreur send tip: $e');
      Get.snackbar('Erreur', 'Impossible d\'envoyer le tip');
    }
  }

  void showTipModal() {
    Get.bottomSheet(
      _TipBottomSheet(onTipSent: sendTip),
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
}

/// Modal pour envoyer un tip
class _TipBottomSheet extends StatelessWidget {
  final Function(double) onTipSent;

  const _TipBottomSheet({required this.onTipSent});

  @override
  Widget build(BuildContext context) {
    final tipAmounts = [1.0, 5.0, 10.0, 20.0, 50.0, 100.0];

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

              const SizedBox(height: 30),

              // Tip amounts grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: tipAmounts.map((amount) {
                  return GestureDetector(
                    onTap: () {
                      Get.back();
                      onTipSent(amount);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '${amount.toStringAsFixed(0)}€',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
