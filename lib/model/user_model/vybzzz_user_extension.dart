import 'package:vybzzz/model/user_model/user_model.dart';
import 'package:vybzzz/common/enum/user_type_enum.dart';
import 'package:vybzzz/common/enum/subscription_tier_enum.dart';

/// Extension pour ajouter les champs VyBzzZ au modèle User existant
///
/// Contient tous les champs spécifiques à VyBzzZ :
/// - Type d'utilisateur (Fan, Artiste, etc.)
/// - Abonnement (Basic, Pro, Premium)
/// - Stripe IDs pour les paiements
/// - Code d'affiliation
/// - Référence parrain

extension VyBzzZUserExtension on User {
  /// Type d'utilisateur VyBzzZ
  /// Stocké dans le champ 'bio' temporairement jusqu'à migration BDD
  UserType getUserType() {
    // TODO: Migrer vers un vrai champ 'user_type' dans Firebase
    // Pour l'instant, on utilise isModerator comme indicateur d'artiste
    if (isModerator == 1) {
      return UserType.artist;
    }
    return UserType.fan;
  }

  /// Définit le type d'utilisateur
  void setUserType(UserType type) {
    // TODO: Sauvegarder dans Firebase avec le champ 'user_type'
    if (type == UserType.artist) {
      isModerator = 1;
    } else {
      isModerator = 0;
    }
  }

  /// Vérifie si l'utilisateur est un artiste
  bool get isArtist => getUserType().isArtist;

  /// Vérifie si l'utilisateur est un fan
  bool get isFan => getUserType().isFan;

  /// Vérifie si l'utilisateur est un PRO
  bool get isPro => getUserType().isPro;

  /// Vérifie si l'utilisateur peut créer des événements
  bool get canCreateEvents => getUserType().canCreateEvents;

  /// Vérifie si l'utilisateur peut gagner des commissions d'affiliation
  bool get canEarnAffiliateCommission => getUserType().canEarnAffiliateCommission;

  /// Obtient le palier d'abonnement (pour les artistes)
  SubscriptionTier? getSubscriptionTier() {
    // TODO: Ajouter un champ 'subscription_tier' dans Firebase
    // Pour l'instant, retourne Basic par défaut pour les artistes
    if (isArtist) {
      return SubscriptionTier.basic;
    }
    return null;
  }

  /// Calcule la part de l'artiste pour un montant donné
  double calculateArtistEarnings(double totalAmount) {
    final tier = getSubscriptionTier();
    if (tier != null) {
      return tier.calculateArtistEarnings(totalAmount);
    }
    return 0.0;
  }

  /// Calcule la commission de la plateforme pour un montant donné
  double calculatePlatformFee(double totalAmount) {
    final tier = getSubscriptionTier();
    if (tier != null) {
      return tier.calculatePlatformFee(totalAmount);
    }
    return 0.0;
  }

  /// Obtient l'ID du compte Stripe (pour recevoir des paiements)
  String? get stripeAccountId {
    // TODO: Ajouter un champ 'stripe_account_id' dans Firebase
    return null;
  }

  /// Obtient l'ID du client Stripe (pour effectuer des paiements)
  String? get stripeCustomerId {
    // TODO: Ajouter un champ 'stripe_customer_id' dans Firebase
    return null;
  }

  /// Obtient le code d'affiliation
  String? get affiliateCode {
    // TODO: Ajouter un champ 'affiliate_code' dans Firebase
    // Générer un code unique pour les Business Bringers
    return null;
  }

  /// Obtient l'ID de l'utilisateur qui a référé cet utilisateur
  int? get referredBy {
    // TODO: Ajouter un champ 'referred_by' dans Firebase
    return null;
  }

  /// Génère un nom d'affichage formaté avec badge
  String getDisplayNameWithBadge() {
    final type = getUserType();
    final tierEmoji = getSubscriptionTier()?.displayName ?? '';

    switch (type) {
      case UserType.artist:
        if (tierEmoji.isNotEmpty) {
          return '${fullname ?? username} 🎤 $tierEmoji';
        }
        return '${fullname ?? username} 🎤';
      case UserType.businessBringer:
        return '${fullname ?? username} 💼';
      case UserType.regionalManager:
        return '${fullname ?? username} 👔';
      case UserType.venueOwner:
        return '${fullname ?? username} 🏛️';
      default:
        return fullname ?? username ?? 'User';
    }
  }
}

/// Classe helper pour créer des utilisateurs VyBzzZ
class VyBzzZUserHelper {
  /// Crée un Map pour Firebase avec les champs VyBzzZ
  static Map<String, dynamic> createVyBzzZUserData({
    required String fullname,
    required String username,
    required String userEmail,
    required UserType userType,
    SubscriptionTier? subscriptionTier,
    String? stripeAccountId,
    String? stripeCustomerId,
    String? affiliateCode,
    int? referredBy,
  }) {
    return {
      'fullname': fullname,
      'username': username,
      'user_email': userEmail,
      'user_type': userType.value,
      'subscription_tier': subscriptionTier?.value,
      'stripe_account_id': stripeAccountId,
      'stripe_customer_id': stripeCustomerId,
      'affiliate_code': affiliateCode,
      'referred_by': referredBy,
      'is_verify': 0,
      'follower_count': 0,
      'following_count': 0,
      'coin_wallet': 0,
      'is_moderator': userType == UserType.artist ? 1 : 0,
    };
  }

  /// Met à jour le type d'utilisateur
  static Map<String, dynamic> updateUserType(UserType type) {
    return {
      'user_type': type.value,
      'is_moderator': type == UserType.artist ? 1 : 0,
    };
  }

  /// Met à jour le palier d'abonnement
  static Map<String, dynamic> updateSubscriptionTier(SubscriptionTier tier) {
    return {
      'subscription_tier': tier.value,
    };
  }

  /// Met à jour les IDs Stripe
  static Map<String, dynamic> updateStripeIds({
    String? accountId,
    String? customerId,
  }) {
    final data = <String, dynamic>{};
    if (accountId != null) data['stripe_account_id'] = accountId;
    if (customerId != null) data['stripe_customer_id'] = customerId;
    return data;
  }

  /// Génère un code d'affiliation unique
  static String generateAffiliateCode(String username) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final code = '${username.toUpperCase()}_${timestamp.toString().substring(7)}';
    return code.replaceAll(' ', '').substring(0, 12);
  }
}
