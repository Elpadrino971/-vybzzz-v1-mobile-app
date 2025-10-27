# 🎵 VyBzzZ - Application Mobile de Concerts Live

VyBzzZ est la première plateforme mobile qui permet aux artistes de diffuser leurs concerts en live et de recevoir leurs paiements tous les **lundis à J+14**. Fini l'attente de 7-30 jours !

## 🚀 Stack Technique

- **Frontend Mobile**: Flutter 3.5+ / Dart
- **Backend**: Firebase (Firestore + Auth + Storage)
- **Streaming**: 100MS Live
- **Paiements**: Stripe Connect
- **Design**: Material Design avec thèmes personnalisés

## ✨ Fonctionnalités Principales

### 👥 5 Types de Comptes
- **Fan** : Achetez des billets et profitez des concerts
- **Artiste** : Organisez des concerts et recevez vos paiements
- **Apporteur d'Affaire** : Gagnez des commissions d'affiliation (2.5% / 1.5% / 1%)
- **Responsable Régional** : Gérez les opérations dans votre région
- **Propriétaire de Salle** : Louez votre salle pour des concerts

### 💰 Abonnements Artistes (Paiements J+14 tous les lundis)
- **Basic (19,99€/mois)** : 50% artiste / 50% plateforme
- **Pro (59,99€/mois)** : 60% artiste / 40% plateforme
- **Premium (129,99€/mois)** : 70% artiste / 30% plateforme

### 🎫 3 Types de Billets
- **Virtuel** : Regardez depuis chez vous (le moins cher)
- **Physique** : Assistez au concert sur place (le plus cher)
- **Fanbase** : Visionnage collectif dans une salle locale

### 🎥 Concerts & Streaming
- Live streaming HD avec 100MS
- **Replay disponible 7 jours** après le concert
- Chat en temps réel pendant le live
- Système de pourboires
- QR codes pour les billets
- Analytics en temps réel

### ⚡ Happy Hour
- Chaque mercredi à 20h pendant 15 minutes
- Prix réduits sur tous les types de billets
- Gamification et engagement utilisateur

## 📱 Installation

### Prérequis

- Flutter 3.5+
- Dart SDK
- Android Studio / Xcode
- Un compte Firebase
- Un compte Stripe
- Un compte 100MS Live

### 1. Cloner le projet

```bash
git clone https://github.com/Elpadrino971/-vybzzz-v1-mobile-app.git
cd -vybzzz-v1-mobile-app
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configuration Firebase

1. Créer un projet sur [firebase.google.com](https://firebase.google.com)
2. Ajouter une application Android et iOS
3. Télécharger les fichiers de configuration :
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Activer Authentication (Email + Google)
5. Activer Firestore Database
6. Activer Storage

### 4. Configuration Stripe

1. Créer un compte sur [stripe.com](https://stripe.com)
2. Activer Stripe Connect
3. Récupérer les clés API (publishable key + secret key)
4. Configurer le webhook (voir documentation)

### 5. Configuration 100MS

1. Créer un compte sur [100ms.live](https://www.100ms.live)
2. Créer une application
3. Récupérer l'App ID et le Management Token
4. Mettre à jour `lib/common/config/hms_config.dart`

### 6. Variables d'environnement

Créer un fichier `.env` à la racine :

```env
# Firebase (déjà configuré via google-services.json)

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# 100MS Live
HMS_APP_ID=your_app_id
HMS_MANAGEMENT_TOKEN=your_management_token
```

### 7. Lancer l'application

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Build pour production
flutter build apk --release
flutter build ios --release
```

## 🎨 Thèmes

L'application dispose de 2 thèmes professionnels :

### 🌞 Mode Clair (Blanc et Doré)
- Fond : Blanc cassé (#F5F5F5)
- Accent : Or vif (#FFD700)
- Gradient : Or → Orange doré

### 🌙 Mode Sombre (Noir et Rouge Netflix)
- Fond : Noir pur (#000000)
- Accent : Rouge Netflix (#E50914)
- Gradient : Rouge Netflix → Rouge foncé

## 📂 Structure du Projet

```
lib/
├── common/
│   ├── config/           # Configuration (HMS, Domain, etc.)
│   ├── controller/       # Contrôleurs globaux
│   ├── enum/             # Énumérations (UserType, SubscriptionTier, etc.)
│   ├── extensions/       # Extensions Dart
│   ├── manager/          # Gestionnaires (Theme, Session, etc.)
│   ├── service/          # Services (API, Navigation, etc.)
│   └── widget/           # Widgets réutilisables
├── model/
│   ├── user_model/       # Modèles utilisateur (avec extensions VyBzzZ)
│   ├── event_model/      # Modèles d'événements
│   ├── livestream/       # Modèles de live streaming
│   └── ...
├── screen/               # Écrans de l'application
├── routes/               # Configuration des routes
├── utilities/            # Utilitaires (Theme, Color, Font, etc.)
└── main.dart             # Point d'entrée
```

## 🔥 Fonctionnalités VyBzzZ

### Modèles de Données

#### UserType (5 types)
```dart
enum UserType {
  fan,                  // Spectateur
  artist,               // Artiste
  businessBringer,      // Apporteur d'affaire
  regionalManager,      // Responsable régional
  venueOwner,          // Propriétaire de salle
}
```

#### SubscriptionTier (3 niveaux)
```dart
enum SubscriptionTier {
  basic,    // 19.99€ - 50/50
  pro,      // 59.99€ - 60/40
  premium,  // 129.99€ - 70/30
}
```

#### VyBzzZEvent (avec replay 7 jours)
```dart
class VyBzzZEvent {
  String? replayUrl;
  DateTime? replayExpiresAt;  // 7 jours après le concert
  bool? replayAvailable;

  double? ticketPriceVirtual;
  double? ticketPricePhysical;
  double? ticketPriceFanbase;

  bool? isHappyHour;
  // ... (voir modèle complet)
}
```

## 💳 Modèle de Paiement

### Revenus Artiste
- **Basic (19,99€/mois)** : L'artiste reçoit 50% des ventes
- **Pro (59,99€/mois)** : L'artiste reçoit 60% des ventes
- **Premium (129,99€/mois)** : L'artiste reçoit 70% des ventes

### Transferts
- Paiement tous les **lundis**
- Délai : **J+14** après le concert
- Frais Stripe : ~2.9% + 0.25€

### Exemple
Concert avec 100 billets virtuels à 20€ (Artiste Pro - 60/40) :
- Revenus bruts : 2 000€
- Commission VyBzzZ (40%) : 800€
- Frais Stripe (~3%) : 60€
- **Revenus artiste : 1 200€ (60%)**
- **Transfert : Lundi J+14**

## 🔐 Sécurité

- Firebase Authentication (Email + Google)
- Firestore Security Rules
- Stripe Payment Intent avec 3D Secure
- HTTPS obligatoire
- Variables d'environnement sécurisées

## 📝 Documentation

- [Guide de Configuration Complète](SETUP_GUIDE.md)
- [Schéma Firebase/Firestore](FIREBASE_SCHEMA.md)
- [Guide des Thèmes](COLOR_THEME_GUIDE.md)
- [Guide des Composants](COMPONENTS_COMPLETE_GUIDE.md)
- [Migration 100MS](MIGRATION_100MS.md)

## 🚧 Roadmap

### MVP (30 Novembre 2025)
- [x] Authentification
- [x] Profils utilisateurs (5 types)
- [x] Système de thèmes
- [ ] Création d'événements
- [ ] Achat de billets (3 types)
- [ ] Live streaming 100MS
- [ ] Replay 7 jours
- [ ] Paiements Stripe Connect
- [ ] Dashboard artiste

### Phase 2
- [ ] Shorts auto-générés (AI)
- [ ] Feed TikTok-style
- [ ] Happy Hour automatique
- [ ] Système d'affiliation multi-niveaux
- [ ] NFT ticketing
- [ ] Token $VYBZ

## 🎯 Objectif

Plateforme 100% opérationnelle le **30 novembre 2025** pour le concert de **David Guetta le 31 décembre 2025**.

## 📞 Support

Pour toute question ou problème :
- Email : support@vybzzz.com
- Discord : [discord.gg/vybzzz](https://discord.gg/vybzzz)

## 📄 Licence

© 2025 VyBzzZ. Tous droits réservés.

---

**Créé avec ❤️ par Jean-Sébastien LOUIS-GUSTAVE**

Deadline : 30 novembre 2025 🚀
