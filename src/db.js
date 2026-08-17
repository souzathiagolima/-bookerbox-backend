const { Pool } = require('pg');
require('dotenv').config();

// O Neon (e a maioria dos bancos gerenciados fora do Render) exige conexão
// segura (SSL). Detectamos isso automaticamente pela URL de conexão.
const needsSSL = /sslmode=require|neon\.tech/.test(process.env.DATABASE_URL || '');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: needsSSL ? { rejectUnauthorized: false } : false,
});

module.exports = pool;
