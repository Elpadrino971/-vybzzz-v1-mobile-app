# 🚀 Déploiement VyBzzZ sur Netlify

## 📋 Prérequis

- Compte Netlify (gratuit sur [netlify.com](https://netlify.com))
- Application Flutter compilée pour le web
- Git configuré sur votre machine

## 🔧 Configuration

### 1. Fichier de configuration Netlify

Le fichier `netlify.toml` est déjà configuré avec :
- Dossier de publication : `build/web`
- Commande de build : `flutter build web --release --target=lib/main_web.dart`
- Redirections SPA pour le routage Flutter
- Optimisations de performance

### 2. Build de l'application

```bash
# Dans le dossier VyBzzZ_flutter
flutter build web --release --target=lib/main_web.dart
```

## 🚀 Déploiement

### Option 1 : Déploiement via Git (Recommandé)

1. **Pousser le code sur GitHub/GitLab**
   ```bash
   git add .
   git commit -m "Build web pour Netlify"
   git push origin main
   ```

2. **Connecter Netlify à votre repository**
   - Allez sur [app.netlify.com](https://app.netlify.com)
   - Cliquez sur "New site from Git"
   - Choisissez votre provider (GitHub, GitLab, Bitbucket)
   - Sélectionnez votre repository VyBzzZ

3. **Configuration du build**
   - Build command : `flutter build web --release --target=lib/main_web.dart`
   - Publish directory : `build/web`
   - Cliquez sur "Deploy site"

### Option 2 : Déploiement manuel

1. **Construire l'application**
   ```bash
   flutter build web --release --target=lib/main_web.dart
   ```

2. **Déployer sur Netlify**
   - Allez sur [app.netlify.com](https://app.netlify.com)
   - Glissez-déposez le dossier `build/web` dans la zone de déploiement
   - Votre site sera déployé automatiquement

## ⚙️ Configuration avancée

### Variables d'environnement

Si nécessaire, ajoutez ces variables dans Netlify :
- `FLUTTER_VERSION` : Version de Flutter utilisée
- `NODE_VERSION` : Version de Node.js (si nécessaire)

### Domaines personnalisés

1. Dans les paramètres de votre site Netlify
2. Allez dans "Domain management"
3. Ajoutez votre domaine personnalisé
4. Configurez les enregistrements DNS selon les instructions

## 🔍 Vérification

Après le déploiement, vérifiez :
- ✅ L'application se charge correctement
- ✅ Le thème clair/sombre fonctionne
- ✅ Les redirections SPA marchent
- ✅ Les performances sont bonnes

## 🐛 Dépannage

### Erreur de build
- Vérifiez que Flutter est installé et à jour
- Assurez-vous que toutes les dépendances sont installées
- Vérifiez les logs de build dans Netlify

### Erreur de routage
- Vérifiez que le fichier `netlify.toml` est présent
- Assurez-vous que les redirections sont correctes

### Problèmes de performance
- Vérifiez que le build est en mode `--release`
- Optimisez les assets (images, fonts)
- Utilisez la compression gzip de Netlify

## 📱 Fonctionnalités disponibles

Cette version web simplifiée inclut :
- ✅ Interface utilisateur responsive
- ✅ Système de thèmes (clair/sombre)
- ✅ Design moderne et élégant
- ✅ Optimisations de performance

## 🔮 Prochaines étapes

Pour une version complète :
1. Corriger les erreurs de compilation dans le code principal
2. Adapter les fonctionnalités mobiles pour le web
3. Optimiser les performances web
4. Ajouter le PWA (Progressive Web App)

---

**Note** : Cette version est une démonstration fonctionnelle. Pour une application complète, il faudra résoudre les erreurs de compilation dans le code principal.
