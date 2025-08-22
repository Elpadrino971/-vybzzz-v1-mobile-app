#!/bin/bash

echo "📱 CONSTRUCTION DE LA PWA iOS VYBZZZ"
echo "===================================="
echo ""

echo "🎯 OBJECTIF :"
echo "Créer une PWA (Progressive Web App) qui s'installe sur votre iPhone/iPad !"
echo ""

echo "✅ CE QUI VA ÊTRE CRÉÉ :"
echo "- Site web mobile optimisé"
echo "- S'installe comme une app sur iPhone/iPad"
echo "- Thème clair/sombre"
echo "- Interface mobile parfaite"
echo "- Ajout à l'écran d'accueil"
echo ""

echo "🔧 CONSTRUCTION EN COURS..."
echo ""

# Construire l'application web Flutter
echo "📱 Construction de l'application web..."
flutter build web --release --target=lib/main_mobile.dart

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCÈS ! PWA iOS construite !"
    echo ""
    
    # Créer le manifeste PWA
    echo "📱 Création du manifeste PWA..."
    cat > build/web/manifest.json << 'EOF'
{
  "name": "VyBzzZ Mobile",
  "short_name": "VyBzzZ",
  "description": "Application VyBzzZ mobile",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196f3",
  "orientation": "portrait",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF

    # Modifier index.html pour PWA
    echo "📱 Modification de index.html pour PWA..."
    sed -i '' 's/<head>/<head>\n    <link rel="manifest" href="manifest.json">\n    <meta name="apple-mobile-web-app-capable" content="yes">\n    <meta name="apple-mobile-web-app-status-bar-style" content="default">\n    <meta name="apple-mobile-web-app-title" content="VyBzzZ">\n    <link rel="apple-touch-icon" href="icons\/Icon-192.png">/' build/web/index.html

    echo ""
    echo "📁 FICHIERS CRÉÉS :"
    echo "build/web/ (dossier complet)"
    echo "build/web/manifest.json (manifeste PWA)"
    echo "build/web/index.html (page PWA)"
    echo ""
    
    echo "📱 POUR INSTALLER SUR VOTRE iPHONE/iPAD :"
    echo ""
    echo "🚀 MÉTHODE SIMPLE :"
    echo "1. Ouvrez Safari sur votre iPhone/iPad"
    echo "2. Allez sur votre site web"
    echo "3. Appuyez sur le bouton 'Partager' (📤)"
    echo "4. Sélectionnez 'Sur l'écran d'accueil'"
    echo "5. Appuyez sur 'Ajouter'"
    echo "6. Votre app VyBzzZ sera sur votre écran d'accueil !"
    echo ""
    
    echo "🌐 DÉPLOIEMENT :"
    echo "1. Uploadez le dossier 'build/web' sur un hébergeur"
    echo "2. Ou utilisez GitHub Pages (gratuit)"
    echo "3. Ou utilisez Netlify (mais on connaît l'histoire... 😅)"
    echo ""
    
    echo "🚀 AVANTAGES DE LA PWA iOS :"
    echo "✅ S'installe comme une vraie app"
    echo "✅ Interface mobile parfaite"
    echo "✅ Thème clair/sombre"
    echo "✅ Ajout à l'écran d'accueil"
    echo "✅ Pas besoin de Xcode"
    echo "✅ Déploiement simple"
    echo ""
    
    # Ouvrir le dossier
    if command -v open &> /dev/null; then
        echo "📁 Ouverture du dossier build/web..."
        open build/web/
    fi
    
else
    echo "❌ Erreur lors de la construction"
    echo "Vérifiez que Flutter est bien installé et configuré"
    exit 1
fi

echo "🎯 VOTRE PWA iOS EST PRÊTE !"
echo "Installez-la sur votre iPhone/iPad et profitez-en ! 📱✨"
echo ""
echo "💡 PROCHAINES ÉTAPES :"
echo "1. Déployez le dossier 'build/web' sur un hébergeur"
echo "2. Installez la PWA sur votre iPhone/iPad"
echo "3. Profitez de votre app mobile !"
