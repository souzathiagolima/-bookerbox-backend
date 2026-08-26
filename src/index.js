require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const bookRoutes = require('./routes/books');
const shelfRoutes = require('./routes/shelves');
const reviewRoutes = require('./routes/reviews');
const userRoutes = require('./routes/users');
const feedRoutes = require('./routes/feed');
const notificationRoutes = require('./routes/notifications');
const adminRoutes = require('./routes/admin');

const app = express();
app.use(cors());
app.use(express.json({ limit: '3mb' }));

app.get('/health', (req, res) => res.json({ ok: true }));

app.use('/auth', authRoutes);
app.use('/books', bookRoutes);
app.use('/shelves', shelfRoutes);
app.use('/reviews', reviewRoutes);
app.use('/users', userRoutes);
app.use('/feed', feedRoutes);
app.use('/notifications', notificationRoutes);
app.use('/admin', adminRoutes);

app.use((req, res) => res.status(404).json({ error: 'Rota não encontrada.' }));

// tratador de erro genérico, para nada explodir sem resposta ao app
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Erro interno do servidor.' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Bookerbox API rodando em http://localhost:${PORT}`));
