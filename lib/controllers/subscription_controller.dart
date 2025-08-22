import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../models/subscription_model.dart';
import '../models/product_model.dart';

class SubscriptionController extends GetxController {
  final RevenueCatService _revenueCatService = Get.find<RevenueCatService>();
  
  // Variables observables
  final _isLoading = false.obs;
  final _subscription = Rxn<SubscriptionModel>();
  final _products = <ProductModel>[].obs;
  final _selectedProduct = Rxn<ProductModel>();
  final _errorMessage = ''.obs;
  final _isPurchasing = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  SubscriptionModel? get subscription => _subscription.value;
  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct.value;
  String get errorMessage => _errorMessage.value;
  bool get isPurchasing => _isPurchasing.value;
  
  // Getters de statut
  bool get hasActiveSubscription => subscription?.isActive ?? false;
  bool get isPremium => _revenueCatService.isPremium;
  bool get isPro => _revenueCatService.isPro;
  String get subscriptionLevel => _revenueCatService.getCurrentSubscriptionLevel();

  @override
  void onInit() {
    super.onInit();
    _initializeSubscription();
  }

  /// Initialiser les informations d'abonnement
  Future<void> _initializeSubscription() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      // Attendre que RevenueCat soit initialisé
      while (!_revenueCatService.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Charger les produits
      await _revenueCatService.loadProducts();
      
      // Charger les informations d'abonnement
      await _loadSubscriptionInfo();
      
      // Charger les produits formatés
      _products.value = _revenueCatService.getFormattedProducts();
      
    } catch (e) {
      _errorMessage.value = 'Erreur lors de l\'initialisation: $e';
      print('Erreur d\'initialisation: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Charger les informations d'abonnement
  Future<void> _loadSubscriptionInfo() async {
    try {
      final subscriptionInfo = _revenueCatService.getSubscriptionInfo();
      _subscription.value = subscriptionInfo;
      
      print('Informations d\'abonnement chargées: ${subscriptionInfo?.status}');
      
    } catch (e) {
      print('Erreur lors du chargement de l\'abonnement: $e');
    }
  }

  /// Sélectionner un produit
  void selectProduct(ProductModel product) {
    _selectedProduct.value = product;
    print('Produit sélectionné: ${product.displayName}');
  }

  /// Acheter le produit sélectionné
  Future<bool> purchaseSelectedProduct() async {
    if (_selectedProduct.value == null) {
      _errorMessage.value = 'Aucun produit sélectionné';
      return false;
    }

    try {
      _isPurchasing.value = true;
      _errorMessage.value = '';
      
      // Trouver le StoreProduct correspondant
      final storeProduct = _revenueCatService.availableProducts
          .firstWhere((product) => product.identifier == _selectedProduct.value!.id);
      
      // Effectuer l'achat
      final success = await _revenueCatService.purchaseProduct(storeProduct);
      
      if (success) {
        // Recharger les informations d'abonnement
        await _loadSubscriptionInfo();
        
        // Réinitialiser la sélection
        _selectedProduct.value = null;
        
        Get.snackbar(
          'Succès',
          'Achat effectué avec succès !',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        
        return true;
      } else {
        _errorMessage.value = 'Échec de l\'achat';
        return false;
      }
      
    } catch (e) {
      _errorMessage.value = 'Erreur lors de l\'achat: $e';
      print('Erreur d\'achat: $e');
      return false;
    } finally {
      _isPurchasing.value = false;
    }
  }

  /// Restaurer les achats
  Future<bool> restorePurchases() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      final success = await _revenueCatService.restorePurchases();
      
      if (success) {
        await _loadSubscriptionInfo();
        
        Get.snackbar(
          'Succès',
          'Achats restaurés avec succès !',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        
        return true;
      } else {
        _errorMessage.value = 'Aucun achat à restaurer';
        return false;
      }
      
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la restauration: $e';
      print('Erreur de restauration: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Vérifier l'accès à une fonctionnalité
  bool checkFeatureAccess(String feature) {
    return _revenueCatService.hasAccess(feature);
  }

  /// Obtenir le niveau d'accès recommandé pour une fonctionnalité
  String getRecommendedSubscriptionLevel(String feature) {
    switch (feature) {
      case 'unlimited_videos':
      case 'advanced_filters':
      case 'no_watermark':
        return 'premium';
      case 'custom_branding':
      case 'analytics_dashboard':
        return 'pro';
      default:
        return 'basic';
    }
  }

  /// Obtenir le produit recommandé pour un niveau
  ProductModel? getRecommendedProduct(String level) {
    try {
      return _products.firstWhere((product) => 
          product.productType == level && 
          product.subscriptionPeriod == 'monthly');
    } catch (e) {
      return null;
    }
  }

  /// Rafraîchir les informations d'abonnement
  Future<void> refreshSubscription() async {
    try {
      _isLoading.value = true;
      await _loadSubscriptionInfo();
    } catch (e) {
      print('Erreur lors du rafraîchissement: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Synchroniser avec le backend
  Future<void> syncWithBackend() async {
    try {
      await _revenueCatService.syncWithBackend();
      print('Synchronisation avec le backend terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage.value = '';
  }

  /// Obtenir le statut d'abonnement formaté
  String get formattedSubscriptionStatus {
    if (subscription?.isActive ?? false) {
      if (subscription?.isExpiringSoon ?? false) {
        return 'Expire bientôt';
      }
      return 'Actif';
    } else if (subscription?.isExpired ?? false) {
      return 'Expiré';
    } else {
      return 'Inactif';
    }
  }

  /// Obtenir la date d'expiration formatée
  String get formattedExpiryDate {
    final endDate = subscription?.endDate;
    if (endDate == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    
    if (difference < 0) {
      return 'Expiré';
    } else if (difference == 0) {
      return 'Expire aujourd\'hui';
    } else if (difference == 1) {
      return 'Expire demain';
    } else if (difference <= 7) {
      return 'Expire dans $difference jours';
    } else {
      return 'Expire le ${endDate.day}/${endDate.month}/${endDate.year}';
    }
  }

  @override
  void onClose() {
    // Nettoyer les ressources si nécessaire
    super.onClose();
  }
}
