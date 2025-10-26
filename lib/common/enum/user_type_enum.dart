/// Enumération des types d'utilisateurs VyBzzZ
///
/// 5 types de comptes :
/// - Fan : Spectateur/acheteur de billets
/// - Artist : Artiste qui organise des concerts
/// - BusinessBringer : Apporteur d'affaire (affilié)
/// - RegionalManager : Responsable régional
/// - VenueOwner : Propriétaire de salle

enum UserType {
  fan('fan', 'Fan'),
  artist('artist', 'Artiste'),
  businessBringer('business_bringer', 'Apporteur d\'Affaire'),
  regionalManager('regional_manager', 'Responsable Régional'),
  venueOwner('venue_owner', 'Propriétaire de Salle');

  final String value;
  final String displayName;

  const UserType(this.value, this.displayName);

  /// Convertir une string en UserType
  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UserType.fan, // Par défaut : fan
    );
  }

  /// Vérifie si un utilisateur est un artiste
  bool get isArtist => this == UserType.artist;

  /// Vérifie si un utilisateur est un fan
  bool get isFan => this == UserType.fan;

  /// Vérifie si un utilisateur est un PRO (artiste, AA, RM, propriétaire)
  bool get isPro => this != UserType.fan;

  /// Vérifie si un utilisateur peut créer des événements
  bool get canCreateEvents => this == UserType.artist || this == UserType.venueOwner;

  /// Vérifie si un utilisateur peut recevoir des commissions d'affiliation
  bool get canEarnAffiliateCommission => this == UserType.businessBringer || this == UserType.regionalManager;

  /// Obtient l'icône associée au type d'utilisateur
  String get iconPath {
    switch (this) {
      case UserType.fan:
        return 'assets/icons/ic_audience.png';
      case UserType.artist:
        return 'assets/icons/ic_mic.png';
      case UserType.businessBringer:
        return 'assets/icons/ic_handshake.png';
      case UserType.regionalManager:
        return 'assets/icons/ic_manager.png';
      case UserType.venueOwner:
        return 'assets/icons/ic_venue.png';
    }
  }

  /// Obtient la description du type d'utilisateur
  String get description {
    switch (this) {
      case UserType.fan:
        return 'Achetez des billets et profitez des concerts live';
      case UserType.artist:
        return 'Organisez des concerts et recevez vos paiements rapidement';
      case UserType.businessBringer:
        return 'Gagnez des commissions en apportant des artistes';
      case UserType.regionalManager:
        return 'Gérez les opérations dans votre région';
      case UserType.venueOwner:
        return 'Louez votre salle pour des concerts';
    }
  }
}
