# 🚀 Guide de Configuration Complète - VyBzzZ

Guide détaillé pour configurer Firebase, Stripe Connect et 100MS pour VyBzzZ.

## 📋 Table des Matières

1. [Configuration Firebase](#1-configuration-firebase)
2. [Configuration Stripe Connect](#2-configuration-stripe-connect)
3. [Configuration 100MS Live](#3-configuration-100ms-live)
4. [Variables d'Environnement](#4-variables-denvironnement)
5. [Test de l'Application](#5-test-de-lapplication)
6. [Déploiement](#6-déploiement)

---

## 1. Configuration Firebase

### Étape 1.1 : Créer un Projet Firebase

1. Aller sur [console.firebase.google.com](https://console.firebase.google.com)
2. Cliquer sur "Ajouter un projet"
3. Nom du projet : `VyBzzZ`
4. Activer Google Analytics (recommandé)
5. Créer le projet

### Étape 1.2 : Ajouter une Application Android

1. Dans la console Firebase, cliquer sur l'icône Android
2. **Package name** : `com.retrytech.vybzzz` (vérifier dans `android/app/build.gradle`)
3. **App nickname** : `VyBzzZ Android`
4. Télécharger `google-services.json`
5. Placer le fichier dans : `android/app/google-services.json`

### Étape 1.3 : Ajouter une Application iOS

1. Dans la console Firebase, cliquer sur l'icône iOS
2. **Bundle ID** : `com.retrytech.vybzzz` (vérifier dans Xcode)
3. **App nickname** : `VyBzzZ iOS`
4. Télécharger `GoogleService-Info.plist`
5. Placer le fichier dans : `ios/Runner/GoogleService-Info.plist`

### Étape 1.4 : Activer Authentication

1. Dans Firebase Console → Authentication
2. Onglet "Sign-in method"
3. Activer **Email/Password** :
   - Cliquer sur "Email/Password"
   - Activer
   - Sauvegarder

4. Activer **Google** :
   - Cliquer sur "Google"
   - Activer
   - Email d'assistance : votre email
   - Sauvegarder

### Étape 1.5 : Activer Firestore Database

1. Dans Firebase Console → Firestore Database
2. Créer une base de données
3. Mode : **Production** (avec règles de sécurité)
4. Localisation : `europe-west` (pour la France)
5. Créer

6. **Règles de sécurité** (onglet "Rules") :
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read: if true;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
       match /events/{eventId} {
         allow read: if resource.data.status != 'draft' ||
                        request.auth.uid == resource.data.artist_id;
         allow create: if request.auth != null;
         allow update: if request.auth.uid == resource.data.artist_id;
       }
       match /tickets/{ticketId} {
         allow read: if request.auth.uid == resource.data.user_id;
         allow create: if request.auth != null && request.auth.uid == request.resource.data.user_id;
       }
     }
   }
   ```

7. **Index** (onglet "Indexes") :
   - Créer un index pour `events` : `artist_id` (asc) + `start_time` (desc)
   - Créer un index pour `tickets` : `user_id` (asc) + `purchased_at` (desc)

### Étape 1.6 : Activer Storage

1. Dans Firebase Console → Storage
2. Get Started
3. Mode : **Production**
4. Localisation : `europe-west`
5. Terminé

6. **Règles de sécurité** :
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read: if true;
         allow write: if request.auth.uid == userId;
       }
       match /events/{eventId}/{allPaths=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

---

## 2. Configuration Stripe Connect

### Étape 2.1 : Créer un Compte Stripe

1. Aller sur [stripe.com](https://stripe.com)
2. Créer un compte
3. Activer votre compte (fournir les informations requises)

### Étape 2.2 : Activer Stripe Connect

1. Dans Dashboard Stripe → Connect
2. Activer Stripe Connect
3. Type de plateforme : **Express** (le plus simple pour les artistes)
4. Nom de la plateforme : `VyBzzZ`

### Étape 2.3 : Obtenir les Clés API

1. Dashboard Stripe → Developers → API keys
2. **Mode Test** :
   - **Publishable key** : `pk_test_...`
   - **Secret key** : `sk_test_...`
   - Copier et sauvegarder les deux clés

3. **Mode Production** (plus tard) :
   - Basculer sur "View live keys"
   - **Publishable key** : `pk_live_...`
   - **Secret key** : `sk_live_...`

### Étape 2.4 : Configurer les Webhooks

1. Dashboard Stripe → Developers → Webhooks
2. Ajouter un endpoint :
   - **URL** : `https://your-cloud-function-url/stripe-webhook`
   - **Description** : `VyBzzZ Webhooks`
   - **Événements à écouter** :
     - `payment_intent.succeeded`
     - `payment_intent.payment_failed`
     - `account.updated`
     - `transfer.created`
     - `payout.paid`

3. Copier le **Webhook Secret** : `whsec_...`

### Étape 2.5 : Configurer les Transferts Automatiques

1. Dashboard Stripe → Connect → Settings
2. **Payout schedule** :
   - Frequency : **Weekly**
   - Day : **Monday**
   - Delay : **14 days**

---

## 3. Configuration 100MS Live

### Étape 3.1 : Créer un Compte 100MS

1. Aller sur [100ms.live](https://www.100ms.live)
2. Sign up / Create account
3. Vérifier votre email

### Étape 3.2 : Créer une Application

1. Dans Dashboard → Apps
2. Créer une nouvelle app :
   - **Name** : `VyBzzZ`
   - **Description** : `Live concert streaming platform`
   - Create

### Étape 3.3 : Configurer les Templates

1. Dashboard → Templates
2. Créer un template **Host** (pour l'artiste) :
   - **Name** : `VyBzzZ Artist`
   - **Publish** : ✅ Audio + Video
   - **Subscribe** : ✅ Audio + Video
   - **Screenshare** : ✅
   - **Max peers** : Unlimited
   - **Recording** : ✅ Enable

3. Créer un template **Viewer** (pour les spectateurs) :
   - **Name** : `VyBzzZ Viewer`
   - **Publish** : ❌ (seulement chat)
   - **Subscribe** : ✅ Audio + Video
   - **Max peers** : Unlimited

### Étape 3.4 : Obtenir les Credentials

1. Dashboard → Developer
2. Copier :
   - **App ID** : `your_app_id`
   - **Access Key** : `your_access_key`
   - **Secret Key** : `your_secret_key`
   - **Management Token** : `your_management_token`

### Étape 3.5 : Configuration dans le Code

Mettre à jour `lib/common/config/hms_config.dart` :

```dart
class HMSConfig {
  static const String appId = 'your_app_id';
  static const String accessKey = 'your_access_key';
  static const String secretKey = 'your_secret_key';
  static const String managementToken = 'your_management_token';

  static const String artistTemplateId = 'template_id_artist';
  static const String viewerTemplateId = 'template_id_viewer';
}
```

---

## 4. Variables d'Environnement

### Étape 4.1 : Créer le fichier `.env`

Créer un fichier `.env` à la racine du projet :

```env
# Firebase
# (Déjà configuré via google-services.json et GoogleService-Info.plist)

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# 100MS Live
HMS_APP_ID=your_app_id
HMS_ACCESS_KEY=your_access_key
HMS_SECRET_KEY=your_secret_key
HMS_MANAGEMENT_TOKEN=your_management_token
HMS_ARTIST_TEMPLATE_ID=template_id_artist
HMS_VIEWER_TEMPLATE_ID=template_id_viewer

# App
APP_NAME=VyBzzZ
APP_ENV=development
APP_DEBUG=true
```

### Étape 4.2 : Ajouter `.env` au `.gitignore`

**IMPORTANT** : Ne jamais commit le fichier `.env` !

```bash
echo ".env" >> .gitignore
```

### Étape 4.3 : Créer `.env.example`

Créer un template pour les autres développeurs :

```env
# Firebase
# Configuré via google-services.json

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_secret_here

# 100MS Live
HMS_APP_ID=your_app_id_here
HMS_ACCESS_KEY=your_access_key_here
HMS_SECRET_KEY=your_secret_key_here
HMS_MANAGEMENT_TOKEN=your_token_here
HMS_ARTIST_TEMPLATE_ID=template_id_here
HMS_VIEWER_TEMPLATE_ID=template_id_here
```

---

## 5. Test de l'Application

### Étape 5.1 : Vérifier l'Installation

```bash
# Installer les dépendances
flutter pub get

# Vérifier qu'il n'y a pas d'erreurs
flutter analyze

# Lancer les tests
flutter test
```

### Étape 5.2 : Test sur Émulateur/Simulateur

```bash
# Android
flutter run

# iOS (macOS uniquement)
flutter run -d ios
```

### Étape 5.3 : Test des Fonctionnalités

**Test 1 : Authentication**
1. Créer un compte avec email/password
2. Se déconnecter
3. Se reconnecter
4. Tester Google Sign-In

**Test 2 : Profils Utilisateurs**
1. Créer un profil Artiste
2. Créer un profil Fan
3. Basculer entre les thèmes clair/sombre

**Test 3 : Événements**
1. (Artiste) Créer un événement
2. (Fan) Voir la liste des événements
3. (Fan) Voir les détails d'un événement

**Test 4 : Paiements (Mode Test)**
1. Acheter un billet avec une carte de test Stripe :
   - Numéro : `4242 4242 4242 4242`
   - Date : n'importe quelle date future
   - CVC : n'importe quel 3 chiffres
2. Vérifier dans Stripe Dashboard que le paiement est bien reçu

**Test 5 : Live Streaming**
1. (Artiste) Démarrer un live
2. (Fan) Rejoindre le live
3. Tester le chat
4. (Artiste) Terminer le live
5. Vérifier que le replay est disponible

---

## 6. Déploiement

### Étape 6.1 : Préparer pour Production

1. **Basculer Stripe en mode Live** :
   - Remplacer les clés test par les clés live dans `.env`

2. **Basculer Firebase en mode Production** :
   - Vérifier les règles de sécurité Firestore
   - Activer App Check pour la sécurité

3. **Créer les icônes de l'app** :
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

### Étape 6.2 : Build Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (pour Google Play)
flutter build appbundle --release
```

Le fichier sera dans :
- APK : `build/app/outputs/flutter-apk/app-release.apk`
- Bundle : `build/app/outputs/bundle/release/app-release.aab`

### Étape 6.3 : Build iOS

```bash
# Build pour iOS
flutter build ios --release

# Ouvrir dans Xcode
open ios/Runner.xcworkspace
```

Dans Xcode :
1. Product → Archive
2. Distribute App
3. App Store Connect / Ad Hoc / Enterprise

### Étape 6.4 : Publier sur les Stores

**Google Play Store :**
1. Créer un compte Google Play Developer (25$)
2. Créer une nouvelle application
3. Uploader le fichier `.aab`
4. Remplir les informations requises
5. Soumettre pour review

**Apple App Store :**
1. Créer un compte Apple Developer (99$/an)
2. App Store Connect → My Apps → Nouvelle App
3. Upload via Xcode ou Transporter
4. Remplir les informations requises
5. Soumettre pour review

---

## 🎯 Checklist Finale

Avant le lancement du 30 novembre 2025 :

### Backend
- [ ] Firebase configuré et sécurisé
- [ ] Firestore rules testées
- [ ] Storage rules testées
- [ ] Indexes créés
- [ ] Stripe Connect activé (mode Live)
- [ ] Webhooks Stripe configurés
- [ ] 100MS templates créés
- [ ] 100MS recording activé

### Frontend
- [ ] App testée sur Android
- [ ] App testée sur iOS
- [ ] Tous les flows testés (signup, login, achat, live, etc.)
- [ ] Thèmes fonctionnels (clair/sombre)
- [ ] Performance optimisée
- [ ] Icônes et splash screen créés

### Légal
- [ ] CGU rédigées
- [ ] Politique de confidentialité rédigée
- [ ] Mentions légales
- [ ] RGPD compliance

### Monitoring
- [ ] Firebase Analytics activé
- [ ] Crashlytics configuré
- [ ] Stripe Dashboard monitoring
- [ ] 100MS analytics

---

## 📞 Support

En cas de problème :

- **Firebase** : [firebase.google.com/support](https://firebase.google.com/support)
- **Stripe** : [support.stripe.com](https://support.stripe.com)
- **100MS** : [docs.100ms.live](https://docs.100ms.live)

---

**Guide créé pour VyBzzZ** 🚀
Deadline : 30 novembre 2025

Bon courage ! 💪
