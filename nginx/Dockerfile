FROM nginx:alpine

# Instalar OpenSSL para generar certificados
RUN apk add --no-cache openssl

# Crear directorio para certificados
RUN mkdir -p /etc/nginx/ssl

# Copiar configuración de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar script de generación de certificados
COPY generate-certs.sh /generate-certs.sh
RUN chmod +x /generate-certs.sh

# Generar certificados al iniciar
RUN /generate-certs.sh

EXPOSE 8089

CMD ["nginx", "-g", "daemon off;"]
