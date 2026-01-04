# Usar la versión que SABEMOS que funciona
FROM node:18-alpine

WORKDIR /app

# Copiar solo lo necesario
COPY package*.json ./
RUN npm ci --only=production

# Copiar código
COPY . .

# Exponer puerto
EXPOSE 5000

# Comando simple
CMD ["node", "src/index.js"]