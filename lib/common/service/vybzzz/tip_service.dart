import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/tip_model/tip_model.dart';

/// Service pour gérer les pourboires VyBzzZ
///
/// Permet aux spectateurs d'envoyer des pourboires aux artistes
/// pendant les concerts live

class TipService {
  static final TipService _instance = TipService._internal();
  factory TipService() => _instance;
  TipService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tips';

  // ============================================
  // CREATE
  // ============================================

  /// Crée un nouveau pourboire
  Future<TipModel> createTip({
    required int fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required int toArtistId,
    required String toArtistName,
    String? toArtistPhoto,
    required String eventId,
    required String eventTitle,
    required double amount,
    String? message,
  }) async {
    try {
      final tip = TipModel(
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserPhoto: fromUserPhoto,
        toArtistId: toArtistId,
        toArtistName: toArtistName,
        toArtistPhoto: toArtistPhoto,
        eventId: eventId,
        eventTitle: eventTitle,
        amount: amount,
        message: message,
        status: TipStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection(_collectionName).add(tip.toJson());
      tip.id = docRef.id;

      return tip;
    } catch (e) {
      throw Exception('Erreur lors de la création du pourboire: $e');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Récupère un pourboire par ID
  Future<TipModel?> getTipById(String tipId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(tipId).get();
      if (!doc.exists) return null;
      return TipModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du pourboire: $e');
    }
  }

  /// Récupère tous les pourboires envoyés par un utilisateur
  Future<List<TipModel>> getTipsSentByUser(int userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('from_user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pourboires envoyés: $e');
    }
  }

  /// Récupère tous les pourboires reçus par un artiste
  Future<List<TipModel>> getTipsReceivedByArtist(int artistId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('to_artist_id', isEqualTo: artistId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pourboires reçus: $e');
    }
  }

  /// Récupère tous les pourboires d'un événement
  Future<List<TipModel>> getTipsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('event_id', isEqualTo: eventId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pourboires: $e');
    }
  }

  /// Stream des pourboires d'un événement (temps réel)
  Stream<List<TipModel>> streamEventTips(String eventId) {
    return _firestore
        .collection(_collectionName)
        .where('event_id', isEqualTo: eventId)
        .where('status', isEqualTo: TipStatus.completed.value)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList());
  }

  /// Stream des pourboires reçus par un artiste
  Stream<List<TipModel>> streamArtistTips(int artistId) {
    return _firestore
        .collection(_collectionName)
        .where('to_artist_id', isEqualTo: artistId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList());
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Met à jour un pourboire
  Future<void> updateTip(TipModel tip) async {
    try {
      if (tip.id == null) {
        throw Exception('L\'ID du pourboire est requis pour la mise à jour');
      }

      await _firestore.collection(_collectionName).doc(tip.id).update(tip.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du pourboire: $e');
    }
  }

  /// Marque un pourboire comme complété
  Future<void> markAsCompleted(
    String tipId,
    String paymentIntentId,
    String transactionId,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(tipId).update({
        'status': TipStatus.completed.value,
        'stripe_payment_intent_id': paymentIntentId,
        'stripe_transaction_id': transactionId,
        'completed_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage comme complété: $e');
    }
  }

  /// Marque un pourboire comme échoué
  Future<void> markAsFailed(String tipId, String failureReason) async {
    try {
      await _firestore.collection(_collectionName).doc(tipId).update({
        'status': TipStatus.failed.value,
        'failure_reason': failureReason,
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage comme échoué: $e');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Suppression permanente d'un pourboire (à utiliser avec précaution)
  Future<void> permanentDeleteTip(String tipId) async {
    try {
      await _firestore.collection(_collectionName).doc(tipId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression permanente: $e');
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Calcule le total des pourboires reçus par un artiste
  Future<double> getTotalTipsReceived(int artistId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('to_artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: TipStatus.completed.value)
          .get();

      final tips =
          querySnapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();

      double total = 0;
      for (final tip in tips) {
        total += tip.amount ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul des pourboires totaux: $e');
    }
  }

  /// Calcule les pourboires du mois en cours
  Future<double> getCurrentMonthTips(int artistId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('to_artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: TipStatus.completed.value)
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final tips =
          querySnapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();

      double total = 0;
      for (final tip in tips) {
        total += tip.amount ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul des pourboires du mois: $e');
    }
  }

  /// Récupère les meilleurs donateurs pour un artiste
  Future<Map<String, dynamic>> getTopTippers(int artistId, {int limit = 10}) async {
    try {
      final tips = await getTipsReceivedByArtist(artistId);

      // Grouper par utilisateur
      final userTips = <int, List<TipModel>>{};
      for (final tip in tips) {
        if (tip.status == TipStatus.completed && tip.fromUserId != null) {
          userTips.putIfAbsent(tip.fromUserId!, () => []).add(tip);
        }
      }

      // Calculer les totaux
      final userTotals = <Map<String, dynamic>>[];
      for (final entry in userTips.entries) {
        double total = 0;
        for (final tip in entry.value) {
          total += tip.amount ?? 0;
        }

        userTotals.add({
          'user_id': entry.key,
          'user_name': entry.value.first.fromUserName,
          'user_photo': entry.value.first.fromUserPhoto,
          'total_amount': total,
          'tip_count': entry.value.length,
        });
      }

      // Trier par montant total
      userTotals.sort((a, b) => (b['total_amount'] as double).compareTo(a['total_amount'] as double));

      return {
        'top_tippers': userTotals.take(limit).toList(),
        'total_tippers': userTotals.length,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des meilleurs donateurs: $e');
    }
  }

  /// Récupère les derniers pourboires avec messages
  Future<List<TipModel>> getRecentTipsWithMessages(int artistId, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('to_artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: TipStatus.completed.value)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      final tips =
          querySnapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();

      // Filtrer ceux qui ont des messages
      return tips.where((tip) => tip.message != null && tip.message!.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pourboires avec messages: $e');
    }
  }
}
