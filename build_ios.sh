#!/bin/bash

echo "🍎 CONSTRUCTION DE L'APPLICATION iOS VYBZZZ"
echo "=========================================="
echo ""

echo "🎯 OBJECTIF :"
echo "Créer une application iOS qui fonctionne directement sur votre iPhone/iPad !"
echo ""

echo "✅ CE QUI VA ÊTRE CRÉÉ :"
echo "- Application iOS (.ipa)"
echo "- Interface iOS native et rapide"
echo "- Thème clair/sombre iOS"
echo "- Fonctionne hors ligne"
echo "- Installation via TestFlight ou App Store"
echo ""

echo "🔧 CONSTRUCTION EN COURS..."
echo ""

# Vérifier si on est sur macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ ERREUR : La construction iOS nécessite macOS"
    echo "Vous devez être sur un Mac pour construire une app iOS"
    echo ""
    echo "💡 SOLUTIONS :"
    echo "1. Utilisez un Mac"
    echo "2. Utilisez un service cloud (Codemagic, Bitrise)"
    echo "3. Utilisez la PWA iOS (plus simple)"
    exit 1
fi

# Vérifier si Xcode est installé
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ ERREUR : Xcode n'est pas installé"
    echo "Installez Xcode depuis l'App Store"
    echo ""
    echo "💡 ALTERNATIVE : PWA iOS"
    echo "Créons une PWA qui s'installe sur votre iPhone !"
    echo ""
    
    read -p "Voulez-vous créer une PWA iOS à la place ? (y/n): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        echo "🚀 Création de la PWA iOS..."
        ./build_pwa_ios.sh
        exit 0
    else
        echo "Installez Xcode et relancez le script"
        exit 1
    fi
fi

echo "📱 Construction de l'application iOS..."
flutter build ios --release --target=lib/main_mobile.dart

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCÈS ! Application iOS construite !"
    echo ""
    echo "📁 FICHIERS CRÉÉS :"
    echo "build/ios/archive/Runner.xcarchive"
    echo ""
    echo "📱 POUR INSTALLER SUR VOTRE iPHONE/iPAD :"
    echo ""
    echo "🔧 OPTION 1 : TestFlight (Recommandé)"
    echo "1. Ouvrez Xcode"
    echo "2. Archivez votre projet"
    echo "3. Uploadez sur App Store Connect"
    echo "4. Invitez-vous sur TestFlight"
    echo "5. Installez sur votre iPhone via TestFlight"
    echo ""
    echo "🚀 OPTION 2 : Installation directe"
    echo "1. Connectez votre iPhone au Mac"
    echo "2. Sélectionnez votre appareil dans Xcode"
    echo "3. Appuyez sur 'Run'"
    echo "4. L'app s'installe directement !"
    echo ""
    
    echo "🚀 AVANTAGES DE L'APP iOS :"
    echo "✅ Fonctionne directement sur iPhone/iPad"
    echo "✅ Interface iOS native et rapide"
    echo "✅ Thème clair/sombre iOS parfait"
    echo "✅ Fonctionne hors ligne"
    echo "✅ Installation via TestFlight ou App Store"
    echo ""
    
    # Ouvrir le projet dans Xcode
    if command -v open &> /dev/null; then
        echo "📁 Ouverture du projet dans Xcode..."
        open ios/Runner.xcworkspace
    fi
    
else
    echo "❌ Erreur lors de la construction"
    echo "Vérifiez que Flutter et Xcode sont bien configurés"
    exit 1
fi

echo "🎯 VOTRE APPLICATION iOS EST PRÊTE !"
echo "Installez-la sur votre iPhone/iPad et profitez-en ! 🍎✨"
