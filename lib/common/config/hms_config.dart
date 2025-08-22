/// Configuration pour 100ms.live
class HMSConfig {
  // Configuration de base 100ms.live
  static const String appGroupId = 'your_app_group_id'; // À configurer dans 100ms.live
  static const String templateId = 'your_template_id'; // À configurer dans 100ms.live
  
  // URLs de l'API 100ms.live
  static const String apiBaseUrl = 'https://api.100ms.live';
  static const String tokenEndpoint = '/v2/token';
  
  // Configuration des rooms
  static const int maxParticipants = 1000; // Limite de participants par room
  static const int maxCoHosts = 4; // Limite de co-hosts
  
  // Configuration vidéo
  static const int defaultVideoBitrate = 1000; // kbps
  static const int defaultAudioBitrate = 64; // kbps
  static const String defaultVideoCodec = 'H264';
  static const String defaultAudioCodec = 'AAC';
  
  // Configuration des permissions
  static const bool allowCameraByDefault = true;
  static const bool allowMicrophoneByDefault = true;
  static const bool allowScreenShare = false; // Pour l'instant
  
  // Configuration des métriques
  static const bool enableAnalytics = true;
  static const bool enableQualityMetrics = true;
  
  // Configuration des timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int reconnectionTimeout = 5000; // 5 secondes
  static const int maxReconnectionAttempts = 3;
  
  // Configuration des notifications
  static const bool enablePushNotifications = true;
  static const bool enableInAppNotifications = true;
  
  /// Vérifier si la configuration est valide
  static bool get isConfigValid {
    return appGroupId != 'your_app_group_id' && 
           templateId != 'your_template_id';
  }
  
  /// Obtenir la configuration pour le développement
  static Map<String, dynamic> get devConfig {
    return {
      'appGroupId': appGroupId,
      'templateId': templateId,
      'maxParticipants': maxParticipants,
      'maxCoHosts': maxCoHosts,
      'videoBitrate': defaultVideoBitrate,
      'audioBitrate': defaultAudioBitrate,
      'videoCodec': defaultVideoCodec,
      'audioCodec': defaultAudioCodec,
    };
  }
  
  /// Obtenir la configuration pour la production
  static Map<String, dynamic> get prodConfig {
    return {
      'appGroupId': appGroupId,
      'templateId': templateId,
      'maxParticipants': maxParticipants * 10, // 10x plus de participants en prod
      'maxCoHosts': maxCoHosts,
      'videoBitrate': defaultVideoBitrate * 2, // Qualité plus élevée en prod
      'audioBitrate': defaultAudioBitrate * 2,
      'videoCodec': defaultVideoCodec,
      'audioCodec': defaultAudioCodec,
    };
  }
}
