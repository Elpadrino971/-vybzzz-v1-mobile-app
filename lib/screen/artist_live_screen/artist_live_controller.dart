import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:vybzzz/common/service/vybzzz/live_streaming_service.dart';
import 'package:vybzzz/common/service/vybzzz/live_chat_service.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/model/chat_model/live_chat_message_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:vybzzz/common/manager/logger.dart';
import 'package:vybzzz/common/service/vybzzz/event_service.dart';

/// Contrôleur pour l'écran de live artiste (broadcaster)
class ArtistLiveController extends GetxController {
  final LiveStreamingService _streamingService = LiveStreamingService();
  final LiveChatService _chatService = LiveChatService();
  final AuthController _authController = Get.find<AuthController>();
  final EventService _eventService = EventService();

  // Event
  late VyBzzZEvent event;

  // 100MS SDK
  late HMSSDK hmsSDK;
  final Rx<HMSPeer?> localPeer = Rx<HMSPeer?>(null);
  final RxList<HMSPeer> remotePeers = <HMSPeer>[].obs;

  // État du live
  final RxBool isLiveActive = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isVideoMuted = false.obs;
  final RxBool isAudioMuted = false.obs;
  final RxBool isCameraFront = true.obs;

  // Stats en temps réel
  final RxInt viewerCount = 0.obs;
  final RxDouble totalTipsReceived = 0.0.obs;
  final RxInt messageCount = 0.obs;
  final RxString liveDuration = '00:00'.obs;

  // Chat messages
  final RxList<LiveChatMessage> recentMessages = <LiveChatMessage>[].obs;

  // Room ID
  String? roomId;

  // Timer pour la durée
  DateTime? liveStartTime;

  @override
  void onInit() {
    super.onInit();
    _initializeHMS();
  }

  @override
  void onClose() {
    if (isLiveActive.value) {
      endLive();
    }
    super.onClose();
  }

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> _initializeHMS() async {
    try {
      // Initialiser le SDK 100MS
      hmsSDK = HMSSDK();
      await hmsSDK.build();

      // Créer la room si elle n'existe pas
      await _createRoom();

      Loggers.success('HMS initialisé');
    } catch (e) {
      Loggers.error('Erreur init HMS: $e');
    }
  }

  Future<void> _createRoom() async {
    try {
      roomId = await _streamingService.createRoom(
        eventId: event.id!,
        eventTitle: event.title ?? 'Concert Live',
      );

      Loggers.success('Room créée: $roomId');
    } catch (e) {
      Loggers.error('Erreur création room: $e');
    }
  }

  // ============================================
  // START/STOP LIVE
  // ============================================

  Future<void> startLive() async {
    try {
      isLoading.value = true;

      final user = _authController.currentUser.value;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (roomId == null) {
        throw Exception('Room non créée');
      }

      // Générer le token broadcaster
      final token = await _streamingService.generateAuthToken(
        roomId: roomId!,
        userId: user.id ?? 0,
        userName: user.fullname ?? 'Artiste',
        isBroadcaster: true,
      );

      // Configuration HMS
      final config = HMSConfig(
        authToken: token,
        userName: user.fullname ?? 'Artiste',
      );

      // Joindre la room en tant que broadcaster
      await hmsSDK.join(config: config);

      // Activer la caméra et le micro
      await hmsSDK.toggleMic();
      await hmsSDK.toggleCamera();

      // Mettre à jour le statut de la room
      await _streamingService.updateRoomStatus(
        eventId: event.id!,
        isActive: true,
      );

      // Démarrer l'enregistrement
      await _streamingService.startRecording(roomId!);

      // Mettre à jour l'état
      isLiveActive.value = true;
      liveStartTime = DateTime.now();

      // Lancer les listeners
      _startListeners();

      // Message système
      await _chatService.sendSystemMessage(
        eventId: event.id!,
        message: '🎉 Le concert a commencé!',
      );

      isLoading.value = false;

      Get.snackbar(
        'Live démarré!',
        'Votre concert est maintenant en direct',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      Loggers.success('Live démarré!');
    } catch (e) {
      isLoading.value = false;
      Loggers.error('Erreur start live: $e');
      Get.snackbar('Erreur', 'Impossible de démarrer le live');
    }
  }

  Future<void> endLive() async {
    try {
      isLoading.value = true;

      if (roomId == null) return;

      // Quitter la room
      await hmsSDK.leave();

      // Arrêter le live et récupérer l'URL du replay
      final replayUrl = await _streamingService.endLive(
        eventId: event.id!,
        roomId: roomId!,
      );

      // Message système
      await _chatService.sendSystemMessage(
        eventId: event.id!,
        message: '🎬 Le concert est terminé. Replay disponible 7 jours!',
      );

      isLiveActive.value = false;
      isLoading.value = false;

      Get.snackbar(
        'Live terminé',
        'Le replay est maintenant disponible pour 7 jours',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      Loggers.success('Live terminé, replay: $replayUrl');

      // Retourner au dashboard
      Get.back();
    } catch (e) {
      isLoading.value = false;
      Loggers.error('Erreur end live: $e');
      Get.snackbar('Erreur', 'Erreur lors de la fin du live');
    }
  }

  // ============================================
  // CONTROLS
  // ============================================

  Future<void> toggleVideo() async {
    try {
      await hmsSDK.toggleCamera();
      isVideoMuted.value = !isVideoMuted.value;
    } catch (e) {
      Loggers.error('Erreur toggle video: $e');
    }
  }

  Future<void> toggleAudio() async {
    try {
      await hmsSDK.toggleMic();
      isAudioMuted.value = !isAudioMuted.value;
    } catch (e) {
      Loggers.error('Erreur toggle audio: $e');
    }
  }

  Future<void> switchCamera() async {
    try {
      await hmsSDK.switchCamera();
      isCameraFront.value = !isCameraFront.value;
    } catch (e) {
      Loggers.error('Erreur switch camera: $e');
    }
  }

  // ============================================
  // LISTENERS
  // ============================================

  void _startListeners() {
    // Écouter le nombre de viewers
    _streamingService.streamViewerCount(event.id!).listen((count) {
      viewerCount.value = count;
    });

    // Écouter les derniers messages du chat
    _chatService.streamMessages(event.id!).listen((messages) {
      // Garder seulement les 5 derniers
      if (messages.length > 5) {
        recentMessages.value = messages.sublist(messages.length - 5);
      } else {
        recentMessages.value = messages;
      }

      messageCount.value = messages.length;

      // Calculer le total des tips
      totalTipsReceived.value = messages
          .where((msg) => msg.type == MessageType.tip)
          .fold(0.0, (sum, msg) => sum + (msg.tipAmount ?? 0));
    });

    // Mettre à jour la durée toutes les secondes
    _updateDuration();
  }

  void _updateDuration() {
    if (!isLiveActive.value || liveStartTime == null) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (isLiveActive.value && liveStartTime != null) {
        final duration = DateTime.now().difference(liveStartTime!);
        final hours = duration.inHours.toString().padLeft(2, '0');
        final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

        if (duration.inHours > 0) {
          liveDuration.value = '$hours:$minutes:$seconds';
        } else {
          liveDuration.value = '$minutes:$seconds';
        }

        _updateDuration(); // Récursif
      }
    });
  }
}
