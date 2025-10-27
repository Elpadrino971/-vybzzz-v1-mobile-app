import 'package:vybzzz/common/enum/user_type_enum.dart';
import 'package:vybzzz/common/enum/subscription_tier_enum.dart';
import 'package:vybzzz/model/user_model/user_model.dart';

/// Extension VyBzzZ pour le modèle User
///
/// Ajoute les champs spécifiques à VyBzzZ :
/// - Type d'utilisateur (Fan, Artiste, AA, RM, Propriétaire)
/// - Palier d'abonnement (pour les artistes)
/// - Identifiants Stripe (paiements)
/// - Système d'affiliation

extension UserVyBzzZExtension on User {
  // ============================================
  // CHAMPS VYBZZZ
  // ============================================

  /// Type d'utilisateur VyBzzZ
  UserType get userType {
    // Récupérer depuis un champ custom ou metadata
    // Pour l'instant, on utilise un champ qui sera ajouté au User
    final typeStr = _getUserTypeString();
    return UserType.fromString(typeStr);
  }

  /// Palier d'abonnement (artistes uniquement)
  SubscriptionTier? get subscriptionTier {
    if (!userType.isArtist) return null;
    final tierStr = _getSubscriptionTierString();
    if (tierStr == null) return null;
    return SubscriptionTier.fromString(tierStr);
  }

  /// ID du compte Stripe Connect (pour recevoir des paiements)
  String? get stripeAccountId => _getStripeAccountId();

  /// ID du client Stripe (pour effectuer des paiements)
  String? get stripeCustomerId => _getStripeCustomerId();

  /// Code d'affiliation unique
  String get affiliateCode {
    return _getAffiliateCode() ?? 'USER_${id ?? 0}';
  }

  /// ID de l'utilisateur parrain (celui qui a référé cet utilisateur)
  int? get referredBy => _getReferredBy();

  // ============================================
  // MÉTHODES HELPER
  // ============================================

  /// Vérifie si l'utilisateur peut créer des événements
  bool get canCreateEvents => userType.canCreateEvents;

  /// Vérifie si l'utilisateur peut recevoir des commissions d'affiliation
  bool get canEarnAffiliateCommission => userType.canEarnAffiliateCommission;

  /// Obtient la part de revenus pour un artiste
  double getArtistShare(double totalAmount) {
    if (!userType.isArtist || subscriptionTier == null) return 0;
    return subscriptionTier!.calculateArtistEarnings(totalAmount);
  }

  /// Obtient la commission de la plateforme
  double getPlatformFee(double totalAmount) {
    if (!userType.isArtist || subscriptionTier == null) return 0;
    return subscriptionTier!.calculatePlatformFee(totalAmount);
  }

  /// Obtient le nom du rôle formaté
  String get userRoleDisplayName => userType.displayName;

  /// Obtient la description du rôle
  String get userRoleDescription => userType.description;

  /// Obtient l'icône du rôle
  String get userRoleIcon => userType.iconPath;

  /// Vérifie si l'utilisateur a configuré Stripe Connect
  bool get hasStripeConnected => stripeAccountId != null && stripeAccountId!.isNotEmpty;

  /// Vérifie si l'utilisateur peut recevoir des paiements
  bool get canReceivePayments => userType.isArtist && hasStripeConnected;

  // ============================================
  // MÉTHODES PRIVÉES (à implémenter avec le vrai stockage)
  // ============================================

  /// Récupère le type d'utilisateur depuis le stockage
  /// TODO: Ajouter un champ 'user_type' au modèle User dans Firestore
  String _getUserTypeString() {
    // Pour l'instant, retourne 'fan' par défaut
    // Sera remplacé par: return metadata?['user_type'] ?? 'fan';
    return 'fan';
  }

  /// Récupère le palier d'abonnement depuis le stockage
  /// TODO: Ajouter un champ 'subscription_tier' au modèle User dans Firestore
  String? _getSubscriptionTierString() {
    // Sera remplacé par: return metadata?['subscription_tier'];
    return null;
  }

  /// Récupère l'ID du compte Stripe Connect
  /// TODO: Ajouter un champ 'stripe_account_id' au modèle User dans Firestore
  String? _getStripeAccountId() {
    // Sera remplacé par: return metadata?['stripe_account_id'];
    return null;
  }

  /// Récupère l'ID du client Stripe
  /// TODO: Ajouter un champ 'stripe_customer_id' au modèle User dans Firestore
  String? _getStripeCustomerId() {
    // Sera remplacé par: return metadata?['stripe_customer_id'];
    return null;
  }

  /// Récupère le code d'affiliation
  /// TODO: Ajouter un champ 'affiliate_code' au modèle User dans Firestore
  String? _getAffiliateCode() {
    // Sera remplacé par: return metadata?['affiliate_code'];
    return null;
  }

  /// Récupère l'ID du parrain
  /// TODO: Ajouter un champ 'referred_by' au modèle User dans Firestore
  int? _getReferredBy() {
    // Sera remplacé par: return metadata?['referred_by'];
    return null;
  }
}
