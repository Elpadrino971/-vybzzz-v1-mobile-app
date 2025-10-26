import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/common/service/vybzzz/stripe_service.dart';
import 'package:vybzzz/model/payout_model/payout_model.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Service d'automatisation des payouts J+14
///
/// Ce service doit être appelé par une Cloud Function Firebase
/// déclenchée par un cron job tous les lundis

class PayoutAutomationService {
  static final PayoutAutomationService _instance =
      PayoutAutomationService._internal();
  factory PayoutAutomationService() => _instance;
  PayoutAutomationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StripeService _stripeService = StripeService();

  // ============================================
  // PROCESS MONDAY PAYOUTS (J+14)
  // ============================================

  /// Traite tous les payouts prévus pour aujourd'hui (lundi)
  ///
  /// Cette fonction doit être appelée automatiquement tous les lundis
  /// via Firebase Cloud Functions + Cloud Scheduler
  Future<void> processMondayPayouts() async {
    try {
      final today = DateTime.now();

      // Vérifier que c'est bien un lundi
      if (today.weekday != DateTime.monday) {
        Loggers.warning('Payout automation appelée un ${_getDayName(today.weekday)} au lieu d\'un lundi');
        return;
      }

      Loggers.success('=== Début du traitement des payouts du ${_formatDate(today)} ===');

      // Récupérer tous les événements terminés dont la date de paiement est aujourd'hui
      final payoutDate = DateTime(today.year, today.month, today.day);

      final eventsSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'ended')
          .where('payout_status', isEqualTo: 'pending')
          .get();

      int successCount = 0;
      int failedCount = 0;
      double totalPaidOut = 0;

      for (final eventDoc in eventsSnapshot.docs) {
        try {
          final eventData = eventDoc.data();
          final eventId = eventDoc.id;
          final artistId = eventData['artist_id'] as int?;
          final eventDate = (eventData['start_time'] as Timestamp?)?.toDate();

          if (artistId == null || eventDate == null) {
            Loggers.warning('Event $eventId: données manquantes');
            continue;
          }

          // Calculer la date de paiement théorique (J+14 Monday)
          final expectedPayoutDate = PayoutModel.calculatePaymentDate(eventDate);

          // Vérifier si c'est aujourd'hui
          if (!_isSameDay(expectedPayoutDate, payoutDate)) {
            continue; // Pas encore le bon jour
          }

          // Traiter le payout pour cet événement
          final success = await _processEventPayout(eventId, artistId);

          if (success) {
            successCount++;
            Loggers.success('✓ Payout réussi pour event $eventId');
          } else {
            failedCount++;
            Loggers.error('✗ Payout échoué pour event $eventId');
          }
        } catch (e) {
          failedCount++;
          Loggers.error('Erreur traitement event ${eventDoc.id}: $e');
        }
      }

      Loggers.success('=== Fin du traitement ===');
      Loggers.success('Succès: $successCount | Échecs: $failedCount | Total payé: ${totalPaidOut.toStringAsFixed(2)}€');
    } catch (e) {
      Loggers.error('Erreur globale process payouts: $e');
    }
  }

  // ============================================
  // PROCESS SINGLE EVENT PAYOUT
  // ============================================

  /// Traite le payout pour un événement spécifique
  Future<bool> _processEventPayout(String eventId, int artistId) async {
    try {
      // 1. Récupérer le compte Stripe Connect de l'artiste
      final artistDoc = await _firestore.collection('users').doc(artistId.toString()).get();
      if (!artistDoc.exists) {
        throw Exception('Artiste introuvable');
      }

      final artistData = artistDoc.data();
      final connectAccountId = artistData?['stripe_connect_account_id'] as String?;
      final onboardingCompleted = artistData?['stripe_onboarding_completed'] as bool? ?? false;

      if (connectAccountId == null || !onboardingCompleted) {
        Loggers.warning('Artiste $artistId: Stripe non configuré');
        await _markPayoutFailed(eventId, 'Stripe non configuré');
        return false;
      }

      // 2. Calculer le montant à transférer
      final payoutAmount = await _stripeService.calculatePayoutAmount(
        eventId: eventId,
        artistId: artistId,
      );

      if (payoutAmount <= 0) {
        Loggers.warning('Event $eventId: montant = 0€');
        await _markPayoutCompleted(eventId, 0);
        return true; // Succès mais rien à payer
      }

      // 3. Créer le transfert Stripe
      final transferId = await _stripeService.createTransfer(
        connectAccountId: connectAccountId,
        amount: payoutAmount,
        currency: 'eur',
        eventId: eventId,
        artistId: artistId,
      );

      // 4. Créer le PayoutModel dans Firestore
      await _createPayoutRecord(
        eventId: eventId,
        artistId: artistId,
        amount: payoutAmount,
        transferId: transferId,
      );

      // 5. Marquer l'événement comme payé
      await _markPayoutCompleted(eventId, payoutAmount);

      Loggers.success('Payout réussi: $payoutAmount€ → Artiste $artistId (Transfer: $transferId)');
      return true;
    } catch (e) {
      Loggers.error('Erreur payout event $eventId: $e');
      await _markPayoutFailed(eventId, e.toString());
      return false;
    }
  }

  // ============================================
  // FIRESTORE UPDATES
  // ============================================

  Future<void> _createPayoutRecord({
    required String eventId,
    required int artistId,
    required double amount,
    required String transferId,
  }) async {
    final payout = PayoutModel(
      id: transferId,
      eventId: eventId,
      artistId: artistId,
      finalAmount: amount,
      paymentDate: DateTime.now(),
      status: PayoutStatus.completed,
    );

    await _firestore
        .collection('payouts')
        .doc(transferId)
        .set(payout.toJson());
  }

  Future<void> _markPayoutCompleted(String eventId, double amount) async {
    await _firestore.collection('events').doc(eventId).update({
      'payout_status': 'completed',
      'payout_completed_at': FieldValue.serverTimestamp(),
      'payout_amount': amount,
    });
  }

  Future<void> _markPayoutFailed(String eventId, String reason) async {
    await _firestore.collection('events').doc(eventId).update({
      'payout_status': 'failed',
      'payout_failed_at': FieldValue.serverTimestamp(),
      'payout_failure_reason': reason,
    });
  }

  // ============================================
  // HELPERS
  // ============================================

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================
  // MANUAL TRIGGER (for testing)
  // ============================================

  /// Déclenche manuellement un payout pour un événement
  /// (pour les tests uniquement)
  Future<bool> triggerManualPayout(String eventId, int artistId) async {
    Loggers.warning('⚠️ Payout manuel déclenché pour event $eventId');
    return await _processEventPayout(eventId, artistId);
  }

  /// Récupère tous les événements éligibles au payout aujourd'hui
  Future<List<Map<String, dynamic>>> getEligibleEventsForToday() async {
    final today = DateTime.now();
    final payoutDate = DateTime(today.year, today.month, today.day);

    final eventsSnapshot = await _firestore
        .collection('events')
        .where('status', isEqualTo: 'ended')
        .where('payout_status', isEqualTo: 'pending')
        .get();

    final eligibleEvents = <Map<String, dynamic>>[];

    for (final eventDoc in eventsSnapshot.docs) {
      final eventData = eventDoc.data();
      final eventDate = (eventData['start_time'] as Timestamp?)?.toDate();

      if (eventDate == null) continue;

      final expectedPayoutDate = PayoutModel.calculatePaymentDate(eventDate);

      if (_isSameDay(expectedPayoutDate, payoutDate)) {
        eligibleEvents.add({
          'event_id': eventDoc.id,
          'event_title': eventData['title'],
          'artist_id': eventData['artist_id'],
          'event_date': eventDate,
          'payout_date': expectedPayoutDate,
        });
      }
    }

    return eligibleEvents;
  }
}
