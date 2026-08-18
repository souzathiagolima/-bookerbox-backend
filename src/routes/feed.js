const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Isto é o que diferencia uma rede social de um mural público:
// o feed só traz atividade sua e de quem você segue, não de todo mundo.
// Combina resenhas com atualizações de estante (começou a ler / terminou),
// parecido com o "diário de atividade" do Letterboxd.
router.get('/', requireAuth, async (req, res) => {
  const limit = Math.min(Number(req.query.limit) || 20, 50);
  const offset = Number(req.query.offset) || 0;

  const result = await pool.query(
    `(
       SELECT 'review' AS activity_type, r.id, r.user_id, r.book_id, r.rating, r.text, r.created_at,
         u.name AS user_name, u.avatar_url,
         b.title AS book_title, b.authors AS book_authors, b.cover_url AS book_cover,
         (SELECT COUNT(*) FROM likes l WHERE l.review_id = r.id)::int AS like_count,
         EXISTS(SELECT 1 FROM likes l WHERE l.review_id = r.id AND l.user_id = $1) AS liked_by_me,
         NULL::shelf_status AS shelf_status
       FROM reviews r
       JOIN users u ON u.id = r.user_id
       JOIN books b ON b.id = r.book_id
       WHERE r.user_id = $1 OR r.user_id IN (SELECT following_id FROM follows WHERE follower_id = $1)
     )
     UNION ALL
     (
       SELECT 'shelf' AS activity_type, s.id, s.user_id, s.book_id, NULL::smallint AS rating, NULL::text AS text, s.updated_at AS created_at,
         u.name AS user_name, u.avatar_url,
         b.title AS book_title, b.authors AS book_authors, b.cover_url AS book_cover,
         0 AS like_count, false AS liked_by_me,
         s.status AS shelf_status
       FROM shelves s
       JOIN users u ON u.id = s.user_id
       JOIN books b ON b.id = s.book_id
       WHERE (s.user_id = $1 OR s.user_id IN (SELECT following_id FROM follows WHERE follower_id = $1))
         AND s.status IN ('reading', 'read')
     )
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [req.userId, limit, offset]
  );
  res.json({ reviews: result.rows });
});

module.exports = router;
