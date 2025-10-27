import 'package:get/get.dart';
import 'package:vybzzz/model/vybz_coin_model/vybz_coin_model.dart';
import 'package:vybzzz/common/service/vybzzz/vybz_coin_service.dart';
import 'package:vybzzz/common/service/vybzzz/stripe_service.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Controller pour le shop VyBzzZ
class VybzShopController extends GetxController {
  final VybzCoinService _coinService = VybzCoinService();
  final StripeService _stripeService = StripeService();
  final AuthController _authController = Get.find<AuthController>();

  // Packs disponibles
  final RxList<VybzCoinPack> packs = <VybzCoinPack>[].obs;

  // Solde utilisateur
  final RxInt userBalance = 0.obs;

  // État
  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;

  // Stats
  final RxInt totalSpent = 0.obs;
  final RxDouble totalPurchased = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPacks();
    _loadUserData();
  }

  void _loadPacks() {
    packs.value = VybzCoinPack.defaultPacks;
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;

      final user = _authController.currentUser.value;
      if (user == null) return;

      final userId = user.id!;

      // Charger le solde
      final balance = await _coinService.getUserBalance(userId);
      userBalance.value = balance;

      // Stream du solde
      _coinService.streamUserBalance(userId).listen((balance) {
        userBalance.value = balance;
      });

      // Charger les stats
      final spent = await _coinService.getTotalSpent(userId);
      final purchased = await _coinService.getTotalPurchased(userId);

      totalSpent.value = spent;
      totalPurchased.value = purchased;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Loggers.error('Erreur load user data: $e');
    }
  }

  // ============================================
  // PURCHASE
  // ============================================

  Future<void> purchasePack(VybzCoinPack pack) async {
    try {
      isPurchasing.value = true;

      final user = _authController.currentUser.value;
      if (user == null) {
        Get.snackbar('Erreur', 'Vous devez être connecté');
        isPurchasing.value = false;
        return;
      }

      // 1. Créer Payment Intent avec Stripe
      final paymentData = await _stripeService.createPaymentIntent(
        amount: pack.priceEur,
        currency: 'eur',
        buyerId: user.id!,
        artistId: 0, // Platform purchase
        eventId: 'vybz_shop',
        eventTitle: 'Pack ${pack.name}',
      );

      final paymentIntentId = paymentData['paymentIntentId'] as String;
      final clientSecret = paymentData['clientSecret'] as String;

      // 2. Confirmer le paiement
      final success = await _stripeService.confirmPaymentIntent(
        paymentIntentId: paymentIntentId,
        clientSecret: clientSecret,
      );

      if (!success) {
        throw Exception('Paiement échoué');
      }

      // 3. Ajouter les Vybz au compte
      final purchaseSuccess = await _coinService.purchasePack(
        userId: user.id!,
        pack: pack,
        stripePaymentIntentId: paymentIntentId,
      );

      if (!purchaseSuccess) {
        throw Exception('Erreur lors de l\'ajout des Vybz');
      }

      isPurchasing.value = false;

      // Success!
      Get.snackbar(
        'Succès! ${pack.icon}',
        '${pack.totalVybz} Vybz ajoutés à votre compte!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Recharger le solde
      await _loadUserData();
    } catch (e) {
      isPurchasing.value = false;
      Loggers.error('Erreur purchase pack: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'acheter le pack: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  String getBalanceInEur() {
    return VybzCoin.vybzToEur(userBalance.value).toStringAsFixed(2);
  }
}
