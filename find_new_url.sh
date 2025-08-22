#!/bin/bash

echo "🔍 RECHERCHE DE LA NOUVELLE URL NETLIFY"
echo "========================================"
echo ""

echo "🚨 PROBLÈME IDENTIFIÉ :"
echo "L'ancienne URL melodic-biscuit-22c9ed.netlify.app ne fonctionne plus !"
echo ""

echo "✅ SOLUTION :"
echo "Votre site a été redéployé et a une nouvelle URL !"
echo ""

echo "📋 ÉTAPES POUR TROUVER VOTRE NOUVELLE URL :"
echo "1. Allez sur https://app.netlify.com"
echo "2. Connectez-vous à votre compte"
echo "3. Cliquez sur votre projet 'melodic-biscuit-22c9ed'"
echo "4. Dans 'Site overview', regardez la section 'Domain'"
echo "5. Votre nouvelle URL sera affichée là"
echo ""

echo "🔄 REDÉPLOIEMENT RECOMMANDÉ :"
echo "Pour être sûr, redéployez le dossier build/web sur Netlify"
echo ""

echo "📁 Dossier à redéployer : build/web"
echo "📊 Taille : $(du -sh build/web | cut -f1)"
echo ""

echo "🎯 APRÈS LE REDÉPLOIEMENT :"
echo "- Notez la nouvelle URL affichée"
echo "- Testez votre site avec cette nouvelle URL"
echo "- Partagez la bonne URL"
echo ""

echo "💡 CONSEIL :"
echo "Netlify génère parfois de nouvelles URLs lors des redéploiements."
echo "C'est normal et votre site fonctionne toujours !"
echo ""

# Ouvrir le dossier build
if command -v open &> /dev/null; then
    echo "📁 Ouverture du dossier build..."
    open build/web
fi

echo "🚀 Maintenant, redéployez sur Netlify et trouvez votre nouvelle URL !"
