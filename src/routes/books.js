const express = require('express');
const pool = require('../db');

const router = express.Router();

// Busca no Google Books e guarda (cacheia) cada resultado na nossa própria
// tabela `books`, para as próximas leituras desse livro serem instantâneas
// e para resenhas/estantes poderem referenciar um id nosso e estável.
router.get('/search', async (req, res) => {
  const q = req.query.q;
  if (!q) return res.status(400).json({ error: 'Parâmetro "q" é obrigatório.' });

  try {
    const apiRes = await fetch(`https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(q)}&maxResults=20`);
    const data = await apiRes.json();
    const items = data.items || [];

    const books = [];
    for (const it of items) {
      const info = it.volumeInfo || {};
      const isbn13 = (info.industryIdentifiers || []).find(i => i.type === 'ISBN_13')?.identifier || null;

      const result = await pool.query(
        `INSERT INTO books (google_books_id, title, authors, cover_url, description, isbn)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (google_books_id) DO UPDATE SET
           title = EXCLUDED.title,
           authors = EXCLUDED.authors,
           cover_url = EXCLUDED.cover_url,
           description = EXCLUDED.description
         RETURNING *`,
        [
          it.id,
          info.title || 'Sem título',
          (info.authors || []).join(', ') || null,
          (info.imageLinks?.thumbnail || '').replace('http:', 'https:') || null,
          info.description || null,
          isbn13,
        ]
      );
      books.push(result.rows[0]);
    }
    res.json({ books });
  } catch (err) {
    console.error(err);
    res.status(502).json({ error: 'Não foi possível buscar livros agora. Tente de novo em instantes.' });
  }
});

router.get('/:id', async (req, res) => {
  const result = await pool.query('SELECT * FROM books WHERE id = $1', [req.params.id]);
  if (!result.rows.length) return res.status(404).json({ error: 'Livro não encontrado.' });
  res.json({ book: result.rows[0] });
});

module.exports = router;
