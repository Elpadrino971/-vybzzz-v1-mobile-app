# 🎭 Guide de Configuration DeepAR pour VyBzzZ

## 📋 Vue d'ensemble

Ce guide vous accompagne dans l'installation et la configuration complète de DeepAR.ai pour votre application VyBzzZ Flutter.

## 🚀 Installation

### 1. Dépendances Flutter

Les dépendances DeepAR sont déjà configurées dans `pubspec.yaml` :

```yaml
dependencies:
  deepar_flutter_plus: ^0.2.0
```

### 2. Installation des dépendances

```bash
cd VyBzzZ_flutter
flutter pub get
```

## 🔑 Configuration des Clés de Licence

### 1. Obtenir vos clés DeepAR

1. Rendez-vous sur [DeepAR.ai](https://www.deepar.ai/)
2. Créez un compte développeur
3. Générez vos clés de licence pour Android et iOS

### 2. Configuration Backend

Dans votre fichier `.env` du backend :

```env
# Configuration DeepAR
DEEPAR_ANDROID_KEY=votre_clé_android_ici
DEEPAR_IOS_KEY=votre_clé_ios_ici
DEEPAR_ENABLED=true
```

### 3. Configuration Flutter

Dans `lib/common/config/app_config.dart`, ajoutez :

```dart
class AppConfig {
  static const String deeparAndroidKey = 'votre_clé_android_ici';
  static const String deeparIOSKey = 'votre_clé_ios_ici';
}
```

## 📱 Configuration Android

### 1. Permissions

Dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. Configuration build.gradle

Dans `android/app/build.gradle` :

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

## 🍎 Configuration iOS

### 1. Permissions

Dans `ios/Runner/Info.plist` :

```xml
<key>NSCameraUsageDescription</key>
<string>Cette application nécessite l'accès à la caméra pour les effets AR</string>
<key>NSMicrophoneUsageDescription</key>
<string>Cette application nécessite l'accès au microphone pour l'enregistrement</string>
```

### 2. Configuration Podfile

Dans `ios/Podfile` :

```ruby
platform :ios, '12.0'
```

## 🎨 Utilisation des Filtres AR

### 1. Structure des Filtres

Les filtres DeepAR sont stockés dans la base de données avec cette structure :

```sql
CREATE TABLE deepar_filters (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(25),
  image VARCHAR(999),
  filter_file VARCHAR(999),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. Ajout de Filtres via l'Admin

1. Connectez-vous à l'interface d'administration
2. Allez dans "Settings" > "DeepAR Filters"
3. Cliquez sur "Add Filter"
4. Remplissez :
   - **Title** : Nom du filtre (ex: "Sparkle", "Vintage")
   - **Image** : Image de prévisualisation
   - **File** : Fichier .ar du filtre

### 3. Filtres d'Exemple

Voici quelques filtres populaires que vous pouvez ajouter :

- **Sparkle** : Effet de paillettes
- **Vintage** : Filtre rétro
- **Neon** : Effet néon coloré
- **Glitch** : Effet de glitch numérique
- **Rainbow** : Effet arc-en-ciel

## 🔧 Code d'Intégration

### 1. Initialisation DeepAR

```dart
class CameraScreenController extends GetxController {
  final Rx<DeepArControllerPlus> deepArControllerPlus = DeepArControllerPlus().obs;
  RxBool isDeepARInitialized = false.obs;
  
  Future<void> _initDeepArCamera() async {
    try {
      await deepArControllerPlus.value.initialize(
        androidLicenseKey: appSetting?.deeparAndroidKey,
        iosLicenseKey: appSetting?.deeparIOSKey,
        resolution: Resolution.high
      );
      deepArControllerPlus.value.switchEffect('');
      isDeepARInitialized.value = true;
    } catch (e) {
      Loggers.error('Error initializing AR: $e');
    }
  }
}
```

### 2. Application des Filtres

```dart
Future<void> applyARFilterEffect(DeepARFilters effect) async {
  selectedEffect.value = effect;
  
  try {
    if (effect.id != -1) {
      showLoader();
      
      // Télécharger le fichier de filtre AR
      final fileInfo = await DefaultCacheManager()
          .downloadFile(effect.filterFile?.addBaseURL() ?? '');
      
      stopLoader();
      deepArControllerPlus.value.switchEffect(fileInfo.file.path);
    } else {
      // Effacer l'effet
      deepArControllerPlus.value.switchEffect('');
    }
  } catch (e, stackTrace) {
    stopLoader();
    Loggers.error('Failed to apply AR filter: $e\n$stackTrace');
  }
}
```

### 3. Capture avec Effets AR

```dart
Future<void> capturePhoto() async {
  if (isDeepAr) {
    if (isDeepARInitialized.value == false) return;
  }
  
  try {
    XFile file;
    if (isDeepAr) {
      File photo = await deepArControllerPlus.value.takeScreenshot();
      file = XFile(photo.path);
    } else {
      file = XFile(await RetrytechPlugin.shared.captureImage() ?? '');
    }
    
    await handleImageStory(MediaFile(
      file: file, 
      type: MediaType.image, 
      thumbNail: file
    ));
  } catch (e) {
    Loggers.error("Photo capture error: $e");
  }
}
```

## 🧪 Test et Débogage

### 1. Vérification de l'Installation

```bash
# Vérifier que DeepAR est installé
flutter pub deps | grep deepar

# Analyser le code
flutter analyze

# Tester la compilation
flutter build apk --debug
```

### 2. Logs de Débogage

Activez les logs détaillés dans votre application :

```dart
Loggers.info('DeepAR initialization started');
Loggers.info('DeepAR license key: ${appSetting?.deeparAndroidKey}');
Loggers.info('DeepAR initialized: ${isDeepARInitialized.value}');
```

### 3. Test des Filtres

1. Ouvrez l'application
2. Allez dans l'écran de caméra
3. Activez DeepAR dans les paramètres
4. Testez différents filtres
5. Vérifiez que les effets s'appliquent en temps réel

## 🚨 Résolution des Problèmes

### 1. Erreur d'Initialisation

**Problème** : `Error initializing AR: Invalid license key`

**Solution** :
- Vérifiez vos clés de licence dans le backend
- Assurez-vous que les clés sont valides et non expirées
- Vérifiez la configuration dans `.env`

### 2. Filtres qui ne se Chargent Pas

**Problème** : Les filtres AR ne s'appliquent pas

**Solution** :
- Vérifiez que les fichiers .ar sont bien uploadés
- Contrôlez les permissions de fichiers
- Vérifiez la connexion internet pour le téléchargement

### 3. Performance Lente

**Problème** : L'application est lente avec DeepAR

**Solution** :
- Réduisez la résolution à `Resolution.medium`
- Optimisez la taille des fichiers de filtres
- Utilisez le cache pour les filtres fréquemment utilisés

## 📊 Monitoring et Analytics

### 1. Métriques à Surveiller

- Taux de succès d'initialisation DeepAR
- Temps de chargement des filtres
- Utilisation des différents filtres
- Performance de l'application

### 2. Intégration Analytics

```dart
// Exemple avec Firebase Analytics
await FirebaseAnalytics.instance.logEvent(
  name: 'deepar_filter_applied',
  parameters: {
    'filter_id': effect.id.toString(),
    'filter_name': effect.title,
    'camera_type': cameraType.toString(),
  },
);
```

## 🔮 Fonctionnalités Avancées

### 1. Filtres Personnalisés

Créez vos propres filtres AR avec l'outil DeepAR Studio :
1. Téléchargez [DeepAR Studio](https://www.deepar.ai/studio)
2. Créez votre filtre personnalisé
3. Exportez en format .ar
4. Uploadez dans votre application

### 2. Filtres Dynamiques

Implémentez des filtres qui changent selon :
- L'heure de la journée
- La localisation
- Les événements spéciaux
- Les préférences utilisateur

### 3. Intégration IA

Combinez DeepAR avec des modèles d'IA pour :
- Détection automatique d'objets
- Filtres adaptatifs
- Recommandations personnalisées

## 📚 Ressources Supplémentaires

- [Documentation DeepAR Flutter](https://docs.deepar.ai/flutter)
- [DeepAR Studio](https://www.deepar.ai/studio)
- [Communauté DeepAR](https://community.deepar.ai/)
- [Exemples de Code](https://github.com/deepar-ai/deepar-flutter-examples)

## 🎯 Prochaines Étapes

1. ✅ Installer et configurer DeepAR
2. 🔧 Tester les filtres de base
3. 🎨 Créer des filtres personnalisés
4. 📱 Optimiser les performances
5. 🚀 Déployer en production

---

**Note** : Ce guide est spécifique à VyBzzZ. Pour des informations générales sur DeepAR, consultez la [documentation officielle](https://docs.deepar.ai/).
