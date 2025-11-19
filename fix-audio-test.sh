#!/bin/bash

echo "============================================"
echo " Configuración mínima para prueba de audio"
echo "============================================"
echo ""

echo "1. Verificando contexto actual de extensiones..."
cd /home/user/asterisk
docker compose exec ast-db psql -U asterisk -d asterisk -c "SELECT id, context, transport FROM ps_endpoints WHERE id IN ('1001', '1002', '1003');"

echo ""
echo "2. Actualizando contexto a 'testing'..."
docker compose exec ast-db psql -U asterisk -d asterisk -c "UPDATE ps_endpoints SET context = 'testing' WHERE id IN ('1001', '1002', '1003');"

echo ""
echo "3. Verificando cambio..."
docker compose exec ast-db psql -U asterisk -d asterisk -c "SELECT id, context, transport FROM ps_endpoints WHERE id IN ('1001', '1002', '1003');"

echo ""
echo "4. Recargando configuración de Asterisk..."
docker compose exec asterisk asterisk -rx "module reload res_pjsip.so"
docker compose exec asterisk asterisk -rx "pjsip reload"

echo ""
echo "============================================"
echo " ✓ Configuración completada"
echo "============================================"
echo ""
echo "PRUEBA BÁSICA:"
echo "  1. Abre Zoiper (extensión 1001)"
echo "  2. Marca: 600"
echo "  3. Deberías escuchar tu propia voz (echo)"
echo ""
echo "OTRAS PRUEBAS:"
echo "  - Extensión 700: Reproduce 'hello-world'"
echo "  - Extensión 1002: Llama a otra extensión (si existe)"
echo "============================================"
