#!/bin/bash
# ============================================================================
# Script de verificación de Asterisk - Ambiente de Calidad
# ============================================================================
# Este script verifica que Asterisk esté correctamente configurado
# Ejecutar dentro del contenedor de Asterisk:
#   docker exec -it asterisk /verify-asterisk.sh
# ============================================================================

echo "============================================================================"
echo "  VERIFICACIÓN DE ASTERISK - AMBIENTE DE CALIDAD"
echo "============================================================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de errores
ERRORS=0

# ============================================================================
# 1. Verificar que Asterisk esté corriendo
# ============================================================================
echo "1. Verificando que Asterisk esté corriendo..."
if pgrep -x "asterisk" > /dev/null; then
    echo -e "${GREEN}✓ Asterisk está corriendo${NC}"
else
    echo -e "${RED}✗ Asterisk NO está corriendo${NC}"
    ((ERRORS++))
fi
echo ""

# ============================================================================
# 2. Verificar conexión a PostgreSQL
# ============================================================================
echo "2. Verificando conexión a PostgreSQL (ODBC)..."
asterisk -rx "odbc show" 2>/dev/null | grep -q "asterisk"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Conexión ODBC a PostgreSQL OK${NC}"
    asterisk -rx "odbc show" 2>/dev/null | grep "asterisk"
else
    echo -e "${RED}✗ No se pudo conectar a PostgreSQL via ODBC${NC}"
    ((ERRORS++))
fi
echo ""

# ============================================================================
# 3. Verificar que PJSIP esté cargado
# ============================================================================
echo "3. Verificando módulo PJSIP..."
asterisk -rx "module show like pjsip" 2>/dev/null | grep -q "res_pjsip.so"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Módulo PJSIP cargado${NC}"
else
    echo -e "${RED}✗ Módulo PJSIP NO cargado${NC}"
    ((ERRORS++))
fi
echo ""

# ============================================================================
# 4. Verificar WebSocket para WebRTC
# ============================================================================
echo "4. Verificando WebSocket (WebRTC)..."
asterisk -rx "module show like websocket" 2>/dev/null | grep -q "res_http_websocket.so"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Módulo WebSocket cargado${NC}"
else
    echo -e "${YELLOW}⚠ Módulo WebSocket NO cargado (WebRTC no funcionará)${NC}"
fi
echo ""

# ============================================================================
# 5. Verificar transportes PJSIP
# ============================================================================
echo "5. Verificando transportes PJSIP..."
echo "   Transportes configurados:"
asterisk -rx "pjsip show transports" 2>/dev/null
echo ""

# ============================================================================
# 6. Verificar extensiones registradas
# ============================================================================
echo "6. Verificando extensiones en base de datos..."
echo "   Extensiones configuradas en Realtime:"
asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -E "1001|1002|1003"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Extensiones de prueba encontradas en BD${NC}"
else
    echo -e "${YELLOW}⚠ No se encontraron extensiones 1001-1003 (verificar BD)${NC}"
fi
echo ""

# ============================================================================
# 7. Verificar codecs de video
# ============================================================================
echo "7. Verificando codecs de video disponibles..."
asterisk -rx "core show codecs" 2>/dev/null | grep -i "h264\|vp8\|vp9"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Codecs de video disponibles${NC}"
else
    echo -e "${YELLOW}⚠ No se encontraron codecs de video${NC}"
fi
echo ""

# ============================================================================
# 8. Verificar dialplan [testing]
# ============================================================================
echo "8. Verificando contexto [testing] en dialplan..."
asterisk -rx "dialplan show testing" 2>/dev/null | grep -q "_1XXX"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Contexto [testing] configurado${NC}"
else
    echo -e "${RED}✗ Contexto [testing] NO encontrado${NC}"
    ((ERRORS++))
fi
echo ""

# ============================================================================
# 9. Verificar puertos abiertos
# ============================================================================
echo "9. Verificando puertos..."
echo "   SIP UDP:  5060"
netstat -tuln 2>/dev/null | grep ":5060" || echo "   (comando netstat no disponible)"
echo "   WebSocket: 8089 (si WebRTC está habilitado)"
netstat -tuln 2>/dev/null | grep ":8089" || echo "   (no escuchando o netstat no disponible)"
echo ""

# ============================================================================
# RESUMEN
# ============================================================================
echo "============================================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ VERIFICACIÓN COMPLETADA - TODO OK${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "  1. Configurar Zoiper con credenciales:"
    echo "     - Usuario: test1001, Password: Test1001!"
    echo "     - Usuario: test1002, Password: Test1002!"
    echo "     - Usuario: test1003, Password: Test1003!"
    echo "  2. Hacer llamadas de prueba entre extensiones"
    echo "  3. Verificar que funcione audio y video"
else
    echo -e "${RED}✗ VERIFICACIÓN COMPLETADA CON $ERRORS ERRORES${NC}"
    echo ""
    echo "Revisar los errores arriba y corregirlos antes de continuar."
fi
echo "============================================================================"

exit $ERRORS
