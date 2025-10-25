# VyBzzZ - Plateforme de Concerts Live avec Paiement Immédiat

VyBzzZ est la première plateforme qui paie les artistes **instantanément** après leur concert. Fini l'attente de 7-30 jours.

## Stack Technique

- **Frontend**: Next.js 14 + React 18 + TypeScript + Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Streaming**: 100MS Live
- **Paiements**: Stripe Connect
- **Déploiement**: Vercel + Supabase Cloud

## Fonctionnalités Principales

- Authentification (email + Google OAuth)
- Création et gestion d'événements
- Achat de billets avec QR codes
- Live streaming HD avec 100MS
- Chat en temps réel
- Système de pourboires
- Transferts immédiats aux artistes (via Stripe Connect)
- Commission 10% (la plus basse du marché)
- Analytics en temps réel

## Installation

### Prérequis

- Node.js 18+
- npm ou yarn
- Un compte Supabase
- Un compte Stripe
- Un compte 100MS Live

### 1. Cloner le projet

```bash
git clone https://github.com/votre-repo/vybzzz.git
cd vybzzz
```

### 2. Installer les dépendances

```bash
npm install
```

### 3. Configuration Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Exécuter le script SQL dans `supabase/schema.sql` dans l'éditeur SQL
3. Activer l'authentification Google dans les settings
4. Récupérer les clés API (URL + anon key)

### 4. Configuration Stripe

1. Créer un compte sur [stripe.com](https://stripe.com)
2. Activer Stripe Connect
3. Récupérer les clés API (publishable key + secret key)
4. Configurer le webhook endpoint : `https://votre-domaine.com/api/stripe/webhook`
5. Récupérer le webhook secret

### 5. Configuration 100MS

1. Créer un compte sur [100ms.live](https://www.100ms.live)
2. Créer une application
3. Récupérer l'App ID et le Management Token

### 6. Variables d'environnement

Copier `.env.example` vers `.env` et remplir les valeurs :

```bash
cp .env.example .env
```

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://votre-projet.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=votre_anon_key
SUPABASE_SERVICE_ROLE_KEY=votre_service_role_key

# Stripe
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# 100MS Live
NEXT_PUBLIC_HMS_APP_ID=votre_app_id
HMS_MANAGEMENT_TOKEN=votre_management_token

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 7. Lancer le serveur de développement

```bash
npm run dev
```

Ouvrir [http://localhost:3000](http://localhost:3000) dans votre navigateur.

## Déploiement

### Déployer sur Vercel

1. Connecter votre repo GitHub à Vercel
2. Configurer les variables d'environnement
3. Déployer

```bash
npm run build
```

### Configurer le webhook Stripe

Après déploiement, configurer l'URL du webhook dans Stripe :

```
https://votre-domaine.vercel.app/api/stripe/webhook
```

Événements à écouter :
- `payment_intent.succeeded`
- `payment_intent.payment_failed`

## Structure du Projet

```
vybzzz/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── signup/page.tsx
│   ├── api/
│   │   ├── stripe/
│   │   │   ├── checkout/route.ts
│   │   │   ├── webhook/route.ts
│   │   │   ├── connect/route.ts
│   │   │   └── tip/route.ts
│   │   └── hms/token/route.ts
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── components/
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Card.tsx
│   │   └── Logo.tsx
│   └── Navbar.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   └── server.ts
│   ├── hooks/useAuth.ts
│   └── utils.ts
├── supabase/schema.sql
└── README.md
```

## Utilisation

### Créer un compte Artiste

1. S'inscrire avec le type "Artiste"
2. Configurer Stripe Connect pour recevoir les paiements
3. Créer un événement
4. Partager le lien avec vos fans

### Acheter un billet

1. S'inscrire avec le type "Fan"
2. Parcourir les événements
3. Acheter un billet
4. Recevoir le QR code par email

### Lancer un live

1. Créer un événement de type "Live"
2. Configurer la date et le prix
3. Cliquer sur "Démarrer le live" à l'heure prévue
4. Vos fans reçoivent une notification
5. Streamer via 100MS
6. Recevoir les pourboires en direct

## Modèle Économique

- **Commission billets** : 10% (vs 10-15% chez les concurrents)
- **Commission pourboires** : 5%
- **Transfert** : Immédiat après le concert
- **Frais Stripe** : ~2.9% + 0.25€

Exemple de revenus pour un concert avec 100 billets à 20€ :
- Revenus bruts : 2 000€
- Commission VyBzzZ (10%) : 200€
- Frais Stripe (~3%) : 60€
- **Revenus artiste : 1 740€ (87%)**
- **Transfert : IMMÉDIAT**

## Sécurité

- Row Level Security (RLS) activé sur toutes les tables Supabase
- Vérification de signature webhook Stripe
- HTTPS obligatoire (via Vercel)
- Variables d'environnement sécurisées
- Authentification JWT via Supabase

## Support

Pour toute question ou problème :
- Email : support@vybzzz.com
- Discord : [discord.gg/vybzzz](https://discord.gg/vybzzz)

## Licence

© 2025 VyBzzZ. Tous droits réservés.

---

**Créé avec amour par Jean-Sébastien LOUIS-GUSTAVE**

Deadline : 31 décembre 2025
