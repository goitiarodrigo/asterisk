# Multi-stage build para frontend React + TypeScript
# Stage 1: Build de la aplicación
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar package files
COPY package.json package-lock.json* ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Build de producción
RUN npm run build

# Stage 2: Nginx para servir la aplicación
FROM nginx:alpine

# Copiar build desde stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar configuración de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar entrypoint que genera config runtime
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Exponer puerto 80
EXPOSE 80

# Usar entrypoint personalizado
ENTRYPOINT ["/docker-entrypoint.sh"]
