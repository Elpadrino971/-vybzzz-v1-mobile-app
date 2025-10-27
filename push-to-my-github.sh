#!/bin/bash

# Script pour pusher VyBzzZ vers TON GitHub personnel
# Usage: ./push-to-my-github.sh VOTRE_USERNAME

USERNAME=$1

if [ -z "$USERNAME" ]; then
    echo "❌ Usage: ./push-to-my-github.sh VOTRE_USERNAME_GITHUB"
    echo "Exemple: ./push-to-my-github.sh Elpadrino971"
    exit 1
fi

echo "🚀 Push VyBzzZ vers GitHub de $USERNAME..."

# Va dans le dossier du projet
cd /home/user/-vybzzz-v1-mobile-app

# Crée une branche main propre
git checkout -b main

# Enlève l'ancien origin
git remote remove origin 2>/dev/null || true

# Ajoute TON GitHub
git remote add origin https://github.com/$USERNAME/vybzzz-mobile-app.git

echo "📝 Remote configuré: https://github.com/$USERNAME/vybzzz-mobile-app.git"
echo ""
echo "⚠️  IMPORTANT: Crée d'abord le repository sur GitHub!"
echo "   1. Va sur https://github.com/new"
echo "   2. Nom: vybzzz-mobile-app"
echo "   3. Privé ou Public (au choix)"
echo "   4. NE crée PAS de README (on a déjà le code)"
echo ""
echo "✅ Repository créé sur GitHub? Appuie sur ENTER pour continuer..."
read

echo "🔼 Push vers GitHub..."
git push -u origin main

echo ""
echo "✅ TERMINÉ!"
echo "📍 Code disponible sur: https://github.com/$USERNAME/vybzzz-mobile-app"
echo ""
echo "Pour cloner depuis n'importe où:"
echo "   git clone https://github.com/$USERNAME/vybzzz-mobile-app.git"
echo ""
echo "🎉 SUCCÈS! Tu as maintenant ton propre repository VyBzzZ!"
