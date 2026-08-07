const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth); // toda rota de estante exige login

router.get('/', async (req, res) => {
  const result = await pool.query(
    `SELECT s.*, b.title, b.authors, b.cover_url
     FROM shelves s JOIN books b ON b.id = s.book_id
     WHERE s.user_id = $1
     ORDER BY s.updated_at DESC`,
    [req.userId]
  );
  res.json({ shelves: result.rows });
});

// Define/atualiza o status de um livro na estante do usuário logado.
// Chamar de novo com o mesmo status funciona como "remover" no app.
router.put('/:bookId', async (req, res) => {
  const { status } = req.body;
  if (!['want', 'reading', 'read'].includes(status)) {
    return res.status(400).json({ error: 'status deve ser "want", "reading" ou "read".' });
  }
  const result = await pool.query(
    `INSERT INTO shelves (user_id, book_id, status)
     VALUES ($1, $2, $3)
     ON CONFLICT (user_id, book_id) DO UPDATE SET status = EXCLUDED.status, updated_at = now()
     RETURNING *`,
    [req.userId, req.params.bookId, status]
  );
  res.json({ shelf: result.rows[0] });
});

router.delete('/:bookId', async (req, res) => {
  await pool.query('DELETE FROM shelves WHERE user_id = $1 AND book_id = $2', [req.userId, req.params.bookId]);
  res.status(204).end();
});

module.exports = router;
