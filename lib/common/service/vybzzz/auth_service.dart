import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/user_model/user_model.dart';

/// Service d'authentification VyBzzZ
///
/// Gère l'authentification Firebase avec :
/// - Email/Password
/// - Google Sign-In
/// - Création/mise à jour des profils utilisateurs

class VyBzzZAuthService {
  static final VyBzzZAuthService _instance = VyBzzZAuthService._internal();
  factory VyBzzZAuthService() => _instance;
  VyBzzZAuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // GETTERS
  // ============================================

  /// Récupère l'utilisateur Firebase actuellement connecté
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Vérifie si un utilisateur est connecté
  bool get isLoggedIn => currentFirebaseUser != null;

  /// Stream d'état de connexion
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // ============================================
  // EMAIL/PASSWORD AUTH
  // ============================================

  /// Inscription avec email et mot de passe
  Future<firebase_auth.UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullname,
    required String username,
  }) async {
    try {
      // Vérifier si le username existe déjà
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        throw Exception('Ce nom d\'utilisateur est déjà pris');
      }

      // Créer le compte Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le profil utilisateur dans Firestore
      if (credential.user != null) {
        await _createUserProfile(
          firebaseUid: credential.user!.uid,
          email: email,
          fullname: fullname,
          username: username,
          loginMethod: 'email',
        );

        // Envoyer l'email de vérification
        await credential.user!.sendEmailVerification();
      }

      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// Connexion avec email et mot de passe
  Future<firebase_auth.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // ============================================
  // GOOGLE SIGN-IN
  // ============================================

  /// Connexion avec Google
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer les credentials Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter à Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Vérifier si c'est un nouvel utilisateur
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Créer le profil utilisateur
        await _createUserProfile(
          firebaseUid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          fullname: userCredential.user!.displayName ?? 'Utilisateur',
          username: _generateUsernameFromEmail(userCredential.user!.email!),
          loginMethod: 'google',
          profilePhoto: userCredential.user!.photoURL,
        );
      }

      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  /// Envoyer un email de réinitialisation de mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'email: $e');
    }
  }

  /// Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Réauthentifier l'utilisateur
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Changer le mot de passe
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors du changement de mot de passe: $e');
    }
  }

  // ============================================
  // LOGOUT
  // ============================================

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Récupère le profil utilisateur depuis Firestore
  Future<User?> getUserProfile(String firebaseUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('identity', isEqualTo: firebaseUid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return User.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  /// Met à jour le profil utilisateur
  Future<void> updateUserProfile(User user) async {
    try {
      if (user.id == null) {
        throw Exception('L\'ID de l\'utilisateur est requis');
      }

      final doc = await _firestore
          .collection('users')
          .where('id', isEqualTo: user.id)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        throw Exception('Utilisateur introuvable');
      }

      await _firestore.collection('users').doc(doc.docs.first.id).update(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  /// Crée un profil utilisateur dans Firestore
  Future<void> _createUserProfile({
    required String firebaseUid,
    required String email,
    required String fullname,
    required String username,
    required String loginMethod,
    String? profilePhoto,
  }) async {
    try {
      // Générer un ID unique
      final userId = DateTime.now().millisecondsSinceEpoch;

      final user = User(
        id: userId,
        identity: firebaseUid,
        fullname: fullname,
        username: username,
        userEmail: email,
        profilePhoto: profilePhoto,
        loginMethod: loginMethod,
        isVerify: 0,
        isModerator: 0,
        followerCount: 0,
        followingCount: 0,
        coinWallet: 0,
        coinCollectedLifetime: 0,
        coinGiftedLifetime: 0,
        coinPurchasedLifetime: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('users').add(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création du profil: $e');
    }
  }

  /// Vérifie si un username existe déjà
  Future<bool> _checkUsernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Génère un username à partir d'un email
  String _generateUsernameFromEmail(String email) {
    final username = email.split('@')[0].toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
    return '$username$timestamp';
  }

  /// Gère les exceptions Firebase Auth
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'weak-password':
        message = 'Le mot de passe est trop faible';
        break;
      case 'email-already-in-use':
        message = 'Un compte existe déjà avec cet email';
        break;
      case 'invalid-email':
        message = 'L\'adresse email est invalide';
        break;
      case 'user-not-found':
        message = 'Aucun utilisateur trouvé avec cet email';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect';
        break;
      case 'user-disabled':
        message = 'Ce compte a été désactivé';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives. Réessayez plus tard';
        break;
      case 'operation-not-allowed':
        message = 'Cette méthode de connexion n\'est pas activée';
        break;
      case 'requires-recent-login':
        message = 'Veuillez vous reconnecter pour effectuer cette action';
        break;
      default:
        message = 'Erreur d\'authentification: ${e.message}';
    }

    return Exception(message);
  }

  // ============================================
  // ACCOUNT DELETION
  // ============================================

  /// Supprimer le compte utilisateur
  Future<void> deleteAccount(String password) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Réauthentifier pour la suppression
      if (user.email != null) {
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Supprimer le profil de Firestore
      final profile = await getUserProfile(user.uid);
      if (profile?.id != null) {
        final doc = await _firestore
            .collection('users')
            .where('id', isEqualTo: profile!.id)
            .limit(1)
            .get();

        if (doc.docs.isNotEmpty) {
          await _firestore.collection('users').doc(doc.docs.first.id).delete();
        }
      }

      // Supprimer le compte Firebase
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: $e');
    }
  }
}
