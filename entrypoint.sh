#!/bin/bash
set -e

echo "============================================"
echo "  Asterisk Startup - Ambiente de Calidad"
echo "============================================"

# Generar certificados SSL si no existen
if [ ! -f /etc/asterisk/keys/asterisk-combined.pem ]; then
    echo "→ Generando certificados SSL para WebRTC..."
    /usr/local/bin/generate-ssl-certs.sh
else
    echo "→ Certificados SSL ya existen, omitiendo generación"
fi

echo "→ Iniciando Asterisk..."
echo "============================================"

# Run Asterisk in the foreground so Docker keeps container alive
exec /usr/sbin/asterisk -f -U asterisk