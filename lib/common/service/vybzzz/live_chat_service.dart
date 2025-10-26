import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/chat_model/live_chat_message_model.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Service de gestion du chat live
///
/// Permet:
/// - Envoyer des messages de chat
/// - Envoyer des tips avec message
/// - Stream des messages en temps réel
/// - Modération basique

class LiveChatService {
  static final LiveChatService _instance = LiveChatService._internal();
  factory LiveChatService() => _instance;
  LiveChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // SEND MESSAGES
  // ============================================

  /// Envoie un message de chat
  Future<String> sendChatMessage({
    required String eventId,
    required int userId,
    required String userName,
    String? userPhoto,
    required String message,
  }) async {
    try {
      // Validation
      if (message.trim().isEmpty) {
        throw Exception('Le message ne peut pas être vide');
      }

      if (message.length > 500) {
        throw Exception('Le message est trop long (max 500 caractères)');
      }

      // Créer le message
      final chatMessage = LiveChatMessage.chat(
        eventId: eventId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        message: message.trim(),
      );

      // Sauvegarder dans Firestore
      final docRef = await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .add(chatMessage.toJson());

      Loggers.success('Message envoyé: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      Loggers.error('Erreur envoi message: $e');
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  /// Envoie un message de tip
  Future<String> sendTipMessage({
    required String eventId,
    required int userId,
    required String userName,
    String? userPhoto,
    required double tipAmount,
  }) async {
    try {
      // Validation
      if (tipAmount <= 0) {
        throw Exception('Le montant du tip doit être positif');
      }

      // Créer le message de tip
      final tipMessage = LiveChatMessage.tip(
        eventId: eventId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        tipAmount: tipAmount,
      );

      // Sauvegarder dans Firestore
      final docRef = await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .add(tipMessage.toJson());

      Loggers.success('Tip envoyé: ${tipAmount}€');
      return docRef.id;
    } catch (e) {
      Loggers.error('Erreur envoi tip: $e');
      throw Exception('Erreur lors de l\'envoi du tip: $e');
    }
  }

  /// Envoie un message système
  Future<String> sendSystemMessage({
    required String eventId,
    required String message,
  }) async {
    try {
      final systemMessage = LiveChatMessage.system(
        eventId: eventId,
        message: message,
      );

      final docRef = await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .add(systemMessage.toJson());

      return docRef.id;
    } catch (e) {
      Loggers.error('Erreur envoi system message: $e');
      throw Exception('Erreur lors de l\'envoi du message système: $e');
    }
  }

  // ============================================
  // STREAM MESSAGES
  // ============================================

  /// Stream des messages du chat en temps réel
  Stream<List<LiveChatMessage>> streamMessages(String eventId) {
    return _firestore
        .collection('live_chats')
        .doc(eventId)
        .collection('messages')
        .orderBy('sent_at', descending: false)
        .limit(100) // Limiter aux 100 derniers messages
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LiveChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Récupère les derniers messages
  Future<List<LiveChatMessage>> getRecentMessages({
    required String eventId,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .orderBy('sent_at', descending: true)
          .limit(limit)
          .get();

      final messages = querySnapshot.docs
          .map((doc) => LiveChatMessage.fromFirestore(doc))
          .toList();

      // Inverser pour avoir les plus anciens en premier
      return messages.reversed.toList();
    } catch (e) {
      Loggers.error('Erreur récupération messages: $e');
      return [];
    }
  }

  // ============================================
  // MODERATION
  // ============================================

  /// Supprime un message
  Future<void> deleteMessage({
    required String eventId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .doc(messageId)
          .delete();

      Loggers.success('Message supprimé: $messageId');
    } catch (e) {
      Loggers.error('Erreur suppression message: $e');
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }

  /// Compte le nombre de messages
  Future<int> getMessageCount(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      Loggers.error('Erreur count messages: $e');
      return 0;
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  /// Nettoie les messages d'un événement terminé
  Future<void> cleanupEventMessages(String eventId) async {
    try {
      final batch = _firestore.batch();

      final querySnapshot = await _firestore
          .collection('live_chats')
          .doc(eventId)
          .collection('messages')
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Loggers.success('Cleanup: ${querySnapshot.docs.length} messages supprimés');
    } catch (e) {
      Loggers.error('Erreur cleanup messages: $e');
    }
  }
}
