/// Configuration des domaines pour VyBzzZ
/// 
/// Ce fichier contient toutes les URLs et domaines utilisés par l'application
/// Mettez à jour ces valeurs selon votre configuration de production

class DomainConfig {
  // ===== DOMAINES DE PRODUCTION =====
  
  /// Domaine principal de l'application
  static const String mainDomain = 'vybzzz.com';
  
  /// Domaine de l'API backend
  static const String apiDomain = 'api.vybzzz.com';
  
  /// Domaine de l'interface d'administration
  static const String adminDomain = 'admin.vybzzz.com';
  
  // ===== URLs COMPLÈTES =====
  
  /// URL principale du site web
  static const String mainUrl = 'https://$mainDomain';
  
  /// URL de l'API avec protocole HTTPS
  static const String apiUrl = 'https://$apiDomain';
  
  /// URL de l'interface d'administration
  static const String adminUrl = 'https://$adminDomain';
  
  // ===== ENDPOINTS API =====
  
  /// Endpoint de base de l'API
  static const String apiBaseUrl = '$apiUrl/api';
  
  /// Endpoint d'authentification
  static const String authEndpoint = '$apiBaseUrl/auth';
  
  /// Endpoint des utilisateurs
  static const String usersEndpoint = '$apiBaseUrl/users';
  
  /// Endpoint des posts
  static const String postsEndpoint = '$apiBaseUrl/posts';
  
  /// Endpoint des stories
  static const String storiesEndpoint = '$apiBaseUrl/stories';
  
  /// Endpoint des commentaires
  static const String commentsEndpoint = '$apiBaseUrl/comments';
  
  /// Endpoint des likes
  static const String likesEndpoint = '$apiBaseUrl/likes';
  
  /// Endpoint des notifications
  static const String notificationsEndpoint = '$apiBaseUrl/notifications';
  
  /// Endpoint des messages
  static const String messagesEndpoint = '$apiBaseUrl/messages';
  
  /// Endpoint des lives
  static const String livesEndpoint = '$apiBaseUrl/lives';
  
  /// Endpoint des traductions
  static const String translationEndpoint = '$apiBaseUrl/translation';
  
  /// Endpoint des paiements
  static const String paymentsEndpoint = '$apiBaseUrl/payments';
  
  /// Endpoint des abonnements
  static const String subscriptionsEndpoint = '$apiBaseUrl/subscriptions';
  
  // ===== ENDPOINTS SPÉCIAUX =====
  
  /// Endpoint de téléchargement des fichiers
  static const String downloadEndpoint = '$apiBaseUrl/download';
  
  /// Endpoint d'upload des fichiers
  static const String uploadEndpoint = '$apiBaseUrl/upload';
  
  /// Endpoint de recherche
  static const String searchEndpoint = '$apiBaseUrl/search';
  
  /// Endpoint des statistiques
  static const String statsEndpoint = '$apiBaseUrl/stats';
  
  // ===== WEBSOCKETS =====
  
  /// URL du serveur WebSocket pour les notifications en temps réel
  static const String websocketUrl = 'wss://$apiDomain/ws';
  
  // ===== STORAGE =====
  
  /// URL de base pour le stockage des fichiers (DigitalOcean Spaces)
  static const String storageUrl = 'https://vybzzz-storage.nyc3.digitaloceanspaces.com';
  
  /// URL des images de profil
  static const String profileImagesUrl = '$storageUrl/profile-images';
  
  /// URL des images de posts
  static const String postImagesUrl = '$storageUrl/post-images';
  
  /// URL des vidéos
  static const String videosUrl = '$storageUrl/videos';
  
  /// URL des audios
  static const String audiosUrl = '$storageUrl/audios';
  
  // ===== CONFIGURATION ENVIRONNEMENT =====
  
  /// Détermine si l'application est en mode production
  static const bool isProduction = true;
  
  /// Détermine si l'application est en mode développement
  static const bool isDevelopment = false;
  
  /// Détermine si l'application est en mode test
  static const bool isTest = false;
  
  // ===== MÉTHODES UTILITAIRES =====
  
  /// Retourne l'URL complète pour un endpoint donné
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl/$endpoint';
  }
  
  /// Retourne l'URL complète pour un fichier de stockage
  static String getStorageUrl(String filePath) {
    return '$storageUrl/$filePath';
  }
  
  /// Retourne l'URL complète pour une image de profil
  static String getProfileImageUrl(String fileName) {
    return '$profileImagesUrl/$fileName';
  }
  
  /// Retourne l'URL complète pour une image de post
  static String getPostImageUrl(String fileName) {
    return '$postImagesUrl/$fileName';
  }
  
  /// Retourne l'URL complète pour une vidéo
  static String getVideoUrl(String fileName) {
    return '$videosUrl/$fileName';
  }
  
  /// Retourne l'URL complète pour un audio
  static String getAudioUrl(String fileName) {
    return '$audiosUrl/$fileName';
  }
  
  /// Vérifie si une URL est valide
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Retourne le domaine d'une URL
  static String? getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }
}

/// Configuration des domaines pour le développement
class DevelopmentDomainConfig extends DomainConfig {
  // ===== DOMAINES DE DÉVELOPPEMENT =====
  
  /// Domaine principal de développement
  static const String devMainDomain = 'localhost';
  
  /// Domaine de l'API de développement
  static const String devApiDomain = 'localhost';
  
  /// Port de l'API de développement
  static const int devApiPort = 8000;
  
  // ===== URLs DE DÉVELOPPEMENT =====
  
  /// URL principale de développement
  static const String devMainUrl = 'http://$devMainDomain:3000';
  
  /// URL de l'API de développement
  static const String devApiUrl = 'http://$devApiDomain:$devApiPort';
  
  /// Endpoint de base de l'API de développement
  static const String devApiBaseUrl = '$devApiUrl/api';
  
  // ===== CONFIGURATION ENVIRONNEMENT =====
  
  /// Détermine si l'application est en mode production
  static const bool isProduction = false;
  
  /// Détermine si l'application est en mode développement
  static const bool isDevelopment = true;
  
  /// Détermine si l'application est en mode test
  static const bool isTest = false;
}

/// Configuration des domaines pour les tests
class TestDomainConfig extends DomainConfig {
  // ===== DOMAINES DE TEST =====
  
  /// Domaine principal de test
  static const String testMainDomain = 'test.vybzzz.com';
  
  /// Domaine de l'API de test
  static const String testApiDomain = 'test-api.vybzzz.com';
  
  // ===== URLs DE TEST =====
  
  /// URL principale de test
  static const String testMainUrl = 'https://$testMainDomain';
  
  /// URL de l'API de test
  static const String testApiUrl = 'https://$testApiDomain';
  
  /// Endpoint de base de l'API de test
  static const String testApiBaseUrl = '$testApiUrl/api';
  
  // ===== CONFIGURATION ENVIRONNEMENT =====
  
  /// Détermine si l'application est en mode production
  static const bool isProduction = false;
  
  /// Détermine si l'application est en mode développement
  static const bool isDevelopment = false;
  
  /// Détermine si l'application est en mode test
  static const bool isTest = true;
}
