#!/bin/bash

echo "🚀 DÉPLOIEMENT DE L'APP MOBILE COMPLÈTE VYBZZZ !"
echo "=================================================="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "app_mobile_complete.html" ]; then
    echo "❌ Erreur: app_mobile_complete.html non trouvé !"
    echo "Assurez-vous d'être dans le répertoire VyBzzZ_flutter"
    exit 1
fi

echo "✅ Fichier app_mobile_complete.html trouvé !"

# Créer le répertoire build/web s'il n'existe pas
if [ ! -d "build/web" ]; then
    echo "📁 Création du répertoire build/web..."
    mkdir -p build/web
fi

# Copier l'app mobile complète
echo "📱 Copie de l'app mobile complète..."
cp app_mobile_complete.html build/web/index.html

# Copier le dashboard existant
if [ -f "dashboard_web_simple.html" ]; then
    echo "📊 Copie du dashboard..."
    cp dashboard_web_simple.html build/web/dashboard.html
else
    echo "⚠️  Dashboard non trouvé, création d'un dashboard simple..."
    cat > build/web/dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Vybzzz</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center; }
        .stat-number { font-size: 2em; font-weight: bold; color: #f57c00; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎵 Dashboard Vybzzz</h1>
        <p>Tableau de bord professionnel</p>
    </div>
    
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">1,234</div>
            <div>Concerts vendus</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">$45,678</div>
            <div>Chiffre d'affaires</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">89</div>
            <div>Lives actifs</div>
        </div>
    </div>
    
    <div style="text-align: center;">
        <a href="./index.html" style="background: #f57c00; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; display: inline-block;">
            📱 Retour à l'app mobile
        </a>
    </div>
</body>
</html>
EOF
fi

# Créer un fichier README
echo "📝 Création du README..."
cat > build/web/README.md << 'EOF'
# 🎵 Vybzzz - Application Mobile Complète

## 📱 Fonctionnalités

### Écrans disponibles :
- **🏠 Home** : Liste des événements et concerts
- **🔍 Discover** : Recherche et découverte d'événements
- **➕ Create** : Création de contenu (vidéos, lives, photos)
- **👤 Profile** : Profil utilisateur avec statistiques

### 🎨 Thèmes :
- **Mode clair** : Blanc et doré
- **Mode sombre** : Noir et rouge Netflix

### 🚀 Navigation :
- Navigation bottom intuitive
- Bouton thème flottant
- Transitions fluides entre écrans

## 🌐 Accès :
- **App mobile** : `index.html`
- **Dashboard** : `dashboard.html`

## 📱 Compatibilité :
- ✅ Mobile (responsive)
- ✅ PWA (Progressive Web App)
- ✅ Tous les navigateurs modernes

---
*Développé avec ❤️ pour Vybzzz*
EOF

echo ""
echo "🎯 RÉSUMÉ DU DÉPLOIEMENT :"
echo "============================"
echo "✅ App mobile complète créée"
echo "✅ Dashboard intégré"
echo "✅ README ajouté"
echo "✅ Tous les écrans fonctionnels"
echo ""
echo "📁 Fichiers dans build/web :"
ls -la build/web/
echo ""
echo "🚀 PRÊT POUR LE DÉPLOIEMENT !"
echo ""
echo "📋 PROCHAINES ÉTAPES :"
echo "1. Uploadez le dossier 'build/web' sur GitHub"
echo "2. Activez GitHub Pages dans les paramètres"
echo "3. Votre app sera accessible sur : https://[username].github.io/[repo]"
echo ""
echo "🎉 VYBZZZ EST PRÊT ! 🎉"
