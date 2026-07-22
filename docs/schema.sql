-- TuneBox Database Schema for Supabase PostgreSQL
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Users ──
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  username TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  is_artist BOOLEAN DEFAULT FALSE,
  is_admin BOOLEAN DEFAULT FALSE,
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  total_plays INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Genres ──
CREATE TABLE IF NOT EXISTS genres (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  icon TEXT,
  color TEXT,
  songs_count INT DEFAULT 0
);

-- ── Albums ──
CREATE TABLE IF NOT EXISTS albums (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  artist_id UUID REFERENCES users(id) ON DELETE CASCADE,
  cover_url TEXT,
  description TEXT,
  year INT,
  songs_count INT DEFAULT 0,
  total_plays INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Songs ──
CREATE TABLE IF NOT EXISTS songs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  artist_id UUID REFERENCES users(id) ON DELETE CASCADE,
  album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
  audio_url TEXT NOT NULL,
  cover_url TEXT,
  genre TEXT,
  language TEXT,
  year INT,
  description TEXT,
  tags TEXT[],
  duration INT DEFAULT 0,
  plays_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  downloads_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  is_approved BOOLEAN DEFAULT FALSE,
  is_explicit BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Playlists ──
CREATE TABLE IF NOT EXISTS playlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  description TEXT,
  cover_url TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  songs_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Playlist Songs ──
CREATE TABLE IF NOT EXISTS playlist_songs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  playlist_id UUID REFERENCES playlists(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(playlist_id, song_id)
);

-- ── Likes ──
CREATE TABLE IF NOT EXISTS likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, song_id)
);

-- ── Playlist Likes ──
CREATE TABLE IF NOT EXISTS playlist_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  playlist_id UUID REFERENCES playlists(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, playlist_id)
);

-- ── Comments ──
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  likes_count INT DEFAULT 0,
  replies_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Comment Likes ──
CREATE TABLE IF NOT EXISTS comment_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, comment_id)
);

-- ── Followers ──
CREATE TABLE IF NOT EXISTS followers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- ── Downloads ──
CREATE TABLE IF NOT EXISTS downloads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  file_path TEXT,
  progress INT DEFAULT 0,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── History ──
CREATE TABLE IF NOT EXISTS history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  played_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Notifications ──
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT,
  reference_id UUID,
  image_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Reports ──
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE SET NULL,
  comment_id UUID REFERENCES comments(id) ON DELETE SET NULL,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Banners ──
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  subtitle TEXT,
  image_url TEXT,
  link_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Indexes ──
CREATE INDEX idx_songs_artist ON songs(artist_id);
CREATE INDEX idx_songs_approved ON songs(is_approved);
CREATE INDEX idx_songs_plays ON songs(plays_count DESC);
CREATE INDEX idx_songs_created ON songs(created_at DESC);
CREATE INDEX idx_songs_genre ON songs(genre);
CREATE INDEX idx_playlists_user ON playlists(user_id);
CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id);
CREATE INDEX idx_playlist_songs_song ON playlist_songs(song_id);
CREATE INDEX idx_likes_user ON likes(user_id);
CREATE INDEX idx_likes_song ON likes(song_id);
CREATE INDEX idx_comments_song ON comments(song_id);
CREATE INDEX idx_comments_parent ON comments(parent_id);
CREATE INDEX idx_followers_follower ON followers(follower_id);
CREATE INDEX idx_followers_following ON followers(following_id);
CREATE INDEX idx_history_user ON history(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_downloads_user ON downloads(user_id);

-- ── RLS Policies ──
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- Public read policies
CREATE POLICY "Public profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Approved songs" ON songs FOR SELECT USING (is_approved = true);
CREATE POLICY "Public playlists" ON playlists FOR SELECT USING (is_public = true);
CREATE POLICY "Public banners" ON banners FOR SELECT USING (is_active = true);

-- User-specific policies
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own likes" ON likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON likes FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Users can read own likes" ON likes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own comments" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Users can read comments" ON comments FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON followers FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON followers FOR DELETE USING (auth.uid() = follower_id);
CREATE POLICY "Users can read followers" ON followers FOR SELECT USING (true);
CREATE POLICY "Users can manage own playlists" ON playlists FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage playlist songs" ON playlist_songs FOR ALL USING (
  EXISTS (SELECT 1 FROM playlists WHERE id = playlist_id AND user_id = auth.uid())
);
CREATE POLICY "Users can manage own downloads" ON downloads FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own history" ON history FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can read own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can report" ON reports FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ── Functions ──
CREATE OR REPLACE FUNCTION increment_play_count(song_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE songs SET plays_count = plays_count + 1 WHERE id = song_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_download_count(song_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE songs SET downloads_count = downloads_count + 1 WHERE id = song_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_playlist_songs_count(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE playlists SET songs_count = songs_count + 1 WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_playlist_songs_count(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE playlists SET songs_count = GREATEST(songs_count - 1, 0) WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_playlist_likes_count(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE playlists SET likes_count = likes_count + 1 WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_playlist_likes_count(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE playlists SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ── Storage Buckets ──
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('songs', 'songs', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('covers', 'covers', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('banners', 'banners', true);

-- Storage policies
CREATE POLICY "Avatar upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');
CREATE POLICY "Avatar read" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Song upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'songs');
CREATE POLICY "Song read" ON storage.objects FOR SELECT USING (bucket_id = 'songs');
CREATE POLICY "Cover upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'covers');
CREATE POLICY "Cover read" ON storage.objects FOR SELECT USING (bucket_id = 'covers');
CREATE POLICY "Banner upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'banners');
CREATE POLICY "Banner read" ON storage.objects FOR SELECT USING (bucket_id = 'banners');
