class RevenueCatConfig {
  // Configuration des produits VyBzzZ
  static const Map<String, ProductConfig> products = {
    'vybzzz_premium_monthly': ProductConfig(
      id: 'vybzzz_premium_monthly',
      title: 'VyBzzZ Premium Mensuel',
      description: 'Accès premium mensuel avec fonctionnalités avancées',
      price: 9.99,
      currency: 'EUR',
      features: [
        'unlimited_videos',
        'advanced_filters',
        'no_watermark',
        'priority_support'
      ],
      entitlement: 'premium_access',
      period: 'monthly',
    ),
    'vybzzz_premium_yearly': ProductConfig(
      id: 'vybzzz_premium_yearly',
      title: 'VyBzzZ Premium Annuel',
      description: 'Accès premium annuel avec 2 mois gratuits',
      price: 99.99,
      currency: 'EUR',
      features: [
        'unlimited_videos',
        'advanced_filters',
        'no_watermark',
        'priority_support'
      ],
      entitlement: 'premium_access',
      period: 'yearly',
      savings: '2 mois gratuits',
    ),
    'vybzzz_pro_monthly': ProductConfig(
      id: 'vybzzz_pro_monthly',
      title: 'VyBzzZ Pro Mensuel',
      description: 'Accès professionnel mensuel avec toutes les fonctionnalités',
      price: 19.99,
      currency: 'EUR',
      features: [
        'unlimited_videos',
        'advanced_filters',
        'no_watermark',
        'priority_support',
        'custom_branding',
        'analytics_dashboard'
      ],
      entitlement: 'pro_access',
      period: 'monthly',
    ),
    'vybzzz_pro_yearly': ProductConfig(
      id: 'vybzzz_pro_yearly',
      title: 'VyBzzZ Pro Annuel',
      description: 'Accès professionnel annuel avec 2 mois gratuits',
      price: 199.99,
      currency: 'EUR',
      features: [
        'unlimited_videos',
        'advanced_filters',
        'no_watermark',
        'priority_support',
        'custom_branding',
        'analytics_dashboard'
      ],
      entitlement: 'pro_access',
      period: 'yearly',
      savings: '2 mois gratuits',
    ),
  };

  // Configuration des entitlements
  static const Map<String, EntitlementConfig> entitlements = {
    'premium_access': EntitlementConfig(
      id: 'premium_access',
      name: 'Accès Premium',
      description: 'Accès aux fonctionnalités premium de VyBzzZ',
      features: [
        'unlimited_videos',
        'advanced_filters',
        'no_watermark',
        'priority_support'
      ],
    ),
    'pro_access': EntitlementConfig(
      id: 'pro_access',
      name: 'Accès Pro',
      description: 'Accès aux fonctionnalités professionnelles de VyBzzZ',
      features: [
        'unlimited_videos',
        'advanced_filters',
        'no_watermark',
        'priority_support',
        'custom_branding',
        'analytics_dashboard'
      ],
    ),
    'basic_access': EntitlementConfig(
      id: 'basic_access',
      name: 'Accès Basique',
      description: 'Accès aux fonctionnalités de base de VyBzzZ',
      features: [
        'limited_videos',
        'basic_filters',
        'with_watermark'
      ],
    ),
  };

  // Configuration des fonctionnalités
  static const Map<String, FeatureConfig> features = {
    'unlimited_videos': FeatureConfig(
      id: 'unlimited_videos',
      name: 'Vidéos illimitées',
      description: 'Créez autant de vidéos que vous voulez',
      icon: '🎬',
      requiredLevel: 'premium',
    ),
    'advanced_filters': FeatureConfig(
      id: 'advanced_filters',
      name: 'Filtres avancés',
      description: 'Accédez à tous nos filtres et effets premium',
      icon: '✨',
      requiredLevel: 'premium',
    ),
    'no_watermark': FeatureConfig(
      id: 'no_watermark',
      name: 'Sans watermark',
      description: 'Vos vidéos sans marque VyBzzZ',
      icon: '🚫',
      requiredLevel: 'premium',
    ),
    'priority_support': FeatureConfig(
      id: 'priority_support',
      name: 'Support prioritaire',
      description: 'Support client prioritaire et dédié',
      icon: '🎯',
      requiredLevel: 'premium',
    ),
    'custom_branding': FeatureConfig(
      id: 'custom_branding',
      name: 'Marque personnalisée',
      description: 'Ajoutez votre propre logo et marque',
      icon: '🏷️',
      requiredLevel: 'pro',
    ),
    'analytics_dashboard': FeatureConfig(
      id: 'analytics_dashboard',
      name: 'Tableau de bord analytique',
      description: 'Suivez les performances de vos vidéos',
      icon: '📊',
      requiredLevel: 'pro',
    ),
    'limited_videos': FeatureConfig(
      id: 'limited_videos',
      name: 'Vidéos limitées',
      description: 'Nombre limité de vidéos par mois',
      icon: '📹',
      requiredLevel: 'basic',
    ),
    'basic_filters': FeatureConfig(
      id: 'basic_filters',
      name: 'Filtres de base',
      description: 'Accès aux filtres essentiels',
      icon: '🔧',
      requiredLevel: 'basic',
    ),
    'with_watermark': FeatureConfig(
      id: 'with_watermark',
      name: 'Avec watermark',
      description: 'Vidéos avec marque VyBzzZ',
      icon: '💧',
      requiredLevel: 'basic',
    ),
  };

  // Obtenir la configuration d'un produit
  static ProductConfig? getProduct(String productId) {
    return products[productId];
  }

  // Obtenir la configuration d'un entitlement
  static EntitlementConfig? getEntitlement(String entitlementId) {
    return entitlements[entitlementId];
  }

  // Obtenir la configuration d'une fonctionnalité
  static FeatureConfig? getFeature(String featureId) {
    return features[featureId];
  }

  // Obtenir tous les produits d'un niveau
  static List<ProductConfig> getProductsByLevel(String level) {
    return products.values
        .where((product) => product.entitlement == '${level}_access')
        .toList();
  }

  // Obtenir toutes les fonctionnalités d'un niveau
  static List<FeatureConfig> getFeaturesByLevel(String level) {
    return features.values
        .where((feature) => feature.requiredLevel == level)
        .toList();
  }

  // Vérifier si un produit a une fonctionnalité
  static bool productHasFeature(String productId, String featureId) {
    final product = products[productId];
    if (product == null) return false;
    
    return product.features.contains(featureId);
  }

  // Obtenir le niveau minimum requis pour une fonctionnalité
  static String getRequiredLevelForFeature(String featureId) {
    final feature = features[featureId];
    return feature?.requiredLevel ?? 'basic';
  }
}

class ProductConfig {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> features;
  final String entitlement;
  final String period;
  final String? savings;

  const ProductConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.features,
    required this.entitlement,
    required this.period,
    this.savings,
  });
}

class EntitlementConfig {
  final String id;
  final String name;
  final String description;
  final List<String> features;

  const EntitlementConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.features,
  });
}

class FeatureConfig {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String requiredLevel;

  const FeatureConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredLevel,
  });
}
