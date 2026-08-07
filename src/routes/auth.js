const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../db');
const { signToken } = require('../utils/jwt');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Nome, e-mail e senha são obrigatórios.' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'A senha precisa ter ao menos 6 caracteres.' });
  }
  try {
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (existing.rows.length) {
      return res.status(409).json({ error: 'Já existe uma conta com esse e-mail.' });
    }
    const hash = await bcrypt.hash(password, 10);
    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash)
       VALUES ($1, $2, $3)
       RETURNING id, name, email, avatar_url, created_at`,
      [name, email.toLowerCase(), hash]
    );
    const user = result.rows[0];
    const token = signToken(user);
    res.status(201).json({ token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao criar conta.' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'E-mail e senha são obrigatórios.' });
  }
  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email.toLowerCase()]);
    const user = result.rows[0];
    if (!user || !user.password_hash) {
      return res.status(401).json({ error: 'E-mail ou senha incorretos.' });
    }
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ error: 'E-mail ou senha incorretos.' });
    }
    const token = signToken(user);
    delete user.password_hash;
    res.json({ token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao entrar.' });
  }
});

router.get('/me', requireAuth, async (req, res) => {
  const result = await pool.query(
    'SELECT id, name, email, avatar_url, created_at FROM users WHERE id = $1',
    [req.userId]
  );
  if (!result.rows.length) return res.status(404).json({ error: 'Usuário não encontrado.' });
  res.json({ user: result.rows[0] });
});

module.exports = router;

/*
  Próximo passo (Fase 3 do plano): adicionar aqui
  POST /auth/facebook  -> recebe o token do Facebook Login SDK do app,
                           valida na Graph API da Meta, cria/atualiza o
                           usuário por facebook_id e devolve um token nosso.
  POST /auth/apple     -> mesma ideia, mas para "Sign in with Apple"
                           (obrigatório pela Apple se oferecemos login Facebook).
*/
