#!/bin/bash
set -e

echo "============================================"
echo "  Asterisk Startup - Ambiente de Calidad"
echo "============================================"

# Detectar IP del host automáticamente
# Desde Docker, el gateway es la IP del host
HOST_IP=$(ip route | grep default | awk '{print $3}')
echo "→ IP del host detectada: $HOST_IP"

# Actualizar pjsip.conf con la IP del host en tiempo de ejecución
echo "→ Configurando external_media_address en pjsip.conf..."
sed -i "s/external_media_address=.*/external_media_address=$HOST_IP/" /etc/asterisk/pjsip.conf
sed -i "s/external_signaling_address=.*/external_signaling_address=$HOST_IP/" /etc/asterisk/pjsip.conf

# Verificar que se aplicó
grep "external_media_address" /etc/asterisk/pjsip.conf | head -2
echo "✓ Configuración NAT aplicada dinámicamente"

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
