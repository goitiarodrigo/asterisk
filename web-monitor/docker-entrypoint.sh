#!/bin/sh
set -e

# Generar archivo de configuración runtime desde variables de entorno
cat > /usr/share/nginx/html/config.js << EOF
window.ENV = {
  VITE_ASTERISK_SERVER: '${VITE_ASTERISK_SERVER:-asterisk}',
  VITE_ASTERISK_PORT: '${VITE_ASTERISK_PORT:-8089}',
  VITE_SIP_USERNAME: '${VITE_SIP_USERNAME:-webuser3001}',
  VITE_SIP_PASSWORD: '${VITE_SIP_PASSWORD:-WebUser3001!}',
  VITE_SIP_EXTENSION: '${VITE_SIP_EXTENSION:-3001}',
  VITE_STUN_SERVERS: '${VITE_STUN_SERVERS:-stun:stun.l.google.com:19302,stun:stun1.l.google.com:19302}'
};
EOF

echo "✓ Configuración runtime generada:"
cat /usr/share/nginx/html/config.js

# Iniciar nginx
exec nginx -g 'daemon off;'
