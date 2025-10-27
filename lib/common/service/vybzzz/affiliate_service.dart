import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/affiliate_model/affiliate_model.dart';

/// Service pour gérer le système d'affiliation VyBzzZ
///
/// Système multi-niveaux:
/// - Niveau 1: 2.5% (référés directs)
/// - Niveau 2: 1.5% (référés de vos référés)
/// - Niveau 3: 1.0% (niveau 3 de profondeur)

class AffiliateService {
  static final AffiliateService _instance = AffiliateService._internal();
  factory AffiliateService() => _instance;
  AffiliateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _affiliatesCollection = 'affiliates';
  final String _commissionsCollection = 'commissions';

  // ============================================
  // AFFILIATES - CREATE
  // ============================================

  /// Crée une nouvelle affiliation
  Future<AffiliateModel> createAffiliate({
    required int businessBringerId,
    required String businessBringerName,
    required int referredUserId,
    required String referredUserName,
    required String referredUserType,
    required AffiliateLevel level,
  }) async {
    try {
      final affiliate = AffiliateModel(
        businessBringerId: businessBringerId,
        businessBringerName: businessBringerName,
        referredUserId: referredUserId,
        referredUserName: referredUserName,
        referredUserType: referredUserType,
        level: level,
        totalCommissionEarned: 0,
        totalTransactions: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef =
          await _firestore.collection(_affiliatesCollection).add(affiliate.toJson());
      affiliate.id = docRef.id;

      return affiliate;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'affiliation: $e');
    }
  }

  // ============================================
  // AFFILIATES - READ
  // ============================================

  /// Récupère une affiliation par ID
  Future<AffiliateModel?> getAffiliateById(String affiliateId) async {
    try {
      final doc =
          await _firestore.collection(_affiliatesCollection).doc(affiliateId).get();
      if (!doc.exists) return null;
      return AffiliateModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'affiliation: $e');
    }
  }

  /// Récupère toutes les affiliations d'un apporteur d'affaire
  Future<List<AffiliateModel>> getAffiliatesByBusinessBringer(
      int businessBringerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_affiliatesCollection)
          .where('business_bringer_id', isEqualTo: businessBringerId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => AffiliateModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des affiliations: $e');
    }
  }

  /// Récupère l'affiliation d'un utilisateur référé
  Future<AffiliateModel?> getAffiliateByReferredUser(int referredUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_affiliatesCollection)
          .where('referred_user_id', isEqualTo: referredUserId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return AffiliateModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'affiliation: $e');
    }
  }

  /// Stream des affiliations d'un apporteur d'affaire
  Stream<List<AffiliateModel>> streamBusinessBringerAffiliates(int businessBringerId) {
    return _firestore
        .collection(_affiliatesCollection)
        .where('business_bringer_id', isEqualTo: businessBringerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AffiliateModel.fromFirestore(doc)).toList());
  }

  // ============================================
  // AFFILIATES - UPDATE
  // ============================================

  /// Met à jour une affiliation
  Future<void> updateAffiliate(AffiliateModel affiliate) async {
    try {
      if (affiliate.id == null) {
        throw Exception('L\'ID de l\'affiliation est requis pour la mise à jour');
      }

      await _firestore
          .collection(_affiliatesCollection)
          .doc(affiliate.id)
          .update(affiliate.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'affiliation: $e');
    }
  }

  /// Ajoute une commission à une affiliation
  Future<void> addCommissionToAffiliate(String affiliateId, double amount) async {
    try {
      final affiliate = await getAffiliateById(affiliateId);
      if (affiliate == null) {
        throw Exception('Affiliation introuvable');
      }

      affiliate.addCommission(amount);
      await updateAffiliate(affiliate);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la commission: $e');
    }
  }

  // ============================================
  // COMMISSIONS - CREATE
  // ============================================

  /// Crée une nouvelle commission
  Future<CommissionModel> createCommission({
    required String affiliateId,
    required int businessBringerId,
    required int referredUserId,
    required String transactionId,
    required String eventId,
    required String ticketId,
    required double transactionAmount,
    required AffiliateLevel level,
  }) async {
    try {
      final commissionAmount = level.calculateCommission(transactionAmount);

      final commission = CommissionModel(
        affiliateId: affiliateId,
        businessBringerId: businessBringerId,
        referredUserId: referredUserId,
        transactionId: transactionId,
        eventId: eventId,
        ticketId: ticketId,
        transactionAmount: transactionAmount,
        commissionAmount: commissionAmount,
        level: level,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final docRef =
          await _firestore.collection(_commissionsCollection).add(commission.toJson());
      commission.id = docRef.id;

      // Mettre à jour l'affiliation
      await addCommissionToAffiliate(affiliateId, commissionAmount);

      return commission;
    } catch (e) {
      throw Exception('Erreur lors de la création de la commission: $e');
    }
  }

  // ============================================
  // COMMISSIONS - READ
  // ============================================

  /// Récupère une commission par ID
  Future<CommissionModel?> getCommissionById(String commissionId) async {
    try {
      final doc =
          await _firestore.collection(_commissionsCollection).doc(commissionId).get();
      if (!doc.exists) return null;
      return CommissionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la commission: $e');
    }
  }

  /// Récupère toutes les commissions d'un apporteur d'affaire
  Future<List<CommissionModel>> getCommissionsByBusinessBringer(
      int businessBringerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_commissionsCollection)
          .where('business_bringer_id', isEqualTo: businessBringerId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CommissionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commissions: $e');
    }
  }

  /// Stream des commissions d'un apporteur d'affaire
  Stream<List<CommissionModel>> streamBusinessBringerCommissions(int businessBringerId) {
    return _firestore
        .collection(_commissionsCollection)
        .where('business_bringer_id', isEqualTo: businessBringerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CommissionModel.fromFirestore(doc)).toList());
  }

  // ============================================
  // COMMISSIONS - UPDATE
  // ============================================

  /// Met à jour une commission
  Future<void> updateCommission(CommissionModel commission) async {
    try {
      if (commission.id == null) {
        throw Exception('L\'ID de la commission est requis pour la mise à jour');
      }

      await _firestore
          .collection(_commissionsCollection)
          .doc(commission.id)
          .update(commission.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la commission: $e');
    }
  }

  /// Marque une commission comme payée
  Future<void> markCommissionAsPaid(String commissionId) async {
    try {
      await _firestore.collection(_commissionsCollection).doc(commissionId).update({
        'status': 'paid',
        'paid_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage de la commission: $e');
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Calcule le total des commissions gagnées
  Future<double> getTotalCommissionsEarned(int businessBringerId) async {
    try {
      final affiliates = await getAffiliatesByBusinessBringer(businessBringerId);

      double total = 0;
      for (final affiliate in affiliates) {
        total += affiliate.totalCommissionEarned ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul des commissions totales: $e');
    }
  }

  /// Calcule les commissions du mois en cours
  Future<double> getCurrentMonthCommissions(int businessBringerId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final querySnapshot = await _firestore
          .collection(_commissionsCollection)
          .where('business_bringer_id', isEqualTo: businessBringerId)
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final commissions =
          querySnapshot.docs.map((doc) => CommissionModel.fromFirestore(doc)).toList();

      double total = 0;
      for (final commission in commissions) {
        total += commission.commissionAmount ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul des commissions du mois: $e');
    }
  }

  /// Compte le nombre total de référés
  Future<int> getTotalReferrals(int businessBringerId) async {
    try {
      final affiliates = await getAffiliatesByBusinessBringer(businessBringerId);
      return affiliates.length;
    } catch (e) {
      throw Exception('Erreur lors du comptage des référés: $e');
    }
  }
}
