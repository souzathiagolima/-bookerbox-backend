-- Bookerbox — migração: adiciona a estante "abandonado" (livros não concluídos)
ALTER TYPE shelf_status ADD VALUE IF NOT EXISTS 'abandoned';
