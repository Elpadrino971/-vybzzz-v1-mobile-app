import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:vybzzz/common/service/vybzzz/auth_service.dart';
import 'package:vybzzz/model/user_model/user_model.dart';
import 'package:vybzzz/common/manager/session_manager.dart';
import 'package:vybzzz/routes/vybzzz_routes.dart';

/// Contrôleur d'authentification VyBzzZ
///
/// Gère l'état de l'authentification et les actions utilisateur

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController extends GetxController {
  final VyBzzZAuthService _authService = VyBzzZAuthService();

  // État
  final Rx<AuthStatus> authStatus = AuthStatus.initial.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthStateChanges();
  }

  // ============================================
  // AUTH STATE LISTENER
  // ============================================

  void _listenToAuthStateChanges() {
    _authService.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        // Utilisateur connecté
        await _loadUserProfile(firebaseUser.uid);
      } else {
        // Utilisateur déconnecté
        currentUser.value = null;
        authStatus.value = AuthStatus.unauthenticated;
        SessionManager.instance.clearSession();
      }
    });
  }

  /// Charge le profil utilisateur depuis Firestore
  Future<void> _loadUserProfile(String firebaseUid) async {
    try {
      final user = await _authService.getUserProfile(firebaseUid);

      if (user != null) {
        currentUser.value = user;
        authStatus.value = AuthStatus.authenticated;

        // Sauvegarder dans la session
        SessionManager.instance.saveUserID(user.id ?? 0);
        SessionManager.instance.saveToken(firebaseUid);

        // Navigation après connexion
        _handlePostAuthNavigation(user);
      } else {
        // Profil non trouvé - rediriger vers la création de profil
        authStatus.value = AuthStatus.unauthenticated;
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement du profil: $e';
      authStatus.value = AuthStatus.error;
    }
  }

  /// Gère la navigation après l'authentification
  void _handlePostAuthNavigation(User user) {
    // Vérifier si l'utilisateur a sélectionné un type
    final userTypeStr = user.data?['user_type'] as String?;

    if (userTypeStr == null || userTypeStr.isEmpty) {
      // Pas de type défini - aller vers la sélection du type
      VyBzzZRoutes.toUserTypeSelection();
    } else {
      // Type défini - aller vers l'écran principal
      VyBzzZRoutes.toMainNavigation();
    }
  }

  // ============================================
  // SIGN UP
  // ============================================

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullname,
    required String username,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullname: fullname,
        username: username,
      );

      isLoading.value = false;

      // Afficher un message de succès
      Get.snackbar(
        'Inscription réussie',
        'Un email de vérification a été envoyé à $email',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur d\'inscription',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  // ============================================
  // SIGN IN
  // ============================================

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur de connexion',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithGoogle();

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur de connexion Google',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.sendPasswordResetEmail(email);

      isLoading.value = false;

      Get.snackbar(
        'Email envoyé',
        'Un email de réinitialisation a été envoyé à $email',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      isLoading.value = false;

      Get.snackbar(
        'Succès',
        'Mot de passe changé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      isLoading.value = false;

      // Rediriger vers la page de connexion
      Get.offAllNamed('/login');
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ============================================
  // PROFILE UPDATE
  // ============================================

  Future<bool> updateProfile(User updatedUser) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.updateUserProfile(updatedUser);
      currentUser.value = updatedUser;

      isLoading.value = false;

      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  // ============================================
  // ACCOUNT DELETION
  // ============================================

  Future<bool> deleteAccount(String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.deleteAccount(password);

      isLoading.value = false;

      Get.snackbar(
        'Compte supprimé',
        'Votre compte a été supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return false;
    }
  }

  // ============================================
  // GETTERS
  // ============================================

  bool get isAuthenticated => authStatus.value == AuthStatus.authenticated;
  bool get isUnauthenticated => authStatus.value == AuthStatus.unauthenticated;
  String get userName => currentUser.value?.fullname ?? '';
  String get userEmail => currentUser.value?.userEmail ?? '';
  String? get userPhoto => currentUser.value?.profilePhoto;
  int? get userId => currentUser.value?.id;
}
