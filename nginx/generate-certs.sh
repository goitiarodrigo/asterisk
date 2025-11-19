#!/bin/sh
set -e

echo "Generando certificados SSL para Nginx WSS Proxy..."

# Generar certificado autofirmado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=CL/ST=Santiago/L=Santiago/O=VecchTelligence/OU=QA/CN=localhost"

echo "Certificados SSL generados exitosamente"
