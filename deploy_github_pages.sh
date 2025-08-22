#!/bin/bash

echo "🚀 DÉPLOIEMENT GITHUB PAGES VYBZZZ"
echo "==================================="
echo ""

echo "📱 ÉTAPE 1 : Construction de l'app mobile"
echo "flutter build web --release --target=lib/main_mobile.dart"
echo ""

# Construction de l'app
flutter build web --release --target=lib/main_mobile.dart

if [ $? -eq 0 ]; then
    echo "✅ App mobile construite avec succès !"
    echo ""
    
    echo "💻 ÉTAPE 2 : Préparation pour GitHub Pages"
    echo "Copie du dashboard dans build/web/"
    
    # Copier le dashboard
    cp dashboard_web_simple.html build/web/dashboard.html
    
    echo "✅ Dashboard web prêt !"
    echo ""
    
    echo "🎯 ÉTAPE 3 : Création des fichiers GitHub Pages"
    
    # Créer le fichier .nojekyll pour GitHub Pages
    touch build/web/.nojekyll
    
    # Créer un README pour GitHub
    cat > build/web/README.md << 'EOF'
# VyBzzZ Mobile App

Application mobile de concerts en live avec vente de tickets.

## 🎵 Fonctionnalités
- Live streaming de concerts
- Vente de tickets
- Shortzz des artistes
- Dashboard business

## 📱 Accès
- **App mobile :** Page principale
- **Dashboard :** /dashboard.html

## 🚀 Déployé sur GitHub Pages
EOF
    
    echo "✅ Fichiers GitHub Pages créés !"
    echo ""
    
    echo "🎯 ÉTAPE 4 : Vérification des fichiers"
    echo "Contenu du dossier build/web/ :"
    ls -la build/web/
    echo ""
    
    echo "🚀 DÉPLOIEMENT GITHUB PAGES PRÊT !"
    echo ""
    echo "📋 INSTRUCTIONS DE DÉPLOIEMENT :"
    echo ""
    echo "1️⃣ CRÉER UN REPO GITHUB :"
    echo "   • Allez sur https://github.com"
    echo "   • Cliquez sur 'New repository'"
    echo "   • Nom : 'vybzzz-app'"
    echo "   • Public ou Private (votre choix)"
    echo "   • Cliquez sur 'Create repository'"
    echo ""
    echo "2️⃣ UPLOADER VOTRE CODE :"
    echo "   • Dans le repo créé, cliquez sur 'uploading an existing file'"
    echo "   • Glissez-déposez TOUT le dossier 'build/web'"
    echo "   • Message de commit : 'Initial deployment VyBzzZ V1'"
    echo "   • Cliquez sur 'Commit changes'"
    echo ""
    echo "3️⃣ ACTIVER GITHUB PAGES :"
    echo "   • Dans votre repo, allez dans 'Settings'"
    echo "   • Scroll jusqu'à 'Pages' (gauche)"
    echo "   • Source : 'Deploy from a branch'"
    echo "   • Branch : 'main' (ou 'master')"
    echo "   • Folder : '/' (root)"
    echo "   • Cliquez sur 'Save'"
    echo ""
    echo "4️⃣ VOTRE APP SERA EN LIGNE :"
    echo "   • URL : https://username.github.io/vybzzz-app"
    echo "   • Dashboard : https://username.github.io/vybzzz-app/dashboard.html"
    echo ""
    echo "🎵 AVANTAGES GITHUB PAGES :"
    echo "• Pas de cache problématique ✅"
    echo "• Déploiement immédiat ✅"
    echo "• Gratuit et fiable ✅"
    echo "• Pas de Netlify ! ✅"
    echo ""
    echo "💰 VOTRE APP VYBZZZ V1 SERA EN LIGNE !"
    
else
    echo "❌ Erreur lors de la construction"
    echo "Vérifiez les dépendances et réessayez"
fi
