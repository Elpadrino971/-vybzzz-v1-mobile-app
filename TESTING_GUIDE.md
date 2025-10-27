# 📱 Guide de Test VyBzzZ

> **Note Importante:** VyBzzZ est une application **Flutter**, pas React Native. Expo Go ne fonctionne donc pas. Voici les alternatives.

---

## 🚀 Option 1: APK Android (RECOMMANDÉ)

### Installation Rapide
```bash
# Build l'APK de développement
flutter build apk --debug

# L'APK se trouve dans:
# build/app/outputs/flutter-apk/app-debug.apk
```

### Comment Installer sur Téléphone:
1. **Active le mode développeur** sur Android:
   - Paramètres → À propos → Tap 7x sur "Numéro de build"

2. **Active l'installation d'applications inconnues**:
   - Paramètres → Sécurité → Sources inconnues

3. **Transfère l'APK** sur ton téléphone:
   - Par USB
   - Par email
   - Par Google Drive/Dropbox
   - Par ADB: `adb install build/app/outputs/flutter-apk/app-debug.apk`

4. **Installe** en tapant sur le fichier APK

---

## 📱 Option 2: Émulateur Android

### Lancer l'émulateur:
```bash
# Liste les émulateurs disponibles
flutter emulators

# Lance un émulateur
flutter emulators --launch <emulator_id>

# Ou utilise Android Studio:
# Tools → Device Manager → Play button
```

### Lancer l'app:
```bash
flutter run
```

---

## 🍎 Option 3: Simulateur iOS (Mac uniquement)

### Requirements:
- macOS
- Xcode installé

### Commandes:
```bash
# Liste les simulateurs
xcrun simctl list devices

# Lance un simulateur
open -a Simulator

# Lance l'app
flutter run
```

---

## 🔥 Option 4: Firebase App Distribution (Alternative à Expo Go)

Firebase App Distribution permet de partager l'app via un lien avec QR code!

### Setup:
1. **Installe Firebase CLI:**
```bash
npm install -g firebase-tools
firebase login
```

2. **Initialise Firebase App Distribution:**
```bash
cd /path/to/vybzzz
firebase init appdistribution
```

3. **Build et distribue:**
```bash
# Build l'APK
flutter build apk --release

# Upload vers Firebase
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_APP_ID \
  --groups "testers" \
  --release-notes "Version de test VyBzzZ"
```

4. **Partage le lien:** Firebase génère un lien + QR code!

---

## 🌐 Option 5: TestFlight (iOS)

Pour distribuer sur iOS (comme Expo Go):

1. **Crée un Apple Developer Account** ($99/an)

2. **Build iOS:**
```bash
flutter build ios --release
```

3. **Upload vers App Store Connect:**
   - Ouvre le projet dans Xcode
   - Product → Archive
   - Distribute App → TestFlight

4. **Invite les testeurs** via email

---

## ⚡ Option 6: Téléphone en USB (Hot Reload)

La meilleure expérience de développement!

### Android:
```bash
# Active le débogage USB sur Android
# Paramètres → Options développeur → Débogage USB

# Vérifie que le téléphone est détecté
adb devices

# Lance l'app avec hot reload
flutter run

# Appuie sur 'r' pour recharger
# Appuie sur 'R' pour restart complet
```

### iOS:
```bash
# Branche l'iPhone
# Trust l'ordinateur sur l'iPhone

# Lance l'app
flutter run
```

---

## 🎯 RECOMMANDATION pour Pitch Investisseur

Pour le **30 novembre**, je recommande:

### 1. **APK de Démo** (5 min de setup)
```bash
flutter build apk --release
```
→ Installe sur ton téléphone Android pour la démo live

### 2. **Firebase App Distribution** (30 min de setup)
→ QR code à montrer aux investisseurs pour qu'ils testent

### 3. **Vidéo de l'App** (backup)
```bash
# Record l'écran pendant que tu utilises l'app
# Utile si problème technique le jour J
```

---

## 🛠️ Scripts Pratiques

### Build APK Rapide:
```bash
#!/bin/bash
# build-debug.sh

echo "🔨 Building VyBzzZ Debug APK..."
flutter clean
flutter pub get
flutter build apk --debug

echo "✅ APK Ready!"
echo "📍 Location: build/app/outputs/flutter-apk/app-debug.apk"

# Optionnel: Installe directement si téléphone connecté
if adb devices | grep -q device; then
    echo "📱 Installing on connected device..."
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    echo "🚀 App installed! Opening now..."
    adb shell monkey -p com.vybzzz.app -c android.intent.category.LAUNCHER 1
fi
```

### Build Release APK:
```bash
#!/bin/bash
# build-release.sh

echo "🔨 Building VyBzzZ Release APK..."
flutter clean
flutter pub get
flutter build apk --release --obfuscate --split-debug-info=./debug-info

echo "✅ Release APK Ready!"
echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"
echo "📦 Size: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"
```

---

## 📊 Comparaison des Options

| Option | Setup | Vitesse | QR Code | Best For |
|--------|-------|---------|---------|----------|
| APK Debug | ⭐ | ⚡⚡⚡ | ❌ | Toi |
| Émulateur | ⭐⭐ | ⚡⚡ | ❌ | Dev |
| USB + Hot Reload | ⭐ | ⚡⚡⚡⚡ | ❌ | Dev rapide |
| Firebase Distribution | ⭐⭐⭐ | ⚡ | ✅ | Investisseurs |
| TestFlight | ⭐⭐⭐⭐⭐ | ⚡ | ✅ | iOS Pro |

---

## 🎯 Action Immédiate

**Pour tester MAINTENANT:**
```bash
cd /home/user/-vybzzz-v1-mobile-app

# Option A: Émulateur (si installé)
flutter run

# Option B: Build APK
flutter build apk --debug
# Puis transfère l'APK sur ton téléphone Android
```

**Pour le pitch du 30 novembre:**
```bash
# Setup Firebase App Distribution
firebase init appdistribution

# Build release
flutter build apk --release

# Distribue avec QR code
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk
```

---

## ❓ Questions Fréquentes

**Q: Pourquoi pas Expo Go?**
R: Expo Go = React Native. VyBzzZ = Flutter. Deux technologies différentes.

**Q: Y a-t-il un équivalent à Expo Go pour Flutter?**
R: Non, mais Firebase App Distribution est similaire (QR code + installation facile).

**Q: Je n'ai pas de Mac, puis-je tester sur iPhone?**
R: Tu peux build sur un service cloud (Codemagic, GitHub Actions) mais c'est complexe. Focus sur Android pour la démo.

**Q: Combien de temps pour setup Firebase App Distribution?**
R: 30 minutes la première fois, puis 5 minutes par build.

---

## 📞 Aide

Si tu bloques, dis-moi:
1. Tu as Android ou iPhone?
2. Tu as accès à un émulateur?
3. Tu veux tester toi ou partager avec investisseurs?

Je t'aiderai avec la solution la plus adaptée! 🚀
