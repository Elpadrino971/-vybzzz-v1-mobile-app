# 🔥 Schéma Firebase/Firestore - VyBzzZ

Documentation complète de la structure de données Firebase pour VyBzzZ.

## 📊 Collections Principales

### 1. `users` - Utilisateurs

Collection contenant tous les utilisateurs (Fans, Artistes, AA, RM, Propriétaires)

```typescript
/users/{userId}
```

**Structure:**
```json
{
  "id": 123,
  "identity": "unique_firebase_uid",
  "fullname": "Jean Dupont",
  "username": "jeandupont",
  "user_email": "jean@example.com",
  "profile_photo": "https://...",
  "bio": "Description de l'utilisateur",

  // VyBzzZ specific fields
  "user_type": "fan|artist|business_bringer|regional_manager|venue_owner",
  "subscription_tier": "basic|pro|premium",  // Pour les artistes uniquement

  // Stripe
  "stripe_account_id": "acct_xxx",  // Pour recevoir des paiements
  "stripe_customer_id": "cus_xxx",   // Pour effectuer des paiements

  // Affiliation
  "affiliate_code": "JEANDUPONT_123",  // Code unique pour AA
  "referred_by": 456,                   // ID de l'utilisateur parrain

  // Stats
  "follower_count": 1250,
  "following_count": 350,
  "coin_wallet": 5000,
  "coin_collected_lifetime": 12000,
  "is_verify": 1,
  "is_moderator": 0,

  // Timestamps
  "created_at": "2025-01-01T12:00:00Z",
  "updated_at": "2025-01-15T14:30:00Z"
}
```

**Types d'utilisateurs:**
- `fan` : Spectateur/acheteur de billets
- `artist` : Artiste qui organise des concerts
- `business_bringer` : Apporteur d'affaire (affilié)
- `regional_manager` : Responsable régional
- `venue_owner` : Propriétaire de salle

**Paliers d'abonnement (artistes uniquement):**
- `basic` : 19,99€/mois - 50% artiste / 50% plateforme
- `pro` : 59,99€/mois - 60% artiste / 40% plateforme
- `premium` : 129,99€/mois - 70% artiste / 30% plateforme

---

### 2. `events` - Événements/Concerts

Collection contenant tous les concerts et événements

```typescript
/events/{eventId}
```

**Structure:**
```json
{
  "id": "event_abc123",
  "artist_id": 123,
  "artist_name": "David Guetta",
  "artist_photo": "https://...",

  // Informations de base
  "title": "David Guetta Live @ Paris",
  "description": "Concert exceptionnel...",
  "cover_image_url": "https://...",

  // Type et statut
  "event_type": "live|physical|hybrid",
  "status": "draft|scheduled|live|ended|cancelled",

  // Dates
  "start_time": "2025-12-31T20:00:00Z",
  "end_time": "2025-12-31T23:00:00Z",

  // Localisation (pour concerts physiques/hybrides)
  "venue_name": "AccorHotels Arena",
  "venue_address": "8 Bd de Bercy, 75012 Paris",
  "venue_lat": 48.839,
  "venue_lon": 2.379,

  // Streaming
  "stream_url": "https://...",
  "hms_room_id": "room_xyz",
  "hms_recording_url": "https://...",

  // Replay (disponible 7 jours)
  "replay_url": "https://...",
  "replay_expires_at": "2026-01-07T23:00:00Z",
  "replay_available": true,

  // Prix des billets (3 types)
  "ticket_price_virtual": 20.00,    // Billet virtuel (le moins cher)
  "ticket_price_physical": 50.00,   // Billet physique (le plus cher)
  "ticket_price_fanbase": 10.00,    // Fanbase (visionnage collectif)

  // Billets vendus
  "ticket_quantity": 1000,          // Total disponible
  "tickets_sold": 245,              // Total vendus
  "tickets_virtual_sold": 150,
  "tickets_physical_sold": 80,
  "tickets_fanbase_sold": 15,

  // Happy Hour
  "is_happy_hour": true,
  "happy_hour_price_virtual": 15.00,
  "happy_hour_price_physical": 40.00,
  "happy_hour_price_fanbase": 7.50,
  "happy_hour_start_time": "2025-12-31T20:00:00Z",
  "happy_hour_end_time": "2025-12-31T20:15:00Z",

  // Stats
  "viewer_count": 1250,             // Spectateurs actuels
  "peak_viewer_count": 1850,        // Pic de spectateurs
  "total_revenue": 12500.00,        // Revenus totaux
  "total_tips": 850.00,             // Pourboires totaux

  // Timestamps
  "created_at": "2025-11-01T10:00:00Z",
  "updated_at": "2025-12-31T20:30:00Z"
}
```

**Types d'événements:**
- `live` : Concert virtuel uniquement
- `physical` : Concert physique uniquement
- `hybrid` : Concert physique + streaming virtuel

**Statuts:**
- `draft` : Brouillon (non publié)
- `scheduled` : Programmé (visible, billets en vente)
- `live` : En direct (concert en cours)
- `ended` : Terminé (replay disponible)
- `cancelled` : Annulé

---

### 3. `tickets` - Billets

Collection contenant tous les billets achetés

```typescript
/tickets/{ticketId}
```

**Structure:**
```json
{
  "id": "ticket_xyz789",
  "event_id": "event_abc123",
  "user_id": 456,

  "ticket_type": "virtual|physical|fanbase",
  "qr_code": "QRCODE_UNIQUE_XYZ789",
  "price_paid": 20.00,

  "status": "valid|used|refunded|cancelled",
  "purchased_at": "2025-12-20T15:30:00Z",
  "used_at": null,

  // Stripe
  "stripe_payment_intent_id": "pi_xxx",
  "stripe_transaction_id": "txn_xxx"
}
```

**Types de billets:**
- `virtual` : Regarder depuis chez soi
- `physical` : Assister sur place
- `fanbase` : Visionnage collectif dans une salle

**Statuts:**
- `valid` : Billet valide (non utilisé)
- `used` : Billet utilisé (entrée validée)
- `refunded` : Remboursé
- `cancelled` : Annulé

---

### 4. `tips` - Pourboires

Collection contenant tous les pourboires envoyés aux artistes

```typescript
/tips/{tipId}
```

**Structure:**
```json
{
  "id": "tip_123",
  "from_user_id": 456,
  "to_artist_id": 123,
  "event_id": "event_abc123",

  "amount": 5.00,
  "message": "Super concert !",

  "stripe_payment_intent_id": "pi_xxx",
  "status": "pending|completed|failed",

  "created_at": "2025-12-31T21:00:00Z"
}
```

---

### 5. `transactions` - Transactions

Collection contenant l'historique financier complet

```typescript
/transactions/{transactionId}
```

**Structure:**
```json
{
  "id": "txn_456",
  "user_id": 123,

  "transaction_type": "ticket_sale|tip|commission|payout|refund",
  "amount": 20.00,
  "platform_fee": 8.00,      // Commission VyBzzZ
  "net_amount": 12.00,        // Montant net pour l'artiste

  "stripe_transaction_id": "txn_xxx",
  "related_entity_id": "event_abc123",

  "status": "pending|completed|failed|refunded",
  "created_at": "2025-12-31T20:00:00Z"
}
```

**Types de transactions:**
- `ticket_sale` : Vente de billet
- `tip` : Pourboire
- `commission` : Commission d'affiliation
- `payout` : Paiement à l'artiste (J+14 lundi)
- `refund` : Remboursement

---

### 6. `payouts` - Paiements aux Artistes

Collection contenant les paiements programmés aux artistes

```typescript
/payouts/{payoutId}
```

**Structure:**
```json
{
  "id": "payout_789",
  "artist_id": 123,
  "subscription_tier": "pro",

  // Événements inclus dans ce payout
  "event_ids": ["event_abc123", "event_def456"],

  // Montants
  "gross_revenue": 12500.00,      // Revenus bruts
  "platform_fee": 5000.00,        // Commission (40% pour Pro)
  "net_amount": 7500.00,          // Montant net
  "stripe_fees": 375.00,          // Frais Stripe (~3%)
  "final_amount": 7125.00,        // Montant final versé

  // Dates
  "event_date": "2025-12-31",     // Date du concert
  "payment_date": "2026-01-14",   // Lundi J+14

  "stripe_transfer_id": "tr_xxx",
  "status": "pending|processing|completed|failed",

  "created_at": "2026-01-13T00:00:00Z",
  "completed_at": "2026-01-14T10:00:00Z"
}
```

---

### 7. `affiliates` - Affiliations

Collection pour le système d'affiliation multi-niveaux

```typescript
/affiliates/{affiliateId}
```

**Structure:**
```json
{
  "id": "aff_123",
  "business_bringer_id": 789,
  "referred_user_id": 456,
  "referred_user_type": "artist",

  // Niveaux de commission
  "level": 1,                     // 1, 2 ou 3
  "commission_rate": 0.025,       // 2.5% (niveau 1)

  // Stats
  "total_commission_earned": 125.00,
  "total_transactions": 15,

  "created_at": "2025-10-01T12:00:00Z"
}
```

**Taux de commission:**
- **Niveau 1** : 2.5% (utilisateurs directement référés)
- **Niveau 2** : 1.5% (utilisateurs référés par vos référés)
- **Niveau 3** : 1.0% (niveau 3 de profondeur)

---

### 8. `live_chat_messages` - Messages de Chat Live

Collection contenant les messages du chat pendant les concerts

```typescript
/events/{eventId}/chat/{messageId}
```

**Structure:**
```json
{
  "id": "msg_123",
  "user_id": 456,
  "username": "jeandupont",
  "profile_photo": "https://...",

  "message": "Super concert !",
  "is_moderator": false,

  "created_at": "2025-12-31T21:05:30Z"
}
```

---

## 🔐 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users - Tout le monde peut lire, seulement le propriétaire peut modifier
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Events - Tout le monde peut lire (sauf draft), artiste peut créer/modifier
    match /events/{eventId} {
      allow read: if resource.data.status != 'draft' ||
                     request.auth.uid == resource.data.artist_id;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.artist_id;
    }

    // Tickets - Seulement le propriétaire peut lire
    match /tickets/{ticketId} {
      allow read: if request.auth.uid == resource.data.user_id;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.user_id;
    }

    // Tips - Expéditeur et destinataire peuvent lire
    match /tips/{tipId} {
      allow read: if request.auth.uid == resource.data.from_user_id ||
                     request.auth.uid == resource.data.to_artist_id;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.from_user_id;
    }

    // Transactions - Seulement le propriétaire peut lire
    match /transactions/{transactionId} {
      allow read: if request.auth.uid == resource.data.user_id;
    }

    // Payouts - Seulement l'artiste peut lire
    match /payouts/{payoutId} {
      allow read: if request.auth.uid == resource.data.artist_id;
    }

    // Chat - Les détenteurs de billets peuvent lire et écrire
    match /events/{eventId}/chat/{messageId} {
      allow read: if exists(/databases/$(database)/documents/tickets/$(request.auth.uid + '_' + eventId));
      allow create: if request.auth != null && request.auth.uid == request.resource.data.user_id;
    }
  }
}
```

---

## 🚀 Indexation

### Index Recommandés

```typescript
// Events
events: [
  { artist_id: 'asc', start_time: 'desc' },
  { status: 'asc', start_time: 'desc' },
  { event_type: 'asc', status: 'asc' }
]

// Tickets
tickets: [
  { user_id: 'asc', purchased_at: 'desc' },
  { event_id: 'asc', status: 'asc' }
]

// Transactions
transactions: [
  { user_id: 'asc', created_at: 'desc' },
  { transaction_type: 'asc', status: 'asc' }
]

// Payouts
payouts: [
  { artist_id: 'asc', payment_date: 'desc' },
  { status: 'asc', payment_date: 'asc' }
]
```

---

## 📈 Requêtes Courantes

### Événements à venir d'un artiste
```dart
FirebaseFirestore.instance
  .collection('events')
  .where('artist_id', isEqualTo: artistId)
  .where('status', isEqualTo: 'scheduled')
  .orderBy('start_time', descending: false)
  .get();
```

### Billets d'un utilisateur
```dart
FirebaseFirestore.instance
  .collection('tickets')
  .where('user_id', isEqualTo: userId)
  .orderBy('purchased_at', descending: true)
  .get();
```

### Paiements d'un artiste
```dart
FirebaseFirestore.instance
  .collection('payouts')
  .where('artist_id', isEqualTo: artistId)
  .where('status', isEqualTo: 'completed')
  .orderBy('payment_date', descending: true)
  .get();
```

---

## 🎯 Migration depuis le Schéma Actuel

1. **Ajouter les nouveaux champs** aux documents `users` existants :
   - `user_type`
   - `subscription_tier`
   - `stripe_account_id`
   - `stripe_customer_id`
   - `affiliate_code`
   - `referred_by`

2. **Créer les nouvelles collections** :
   - `events` (avec replay et 3 types de billets)
   - `payouts`
   - `affiliates`

3. **Migrer les données existantes** si nécessaire

---

## 📝 Notes Importantes

- Les **payouts sont programmés tous les lundis à J+14** après un concert
- Les **replays expirent après 7 jours**
- Le **Happy Hour** se déclenche automatiquement chaque mercredi à 20h pour 15 minutes
- Les **commissions d'affiliation** sont calculées sur 3 niveaux (2.5%, 1.5%, 1%)
- Les **billets Fanbase** permettent le visionnage collectif dans une salle locale

---

**Schéma créé pour VyBzzZ** 🚀
Deadline : 30 novembre 2025
