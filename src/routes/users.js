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

router.get('/:id/reading-stats', async (req, res) => {
  const userId = req.params.id;
  const yearStart = `${new Date().getFullYear()}-01-01`;

  const totalReadRes = await pool.query(
    `SELECT COUNT(*) FROM shelves WHERE user_id = $1 AND status = 'read'`,
    [userId]
  );
  const thisYearRes = await pool.query(
    `SELECT COUNT(*) FROM shelves WHERE user_id = $1 AND status = 'read' AND updated_at >= $2`,
    [userId, yearStart]
  );
  const avgRatingRes = await pool.query(
    `SELECT AVG(rating)::numeric(10,2) AS avg FROM reviews WHERE user_id = $1`,
    [userId]
  );
  const booksRes = await pool.query(
    `SELECT b.authors, b.categories FROM shelves s JOIN books b ON b.id = s.book_id WHERE s.user_id = $1 AND s.status = 'read'`,
    [userId]
  );
  const currentlyReadingRes = await pool.query(
    `SELECT b.id, b.title, b.cover_url FROM shelves s JOIN books b ON b.id = s.book_id
     WHERE s.user_id = $1 AND s.status = 'reading' ORDER BY s.updated_at DESC LIMIT 1`,
    [userId]
  );

  // conta autores e gêneros a partir do texto "A, B" de cada livro lido
  const authorCounts = {};
  const genreCounts = {};
  booksRes.rows.forEach(r => {
    (r.authors || '').split(',').map(a => a.trim()).filter(Boolean).forEach(a => {
      authorCounts[a] = (authorCounts[a] || 0) + 1;
    });
    (r.categories || '').split(',').map(g => g.trim()).filter(Boolean).forEach(g => {
      genreCounts[g] = (genreCounts[g] || 0) + 1;
    });
  });
  let topAuthor = null;
  for (const [name, count] of Object.entries(authorCounts)) {
    if (!topAuthor || count > topAuthor.count) topAuthor = { name, count };
  }
  let topGenre = null;
  for (const [name, count] of Object.entries(genreCounts)) {
    if (!topGenre || count > topGenre.count) topGenre = { name, count };
  }

  // favoritos = livros que a pessoa avaliou com 5 estrelas
  const favoritesRes = await pool.query(
    `SELECT DISTINCT ON (b.id) b.id, b.title, b.cover_url
     FROM reviews r JOIN books b ON b.id = r.book_id
     WHERE r.user_id = $1 AND r.rating = 5
     ORDER BY b.id, r.created_at DESC
     LIMIT 10`,
    [userId]
  );

  res.json({
    totalRead: Number(totalReadRes.rows[0].count),
    readThisYear: Number(thisYearRes.rows[0].count),
    averageRating: avgRatingRes.rows[0].avg ? Number(avgRatingRes.rows[0].avg) : null,
    topAuthor,
    topGenre,
    currentlyReading: currentlyReadingRes.rows[0] || null,
    favorites: favoritesRes.rows,
  });
});

// Compatibilidade literária: quantos livros lidos em comum, em relação
// ao total de livros diferentes que os dois já leram (índice de Jaccard).
router.get('/:id/compatibility', requireAuth, async (req, res) => {
  const otherId = req.params.id;
  if (otherId === req.userId) {
    return res.json({ percent: null, sharedBooks: [] });
  }
  // compatibilidade baseada nos livros que cada um marcou como "lido" na estante
  const mine = await pool.query(`SELECT book_id FROM shelves WHERE user_id = $1 AND status = 'read'`, [req.userId]);
  const theirs = await pool.query(`SELECT book_id FROM shelves WHERE user_id = $1 AND status = 'read'`, [otherId]);

  const mineIds = new Set(mine.rows.map(r => r.book_id));
  const theirIds = new Set(theirs.rows.map(r => r.book_id));
  const sharedIds = [...mineIds].filter(id => theirIds.has(id));
  const unionSize = new Set([...mineIds, ...theirIds]).size;

  const percent = unionSize > 0 ? Math.round((sharedIds.length / unionSize) * 100) : null;

  let sharedBooks = [];
  if (sharedIds.length > 0) {
    const booksRes = await pool.query(
      `SELECT id, title, cover_url FROM books WHERE id = ANY($1::uuid[]) LIMIT 6`,
      [sharedIds]
    );
    sharedBooks = booksRes.rows;
  }

  res.json({ percent, sharedBooks });
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
