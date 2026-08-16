const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../db');
const { signToken } = require('../utils/jwt');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Envia o e-mail de boas-vindas via Resend. Se a chave não estiver configurada
// (RESEND_API_KEY ausente), simplesmente não envia nada — não trava o cadastro.
async function sendWelcomeEmail(user) {
  if (!process.env.RESEND_API_KEY) return;
  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Bookerbox <onboarding@resend.dev>',
        to: user.email,
        subject: 'Bem-vindo(a) ao Bookerbox! 📚',
        html: `
          <div style="font-family: Georgia, serif; max-width: 480px; margin: 0 auto; color: #241C13;">
            <h1 style="color: #8B3A3A; font-size: 22px;">Bem-vindo(a), ${user.name}!</h1>
            <p style="font-size: 15px; line-height: 1.6;">
              Sua conta no Bookerbox foi criada com sucesso. A partir de agora você pode
              avaliar livros, montar suas estantes de leitura e seguir outros leitores.
            </p>
            <p style="font-size: 15px; line-height: 1.6;">Boas leituras! 📖</p>
          </div>
        `,
      }),
    });
    if (!res.ok) {
      console.error('Resend retornou erro ao enviar e-mail de boas-vindas:', await res.text());
    }
  } catch (err) {
    console.error('Falha ao enviar e-mail de boas-vindas:', err.message);
  }
}

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
    sendWelcomeEmail(user); // não bloqueia a resposta — dispara e segue
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
