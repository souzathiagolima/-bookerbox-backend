-- Bookerbox — migração: adiciona coluna de categorias/gêneros aos livros
ALTER TABLE books ADD COLUMN IF NOT EXISTS categories TEXT;
