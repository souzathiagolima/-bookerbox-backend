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
          <div style="font-family: Georgia, serif; max-width: 480px; margin: 0 auto; background: #EFE6D2;">
            <div style="background: #132420; padding: 24px 32px; text-align: center;">
              <span style="font-size: 24px; font-weight: bold; color: #C7A25A; letter-spacing: 0.5px;">📖 Bookerbox</span>
            </div>
            <div style="padding: 28px 32px; color: #241C13;">
              <h1 style="color: #8B3A3A; font-size: 22px; margin: 0 0 12px;">Bem-vindo(a), ${user.name}!</h1>
              <p style="font-size: 15px; line-height: 1.6; margin: 0 0 12px;">
                Sua conta no Bookerbox foi criada com sucesso. A partir de agora você pode
                avaliar livros, montar suas estantes de leitura e seguir outros leitores.
              </p>
              <p style="font-size: 15px; line-height: 1.6; margin: 0 0 24px;">Boas leituras! 📚</p>
              <div style="text-align: center;">
                <a href="https://bookerbox-frontend.onrender.com/" style="display: inline-block; background: #C7A25A; color: #241C13; font-family: Georgia, serif; font-weight: bold; font-size: 15px; padding: 12px 28px; border-radius: 6px; text-decoration: none;">
                  Comece a avaliar livros
                </a>
              </div>
            </div>
            <div style="padding: 16px 32px; text-align: center;">
              <span style="font-size: 11px; color: #8C7439;">Bookerbox · sua estante, sua rede</span>
            </div>
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

router.patch('/avatar', requireAuth, async (req, res) => {
  const { avatarUrl } = req.body;
  if (!avatarUrl || typeof avatarUrl !== 'string') {
    return res.status(400).json({ error: 'avatarUrl é obrigatório.' });
  }
  if (avatarUrl.length > 2_000_000) {
    return res.status(413).json({ error: 'Imagem muito grande. Escolha uma foto menor.' });
  }
  try {
    const result = await pool.query(
      `UPDATE users SET avatar_url = $1 WHERE id = $2 RETURNING id, name, email, avatar_url, created_at`,
      [avatarUrl, req.userId]
    );
    res.json({ user: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar foto de perfil.' });
  }
});

module.exports = router;

router.post('/google', async (req, res) => {
  const { idToken } = req.body;
  if (!idToken) return res.status(400).json({ error: 'idToken é obrigatório.' });
  try {
    const verifyRes = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`);
    const payload = await verifyRes.json();
    if (!verifyRes.ok || payload.error) {
      return res.status(401).json({ error: 'Token do Google inválido.' });
    }
    if (process.env.GOOGLE_CLIENT_ID && payload.aud !== process.env.GOOGLE_CLIENT_ID) {
      return res.status(401).json({ error: 'Token do Google não pertence a este app.' });
    }
    const email = payload.email?.toLowerCase();
    const name = payload.name || email;
    const googleId = payload.sub;
    if (!email) return res.status(400).json({ error: 'Não foi possível obter o e-mail do Google.' });

    const existing = await pool.query('SELECT * FROM users WHERE google_id = $1 OR email = $2', [googleId, email]);
    let user;
    if (existing.rows.length) {
      user = existing.rows[0];
      if (!user.google_id) {
        await pool.query('UPDATE users SET google_id = $1 WHERE id = $2', [googleId, user.id]);
      }
    } else {
      const inserted = await pool.query(
        `INSERT INTO users (name, email, google_id) VALUES ($1, $2, $3)
         RETURNING id, name, email, avatar_url, created_at`,
        [name, email, googleId]
      );
      user = inserted.rows[0];
      sendWelcomeEmail(user);
    }
    delete user.password_hash;
    const token = signToken(user);
    res.json({ token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao entrar com Google.' });
  }
});

router.post('/facebook', async (req, res) => {
  const { accessToken } = req.body;
  if (!accessToken) return res.status(400).json({ error: 'accessToken é obrigatório.' });
  try {
    const verifyRes = await fetch(`https://graph.facebook.com/me?fields=id,name,email&access_token=${encodeURIComponent(accessToken)}`);
    const payload = await verifyRes.json();
    if (!verifyRes.ok || payload.error) {
      return res.status(401).json({ error: 'Token do Facebook inválido.' });
    }
    const email = payload.email?.toLowerCase();
    const name = payload.name || 'Usuário Facebook';
    const facebookId = payload.id;
    if (!email) {
      return res.status(400).json({ error: 'Sua conta do Facebook não compartilhou um e-mail. Tente com Google ou e-mail/senha.' });
    }

    const existing = await pool.query('SELECT * FROM users WHERE facebook_id = $1 OR email = $2', [facebookId, email]);
    let user;
    if (existing.rows.length) {
      user = existing.rows[0];
      if (!user.facebook_id) {
        await pool.query('UPDATE users SET facebook_id = $1 WHERE id = $2', [facebookId, user.id]);
      }
    } else {
      const inserted = await pool.query(
        `INSERT INTO users (name, email, facebook_id) VALUES ($1, $2, $3)
         RETURNING id, name, email, avatar_url, created_at`,
        [name, email, facebookId]
      );
      user = inserted.rows[0];
      sendWelcomeEmail(user);
    }
    delete user.password_hash;
    const token = signToken(user);
    res.json({ token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao entrar com Facebook.' });
  }
});
