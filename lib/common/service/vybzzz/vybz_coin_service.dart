import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/vybz_coin_model/vybz_coin_model.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Service de gestion de la monnaie virtuelle VyBzzZ
///
/// Fonctionnalités:
/// - Gestion du solde utilisateur
/// - Achat de packs Vybz
/// - Dépense de Vybz (tips, etc.)
/// - Historique des transactions

class VybzCoinService {
  static final VybzCoinService _instance = VybzCoinService._internal();
  factory VybzCoinService() => _instance;
  VybzCoinService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // BALANCE (Solde)
  // ============================================

  /// Récupère le solde en Vybz d'un utilisateur
  Future<int> getUserBalance(int userId) async {
    try {
      final doc = await _firestore
          .collection('user_balances')
          .doc(userId.toString())
          .get();

      if (!doc.exists) {
        // Créer le document avec solde 0
        await _firestore
            .collection('user_balances')
            .doc(userId.toString())
            .set({
          'user_id': userId,
          'vybz_balance': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        return 0;
      }

      final data = doc.data();
      return data?['vybz_balance'] as int? ?? 0;
    } catch (e) {
      Loggers.error('Erreur get balance: $e');
      return 0;
    }
  }

  /// Stream du solde en temps réel
  Stream<int> streamUserBalance(int userId) {
    return _firestore
        .collection('user_balances')
        .doc(userId.toString())
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data();
      return data?['vybz_balance'] as int? ?? 0;
    });
  }

  /// Ajoute des Vybz au solde
  Future<void> addVybz({
    required int userId,
    required int amount,
    required String source,
    String? description,
  }) async {
    try {
      // Update balance
      await _firestore
          .collection('user_balances')
          .doc(userId.toString())
          .set({
        'user_id': userId,
        'vybz_balance': FieldValue.increment(amount),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Create transaction record
      await _createTransaction(
        userId: userId,
        amount: amount,
        type: 'credit',
        source: source,
        description: description,
      );

      Loggers.success('$amount Vybz ajoutés à user $userId');
    } catch (e) {
      Loggers.error('Erreur add vybz: $e');
      throw Exception('Erreur lors de l\'ajout de Vybz: $e');
    }
  }

  /// Retire des Vybz du solde
  Future<bool> spendVybz({
    required int userId,
    required int amount,
    required String purpose,
    String? description,
  }) async {
    try {
      // Vérifier le solde
      final currentBalance = await getUserBalance(userId);
      if (currentBalance < amount) {
        Loggers.warning('Solde insuffisant: $currentBalance < $amount');
        return false;
      }

      // Update balance
      await _firestore
          .collection('user_balances')
          .doc(userId.toString())
          .update({
        'vybz_balance': FieldValue.increment(-amount),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      await _createTransaction(
        userId: userId,
        amount: -amount,
        type: 'debit',
        source: purpose,
        description: description,
      );

      Loggers.success('$amount Vybz dépensés par user $userId');
      return true;
    } catch (e) {
      Loggers.error('Erreur spend vybz: $e');
      throw Exception('Erreur lors de la dépense de Vybz: $e');
    }
  }

  // ============================================
  // PURCHASE (Achat de packs)
  // ============================================

  /// Achète un pack de Vybz
  ///
  /// Nécessite un paiement Stripe réussi au préalable
  Future<bool> purchasePack({
    required int userId,
    required VybzCoinPack pack,
    required String stripePaymentIntentId,
  }) async {
    try {
      // Vérifier que le payment intent est valide
      // (Dans un vrai environnement, vérifier avec Stripe)

      // Ajouter les Vybz au solde
      await addVybz(
        userId: userId,
        amount: pack.totalVybz,
        source: 'purchase',
        description: 'Pack ${pack.name} acheté',
      );

      // Enregistrer l'achat
      await _firestore.collection('vybz_purchases').add({
        'user_id': userId,
        'pack_id': pack.id,
        'pack_name': pack.name,
        'vybz_amount': pack.vybzAmount,
        'bonus_vybz': pack.bonusVybz,
        'total_vybz': pack.totalVybz,
        'price_eur': pack.priceEur,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'purchased_at': FieldValue.serverTimestamp(),
      });

      Loggers.success(
          'Pack ${pack.name} acheté: ${pack.totalVybz} Vybz pour ${pack.priceEur}€');
      return true;
    } catch (e) {
      Loggers.error('Erreur purchase pack: $e');
      return false;
    }
  }

  // ============================================
  // TRANSACTIONS
  // ============================================

  Future<void> _createTransaction({
    required int userId,
    required int amount,
    required String type,
    required String source,
    String? description,
  }) async {
    await _firestore.collection('vybz_transactions').add({
      'user_id': userId,
      'amount': amount,
      'type': type, // 'credit' or 'debit'
      'source': source,
      'description': description,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère l'historique des transactions
  Future<List<Map<String, dynamic>>> getUserTransactions(
    int userId, {
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('vybz_transactions')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Loggers.error('Erreur get transactions: $e');
      return [];
    }
  }

  // ============================================
  // STATS
  // ============================================

  /// Total Vybz dépensés par un utilisateur
  Future<int> getTotalSpent(int userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('vybz_transactions')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: 'debit')
          .get();

      int total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as int?)?.abs() ?? 0;
      }

      return total;
    } catch (e) {
      Loggers.error('Erreur get total spent: $e');
      return 0;
    }
  }

  /// Total Vybz achetés par un utilisateur
  Future<double> getTotalPurchased(int userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('vybz_purchases')
          .where('user_id', isEqualTo: userId)
          .get();

      double totalEur = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalEur += (data['price_eur'] as num?)?.toDouble() ?? 0;
      }

      return totalEur;
    } catch (e) {
      Loggers.error('Erreur get total purchased: $e');
      return 0;
    }
  }

  // ============================================
  // GIFT / REFUND
  // ============================================

  /// Offre des Vybz à un utilisateur (admin only)
  Future<void> giftVybz({
    required int userId,
    required int amount,
    String? reason,
  }) async {
    await addVybz(
      userId: userId,
      amount: amount,
      source: 'gift',
      description: reason ?? 'Cadeau VyBzzZ',
    );
  }

  /// Rembourse des Vybz
  Future<void> refundVybz({
    required int userId,
    required int amount,
    String? reason,
  }) async {
    await addVybz(
      userId: userId,
      amount: amount,
      source: 'refund',
      description: reason ?? 'Remboursement',
    );
  }
}
