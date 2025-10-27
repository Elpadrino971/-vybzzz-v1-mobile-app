/// Enumération des paliers d'abonnement pour les artistes
///
/// 3 niveaux d'abonnement avec différents pourcentages de partage :
/// - Basic (19,99€/mois) : 50% artiste / 50% plateforme
/// - Pro (59,99€/mois) : 60% artiste / 40% plateforme
/// - Premium (129,99€/mois) : 70% artiste / 30% plateforme

enum SubscriptionTier {
  basic('basic', 'Basic', 19.99, 0.50, 0.50),
  pro('pro', 'Pro', 59.99, 0.60, 0.40),
  premium('premium', 'Premium', 129.99, 0.70, 0.30);

  final String value;
  final String displayName;
  final double monthlyPrice; // Prix mensuel en euros
  final double artistShare; // Part de l'artiste (ex: 0.50 = 50%)
  final double platformShare; // Part de la plateforme (ex: 0.50 = 50%)

  const SubscriptionTier(
    this.value,
    this.displayName,
    this.monthlyPrice,
    this.artistShare,
    this.platformShare,
  );

  /// Convertir une string en SubscriptionTier
  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.value == value,
      orElse: () => SubscriptionTier.basic, // Par défaut : Basic
    );
  }

  /// Calculer la part de l'artiste pour un montant donné
  double calculateArtistEarnings(double totalAmount) {
    return totalAmount * artistShare;
  }

  /// Calculer la commission de la plateforme pour un montant donné
  double calculatePlatformFee(double totalAmount) {
    return totalAmount * platformShare;
  }

  /// Obtient la couleur associée au tier
  String get colorHex {
    switch (this) {
      case SubscriptionTier.basic:
        return '#FF8C00'; // Orange
      case SubscriptionTier.pro:
        return '#FFD700'; // Or
      case SubscriptionTier.premium:
        return '#E50914'; // Rouge Netflix
    }
  }

  /// Obtient les avantages du tier
  List<String> get benefits {
    switch (this) {
      case SubscriptionTier.basic:
        return [
          '50% de revenus',
          'Paiements le lundi (J+14)',
          'Concerts illimités',
          'Support par email',
        ];
      case SubscriptionTier.pro:
        return [
          '60% de revenus',
          'Paiements le lundi (J+14)',
          'Concerts illimités',
          'Analytics avancées',
          'Support prioritaire',
          'Badge PRO',
        ];
      case SubscriptionTier.premium:
        return [
          '70% de revenus',
          'Paiements le lundi (J+14)',
          'Concerts illimités',
          'Analytics avancées',
          'Support 24/7',
          'Badge PREMIUM',
          'Promotion sur la page d\'accueil',
          'Accès aux fonctionnalités bêta',
        ];
    }
  }

  /// Obtient le nom formaté avec le prix
  String get nameWithPrice => '$displayName - ${monthlyPrice.toStringAsFixed(2)}€/mois';

  /// Obtient le ratio de partage formaté
  String get shareRatio {
    final artistPercent = (artistShare * 100).toInt();
    final platformPercent = (platformShare * 100).toInt();
    return '$artistPercent% / $platformPercent%';
  }
}
