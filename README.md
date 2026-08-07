# Bookerbox — API backend (Fase 1)

Backend real para substituir a persistência simulada do protótipo: contas de
verdade, banco de dados de verdade, e a tabela `follows` que transforma o
mural público do protótipo numa rede social de fato.

## Como rodar localmente

1. **Instale o PostgreSQL** (local, ou um banco gratuito na nuvem — Supabase,
   Neon e Railway todos têm planos free bons para começar).

2. **Crie o banco e rode o schema:**
   ```bash
   createdb bookerbox
   psql bookerbox -f db/schema.sql
   ```
   (se estiver usando Supabase/Neon/Railway, cole o conteúdo de
   `db/schema.sql` no editor SQL do painel deles)

3. **Configure as variáveis de ambiente:**
   ```bash
   cp .env.example .env
   # edite .env com sua DATABASE_URL real e um JWT_SECRET aleatório
   ```

4. **Instale as dependências e suba o servidor:**
   ```bash
   npm install
   npm run dev
   ```
   A API sobe em `http://localhost:3000`. Teste com:
   ```bash
   curl http://localhost:3000/health
   ```

## Endpoints

| Método | Rota | Auth? | O que faz |
|---|---|---|---|
| POST | `/auth/register` | não | Cria conta (nome, e-mail, senha) |
| POST | `/auth/login` | não | Login, devolve um token |
| GET | `/auth/me` | sim | Dados do usuário logado |
| GET | `/books/search?q=` | não | Busca no Google Books e cacheia no banco |
| GET | `/books/:id` | não | Detalhe de um livro já cacheado |
| GET | `/shelves` | sim | Minhas estantes (quero ler / lendo / lido) |
| PUT | `/shelves/:bookId` | sim | Define o status de um livro na minha estante |
| DELETE | `/shelves/:bookId` | sim | Remove um livro da minha estante |
| POST | `/reviews` | sim | Publica uma resenha (marca o livro como "lido") |
| GET | `/reviews/book/:bookId` | opcional | Resenhas de um livro |
| DELETE | `/reviews/:id` | sim | Apaga uma resenha minha |
| POST/DELETE | `/reviews/:id/like` | sim | Curtir / descurtir uma resenha |
| GET | `/users/:id` | não | Perfil público + estatísticas |
| POST/DELETE | `/users/:id/follow` | sim | Seguir / deixar de seguir alguém |
| GET | `/users/:id/followers` | não | Quem segue esse usuário |
| GET | `/users/:id/following` | não | Quem esse usuário segue |
| GET | `/feed` | sim | Resenhas minhas + de quem eu sigo (o feed social) |

Todas as rotas autenticadas esperam o header:
```
Authorization: Bearer SEU_TOKEN_AQUI
```

## O que falta para as próximas fases

- **`POST /auth/facebook` e `/auth/apple`** — login social real (Fase 3 do
  plano técnico). Os pontos de extensão já estão comentados em
  `src/routes/auth.js`.
- **Notificações push** — a tabela `notifications` já existe no schema;
  falta disparar via APNs quando alguém curte/segue/comenta.
- **Deploy** — qualquer serviço tipo Render/Railway sobe isso direto a
  partir deste repositório; só precisa apontar `DATABASE_URL` para o banco
  de produção.
- **Conectar ao app** — o app em React Native chama essas rotas no lugar
  de `window.storage`; a lógica de UI do protótipo (telas, componentes,
  estados) muda muito pouco.

## Segurança antes de ir para produção

- Trocar `JWT_SECRET` por um valor longo e aleatório (nunca o do `.env.example`).
- Adicionar rate limiting nas rotas de login/registro (ex: `express-rate-limit`)
  para evitar força bruta.
- Validar e sanitizar entradas com mais rigor (ex: `zod` ou `joi`) antes do
  lançamento público.
