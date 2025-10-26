import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d'affiliation VyBzzZ
///
/// Système de commissions multi-niveaux :
/// - Niveau 1 : 2.5% (utilisateurs directement référés)
/// - Niveau 2 : 1.5% (utilisateurs référés par vos référés)
/// - Niveau 3 : 1.0% (niveau 3 de profondeur)

enum AffiliateLevel {
  level1(1, 0.025, 'Niveau 1'), // 2.5%
  level2(2, 0.015, 'Niveau 2'), // 1.5%
  level3(3, 0.010, 'Niveau 3'); // 1.0%

  final int level;
  final double commissionRate;
  final String displayName;

  const AffiliateLevel(this.level, this.commissionRate, this.displayName);

  static AffiliateLevel fromLevel(int level) {
    return AffiliateLevel.values.firstWhere(
      (l) => l.level == level,
      orElse: () => AffiliateLevel.level1,
    );
  }

  /// Calcule la commission pour un montant donné
  double calculateCommission(double amount) {
    return amount * commissionRate;
  }

  /// Obtient le taux formaté
  String get rateFormatted => '${(commissionRate * 100).toStringAsFixed(1)}%';
}

class AffiliateModel {
  String? id;
  int? businessBringerId; // ID de l'apporteur d'affaire
  String? businessBringerName;
  int? referredUserId; // ID de l'utilisateur référé
  String? referredUserName;
  String? referredUserType; // fan, artist, etc.

  // Niveau de commission
  AffiliateLevel? level;

  // Stats
  double? totalCommissionEarned;
  int? totalTransactions;
  double? lastCommissionAmount;
  DateTime? lastCommissionDate;

  // Metadata
  DateTime? createdAt;
  DateTime? updatedAt;

  AffiliateModel({
    this.id,
    this.businessBringerId,
    this.businessBringerName,
    this.referredUserId,
    this.referredUserName,
    this.referredUserType,
    this.level,
    this.totalCommissionEarned,
    this.totalTransactions,
    this.lastCommissionAmount,
    this.lastCommissionDate,
    this.createdAt,
    this.updatedAt,
  });

  factory AffiliateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AffiliateModel.fromJson(data)..id = doc.id;
  }

  factory AffiliateModel.fromJson(Map<String, dynamic> json) {
    return AffiliateModel(
      id: json['id'],
      businessBringerId: json['business_bringer_id'],
      businessBringerName: json['business_bringer_name'],
      referredUserId: json['referred_user_id'],
      referredUserName: json['referred_user_name'],
      referredUserType: json['referred_user_type'],
      level: json['level'] != null
          ? AffiliateLevel.fromLevel(json['level'])
          : null,
      totalCommissionEarned: json['total_commission_earned']?.toDouble(),
      totalTransactions: json['total_transactions'],
      lastCommissionAmount: json['last_commission_amount']?.toDouble(),
      lastCommissionDate: json['last_commission_date'] != null
          ? (json['last_commission_date'] as Timestamp).toDate()
          : null,
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_bringer_id': businessBringerId,
      'business_bringer_name': businessBringerName,
      'referred_user_id': referredUserId,
      'referred_user_name': referredUserName,
      'referred_user_type': referredUserType,
      'level': level?.level,
      'total_commission_earned': totalCommissionEarned,
      'total_transactions': totalTransactions,
      'last_commission_amount': lastCommissionAmount,
      'last_commission_date': lastCommissionDate != null
          ? Timestamp.fromDate(lastCommissionDate!)
          : null,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Ajoute une commission
  void addCommission(double amount) {
    totalCommissionEarned = (totalCommissionEarned ?? 0) + amount;
    totalTransactions = (totalTransactions ?? 0) + 1;
    lastCommissionAmount = amount;
    lastCommissionDate = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Calcule la commission pour un montant donné
  double calculateCommission(double amount) {
    return level?.calculateCommission(amount) ?? 0;
  }

  /// Obtient le taux de commission formaté
  String get commissionRateFormatted => level?.rateFormatted ?? '0%';

  /// Obtient le niveau formaté
  String get levelDisplayName => level?.displayName ?? '';

  /// Obtient la commission totale formatée
  String get totalCommissionFormatted =>
      '${(totalCommissionEarned ?? 0).toStringAsFixed(2)}€';
}

/// Modèle de commission individuelle
class CommissionModel {
  String? id;
  String? affiliateId; // Lien vers l'affiliation
  int? businessBringerId;
  int? referredUserId;

  // Transaction source
  String? transactionId;
  String? eventId;
  String? ticketId;

  // Montants
  double? transactionAmount; // Montant de la transaction source
  double? commissionAmount; // Commission gagnée
  AffiliateLevel? level;

  // Statut
  String? status; // pending, paid
  DateTime? paidAt;

  // Metadata
  DateTime? createdAt;

  CommissionModel({
    this.id,
    this.affiliateId,
    this.businessBringerId,
    this.referredUserId,
    this.transactionId,
    this.eventId,
    this.ticketId,
    this.transactionAmount,
    this.commissionAmount,
    this.level,
    this.status,
    this.paidAt,
    this.createdAt,
  });

  factory CommissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommissionModel.fromJson(data)..id = doc.id;
  }

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      id: json['id'],
      affiliateId: json['affiliate_id'],
      businessBringerId: json['business_bringer_id'],
      referredUserId: json['referred_user_id'],
      transactionId: json['transaction_id'],
      eventId: json['event_id'],
      ticketId: json['ticket_id'],
      transactionAmount: json['transaction_amount']?.toDouble(),
      commissionAmount: json['commission_amount']?.toDouble(),
      level: json['level'] != null
          ? AffiliateLevel.fromLevel(json['level'])
          : null,
      status: json['status'],
      paidAt: json['paid_at'] != null
          ? (json['paid_at'] as Timestamp).toDate()
          : null,
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'affiliate_id': affiliateId,
      'business_bringer_id': businessBringerId,
      'referred_user_id': referredUserId,
      'transaction_id': transactionId,
      'event_id': eventId,
      'ticket_id': ticketId,
      'transaction_amount': transactionAmount,
      'commission_amount': commissionAmount,
      'level': level?.level,
      'status': status,
      'paid_at': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// Marque la commission comme payée
  void markAsPaid() {
    status = 'paid';
    paidAt = DateTime.now();
  }

  /// Vérifie si la commission est payée
  bool get isPaid => status == 'paid';

  /// Obtient le montant formatté
  String get commissionFormatted =>
      '${(commissionAmount ?? 0).toStringAsFixed(2)}€';
}
