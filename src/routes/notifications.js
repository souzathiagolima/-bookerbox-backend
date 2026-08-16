const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

router.get('/', async (req, res) => {
  const result = await pool.query(
    `SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 30`,
    [req.userId]
  );
  const [{ count: unread }] = (await pool.query(
    'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND read = false',
    [req.userId]
  )).rows;
  res.json({ notifications: result.rows, unread: Number(unread) });
});

router.post('/read-all', async (req, res) => {
  await pool.query('UPDATE notifications SET read = true WHERE user_id = $1', [req.userId]);
  res.status(204).end();
});

module.exports = router;
