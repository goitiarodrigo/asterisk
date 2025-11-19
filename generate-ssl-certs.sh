#!/bin/bash
# ============================================================================
# Script para generar certificados SSL autofirmados para WebRTC
# ============================================================================
# WebRTC requiere conexión segura (WSS/HTTPS)
# Para desarrollo/QA usamos certificados autofirmados
# Para producción, usar certificados reales (Let's Encrypt, etc.)
# ============================================================================

echo "============================================================================"
echo "  Generando certificados SSL para WebRTC (autofirmados)"
echo "============================================================================"

# Crear directorio para certificados
mkdir -p /etc/asterisk/keys

# Generar certificado autofirmado
openssl req -x509 -newkey rsa:4096 \
  -keyout /etc/asterisk/keys/asterisk.key \
  -out /etc/asterisk/keys/asterisk.pem \
  -days 365 -nodes \
  -subj "/C=CL/ST=Santiago/L=Santiago/O=VecchTelligence/OU=QA/CN=asterisk.local"

# Combinar key y cert en un solo archivo (requerido por Asterisk)
cat /etc/asterisk/keys/asterisk.pem /etc/asterisk/keys/asterisk.key > /etc/asterisk/keys/asterisk-combined.pem

# Permisos
chmod 644 /etc/asterisk/keys/asterisk.pem
chmod 600 /etc/asterisk/keys/asterisk.key
chmod 644 /etc/asterisk/keys/asterisk-combined.pem

echo ""
echo "✓ Certificados generados en /etc/asterisk/keys/"
echo ""
echo "Archivos creados:"
echo "  - asterisk.pem (certificado público)"
echo "  - asterisk.key (llave privada)"
echo "  - asterisk-combined.pem (combinado para Asterisk)"
echo ""
echo "============================================================================"
