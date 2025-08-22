class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currencyCode;
  final String priceString;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.priceString,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currencyCode: json['currency_code'] ?? 'USD',
      priceString: json['price_string'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency_code': currencyCode,
      'price_string': priceString,
    };
  }

  /// Obtenir le type de produit basé sur l'ID
  String get productType {
    if (id.contains('premium')) {
      return 'premium';
    } else if (id.contains('pro')) {
      return 'pro';
    } else {
      return 'basic';
    }
  }

  /// Obtenir la période d'abonnement
  String get subscriptionPeriod {
    if (id.contains('yearly') || id.contains('annual')) {
      return 'yearly';
    } else if (id.contains('monthly')) {
      return 'monthly';
    } else {
      return 'unknown';
    }
  }

  /// Obtenir le nom d'affichage formaté
  String get displayName {
    final type = productType == 'premium' ? 'Premium' : 
                 productType == 'pro' ? 'Pro' : 'Basic';
    final period = subscriptionPeriod == 'yearly' ? 'Annuel' : 
                   subscriptionPeriod == 'monthly' ? 'Mensuel' : '';
    
    return '$type $period'.trim();
  }

  /// Obtenir la description des fonctionnalités
  List<String> get features {
    switch (productType) {
      case 'premium':
        return [
          'Vidéos illimitées',
          'Filtres avancés',
          'Sans watermark',
          'Support prioritaire',
        ];
      case 'pro':
        return [
          'Vidéos illimitées',
          'Filtres avancés',
          'Sans watermark',
          'Support prioritaire',
          'Marque personnalisée',
          'Tableau de bord analytique',
        ];
      default:
        return [
          'Vidéos limitées',
          'Filtres de base',
          'Avec watermark',
        ];
    }
  }

  /// Obtenir le prix formaté avec devise
  String get formattedPrice {
    return '$priceString $currencyCode';
  }

  /// Vérifier si c'est un abonnement annuel
  bool get isYearly => subscriptionPeriod == 'yearly';

  /// Vérifier si c'est un abonnement mensuel
  bool get isMonthly => subscriptionPeriod == 'monthly';

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, price: $priceString)';
  }
}
