const jwt = require('jsonwebtoken');

const SECRET = process.env.JWT_SECRET || 'dev-secret-troque-em-producao';

function signToken(user) {
  return jwt.sign({ sub: user.id, name: user.name, email: user.email }, SECRET, { expiresIn: '30d' });
}

function verifyToken(token) {
  return jwt.verify(token, SECRET);
}

module.exports = { signToken, verifyToken };
