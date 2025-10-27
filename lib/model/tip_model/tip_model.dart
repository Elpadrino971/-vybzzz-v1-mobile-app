import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de pourboire VyBzzZ
///
/// Permet aux spectateurs d'envoyer des pourboires aux artistes
/// pendant les concerts live

enum TipStatus {
  pending('pending', 'En Attente'),
  completed('completed', 'Complété'),
  failed('failed', 'Échoué'),
  refunded('refunded', 'Remboursé');

  final String value;
  final String displayName;

  const TipStatus(this.value, this.displayName);

  static TipStatus fromString(String value) {
    return TipStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TipStatus.pending,
    );
  }

  bool get isCompleted => this == TipStatus.completed;
  bool get canRetry => this == TipStatus.failed;
}

class TipModel {
  String? id;
  int? fromUserId;
  String? fromUserName;
  String? fromUserPhoto;

  int? toArtistId;
  String? toArtistName;
  String? toArtistPhoto;

  String? eventId;
  String? eventTitle;

  // Montant et message
  double? amount;
  String? message;

  // Stripe
  String? stripePaymentIntentId;
  String? stripeTransactionId;

  // Statut
  TipStatus? status;
  String? failureReason;

  // Metadata
  DateTime? createdAt;
  DateTime? completedAt;

  TipModel({
    this.id,
    this.fromUserId,
    this.fromUserName,
    this.fromUserPhoto,
    this.toArtistId,
    this.toArtistName,
    this.toArtistPhoto,
    this.eventId,
    this.eventTitle,
    this.amount,
    this.message,
    this.stripePaymentIntentId,
    this.stripeTransactionId,
    this.status,
    this.failureReason,
    this.createdAt,
    this.completedAt,
  });

  factory TipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TipModel.fromJson(data)..id = doc.id;
  }

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'],
      fromUserId: json['from_user_id'],
      fromUserName: json['from_user_name'],
      fromUserPhoto: json['from_user_photo'],
      toArtistId: json['to_artist_id'],
      toArtistName: json['to_artist_name'],
      toArtistPhoto: json['to_artist_photo'],
      eventId: json['event_id'],
      eventTitle: json['event_title'],
      amount: json['amount']?.toDouble(),
      message: json['message'],
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      stripeTransactionId: json['stripe_transaction_id'],
      status: json['status'] != null
          ? TipStatus.fromString(json['status'])
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
      'from_user_id': fromUserId,
      'from_user_name': fromUserName,
      'from_user_photo': fromUserPhoto,
      'to_artist_id': toArtistId,
      'to_artist_name': toArtistName,
      'to_artist_photo': toArtistPhoto,
      'event_id': eventId,
      'event_title': eventTitle,
      'amount': amount,
      'message': message,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_transaction_id': stripeTransactionId,
      'status': status?.value,
      'failure_reason': failureReason,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'completed_at':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Marque le pourboire comme complété
  void markAsCompleted(String paymentIntentId, String transactionId) {
    status = TipStatus.completed;
    stripePaymentIntentId = paymentIntentId;
    stripeTransactionId = transactionId;
    completedAt = DateTime.now();
  }

  /// Marque le pourboire comme échoué
  void markAsFailed(String reason) {
    status = TipStatus.failed;
    failureReason = reason;
  }

  /// Obtient le montant formatté
  String get amountFormatted => '${(amount ?? 0).toStringAsFixed(2)}€';

  /// Obtient le statut formaté
  String get statusDisplayName => status?.displayName ?? '';

  /// Vérifie si le pourboire est complété
  bool get isCompleted => status?.isCompleted ?? false;

  /// Obtient un aperçu du message
  String get messagePreview {
    if (message == null || message!.isEmpty) return 'Aucun message';
    return message!.length > 50 ? '${message!.substring(0, 50)}...' : message!;
  }
}

/// Montants de pourboire prédéfinis
class TipAmount {
  static const double small = 2.0; // 2€
  static const double medium = 5.0; // 5€
  static const double large = 10.0; // 10€
  static const double xlarge = 20.0; // 20€

  static List<double> get predefinedAmounts => [small, medium, large, xlarge];

  static String formatAmount(double amount) => '${amount.toStringAsFixed(0)}€';
}
