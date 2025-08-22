#!/bin/bash

echo "🚀 DÉPLOIEMENT V1 COMPLÈTE VYBZZZ"
echo "=================================="
echo ""

echo "📱 ÉTAPE 1 : Construction de l'app mobile"
echo "flutter build web --release --target=lib/main_mobile.dart"
echo ""

# Construction de l'app
flutter build web --release --target=lib/main_mobile.dart

if [ $? -eq 0 ]; then
    echo "✅ App mobile construite avec succès !"
    echo ""
    
    echo "💻 ÉTAPE 2 : Préparation du dashboard web"
    echo "Copie du dashboard dans build/web/"
    
    # Copier le dashboard
    cp dashboard_web_simple.html build/web/dashboard.html
    
    echo "✅ Dashboard web prêt !"
    echo ""
    
    echo "🎯 ÉTAPE 3 : Vérification des fichiers"
    echo "Contenu du dossier build/web/ :"
    ls -la build/web/
    echo ""
    
    echo "🚀 DÉPLOIEMENT PRÊT !"
    echo ""
    echo "📋 INSTRUCTIONS DE DÉPLOIEMENT :"
    echo ""
    echo "1️⃣ DÉPLOIEMENT NETLIFY :"
    echo "   • Allez sur https://app.netlify.com"
    echo "   • Glissez-déposez le dossier 'build/web'"
    echo "   • Votre app sera en ligne en 30 secondes !"
    echo ""
    echo "2️⃣ ACCÈS À VOTRE APP :"
    echo "   • App mobile : Votre URL Netlify"
    echo "   • Dashboard web : Votre URL Netlify/dashboard.html"
    echo ""
    echo "3️⃣ TEST SUR iPHONE/iPAD :"
    echo "   • Ouvrez Safari"
    echo "   • Allez sur votre URL Netlify"
    echo "   • Testez tous les boutons"
    echo "   • Installez sur l'écran d'accueil"
    echo ""
    echo "🎵 VOTRE APP VYBZZZ V1 EST PRÊTE !"
    echo "• Live streaming ✅"
    echo "• Vente de tickets ✅"
    echo "• Shortzz des artistes ✅"
    echo "• Dashboard business ✅"
    echo ""
    echo "💰 BUSINESS MODEL : Concerts live + Tickets + Pourboires"
    echo "👥 UTILISATEURS : App mobile pour spectateurs"
    echo "💼 PROS : Dashboard web pour gestion"
    
else
    echo "❌ Erreur lors de la construction"
    echo "Vérifiez les dépendances et réessayez"
fi
