const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Precisa vir ANTES de "/:id", senão o Express acha que "search" é um id de usuário.
router.get('/search', async (req, res) => {
  const q = req.query.q;
  if (!q || !q.trim()) return res.status(400).json({ error: 'Parâmetro "q" é obrigatório.' });
  const result = await pool.query(
    `SELECT id, name, avatar_url FROM users WHERE name ILIKE $1 ORDER BY name LIMIT 20`,
    [`%${q.trim()}%`]
  );
  res.json({ users: result.rows });
});

router.get('/:id', async (req, res) => {
  const userResult = await pool.query(
    'SELECT id, name, avatar_url, created_at FROM users WHERE id = $1',
    [req.params.id]
  );
  if (!userResult.rows.length) return res.status(404).json({ error: 'Usuário não encontrado.' });

  const [{ count: reviewCount }] = (await pool.query(
    'SELECT COUNT(*) FROM reviews WHERE user_id = $1', [req.params.id]
  )).rows;
  const [{ count: followerCount }] = (await pool.query(
    'SELECT COUNT(*) FROM follows WHERE following_id = $1', [req.params.id]
  )).rows;
  const [{ count: followingCount }] = (await pool.query(
    'SELECT COUNT(*) FROM follows WHERE follower_id = $1', [req.params.id]
  )).rows;

  res.json({
    user: userResult.rows[0],
    stats: {
      reviews: Number(reviewCount),
      followers: Number(followerCount),
      following: Number(followingCount),
    },
  });
});

// Seguir é a ação que conecta duas pessoas na rede.
router.post('/:id/follow', requireAuth, async (req, res) => {
  if (req.params.id === req.userId) {
    return res.status(400).json({ error: 'Você não pode seguir a si mesmo.' });
  }
  await pool.query(
    'INSERT INTO follows (follower_id, following_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
    [req.userId, req.params.id]
  );
  try {
    const me = await pool.query('SELECT name FROM users WHERE id = $1', [req.userId]);
    await pool.query(
      `INSERT INTO notifications (user_id, type, payload) VALUES ($1, 'follow', $2)`,
      [req.params.id, JSON.stringify({ actorId: req.userId, actorName: me.rows[0]?.name })]
    );
  } catch (err) {
    console.error('Falha ao criar notificação de follow:', err.message);
  }
  res.status(201).json({ following: true });
});

router.delete('/:id/follow', requireAuth, async (req, res) => {
  await pool.query(
    'DELETE FROM follows WHERE follower_id = $1 AND following_id = $2',
    [req.userId, req.params.id]
  );
  res.status(204).end();
});

router.get('/:id/followers', async (req, res) => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.avatar_url FROM follows f
     JOIN users u ON u.id = f.follower_id WHERE f.following_id = $1`,
    [req.params.id]
  );
  res.json({ followers: result.rows });
});

router.get('/:id/following', async (req, res) => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.avatar_url FROM follows f
     JOIN users u ON u.id = f.following_id WHERE f.follower_id = $1`,
    [req.params.id]
  );
  res.json({ following: result.rows });
});

module.exports = router;
