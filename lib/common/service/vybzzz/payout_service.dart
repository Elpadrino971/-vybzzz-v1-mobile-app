import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/payout_model/payout_model.dart';
import 'package:vybzzz/common/enum/subscription_tier_enum.dart';

/// Service pour gérer les paiements aux artistes
///
/// Fournit des méthodes pour :
/// - Créer des paiements programmés (J+14, lundi)
/// - Traiter les paiements
/// - Récupérer l'historique des paiements

class PayoutService {
  static final PayoutService _instance = PayoutService._internal();
  factory PayoutService() => _instance;
  PayoutService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'payouts';

  // ============================================
  // CREATE
  // ============================================

  /// Crée un nouveau payout programmé
  Future<PayoutModel> createPayout({
    required int artistId,
    required String artistName,
    required String artistEmail,
    required SubscriptionTier subscriptionTier,
    required List<String> eventIds,
    required double grossRevenue,
    required DateTime eventDate,
  }) async {
    try {
      final paymentDate = PayoutModel.calculatePaymentDate(eventDate);

      final payout = PayoutModel(
        artistId: artistId,
        artistName: artistName,
        artistEmail: artistEmail,
        subscriptionTier: subscriptionTier,
        eventIds: eventIds,
        eventCount: eventIds.length,
        grossRevenue: grossRevenue,
        eventDate: eventDate,
        paymentDate: paymentDate,
        status: PayoutStatus.pending,
        createdAt: DateTime.now(),
      );

      // Calculer les montants
      payout.calculateAmounts();

      final docRef = await _firestore.collection(_collectionName).add(payout.toJson());
      payout.id = docRef.id;

      return payout;
    } catch (e) {
      throw Exception('Erreur lors de la création du payout: $e');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Récupère un payout par ID
  Future<PayoutModel?> getPayoutById(String payoutId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(payoutId).get();
      if (!doc.exists) return null;
      return PayoutModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du payout: $e');
    }
  }

  /// Récupère tous les payouts d'un artiste
  Future<List<PayoutModel>> getPayoutsByArtist(int artistId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('artist_id', isEqualTo: artistId)
          .orderBy('payment_date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => PayoutModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des payouts: $e');
    }
  }

  /// Récupère les payouts en attente de traitement
  Future<List<PayoutModel>> getPendingPayouts() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: PayoutStatus.pending.value)
          .where('payment_date', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      return querySnapshot.docs.map((doc) => PayoutModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des payouts en attente: $e');
    }
  }

  /// Récupère les payouts complétés d'un artiste
  Future<List<PayoutModel>> getCompletedPayoutsByArtist(int artistId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: PayoutStatus.completed.value)
          .orderBy('completed_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => PayoutModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des payouts complétés: $e');
    }
  }

  /// Stream des payouts d'un artiste
  Stream<List<PayoutModel>> streamArtistPayouts(int artistId) {
    return _firestore
        .collection(_collectionName)
        .where('artist_id', isEqualTo: artistId)
        .orderBy('payment_date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PayoutModel.fromFirestore(doc)).toList());
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Met à jour un payout
  Future<void> updatePayout(PayoutModel payout) async {
    try {
      if (payout.id == null) {
        throw Exception('L\'ID du payout est requis pour la mise à jour');
      }

      await _firestore.collection(_collectionName).doc(payout.id).update(payout.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du payout: $e');
    }
  }

  /// Marque un payout comme en traitement
  Future<void> markAsProcessing(String payoutId) async {
    try {
      await _firestore.collection(_collectionName).doc(payoutId).update({
        'status': PayoutStatus.processing.value,
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage en traitement: $e');
    }
  }

  /// Marque un payout comme complété
  Future<void> markAsCompleted(
    String payoutId,
    String stripeTransferId,
    String stripePayoutId,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(payoutId).update({
        'status': PayoutStatus.completed.value,
        'stripe_transfer_id': stripeTransferId,
        'stripe_payout_id': stripePayoutId,
        'completed_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage comme complété: $e');
    }
  }

  /// Marque un payout comme échoué
  Future<void> markAsFailed(String payoutId, String failureReason) async {
    try {
      await _firestore.collection(_collectionName).doc(payoutId).update({
        'status': PayoutStatus.failed.value,
        'failure_reason': failureReason,
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage comme échoué: $e');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Suppression permanente d'un payout (à utiliser avec précaution)
  Future<void> permanentDeletePayout(String payoutId) async {
    try {
      await _firestore.collection(_collectionName).doc(payoutId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression permanente: $e');
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Calcule le total des gains d'un artiste
  Future<double> getTotalEarnings(int artistId) async {
    try {
      final payouts = await getCompletedPayoutsByArtist(artistId);

      double total = 0;
      for (final payout in payouts) {
        total += payout.finalAmount ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul des gains totaux: $e');
    }
  }

  /// Calcule les gains du mois en cours
  Future<double> getCurrentMonthEarnings(int artistId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: PayoutStatus.completed.value)
          .where('completed_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('completed_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final payouts =
          querySnapshot.docs.map((doc) => PayoutModel.fromFirestore(doc)).toList();

      double total = 0;
      for (final payout in payouts) {
        total += payout.finalAmount ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul des gains du mois: $e');
    }
  }

  /// Récupère le prochain payout programmé pour un artiste
  Future<PayoutModel?> getNextScheduledPayout(int artistId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: PayoutStatus.pending.value)
          .where('payment_date', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('payment_date', descending: false)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return PayoutModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du prochain payout: $e');
    }
  }
}
