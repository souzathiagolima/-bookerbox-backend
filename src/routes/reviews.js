const express = require('express');
const pool = require('../db');
const { requireAuth, optionalAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/', requireAuth, async (req, res) => {
  const { bookId, rating, text } = req.body;
  if (!bookId || !rating || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'bookId e rating (1 a 5) são obrigatórios.' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const review = await client.query(
      `INSERT INTO reviews (user_id, book_id, rating, text) VALUES ($1, $2, $3, $4) RETURNING *`,
      [req.userId, bookId, rating, text || null]
    );
    // publicar uma resenha também marca o livro como "lido" na estante
    await client.query(
      `INSERT INTO shelves (user_id, book_id, status)
       VALUES ($1, $2, 'read')
       ON CONFLICT (user_id, book_id) DO UPDATE SET status = 'read', updated_at = now()`,
      [req.userId, bookId]
    );
    await client.query('COMMIT');
    res.status(201).json({ review: review.rows[0] });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Erro ao publicar resenha.' });
  } finally {
    client.release();
  }
});

router.get('/book/:bookId', optionalAuth, async (req, res) => {
  const result = await pool.query(
    `SELECT r.*, u.name as user_name, u.avatar_url,
       EXISTS(SELECT 1 FROM likes l WHERE l.review_id = r.id AND l.user_id = $2) as liked_by_me,
       (SELECT COUNT(*) FROM likes l WHERE l.review_id = r.id)::int as like_count
     FROM reviews r JOIN users u ON u.id = r.user_id
     WHERE r.book_id = $1
     ORDER BY r.created_at DESC`,
    [req.params.bookId, req.userId || null]
  );
  res.json({ reviews: result.rows });
});

router.patch('/:id', requireAuth, async (req, res) => {
  const { rating, text } = req.body;
  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'rating (1 a 5) é obrigatório.' });
  }
  const result = await pool.query(
    `UPDATE reviews SET rating = $1, text = $2 WHERE id = $3 AND user_id = $4 RETURNING *`,
    [rating, text || null, req.params.id, req.userId]
  );
  if (!result.rows.length) return res.status(404).json({ error: 'Resenha não encontrada.' });
  res.json({ review: result.rows[0] });
});

router.delete('/:id', requireAuth, async (req, res) => {
  const result = await pool.query(
    'DELETE FROM reviews WHERE id = $1 AND user_id = $2 RETURNING id',
    [req.params.id, req.userId]
  );
  if (!result.rows.length) return res.status(404).json({ error: 'Resenha não encontrada.' });
  res.status(204).end();
});

router.post('/:id/like', requireAuth, async (req, res) => {
  await pool.query(
    'INSERT INTO likes (user_id, review_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
    [req.userId, req.params.id]
  );
  try {
    const review = await pool.query('SELECT user_id, book_id FROM reviews WHERE id = $1', [req.params.id]);
    const ownerId = review.rows[0]?.user_id;
    if (ownerId && ownerId !== req.userId) {
      const [me, book] = await Promise.all([
        pool.query('SELECT name FROM users WHERE id = $1', [req.userId]),
        pool.query('SELECT title FROM books WHERE id = $1', [review.rows[0].book_id]),
      ]);
      await pool.query(
        `INSERT INTO notifications (user_id, type, payload) VALUES ($1, 'like', $2)`,
        [ownerId, JSON.stringify({ actorId: req.userId, actorName: me.rows[0]?.name, bookTitle: book.rows[0]?.title, reviewId: req.params.id })]
      );
    }
  } catch (err) {
    console.error('Falha ao criar notificação de like:', err.message);
  }
  res.status(201).json({ liked: true });
});

router.delete('/:id/like', requireAuth, async (req, res) => {
  await pool.query('DELETE FROM likes WHERE user_id = $1 AND review_id = $2', [req.userId, req.params.id]);
  res.status(204).end();
});

module.exports = router;
