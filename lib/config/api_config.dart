class ApiConfig {
  // Configuration pour vybzzz.online
  static const String baseUrl = 'https://api.vybzzz.online/api';
  static const String webUrl = 'https://vybzzz.online';
  static const String adminUrl = 'https://admin.vybzzz.online';
  static const String cdnUrl = 'https://cdn.vybzzz.online';
  
  // Configuration pour les domaines secondaires (futurs)
  static const Map<String, String> secondaryDomains = {
    'com': 'https://vybzzz.com',
    'fr': 'https://vybzzz.fr',
    'app': 'https://vybzzz.app',
  };
  
  // Méthode pour obtenir l'URL selon le domaine
  static String getUrl(String domain) {
    if (domain == 'online') return baseUrl;
    return secondaryDomains[domain] ?? baseUrl;
  }
}
