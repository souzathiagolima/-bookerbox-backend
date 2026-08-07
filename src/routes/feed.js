const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Isto é o que diferencia uma rede social de um mural público:
// o feed só traz resenhas suas e de quem você segue, não de todo mundo.
router.get('/', requireAuth, async (req, res) => {
  const limit = Math.min(Number(req.query.limit) || 20, 50);
  const offset = Number(req.query.offset) || 0;

  const result = await pool.query(
    `SELECT r.*, u.name as user_name, u.avatar_url,
       b.title as book_title, b.authors as book_authors, b.cover_url as book_cover,
       (SELECT COUNT(*) FROM likes l WHERE l.review_id = r.id)::int as like_count,
       EXISTS(SELECT 1 FROM likes l WHERE l.review_id = r.id AND l.user_id = $1) as liked_by_me
     FROM reviews r
     JOIN users u ON u.id = r.user_id
     JOIN books b ON b.id = r.book_id
     WHERE r.user_id = $1
        OR r.user_id IN (SELECT following_id FROM follows WHERE follower_id = $1)
     ORDER BY r.created_at DESC
     LIMIT $2 OFFSET $3`,
    [req.userId, limit, offset]
  );
  res.json({ reviews: result.rows });
});

module.exports = router;
