import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/common/enum/subscription_tier_enum.dart';

/// Modèle de paiement aux artistes
///
/// Représente un paiement programmé pour un artiste avec :
/// - Paiements tous les lundis
/// - Délai de J+14 après le concert
/// - Calcul des commissions selon le tier

enum PayoutStatus {
  pending('pending', 'En Attente'),
  processing('processing', 'En Traitement'),
  completed('completed', 'Complété'),
  failed('failed', 'Échoué');

  final String value;
  final String displayName;

  const PayoutStatus(this.value, this.displayName);

  static PayoutStatus fromString(String value) {
    return PayoutStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PayoutStatus.pending,
    );
  }

  bool get isCompleted => this == PayoutStatus.completed;
  bool get canRetry => this == PayoutStatus.failed;
}

class PayoutModel {
  String? id;
  int? artistId;
  String? artistName;
  String? artistEmail;

  // Tier d'abonnement de l'artiste au moment du payout
  SubscriptionTier? subscriptionTier;

  // Événements inclus dans ce payout
  List<String>? eventIds;
  int? eventCount;

  // Montants
  double? grossRevenue; // Revenus bruts
  double? platformFee; // Commission VyBzzZ (basée sur le tier)
  double? netAmount; // Montant net (après commission VyBzzZ)
  double? stripeFees; // Frais Stripe (~3%)
  double? finalAmount; // Montant final versé à l'artiste

  // Dates
  DateTime? eventDate; // Date du concert principal
  DateTime? paymentDate; // Lundi J+14

  // Stripe
  String? stripeTransferId;
  String? stripePayoutId;

  // Statut
  PayoutStatus? status;
  String? failureReason;

  // Metadata
  DateTime? createdAt;
  DateTime? completedAt;

  PayoutModel({
    this.id,
    this.artistId,
    this.artistName,
    this.artistEmail,
    this.subscriptionTier,
    this.eventIds,
    this.eventCount,
    this.grossRevenue,
    this.platformFee,
    this.netAmount,
    this.stripeFees,
    this.finalAmount,
    this.eventDate,
    this.paymentDate,
    this.stripeTransferId,
    this.stripePayoutId,
    this.status,
    this.failureReason,
    this.createdAt,
    this.completedAt,
  });

  factory PayoutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PayoutModel.fromJson(data)..id = doc.id;
  }

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'],
      artistId: json['artist_id'],
      artistName: json['artist_name'],
      artistEmail: json['artist_email'],
      subscriptionTier: json['subscription_tier'] != null
          ? SubscriptionTier.fromString(json['subscription_tier'])
          : null,
      eventIds: json['event_ids'] != null
          ? List<String>.from(json['event_ids'])
          : null,
      eventCount: json['event_count'],
      grossRevenue: json['gross_revenue']?.toDouble(),
      platformFee: json['platform_fee']?.toDouble(),
      netAmount: json['net_amount']?.toDouble(),
      stripeFees: json['stripe_fees']?.toDouble(),
      finalAmount: json['final_amount']?.toDouble(),
      eventDate: json['event_date'] != null
          ? (json['event_date'] as Timestamp).toDate()
          : null,
      paymentDate: json['payment_date'] != null
          ? (json['payment_date'] as Timestamp).toDate()
          : null,
      stripeTransferId: json['stripe_transfer_id'],
      stripePayoutId: json['stripe_payout_id'],
      status: json['status'] != null
          ? PayoutStatus.fromString(json['status'])
          : null,
      failureReason: json['failure_reason'],
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artist_id': artistId,
      'artist_name': artistName,
      'artist_email': artistEmail,
      'subscription_tier': subscriptionTier?.value,
      'event_ids': eventIds,
      'event_count': eventCount,
      'gross_revenue': grossRevenue,
      'platform_fee': platformFee,
      'net_amount': netAmount,
      'stripe_fees': stripeFees,
      'final_amount': finalAmount,
      'event_date':
          eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'payment_date':
          paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'stripe_transfer_id': stripeTransferId,
      'stripe_payout_id': stripePayoutId,
      'status': status?.value,
      'failure_reason': failureReason,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'completed_at':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Calcule la date de paiement (J+14, prochain lundi)
  static DateTime calculatePaymentDate(DateTime eventDate) {
    // Ajouter 14 jours
    final after14Days = eventDate.add(const Duration(days: 14));

    // Trouver le prochain lundi
    final dayOfWeek = after14Days.weekday; // 1 = Monday, 7 = Sunday
    int daysUntilMonday;

    if (dayOfWeek == DateTime.monday) {
      daysUntilMonday = 0; // C'est déjà lundi
    } else if (dayOfWeek < DateTime.monday) {
      daysUntilMonday = DateTime.monday - dayOfWeek; // Jours jusqu'au lundi
    } else {
      daysUntilMonday = 7 - (dayOfWeek - DateTime.monday); // Lundi suivant
    }

    return after14Days.add(Duration(days: daysUntilMonday));
  }

  /// Calcule les montants basés sur le tier et les revenus bruts
  void calculateAmounts() {
    if (subscriptionTier == null || grossRevenue == null) return;

    // Commission de la plateforme (basée sur le tier)
    platformFee = subscriptionTier!.calculatePlatformFee(grossRevenue!);

    // Montant net pour l'artiste
    netAmount = subscriptionTier!.calculateArtistEarnings(grossRevenue!);

    // Frais Stripe (~2.9% + 0.25€)
    const stripePercentage = 0.029;
    const stripeFixed = 0.25;
    stripeFees = (netAmount! * stripePercentage) + stripeFixed;

    // Montant final versé
    finalAmount = netAmount! - stripeFees!;
  }

  /// Marque le payout comme complété
  void markAsCompleted(String stripeTransferId, String stripePayoutId) {
    status = PayoutStatus.completed;
    this.stripeTransferId = stripeTransferId;
    this.stripePayoutId = stripePayoutId;
    completedAt = DateTime.now();
  }

  /// Marque le payout comme échoué
  void markAsFailed(String reason) {
    status = PayoutStatus.failed;
    failureReason = reason;
  }

  /// Marque le payout en traitement
  void markAsProcessing() {
    status = PayoutStatus.processing;
  }

  /// Obtient le pourcentage de commission formaté
  String get commissionPercentage {
    if (subscriptionTier == null) return '0%';
    return '${(subscriptionTier!.platformShare * 100).toInt()}%';
  }

  /// Obtient le pourcentage de l'artiste formaté
  String get artistPercentage {
    if (subscriptionTier == null) return '0%';
    return '${(subscriptionTier!.artistShare * 100).toInt()}%';
  }

  /// Vérifie si le payout est prêt à être traité
  bool get isReadyForProcessing {
    if (paymentDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(paymentDate!) &&
        (status == PayoutStatus.pending || status?.canRetry == true);
  }

  /// Obtient le temps restant avant le paiement
  Duration? get timeUntilPayment {
    if (paymentDate == null || status?.isCompleted == true) return null;
    final now = DateTime.now();
    if (now.isAfter(paymentDate!)) return null;
    return paymentDate!.difference(now);
  }

  /// Obtient le statut formaté
  String get statusDisplayName => status?.displayName ?? '';
}
