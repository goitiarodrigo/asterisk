#!/bin/bash
# Fix NAT configuration at runtime
# Este script actualiza la configuración de Asterisk en el contenedor corriendo

echo "=========================================="
echo " Aplicando fix NAT en tiempo real"
echo "=========================================="

# Opción 1: Recargar módulo PJSIP con la configuración correcta
echo "1. Recargando PJSIP..."
docker compose exec asterisk asterisk -rx "module reload res_pjsip.so"

# Opción 2: Verificar que la configuración esté cargada
echo "2. Verificando transporte UDP..."
docker compose exec asterisk asterisk -rx "pjsip show transports" | grep -A 10 "transport-udp"

# Opción 3: Verificar settings RTP
echo "3. Verificando RTP settings..."
docker compose exec asterisk asterisk -rx "rtp show settings"

echo ""
echo "=========================================="
echo " ✓ Comandos ejecutados"
echo "=========================================="
echo ""
echo "Ahora intenta llamar a extensión 600 desde Zoiper"
echo "y verifica los logs con:"
echo "  docker compose logs -f asterisk"
