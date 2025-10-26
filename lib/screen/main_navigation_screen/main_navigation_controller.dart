import 'package:get/get.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';
import 'package:vybzzz/model/user_model/user_vybzzz_extension.dart';

/// Controller pour la navigation principale
class MainNavigationController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Index de l'onglet actif
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Reset to first tab when navigation screen loads
    currentIndex.value = 0;
  }

  // ============================================
  // GETTERS
  // ============================================

  /// Est-ce que l'utilisateur est un artiste?
  bool get isArtist {
    final user = _authController.currentUser.value;
    if (user == null) return false;
    return user.userType.isArtist;
  }

  /// Est-ce que l'utilisateur est un Business Bringer?
  bool get isBusinessBringer {
    final user = _authController.currentUser.value;
    if (user == null) return false;
    return user.userType == UserType.businessBringer;
  }

  /// Est-ce que l'utilisateur est un Regional Manager?
  bool get isRegionalManager {
    final user = _authController.currentUser.value;
    if (user == null) return false;
    return user.userType == UserType.regionalManager;
  }

  /// Nombre d'onglets selon le type d'utilisateur
  int get tabCount {
    if (isArtist) return 4; // Home, Dashboard, Create, Tickets
    if (isBusinessBringer || isRegionalManager) {
      return 3; // Home, Tickets, Stats
    }
    return 2; // Home, Tickets (Fan)
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void changeTab(int index) {
    if (index >= 0 && index < tabCount) {
      currentIndex.value = index;
    }
  }

  void goToHome() => changeTab(0);
  void goToTickets() {
    if (isArtist) {
      changeTab(3);
    } else {
      changeTab(1);
    }
  }

  void goToDashboard() {
    if (isArtist) changeTab(1);
  }

  void goToCreateEvent() {
    if (isArtist) changeTab(2);
  }
}
