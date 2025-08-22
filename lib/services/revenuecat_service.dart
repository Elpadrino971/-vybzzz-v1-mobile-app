import 'dart:convert';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/subscription_model.dart';
import '../models/product_model.dart';

class RevenueCatService extends GetxService {
  static RevenueCatService get to => Get.find();
  
  final _storage = GetStorage();
  final _apiBaseUrl = 'https://api.vybzzz.online/api/revenuecat';
  
  // Variables observables
  final _isInitialized = false.obs;
  final _customerInfo = Rxn<CustomerInfo>();
  final _availableProducts = <StoreProduct>[].obs;
  final _subscriptionStatus = 'inactive'.obs;
  
  // Getters
  bool get isInitialized => _isInitialized.value;
  CustomerInfo? get customerInfo => _customerInfo.value;
  List<StoreProduct> get availableProducts => _availableProducts;
  String get subscriptionStatus => _subscriptionStatus.value;
  
  // Configuration des produits VyBzzZ
  static const Map<String, String> _productIds = {
    'premium_monthly': 'vybzzz_premium_monthly',
    'premium_yearly': 'vybzzz_premium_yearly',
    'pro_monthly': 'vybzzz_pro_monthly',
    'pro_yearly': 'vybzzz_pro_yearly',
  };
  
  // Configuration des entitlements
  static const Map<String, String> _entitlements = {
    'premium': 'premium_access',
    'pro': 'pro_access',
    'basic': 'basic_access',
  };

  @override
  void onInit() {
    super.onInit();
    _initializeRevenueCat();
  }

  /// Initialiser RevenueCat
  Future<void> _initializeRevenueCat() async {
    try {
      // Configuration RevenueCat
      PurchasesConfiguration configuration = PurchasesConfiguration(
        'appl_VOTRE_CLE_PUBLIQUE_ICI', // Remplacez par votre clé publique RevenueCat
      );
      
      await Purchases.configure(configuration);
      
      // Écouter les changements d'état d'abonnement
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfo.value = customerInfo;
        _updateSubscriptionStatus(customerInfo);
        _saveCustomerInfo(customerInfo);
      });
      
      _isInitialized.value = true;
      print('RevenueCat initialisé avec succès');
      
      // Charger les informations client existantes
      await _loadCustomerInfo();
      
    } catch (e) {
      print('Erreur lors de l\'initialisation de RevenueCat: $e');
      _isInitialized.value = false;
    }
  }

  /// Identifier l'utilisateur
  Future<void> identifyUser(String userId) async {
    try {
      if (!_isInitialized.value) {
        await _initializeRevenueCat();
      }
      
      await Purchases.logIn(userId);
      print('Utilisateur identifié: $userId');
      
    } catch (e) {
      print('Erreur lors de l\'identification: $e');
    }
  }

  /// Charger les produits disponibles
  Future<void> loadProducts() async {
    try {
      if (!_isInitialized.value) {
        await _initializeRevenueCat();
      }
      
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current != null) {
        _availableProducts.value = offerings.current!.availablePackages
            .map((package) => package.storeProduct)
            .toList();
      }
      
      print('Produits chargés: ${_availableProducts.length}');
      
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }

  /// Acheter un produit
  Future<bool> purchaseProduct(StoreProduct product) async {
    try {
      if (!_isInitialized.value) {
        await _initializeRevenueCat();
      }
      
      final customerInfo = await Purchases.purchaseStoreProduct(product);
      _customerInfo.value = customerInfo;
      _updateSubscriptionStatus(customerInfo);
      _saveCustomerInfo(customerInfo);
      
      print('Produit acheté avec succès: ${product.identifier}');
      return true;
      
    } catch (e) {
      print('Erreur lors de l\'achat: $e');
      return false;
    }
  }

  /// Restaurer les achats
  Future<bool> restorePurchases() async {
    try {
      if (!_isInitialized.value) {
        await _initializeRevenueCat();
      }
      
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo.value = customerInfo;
      _updateSubscriptionStatus(customerInfo);
      _saveCustomerInfo(customerInfo);
      
      print('Achats restaurés avec succès');
      return true;
      
    } catch (e) {
      print('Erreur lors de la restauration: $e');
      return false;
    }
  }

  /// Vérifier l'accès à une fonctionnalité
  bool hasAccess(String feature) {
    if (_customerInfo.value == null) return false;
    
    final entitlements = _customerInfo.value!.entitlements.active;
    
    switch (feature) {
      case 'unlimited_videos':
        return entitlements.containsKey(_entitlements['premium']) || 
               entitlements.containsKey(_entitlements['pro']);
      case 'advanced_filters':
        return entitlements.containsKey(_entitlements['premium']) || 
               entitlements.containsKey(_entitlements['pro']);
      case 'no_watermark':
        return entitlements.containsKey(_entitlements['premium']) || 
               entitlements.containsKey(_entitlements['pro']);
      case 'custom_branding':
        return entitlements.containsKey(_entitlements['pro']);
      case 'analytics_dashboard':
        return entitlements.containsKey(_entitlements['pro']);
      default:
        return false;
    }
  }

  /// Obtenir le niveau d'abonnement actuel
  String getCurrentSubscriptionLevel() {
    if (_customerInfo.value == null) return 'basic';
    
    final entitlements = _customerInfo.value!.entitlements.active;
    
    if (entitlements.containsKey(_entitlements['pro'])) {
      return 'pro';
    } else if (entitlements.containsKey(_entitlements['premium'])) {
      return 'premium';
    } else {
      return 'basic';
    }
  }

  /// Vérifier si l'abonnement est actif
  bool get isSubscriptionActive {
    return _subscriptionStatus.value == 'active';
  }

  /// Vérifier si l'utilisateur a un abonnement premium
  bool get isPremium {
    return hasAccess('unlimited_videos');
  }

  /// Vérifier si l'utilisateur a un abonnement pro
  bool get isPro {
    return hasAccess('custom_branding');
  }

  /// Mettre à jour le statut d'abonnement
  void _updateSubscriptionStatus(CustomerInfo customerInfo) {
    final entitlements = customerInfo.entitlements.active;
    
    if (entitlements.isNotEmpty) {
      _subscriptionStatus.value = 'active';
    } else {
      _subscriptionStatus.value = 'inactive';
    }
  }

  /// Sauvegarder les informations client
  void _saveCustomerInfo(CustomerInfo customerInfo) {
    try {
      final data = {
        'originalAppUserId': customerInfo.originalAppUserId,
        'originalApplicationId': customerInfo.originalApplicationId,
        'requestDate': customerInfo.requestDate?.toIso8601String(),
        'firstSeen': customerInfo.firstSeen?.toIso8601String(),
        'entitlements': customerInfo.entitlements.active.map((key, value) => MapEntry(key, {
          'identifier': value.identifier,
          'isActive': value.isActive,
          'willRenew': value.willRenew,
          'periodType': value.periodType.toString(),
          'latestPurchaseDate': value.latestPurchaseDate?.toIso8601String(),
          'originalPurchaseDate': value.originalPurchaseDate?.toIso8601String(),
          'expirationDate': value.expirationDate?.toIso8601String(),
          'store': value.store.toString(),
          'productIdentifier': value.productIdentifier,
          'isSandbox': value.isSandbox,
          'unsubscribeDetectedAt': value.unsubscribeDetectedAt?.toIso8601String(),
          'billingIssueDetectedAt': value.billingIssueDetectedAt?.toIso8601String(),
        })),
      };
      
      _storage.write('revenuecat_customer_info', jsonEncode(data));
      
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  /// Charger les informations client sauvegardées
  Future<void> _loadCustomerInfo() async {
    try {
      final data = _storage.read('revenuecat_customer_info');
      if (data != null) {
        // Note: Cette méthode ne restaure pas complètement l'objet CustomerInfo
        // mais permet de conserver certaines informations entre les sessions
        print('Informations client chargées depuis le stockage local');
      }
    } catch (e) {
      print('Erreur lors du chargement: $e');
    }
  }

  /// Synchroniser avec le backend
  Future<void> syncWithBackend() async {
    try {
      // Cette méthode peut être utilisée pour synchroniser les informations
      // d'abonnement avec votre backend Laravel
      print('Synchronisation avec le backend RevenueCat');
      
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  /// Obtenir les informations d'abonnement formatées
  SubscriptionModel? getSubscriptionInfo() {
    if (_customerInfo.value == null) return null;
    
    final entitlements = _customerInfo.value!.entitlements.active;
    if (entitlements.isEmpty) return null;
    
    // Prendre le premier entitlement actif
    final entitlement = entitlements.values.first;
    
    return SubscriptionModel(
      id: entitlement.identifier,
      status: entitlement.isActive ? 'active' : 'inactive',
      productId: entitlement.productIdentifier,
      startDate: entitlement.originalPurchaseDate,
      endDate: entitlement.expirationDate,
      willRenew: entitlement.willRenew,
      store: entitlement.store.toString(),
    );
  }

  /// Obtenir la liste des produits formatés
  List<ProductModel> getFormattedProducts() {
    return _availableProducts.map((product) => ProductModel(
      id: product.identifier,
      title: product.title,
      description: product.description,
      price: product.price,
      currencyCode: product.currencyCode,
      priceString: product.priceString,
    )).toList();
  }

  /// Déconnexion de l'utilisateur
  Future<void> logout() async {
    try {
      await Purchases.logOut();
      _customerInfo.value = null;
      _subscriptionStatus.value = 'inactive';
      _storage.remove('revenuecat_customer_info');
      
      print('Utilisateur déconnecté de RevenueCat');
      
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
}
