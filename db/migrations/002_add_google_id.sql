-- Bookerbox — migração: adiciona coluna para login com Google
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id TEXT UNIQUE;
