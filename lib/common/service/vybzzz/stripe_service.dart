import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:vybzzz/model/user_model/user_vybzzz_extension.dart';
import 'package:vybzzz/model/user_model/user_model.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Service de gestion Stripe Connect et paiements
///
/// Fonctionnalités:
/// - Onboarding artistes (Stripe Connect)
/// - Payment Intent pour achats billets
/// - Transferts automatiques J+14
/// - Gestion des commissions par tier

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stripe API Keys (à configurer via environnement)
  // TODO: Remplacer par vos vraies clés Stripe
  static const String _publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY';
  static const String _secretKey = 'sk_test_YOUR_SECRET_KEY';

  /// Initialise Stripe SDK
  Future<void> initialize() async {
    try {
      Stripe.publishableKey = _publishableKey;
      Stripe.merchantIdentifier = 'merchant.com.vybzzz';
      await Stripe.instance.applySettings();

      Loggers.success('Stripe initialisé');
    } catch (e) {
      Loggers.error('Erreur init Stripe: $e');
      throw Exception('Erreur lors de l\'initialisation de Stripe: $e');
    }
  }

  // ============================================
  // STRIPE CONNECT - ARTIST ONBOARDING
  // ============================================

  /// Crée un compte Stripe Connect pour un artiste
  ///
  /// En production, cette fonction doit être appelée côté backend
  /// car elle nécessite la clé secrète Stripe
  Future<String> createConnectAccount({
    required int userId,
    required String email,
    required String fullname,
    required String country, // 'FR' par défaut
  }) async {
    try {
      // En production, appeler votre backend:
      // POST https://api.vybzzz.com/stripe/connect/create
      // Body: { userId, email, fullname, country }

      // Le backend appelle l'API Stripe:
      // POST https://api.stripe.com/v1/accounts
      // avec les données de l'artiste

      // Pour la démo, on simule un compte ID
      final connectAccountId = 'acct_${DateTime.now().millisecondsSinceEpoch}';

      // Sauvegarder dans Firestore
      await _firestore.collection('users').doc(userId.toString()).update({
        'stripe_connect_account_id': connectAccountId,
        'stripe_onboarding_completed': false,
        'stripe_account_created_at': FieldValue.serverTimestamp(),
      });

      Loggers.success('Compte Connect créé: $connectAccountId');
      return connectAccountId;
    } catch (e) {
      Loggers.error('Erreur création Connect account: $e');
      throw Exception('Erreur lors de la création du compte Connect: $e');
    }
  }

  /// Génère un lien d'onboarding Stripe Connect
  ///
  /// L'artiste clique sur ce lien pour compléter son onboarding
  Future<String> createAccountLink({
    required String connectAccountId,
    required String returnUrl,
    required String refreshUrl,
  }) async {
    try {
      // En production, appeler votre backend:
      // POST https://api.vybzzz.com/stripe/connect/onboarding-link
      // Body: { connectAccountId, returnUrl, refreshUrl }

      // Le backend appelle:
      // POST https://api.stripe.com/v1/account_links

      // URL simulée pour la démo
      final onboardingUrl = 'https://connect.stripe.com/setup/$connectAccountId';

      Loggers.success('Lien onboarding généré');
      return onboardingUrl;
    } catch (e) {
      Loggers.error('Erreur génération lien onboarding: $e');
      throw Exception('Erreur lors de la génération du lien: $e');
    }
  }

  /// Marque l'onboarding comme complété
  Future<void> completeOnboarding(int userId) async {
    try {
      await _firestore.collection('users').doc(userId.toString()).update({
        'stripe_onboarding_completed': true,
        'stripe_onboarding_completed_at': FieldValue.serverTimestamp(),
      });

      Loggers.success('Onboarding complété pour user: $userId');
    } catch (e) {
      Loggers.error('Erreur completion onboarding: $e');
    }
  }

  /// Vérifie si un artiste a complété l'onboarding Stripe
  Future<bool> isOnboardingCompleted(int userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId.toString()).get();
      if (!doc.exists) return false;

      final data = doc.data();
      return data?['stripe_onboarding_completed'] ?? false;
    } catch (e) {
      Loggers.error('Erreur check onboarding: $e');
      return false;
    }
  }

  // ============================================
  // PAYMENT INTENT - TICKET PURCHASE
  // ============================================

  /// Crée un Payment Intent pour l'achat de billets
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required int buyerId,
    required int artistId,
    required String eventId,
    required String eventTitle,
    String? stripeConnectAccountId,
  }) async {
    try {
      // Calculer les montants selon le tier de l'artiste
      final artistDoc = await _firestore.collection('users').doc(artistId.toString()).get();
      if (!artistDoc.exists) {
        throw Exception('Artiste introuvable');
      }

      final artistData = artistDoc.data();
      final tierStr = artistData?['subscription_tier'] as String?;
      final tier = tierStr != null ? SubscriptionTier.fromString(tierStr) : null;

      // Calculer la commission de la plateforme
      double platformFee = 0;
      if (tier != null) {
        platformFee = tier.calculatePlatformFee(amount);
      } else {
        // Par défaut: 50/50
        platformFee = amount * 0.5;
      }

      // Frais Stripe (~3% + 0.25€)
      final stripeFee = (amount * 0.029) + 0.25;

      // En production, appeler votre backend:
      // POST https://api.vybzzz.com/stripe/payment-intent
      // Body: { amount, currency, buyerId, artistId, eventId, platformFee }

      // Le backend appelle:
      // POST https://api.stripe.com/v1/payment_intents
      // avec application_fee_amount pour la commission

      // Pour la démo, simuler un payment intent
      final paymentIntentId = 'pi_${DateTime.now().millisecondsSinceEpoch}';
      final clientSecret = '${paymentIntentId}_secret_${DateTime.now().millisecondsSinceEpoch}';

      // Sauvegarder l'intent dans Firestore
      await _firestore.collection('payment_intents').doc(paymentIntentId).set({
        'payment_intent_id': paymentIntentId,
        'amount': amount,
        'currency': currency,
        'buyer_id': buyerId,
        'artist_id': artistId,
        'event_id': eventId,
        'event_title': eventTitle,
        'platform_fee': platformFee,
        'stripe_fee': stripeFee,
        'artist_amount': amount - platformFee - stripeFee,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'stripe_connect_account_id': stripeConnectAccountId,
      });

      Loggers.success('Payment Intent créé: $paymentIntentId');

      return {
        'paymentIntentId': paymentIntentId,
        'clientSecret': clientSecret,
        'amount': amount,
        'platformFee': platformFee,
        'stripeFee': stripeFee,
        'artistAmount': amount - platformFee - stripeFee,
      };
    } catch (e) {
      Loggers.error('Erreur création Payment Intent: $e');
      throw Exception('Erreur lors de la création du paiement: $e');
    }
  }

  /// Confirme un Payment Intent (après saisie carte)
  Future<bool> confirmPaymentIntent({
    required String paymentIntentId,
    required String clientSecret,
  }) async {
    try {
      // En production, utiliser le SDK Stripe:
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Mettre à jour le statut
      await _firestore.collection('payment_intents').doc(paymentIntentId).update({
        'status': 'succeeded',
        'confirmed_at': FieldValue.serverTimestamp(),
      });

      Loggers.success('Payment Intent confirmé: $paymentIntentId');
      return true;
    } catch (e) {
      Loggers.error('Erreur confirmation Payment Intent: $e');

      // Mettre à jour le statut en erreur
      await _firestore.collection('payment_intents').doc(paymentIntentId).update({
        'status': 'failed',
        'error': e.toString(),
        'failed_at': FieldValue.serverTimestamp(),
      });

      return false;
    }
  }

  // ============================================
  // TRANSFERS - J+14 PAYOUTS
  // ============================================

  /// Crée un transfert Stripe vers un artiste (J+14)
  ///
  /// En production, cette fonction doit être appelée par un Cloud Function
  /// Firebase déclenchée par un cron job tous les lundis
  Future<String> createTransfer({
    required String connectAccountId,
    required double amount,
    required String currency,
    required String eventId,
    required int artistId,
  }) async {
    try {
      // En production, appeler votre backend:
      // POST https://api.vybzzz.com/stripe/transfers
      // Body: { connectAccountId, amount, currency, eventId, artistId }

      // Le backend appelle:
      // POST https://api.stripe.com/v1/transfers
      // {
      //   amount: amount * 100, // en centimes
      //   currency: currency,
      //   destination: connectAccountId,
      //   description: "Paiement pour l'événement X"
      // }

      // Pour la démo, simuler un transfer
      final transferId = 'tr_${DateTime.now().millisecondsSinceEpoch}';

      // Sauvegarder dans Firestore
      await _firestore.collection('transfers').doc(transferId).set({
        'transfer_id': transferId,
        'connect_account_id': connectAccountId,
        'artist_id': artistId,
        'event_id': eventId,
        'amount': amount,
        'currency': currency,
        'status': 'succeeded',
        'created_at': FieldValue.serverTimestamp(),
      });

      Loggers.success('Transfer créé: $transferId - ${amount}€');
      return transferId;
    } catch (e) {
      Loggers.error('Erreur création transfer: $e');
      throw Exception('Erreur lors du transfert: $e');
    }
  }

  /// Récupère les transferts d'un artiste
  Future<List<Map<String, dynamic>>> getArtistTransfers(int artistId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transfers')
          .where('artist_id', isEqualTo: artistId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Loggers.error('Erreur récupération transfers: $e');
      return [];
    }
  }

  /// Calcule le montant à transférer pour un événement (J+14)
  Future<double> calculatePayoutAmount({
    required String eventId,
    required int artistId,
  }) async {
    try {
      // Récupérer tous les Payment Intents réussis pour cet événement
      final querySnapshot = await _firestore
          .collection('payment_intents')
          .where('event_id', isEqualTo: eventId)
          .where('artist_id', isEqualTo: artistId)
          .where('status', isEqualTo: 'succeeded')
          .get();

      double totalArtistAmount = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalArtistAmount += (data['artist_amount'] as num?)?.toDouble() ?? 0;
      }

      // Ajouter les tips
      final tipsSnapshot = await _firestore
          .collection('tips')
          .where('event_id', isEqualTo: eventId)
          .where('to_user_id', isEqualTo: artistId)
          .get();

      double totalTips = 0;
      for (final doc in tipsSnapshot.docs) {
        final data = doc.data();
        totalTips += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      final totalPayout = totalArtistAmount + totalTips;

      Loggers.success('Payout calculé: $totalPayout€ (tickets: $totalArtistAmount€ + tips: $totalTips€)');
      return totalPayout;
    } catch (e) {
      Loggers.error('Erreur calcul payout: $e');
      return 0;
    }
  }

  // ============================================
  // REFUNDS
  // ============================================

  /// Crée un remboursement pour un billet
  Future<String> createRefund({
    required String paymentIntentId,
    required double amount,
  }) async {
    try {
      // En production, appeler votre backend:
      // POST https://api.vybzzz.com/stripe/refunds
      // Body: { paymentIntentId, amount }

      // Le backend appelle:
      // POST https://api.stripe.com/v1/refunds

      final refundId = 'rf_${DateTime.now().millisecondsSinceEpoch}';

      // Mettre à jour le Payment Intent
      await _firestore.collection('payment_intents').doc(paymentIntentId).update({
        'status': 'refunded',
        'refunded_at': FieldValue.serverTimestamp(),
        'refund_id': refundId,
      });

      Loggers.success('Refund créé: $refundId');
      return refundId;
    } catch (e) {
      Loggers.error('Erreur création refund: $e');
      throw Exception('Erreur lors du remboursement: $e');
    }
  }
}
