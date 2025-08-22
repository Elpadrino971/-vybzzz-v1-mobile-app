#!/bin/bash

echo "📱 CONSTRUCTION DE L'APPLICATION MOBILE VYBZZZ"
echo "=============================================="
echo ""

echo "🎯 OBJECTIF :"
echo "Créer une application mobile qui fonctionne directement sur votre téléphone !"
echo ""

echo "✅ CE QUI VA ÊTRE CRÉÉ :"
echo "- Application Android (.apk)"
echo "- Interface mobile optimisée"
echo "- Thème clair/sombre"
echo "- Fonctionne hors ligne"
echo "- Installation simple sur téléphone"
echo ""

echo "🔧 CONSTRUCTION EN COURS..."
echo ""

# Construire l'application Android
echo "📱 Construction de l'APK Android..."
flutter build apk --release --target=lib/main_mobile.dart

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCÈS ! Application mobile construite !"
    echo ""
    echo "📁 FICHIER CRÉÉ :"
    echo "build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📱 POUR INSTALLER SUR VOTRE TÉLÉPHONE :"
    echo "1. Transférez le fichier .apk sur votre téléphone"
    echo "2. Activez 'Sources inconnues' dans les paramètres"
    echo "3. Installez l'application"
    echo "4. Votre app VyBzzZ sera sur votre téléphone !"
    echo ""
    
    # Vérifier la taille du fichier
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -sh build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo "📊 Taille de l'APK : $APK_SIZE"
        echo ""
        
        # Ouvrir le dossier
        if command -v open &> /dev/null; then
            echo "📁 Ouverture du dossier build..."
            open build/app/outputs/flutter-apk/
        fi
    fi
    
    echo "🚀 AVANTAGES DE L'APP MOBILE :"
    echo "✅ Fonctionne directement sur téléphone"
    echo "✅ Pas besoin d'internet après installation"
    echo "✅ Interface native et rapide"
    echo "✅ Thème clair/sombre fonctionnel"
    echo "✅ Installation simple via APK"
    echo ""
    
else
    echo "❌ Erreur lors de la construction"
    echo "Vérifiez que Flutter est bien installé et configuré"
    exit 1
fi

echo "🎯 VOTRE APPLICATION MOBILE EST PRÊTE !"
echo "Installez-la sur votre téléphone et profitez-en ! 📱✨"
