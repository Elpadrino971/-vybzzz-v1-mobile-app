-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS & AUTH
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  user_type TEXT CHECK (user_type IN ('fan', 'artist')) DEFAULT 'fan',
  stripe_account_id TEXT,
  stripe_customer_id TEXT,
  affiliate_code TEXT UNIQUE,
  referred_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ARTISTS (extension de profiles)
CREATE TABLE artists (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  stage_name TEXT NOT NULL,
  genre TEXT[],
  social_links JSONB,
  verified BOOLEAN DEFAULT false,
  total_followers INTEGER DEFAULT 0,
  total_tips DECIMAL(10,2) DEFAULT 0,
  stream_channel_arn TEXT,
  stream_key TEXT,
  stream_ingest_endpoint TEXT,
  stream_playback_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- EVENTS (concerts/lives)
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  artist_id UUID REFERENCES artists(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  event_type TEXT CHECK (event_type IN ('live', 'physical', 'hybrid')) NOT NULL,
  status TEXT CHECK (status IN ('draft', 'scheduled', 'live', 'ended', 'cancelled')) DEFAULT 'draft',
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  venue_name TEXT,
  venue_address TEXT,
  stream_url TEXT,
  replay_url TEXT,
  ticket_price DECIMAL(10,2) DEFAULT 0,
  ticket_quantity INTEGER,
  tickets_sold INTEGER DEFAULT 0,
  is_happy_hour BOOLEAN DEFAULT false,
  happy_hour_price DECIMAL(10,2),
  hms_room_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TICKETS
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) NOT NULL,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  ticket_type TEXT CHECK (ticket_type IN ('digital', 'physical')) NOT NULL,
  qr_code TEXT UNIQUE NOT NULL,
  price_paid DECIMAL(10,2) NOT NULL,
  status TEXT CHECK (status IN ('valid', 'used', 'refunded', 'cancelled')) DEFAULT 'valid',
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  used_at TIMESTAMPTZ,
  UNIQUE(event_id, user_id)
);

-- TIPS (pourboires)
CREATE TABLE tips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  from_user_id UUID REFERENCES profiles(id) NOT NULL,
  to_artist_id UUID REFERENCES artists(id) NOT NULL,
  event_id UUID REFERENCES events(id),
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  message TEXT,
  stripe_payment_intent_id TEXT,
  status TEXT CHECK (status IN ('pending', 'completed', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- FOLLOWS (abonnements artistes)
CREATE TABLE follows (
  follower_id UUID REFERENCES profiles(id) NOT NULL,
  following_id UUID REFERENCES artists(id) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

-- TRANSACTIONS (historique financier)
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  transaction_type TEXT CHECK (transaction_type IN ('ticket_sale', 'tip', 'commission', 'payout', 'refund')) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) DEFAULT 0,
  net_amount DECIMAL(10,2) NOT NULL,
  stripe_transaction_id TEXT,
  related_entity_id UUID,
  status TEXT CHECK (status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LIVE CHAT MESSAGES
CREATE TABLE live_chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) NOT NULL,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security (RLS)

-- Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Artists
ALTER TABLE artists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public artists are viewable by everyone"
  ON artists FOR SELECT
  USING (true);

CREATE POLICY "Artists can update own profile"
  ON artists FOR UPDATE
  USING (auth.uid() = id);

-- Events
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public events are viewable by everyone"
  ON events FOR SELECT
  USING (status != 'draft' OR artist_id = auth.uid());

CREATE POLICY "Artists can create events"
  ON events FOR INSERT
  WITH CHECK (artist_id = auth.uid());

CREATE POLICY "Artists can update own events"
  ON events FOR UPDATE
  USING (artist_id = auth.uid());

-- Tickets
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tickets"
  ON tickets FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create tickets"
  ON tickets FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Tips
ALTER TABLE tips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tips"
  ON tips FOR SELECT
  USING (from_user_id = auth.uid() OR to_artist_id = auth.uid());

CREATE POLICY "Users can create tips"
  ON tips FOR INSERT
  WITH CHECK (from_user_id = auth.uid());

-- Follows
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Follows are viewable by everyone"
  ON follows FOR SELECT
  USING (true);

CREATE POLICY "Users can follow artists"
  ON follows FOR INSERT
  WITH CHECK (follower_id = auth.uid());

CREATE POLICY "Users can unfollow artists"
  ON follows FOR DELETE
  USING (follower_id = auth.uid());

-- Transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
  ON transactions FOR SELECT
  USING (user_id = auth.uid());

-- Live Chat
ALTER TABLE live_chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Chat messages are viewable by ticket holders"
  ON live_chat_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tickets
      WHERE tickets.event_id = live_chat_messages.event_id
      AND tickets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send chat messages"
  ON live_chat_messages FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Functions

-- Increment followers count
CREATE OR REPLACE FUNCTION increment_followers()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE artists
  SET total_followers = total_followers + 1
  WHERE id = NEW.following_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_follow_created
  AFTER INSERT ON follows
  FOR EACH ROW
  EXECUTE FUNCTION increment_followers();

-- Decrement followers count
CREATE OR REPLACE FUNCTION decrement_followers()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE artists
  SET total_followers = total_followers - 1
  WHERE id = OLD.following_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_follow_deleted
  AFTER DELETE ON follows
  FOR EACH ROW
  EXECUTE FUNCTION decrement_followers();

-- Decrement tickets sold
CREATE OR REPLACE FUNCTION decrement_tickets_sold(event_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE events
  SET tickets_sold = GREATEST(tickets_sold - 1, 0)
  WHERE id = event_id;
END;
$$ LANGUAGE plpgsql;

-- Indexes for performance
CREATE INDEX idx_events_artist_id ON events(artist_id);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_start_time ON events(start_time);
CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_tickets_event_id ON tickets(event_id);
CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_id ON follows(following_id);
CREATE INDEX idx_tips_to_artist_id ON tips(to_artist_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_chat_event_id ON live_chat_messages(event_id);
