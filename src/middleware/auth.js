const { verifyToken } = require('../utils/jwt');

// Bloqueia a rota se não houver um token válido no header Authorization.
function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Token ausente.' });
  try {
    const payload = verifyToken(token);
    req.userId = payload.sub;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido ou expirado.' });
  }
}

// Não bloqueia, mas identifica o usuário se ele estiver logado.
// Útil para rotas públicas que mudam de comportamento quando há um usuário
// (ex: mostrar se EU curti essa resenha).
function optionalAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (token) {
    try {
      req.userId = verifyToken(token).sub;
    } catch (err) {
      /* token inválido: segue como anônimo */
    }
  }
  next();
}

module.exports = { requireAuth, optionalAuth };
