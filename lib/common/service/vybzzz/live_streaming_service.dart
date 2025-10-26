import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Service de gestion du live streaming avec 100MS
///
/// Gère:
/// - Création et gestion des rooms 100MS
/// - Génération de tokens d'authentification
/// - Configuration des rôles (broadcaster, viewer)
/// - Recording et replay

class LiveStreamingService {
  static final LiveStreamingService _instance = LiveStreamingService._internal();
  factory LiveStreamingService() => _instance;
  LiveStreamingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 100MS Configuration
  // TODO: Remplacer par vos vraies credentials 100MS
  static const String _templateId = 'YOUR_TEMPLATE_ID';
  static const String _managementToken = 'YOUR_MANAGEMENT_TOKEN';

  // ============================================
  // ROOM MANAGEMENT
  // ============================================

  /// Crée une room 100MS pour un événement
  Future<String> createRoom({
    required String eventId,
    required String eventTitle,
  }) async {
    try {
      // Dans un vrai environnement, vous feriez un appel API à 100MS
      // Pour l'instant, on simule avec un roomId
      final roomId = 'room_${eventId}_${DateTime.now().millisecondsSinceEpoch}';

      // Sauvegarder les infos de la room dans Firestore
      await _firestore.collection('live_rooms').doc(eventId).set({
        'room_id': roomId,
        'event_id': eventId,
        'event_title': eventTitle,
        'created_at': FieldValue.serverTimestamp(),
        'is_active': false,
        'viewer_count': 0,
      });

      Loggers.success('Room créée: $roomId');
      return roomId;
    } catch (e) {
      Loggers.error('Erreur création room: $e');
      throw Exception('Erreur lors de la création de la room: $e');
    }
  }

  /// Génère un token d'authentification pour rejoindre une room
  ///
  /// Dans un vrai environnement, ceci devrait être fait côté serveur
  /// pour des raisons de sécurité
  Future<String> generateAuthToken({
    required String roomId,
    required int userId,
    required String userName,
    required bool isBroadcaster,
  }) async {
    try {
      // En production, vous devez appeler votre backend qui appelle l'API 100MS
      // Exemple: POST https://api.100ms.live/v2/auth-tokens

      // Pour la démo, on retourne un token simulé
      final role = isBroadcaster ? 'broadcaster' : 'viewer';
      final token = 'mock_token_${roomId}_${userId}_$role';

      Loggers.success('Token généré pour $userName ($role)');
      return token;
    } catch (e) {
      Loggers.error('Erreur génération token: $e');
      throw Exception('Erreur lors de la génération du token: $e');
    }
  }

  /// Met à jour le statut de la room (active/inactive)
  Future<void> updateRoomStatus({
    required String eventId,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection('live_rooms').doc(eventId).update({
        'is_active': isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (isActive) {
        // Mettre à jour le statut de l'événement
        await _firestore.collection('events').doc(eventId).update({
          'status': 'live',
          'live_started_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Loggers.error('Erreur update room status: $e');
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Incrémente le compteur de viewers
  Future<void> incrementViewerCount(String eventId) async {
    try {
      await _firestore.collection('live_rooms').doc(eventId).update({
        'viewer_count': FieldValue.increment(1),
      });
    } catch (e) {
      Loggers.error('Erreur increment viewer: $e');
    }
  }

  /// Décrémente le compteur de viewers
  Future<void> decrementViewerCount(String eventId) async {
    try {
      await _firestore.collection('live_rooms').doc(eventId).update({
        'viewer_count': FieldValue.increment(-1),
      });
    } catch (e) {
      Loggers.error('Erreur decrement viewer: $e');
    }
  }

  /// Stream du nombre de viewers
  Stream<int> streamViewerCount(String eventId) {
    return _firestore
        .collection('live_rooms')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data();
      return data?['viewer_count'] ?? 0;
    });
  }

  // ============================================
  // RECORDING
  // ============================================

  /// Démarre l'enregistrement du stream
  Future<void> startRecording(String roomId) async {
    try {
      // En production, appeler l'API 100MS pour démarrer le recording
      // POST https://api.100ms.live/v2/recordings/room/{room_id}/start

      Loggers.success('Recording démarré pour room: $roomId');
    } catch (e) {
      Loggers.error('Erreur start recording: $e');
      throw Exception('Erreur lors du démarrage du recording: $e');
    }
  }

  /// Arrête l'enregistrement et récupère l'URL
  Future<String> stopRecording(String roomId) async {
    try {
      // En production, appeler l'API 100MS pour arrêter le recording
      // POST https://api.100ms.live/v2/recordings/room/{room_id}/stop

      // URL du replay (mockée pour la démo)
      final replayUrl = 'https://vybzzz-replays.s3.amazonaws.com/$roomId.m3u8';

      Loggers.success('Recording arrêté, URL: $replayUrl');
      return replayUrl;
    } catch (e) {
      Loggers.error('Erreur stop recording: $e');
      throw Exception('Erreur lors de l\'arrêt du recording: $e');
    }
  }

  // ============================================
  // END LIVE
  // ============================================

  /// Termine le live et sauvegarde le replay
  Future<String> endLive({
    required String eventId,
    required String roomId,
  }) async {
    try {
      // Arrêter le recording
      final replayUrl = await stopRecording(roomId);

      // Mettre à jour la room
      await updateRoomStatus(eventId: eventId, isActive: false);

      // Mettre à jour l'événement avec le replay
      await _firestore.collection('events').doc(eventId).update({
        'status': 'ended',
        'live_ended_at': FieldValue.serverTimestamp(),
        'replay_url': replayUrl,
        'replay_available': true,
        'replay_expires_at': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
      });

      return replayUrl;
    } catch (e) {
      Loggers.error('Erreur end live: $e');
      throw Exception('Erreur lors de la fin du live: $e');
    }
  }

  // ============================================
  // ROOM INFO
  // ============================================

  /// Récupère les informations d'une room
  Future<Map<String, dynamic>?> getRoomInfo(String eventId) async {
    try {
      final doc = await _firestore.collection('live_rooms').doc(eventId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      Loggers.error('Erreur get room info: $e');
      return null;
    }
  }

  /// Vérifie si une room est active
  Future<bool> isRoomActive(String eventId) async {
    try {
      final roomInfo = await getRoomInfo(eventId);
      return roomInfo?['is_active'] ?? false;
    } catch (e) {
      Loggers.error('Erreur check room active: $e');
      return false;
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  /// Nettoie les rooms inactives (à appeler périodiquement)
  Future<void> cleanupInactiveRooms() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

      final querySnapshot = await _firestore
          .collection('live_rooms')
          .where('is_active', isEqualTo: false)
          .where('created_at', isLessThan: Timestamp.fromDate(cutoffTime))
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      Loggers.success('Cleanup: ${querySnapshot.docs.length} rooms supprimées');
    } catch (e) {
      Loggers.error('Erreur cleanup rooms: $e');
    }
  }
}
