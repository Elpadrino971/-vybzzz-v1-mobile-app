#!/bin/bash

echo "🚀 DÉPLOIEMENT VYBZZZ - VERSION PROPRE"
echo "======================================="
echo ""

echo "🎯 OBJECTIF :"
echo "Déployer votre application VyBzzZ mobile sur Netlify"
echo ""

echo "✅ CE QUI VA ÊTRE FAIT :"
echo "1. Construire l'application mobile"
echo "2. Déployer sur Netlify"
echo "3. Obtenir le lien public"
echo ""

echo "🔧 CONSTRUCTION DE L'APPLICATION..."
flutter build web --release --target=lib/main_mobile.dart

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCÈS ! Application construite !"
    echo ""
    echo "📁 DOSSIER CRÉÉ : build/web/"
    echo ""
    echo "🌐 DÉPLOIEMENT NETLIFY :"
    echo "1. Allez sur https://app.netlify.com"
    echo "2. Connectez-vous à votre compte"
    echo "3. Glissez-déposez le dossier 'build/web'"
    echo "4. Votre app sera en ligne en 30 secondes !"
    echo ""
    echo "📱 INSTALLATION SUR iPHONE/iPAD :"
    echo "1. Ouvrez Safari sur votre iPhone/iPad"
    echo "2. Allez sur votre lien Netlify"
    echo "3. Appuyez sur 'Partager' → 'Sur l'écran d'accueil'"
    echo "4. Votre app VyBzzZ sera sur votre écran d'accueil !"
    echo ""
    
    # Ouvrir le dossier
    if command -v open &> /dev/null; then
        echo "📁 Ouverture du dossier build/web..."
        open build/web/
    fi
    
else
    echo "❌ Erreur lors de la construction"
    echo "Vérifiez que Flutter est bien configuré"
    exit 1
fi

echo "🎯 VOTRE APPLICATION VYBZZZ SERA EN LIGNE EN 1 MINUTE !"
echo "Suivez les étapes ci-dessus !"
