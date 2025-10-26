import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';

/// Modèle de billet VyBzzZ
///
/// Représente un billet acheté pour un événement avec :
/// - 3 types (Virtual, Physical, Fanbase)
/// - QR code unique pour validation
/// - Lien avec Stripe pour le paiement

enum TicketStatus {
  valid('valid', 'Valide'),
  used('used', 'Utilisé'),
  refunded('refunded', 'Remboursé'),
  cancelled('cancelled', 'Annulé');

  final String value;
  final String displayName;

  const TicketStatus(this.value, this.displayName);

  static TicketStatus fromString(String value) {
    return TicketStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TicketStatus.valid,
    );
  }

  bool get isUsable => this == TicketStatus.valid;
  bool get canRefund => this == TicketStatus.valid;
}

class TicketModel {
  String? id;
  String? eventId;
  int? userId;

  // Type et statut
  TicketType? ticketType;
  TicketStatus? status;

  // QR code unique pour validation
  String? qrCode;

  // Prix payé
  double? pricePaid;

  // Stripe
  String? stripePaymentIntentId;
  String? stripeTransactionId;

  // Dates
  DateTime? purchasedAt;
  DateTime? usedAt;
  DateTime? refundedAt;

  // Metadata
  String? userName;
  String? userEmail;
  String? eventTitle;
  DateTime? eventStartTime;

  TicketModel({
    this.id,
    this.eventId,
    this.userId,
    this.ticketType,
    this.status,
    this.qrCode,
    this.pricePaid,
    this.stripePaymentIntentId,
    this.stripeTransactionId,
    this.purchasedAt,
    this.usedAt,
    this.refundedAt,
    this.userName,
    this.userEmail,
    this.eventTitle,
    this.eventStartTime,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel.fromJson(data)..id = doc.id;
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      ticketType: json['ticket_type'] != null
          ? TicketType.fromString(json['ticket_type'])
          : null,
      status: json['status'] != null
          ? TicketStatus.fromString(json['status'])
          : null,
      qrCode: json['qr_code'],
      pricePaid: json['price_paid']?.toDouble(),
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      stripeTransactionId: json['stripe_transaction_id'],
      purchasedAt: json['purchased_at'] != null
          ? (json['purchased_at'] as Timestamp).toDate()
          : null,
      usedAt: json['used_at'] != null
          ? (json['used_at'] as Timestamp).toDate()
          : null,
      refundedAt: json['refunded_at'] != null
          ? (json['refunded_at'] as Timestamp).toDate()
          : null,
      userName: json['user_name'],
      userEmail: json['user_email'],
      eventTitle: json['event_title'],
      eventStartTime: json['event_start_time'] != null
          ? (json['event_start_time'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'ticket_type': ticketType?.value,
      'status': status?.value,
      'qr_code': qrCode,
      'price_paid': pricePaid,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_transaction_id': stripeTransactionId,
      'purchased_at':
          purchasedAt != null ? Timestamp.fromDate(purchasedAt!) : null,
      'used_at': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'refunded_at':
          refundedAt != null ? Timestamp.fromDate(refundedAt!) : null,
      'user_name': userName,
      'user_email': userEmail,
      'event_title': eventTitle,
      'event_start_time': eventStartTime != null
          ? Timestamp.fromDate(eventStartTime!)
          : null,
    };
  }

  /// Génère un QR code unique pour ce billet
  static String generateQRCode(String ticketId, String eventId, int userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'VYBZZZ_${eventId}_${userId}_${ticketId}_$timestamp';
  }

  /// Marque le billet comme utilisé
  void markAsUsed() {
    status = TicketStatus.used;
    usedAt = DateTime.now();
  }

  /// Rembourse le billet
  void refund() {
    status = TicketStatus.refunded;
    refundedAt = DateTime.now();
  }

  /// Annule le billet
  void cancel() {
    status = TicketStatus.cancelled;
  }

  /// Vérifie si le billet peut être scanné
  bool get canBeScanned {
    if (status != TicketStatus.valid) return false;
    if (eventStartTime == null) return true;

    // Autoriser le scan 2 heures avant et jusqu'à la fin de l'événement
    final now = DateTime.now();
    final scanStartTime = eventStartTime!.subtract(const Duration(hours: 2));
    return now.isAfter(scanStartTime);
  }

  /// Obtient le nom du type de billet
  String get ticketTypeName => ticketType?.displayName ?? '';

  /// Obtient le statut formaté
  String get statusDisplayName => status?.displayName ?? '';

  /// Vérifie si le billet est valide
  bool get isValid => status?.isUsable ?? false;

  /// Vérifie si le billet peut être remboursé
  bool get canBeRefunded {
    if (status?.canRefund != true) return false;
    if (eventStartTime == null) return false;

    // Autoriser le remboursement jusqu'à 24h avant l'événement
    final now = DateTime.now();
    final refundDeadline = eventStartTime!.subtract(const Duration(hours: 24));
    return now.isBefore(refundDeadline);
  }
}
