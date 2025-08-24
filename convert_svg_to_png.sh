#!/bin/bash

# Script de conversion SVG vers PNG pour VyBzzZ
# Nécessite ImageMagick installé

echo "🎨 Conversion des images SVG vers PNG pour VyBzzZ..."

# Vérifier si ImageMagick est installé
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick n'est pas installé. Installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install imagemagick
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get install imagemagick
    else
        echo "❌ Système d'exploitation non supporté"
        exit 1
    fi
fi

# Créer le dossier de sortie
mkdir -p assets/images/concepts_png

# Convertir tous les SVG en PNG
echo "🔄 Conversion en cours..."

# UI/UX
if [ -f "assets/images/concepts/ui_ux/dashboard_concept.svg" ]; then
    convert "assets/images/concepts/ui_ux/dashboard_concept.svg" "assets/images/concepts_png/dashboard_concept.png"
    echo "✅ dashboard_concept.svg → dashboard_concept.png"
fi

# Branding
if [ -f "assets/images/concepts/branding/brand_identity.svg" ]; then
    convert "assets/images/concepts/branding/brand_identity.svg" "assets/images/concepts_png/brand_identity.png"
    echo "✅ brand_identity.svg → brand_identity.png"
fi

# Marketing
if [ -f "assets/images/concepts/marketing/campaign_visuals.svg" ]; then
    convert "assets/images/concepts/marketing/campaign_visuals.svg" "assets/images/concepts_png/campaign_visuals.png"
    echo "✅ campaign_visuals.svg → campaign_visuals.png"
fi

# Innovation
if [ -f "assets/images/concepts/innovation/ai_chat_interface.svg" ]; then
    convert "assets/images/concepts/innovation/ai_chat_interface.svg" "assets/images/concepts_png/ai_chat_interface.png"
    echo "✅ ai_chat_interface.svg → ai_chat_interface.png"
fi

# Development
if [ -f "assets/images/concepts/development/mobile_app_flow.svg" ]; then
    convert "assets/images/concepts/development/mobile_app_flow.svg" "assets/images/concepts_png/mobile_app_flow.png"
    echo "✅ mobile_app_flow.svg → mobile_app_flow.png"
fi

echo "🎉 Conversion terminée !"
echo "📁 Images PNG disponibles dans: assets/images/concepts_png/"
echo ""
echo "💡 Pour utiliser les PNG au lieu des SVG, modifiez les chemins dans le code :"
echo "   localImagePath: 'assets/images/concepts_png/nom_image.png'"
