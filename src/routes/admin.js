const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Só deixa passar se o e-mail de quem está logado bater com o dono do app
// (configurado como variável de ambiente ADMIN_EMAIL no Render).
function requireAdmin(req, res, next) {
  const adminEmail = (process.env.ADMIN_EMAIL || '').toLowerCase().trim();
  const userEmail = (req.userEmail || '').toLowerCase().trim();
  if (!adminEmail || userEmail !== adminEmail) {
    return res.status(403).json({ error: 'Acesso restrito.' });
  }
  next();
}

router.get('/stats', requireAuth, requireAdmin, async (req, res) => {
  const queries = {
    users: 'SELECT COUNT(*) FROM users',
    newUsersToday: `SELECT COUNT(*) FROM users WHERE created_at >= CURRENT_DATE`,
    newUsersWeek: `SELECT COUNT(*) FROM users WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'`,
    books: 'SELECT COUNT(*) FROM books',
    reviews: 'SELECT COUNT(*) FROM reviews',
    follows: 'SELECT COUNT(*) FROM follows',
    shelvesWant: `SELECT COUNT(*) FROM shelves WHERE status = 'want'`,
    shelvesReading: `SELECT COUNT(*) FROM shelves WHERE status = 'reading'`,
    shelvesRead: `SELECT COUNT(*) FROM shelves WHERE status = 'read'`,
  };

  const result = {};
  for (const [key, sql] of Object.entries(queries)) {
    const r = await pool.query(sql);
    result[key] = Number(r.rows[0].count);
  }
  res.json(result);
});

module.exports = router;
