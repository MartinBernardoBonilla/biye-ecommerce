# ── Etapa 1: dependencias ──────────────────────────────────────
FROM node:20-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

# ── Etapa 2: producción ────────────────────────────────────────
FROM node:20-alpine AS runner

# Usuario no-root (buena práctica de seguridad)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copiar dependencias ya instaladas
COPY --from=deps /app/node_modules ./node_modules

# Copiar código fuente
COPY src ./src
COPY package.json ./

USER appuser

EXPOSE 5000

CMD ["node", "--import", "dotenv/config", "src/index.js"]